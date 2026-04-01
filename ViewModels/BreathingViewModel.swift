import SwiftUI
import Observation

@Observable @MainActor
class BreathingViewModel {
    let mode: BreathingMode

    var isRunning = false
    var hasStarted = false
    var showStartMessage = false
    var showCompletion = false
    var completedMinutes = 0

    var selectedMinutes: Double = 2
    var totalTime = 120
    var timeRemaining = 120

    var showModeInfo = false

    @ObservationIgnored
    private var timer: Timer?

    // AppStorage equivalents (using UserDefaults for ViewModel)
    private let hasSeenShantiInfoKey = "hasSeenShantiInfo"
    private let hasSeenDharanaInfoKey = "hasSeenDharanaInfo"
    private let hasSeenNidraInfoKey = "hasSeenNidraInfo"
    private let audioGuidanceModeKey = "audioGuidanceMode"

    init(mode: BreathingMode) {
        self.mode = mode
        resetTimer()
    }

    func checkFirstLaunch() {
        let hasSeen: Bool
        let key: String

        switch mode {
        case .calm:
            key = hasSeenShantiInfoKey
        case .focus:
            key = hasSeenDharanaInfoKey
        case .sleep:
            key = hasSeenNidraInfoKey
        }

        hasSeen = UserDefaults.standard.bool(forKey: key)
        if !hasSeen {
            showModeInfo = true
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1 - (Double(timeRemaining) / Double(totalTime))
    }

    var timeString: String {
        String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    var buttonTitle: String {
        if isRunning {
            return "Pause Practice"
        } else {
            return hasStarted ? "Resume Practice" : "Begin Practice"
        }
    }

    var titleText: String {
        switch mode {
        case .calm: return "Shanti"
        case .focus: return "Dharana"
        case .sleep: return "Nidra"
        }
    }

    var subtitleText: String {
        switch mode {
        case .calm: return "Cultivating inner stillness"
        case .focus: return "Steady attention through breath"
        case .sleep: return "Gentle descent into rest"
        }
    }

    var backgroundColor: Color {
        switch mode {
        case .calm: return BreathingMode.calm.color.opacity(0.08)
        case .focus: return Color.indigo.opacity(0.12)
        case .sleep:
            return Color(hue: 0.88, saturation: 0.60, brightness: 0.70).opacity(0.10)
        }
    }

    // MARK: - Session Control

    func toggleSession() {
        if isRunning {
            pauseSession()
        } else {
            if hasStarted {
                resumeSession()
            } else {
                startSession()
            }
        }
    }

    func startSession() {
        hasStarted = true

        withAnimation(.easeInOut(duration: 0.8)) {
            showStartMessage = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 1.0)) {
                self.showStartMessage = false
            }

            self.isRunning = true
            self.totalTime = Int(self.selectedMinutes) * 60
            self.timeRemaining = self.totalTime

            let startGenerator = UIImpactFeedbackGenerator(style: .medium)
            startGenerator.prepare()
            startGenerator.impactOccurred()

            self.startTimer()
        }
    }

    func pauseSession() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resumeSession() {
        isRunning = true
        startTimer()
    }

    func seek(to fraction: CGFloat) {
        let clamped = max(0, min(1, fraction))
        timeRemaining = Int(Double(totalTime) * Double(1 - clamped))
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func resetTimer() {
        totalTime = Int(selectedMinutes) * 60
        timeRemaining = totalTime
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
        }
    }

    private func completeSession() {
        completedMinutes = Int(selectedMinutes)
        isRunning = false
        hasStarted = false
        timer?.invalidate()
        timer = nil

        let endGenerator = UINotificationFeedbackGenerator()
        endGenerator.prepare()
        endGenerator.notificationOccurred(.success)

        let guidanceRawValue = UserDefaults.standard.string(forKey: audioGuidanceModeKey) ?? AudioGuidanceMode.off.rawValue
        if AudioGuidanceMode(rawValue: guidanceRawValue) == .tones {
            SoundManager.shared.playComplete()
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            showCompletion = true
        }
    }

    func hardStop() {
        pauseSession()
        SoundManager.shared.hardStop()
    }

    // MARK: - Completion Overlays

    var completionSanskrit: String {
        switch mode {
        case .calm: return "Shanti"
        case .focus: return "Dharana"
        case .sleep: return "Nidra"
        }
    }

    var completionEnglish: String {
        switch mode {
        case .calm: return "Peace"
        case .focus: return "Clarity"
        case .sleep: return "Rest"
        }
    }

    var completionEmoji: String {
        switch mode {
        case .calm: return "🌿"
        case .focus: return "🔆"
        case .sleep: return "🌙"
        }
    }

    var completionMessage: String {
        switch mode {
        case .calm: return "Carry this stillness with you."
        case .focus: return "Your mind is clearer now. Go do great things."
        case .sleep: return "Let your breath carry you gently into rest."
        }
    }
}
