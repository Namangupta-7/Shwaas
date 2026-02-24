import AVFoundation

// AVAudioPCMBuffer is internally thread-safe; this conformance lets us
// pass freshly-built buffers from a background queue to the main actor.
extension AVAudioPCMBuffer: @retroactive @unchecked Sendable {}

@MainActor
final class SoundManager {

    static let shared = SoundManager()

    private let engine     = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let mixerNode  = AVAudioMixerNode()

    /// Serial queue for buffer generation so we never block the main thread.
    private let buildQueue = DispatchQueue(label: "SoundManager.build", qos: .userInitiated)

    private init() {
        engine.attach(playerNode)
        engine.attach(mixerNode)
        engine.connect(playerNode, to: mixerNode, format: nil)
        engine.connect(mixerNode, to: engine.mainMixerNode, format: nil)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("Audio engine failed:", error)
        }
    }

    // MARK: - Cancel

    /// Gracefully fades out whatever is playing, then stops the node.
    func cancelPending() {
        fadeOutAndStop(duration: 0.5)
    }

    /// Schedules a short fade-out buffer, then stops the player once it finishes.
    private func fadeOutAndStop(duration: Double = 0.5) {
        buildQueue.async { [weak self] in
            guard let self else { return }
            guard let tail = self.buildBuffer(duration: duration, shape: .fade, amplitude: 0.22)
            else { return }
            DispatchQueue.main.async {
                // Stop any queued buffers, then play a smooth fade-out tail.
                self.playerNode.stop()
                self.playerNode.scheduleBuffer(tail, at: nil, options: [])
                self.playerNode.play()
            }
        }
    }

    // MARK: - Pink Noise State

    private struct PinkState {
        var b0 = 0.0, b1 = 0.0, b2 = 0.0, b3 = 0.0, b4 = 0.0, b5 = 0.0, b6 = 0.0
        var seed: UInt64 = 0x123456789ABCDEF0

        mutating func next() -> Double {
            seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17
            let w = Double(Int64(bitPattern: seed)) / Double(Int64.max)
            b0 =  0.99886 * b0 + w * 0.0555179
            b1 =  0.99332 * b1 + w * 0.0750759
            b2 =  0.96900 * b2 + w * 0.1538520
            b3 =  0.86650 * b3 + w * 0.3104856
            b4 =  0.55000 * b4 + w * 0.5329522
            b5 = -0.76160 * b5 - w * 0.0168980
            let p = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) / 6.5
            b6 = w * 0.115926
            return p
        }
    }

    // MARK: - Buffer Generation (off main thread)

    enum Shape { case swell, fade, bell }

    nonisolated private func buildBuffer(duration: Double, shape: Shape,
                             amplitude: Float = 0.22) -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        let total = Int(frameCount)

        for channel in 0..<2 {
            let ch = buffer.floatChannelData![channel]
            var pink = PinkState()
            if channel == 1 { pink.seed = 0xFEDCBA9876543210 }

            for frame in 0..<total {
                let progress = total > 1 ? Double(frame) / Double(total - 1) : 0
                let env: Double
                switch shape {
                case .swell: env = sin(progress * .pi / 2)
                case .fade:  env = cos(progress * .pi / 2)
                case .bell:  env = sin(progress * .pi)       // 0 → peak → 0
                }
                ch[frame] = Float(pink.next() * env) * amplitude
            }
        }
        return buffer
    }

    // Builds on background, schedules + plays on main.
    private func asyncPlay(duration: Double, shape: Shape, amplitude: Float = 0.22) {
        buildQueue.async { [weak self] in
            guard let self else { return }
            // Build the main buffer and a short lead-in fade if needed.
            guard let buf = self.buildBuffer(duration: duration, shape: shape, amplitude: amplitude)
            else { return }
            DispatchQueue.main.async {
                self.playerNode.stop()
                self.playerNode.scheduleBuffer(buf, at: nil, options: [])
                self.playerNode.play()
            }
        }
    }

    // MARK: - Phase Cues

    func playInhaleSequence(duration: Double) {
        // Bell shape: swells up then fades back to zero within the inhale window,
        // so the noise naturally dissolves to silence right as hold begins.
        asyncPlay(duration: duration, shape: .bell)
    }

    func playHold() {
        // The inhale buffer already fades to zero by the time hold starts (bell shape),
        // so we just let the player finish naturally — no abrupt stop needed.
        // Nothing to do here.
    }

    func playExhaleSequence(duration: Double) {
        asyncPlay(duration: duration, shape: .fade)
    }

    func playComplete() {
        buildQueue.async { [weak self] in
            guard let self else { return }
            guard let buf1 = self.buildBuffer(duration: 1.2, shape: .swell, amplitude: 0.18),
                  let buf2 = self.buildBuffer(duration: 2.0, shape: .fade,  amplitude: 0.18)
            else { return }
            DispatchQueue.main.async {
                self.playerNode.stop()
                self.playerNode.scheduleBuffer(buf1, at: nil, options: [])
                self.playerNode.scheduleBuffer(buf2, at: nil, options: [])
                self.playerNode.play()
            }
        }
    }
}
