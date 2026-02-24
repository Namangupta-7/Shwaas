import AVFoundation
import Combine

/// Detects breath amplitude via AVAudioRecorder metering.
/// Does NOT touch AVAudioSession directly — relies on whatever
/// session SoundManager has already configured (.playAndRecord).
@MainActor
final class MicBreathDetector: ObservableObject {

    @Published private(set) var level: Float = 0
    @Published private(set) var isAvailable = false
    var isActive = false

    private var recorder: AVAudioRecorder?
    private var pollTimer: Timer?

    // MARK: - Public API

    func start() {
        guard recorder?.isRecording != true else {
            isAvailable = true
            return
        }
        // Use callback-based permission — most compatible across iOS versions.
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if granted { self.startRecorder() }
                else { self.isAvailable = false }
            }
        }
    }

    func stop() {
        pollTimer?.invalidate()
        pollTimer = nil
        recorder?.stop()
        recorder = nil
        isAvailable = false
        isActive = false
        level = 0
    }

    // MARK: - Private

    private func startRecorder() {
        // Use CAF + linear PCM — no codec license needed, always available.
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shwaas_mic_level.caf")

        let settings: [String: Any] = [
            AVFormatIDKey:            Int(kAudioFormatLinearPCM),
            AVSampleRateKey:          8000.0,
            AVNumberOfChannelsKey:    1,
            AVLinearPCMBitDepthKey:   16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey:    false
        ]

        do {
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.isMeteringEnabled = true
            guard rec.record() else {
                isAvailable = false
                return
            }
            recorder = rec
            isAvailable = true
            startPolling()
        } catch {
            print("MicBreathDetector: recorder error:", error.localizedDescription)
            isAvailable = false
        }
    }

    private func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0,
                                         repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.isActive, let rec = self.recorder else { return }
                rec.updateMeters()
                // Map –60 dB (silence) → 0.0, 0 dB (peak) → 1.0
                let db         = rec.averagePower(forChannel: 0)
                let normalized = Float(max(0.0, min(1.0, (db + 60.0) / 60.0)))
                // Exponential smoothing
                self.level = 0.18 * normalized + 0.82 * self.level
            }
        }
    }
}
