import SwiftUI

struct BreathingAnimationView: View {

    let mode: BreathingMode
    let isRunning: Bool
    /// Live mic amplitude 0–1. When nil the view falls back to timer-driven animation.
    var micLevel: Float? = nil

    @State private var lastPhase: Phase?
    @AppStorage("audioGuidanceMode") var audioGuidanceMode: String = AudioGuidanceMode.off.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase {
        case inhale
        case hold
        case exhale
    }

    var body: some View {

        // Reduce-motion: static circle + phase label, no pulsing.
        if reduceMotion {
            staticView
        } else if let mic = micLevel, isRunning {
            micDrivenView(mic: mic)
        } else {
            timerDrivenView
        }
    }

    // MARK: - Reduce-Motion Static View

    private var staticView: some View {
        ZStack {
            Circle()
                .stroke(sizeColor(for: 1.0).opacity(0.3), lineWidth: 2)
                .frame(width: 260, height: 260)

            Circle()
                .stroke(sizeColor(for: 1.0).opacity(0.6), lineWidth: 3)
                .frame(width: 220, height: 220)

            Circle()
                .fill(sizeColor(for: 1.0))
                .frame(width: 170, height: 170)

            phaseLabel(phase: lastPhase ?? .inhale)
        }
        .frame(width: 300, height: 300)
        .opacity(isRunning ? 1 : 0.4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing circle")
        .accessibilityValue(lastPhase.map { phaseText(for: $0) } ?? "Inhale")
    }

    // MARK: - Mic-Driven View

    private func micDrivenView(mic: Float) -> some View {
        // Map 0–1 mic level to scale 0.85–1.15
        let s: CGFloat = 0.85 + CGFloat(mic) * 0.30

        // Phase is inferred from rising/holding/falling mic (simplified: above 0.5 = inhale/hold, below = exhale)
        let inferredPhase: Phase = mic > 0.55 ? .hold : mic > 0.15 ? .inhale : .exhale

        return ZStack {
            Circle()
                .stroke(sizeColor(for: s).opacity(0.3), lineWidth: 2)
                .frame(width: 260, height: 260)
                .scaleEffect(s)

            Circle()
                .stroke(sizeColor(for: s).opacity(0.6), lineWidth: 3)
                .frame(width: 220, height: 220)
                .scaleEffect(s)

            Circle()
                .fill(sizeColor(for: s))
                .frame(width: 170, height: 170)
                .scaleEffect(s)
                .animation(.easeOut(duration: 0.1), value: s)

            phaseLabel(phase: inferredPhase)
        }
        .frame(width: 300, height: 300)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing circle — mic active")
        .accessibilityValue(phaseText(for: inferredPhase))
    }

    // MARK: - Timer-Driven View (original behaviour)

    private var timerDrivenView: some View {
        TimelineView(.animation) { timeline in

            let t = isRunning ? timeline.date.timeIntervalSinceReferenceDate : 0
            let phaseValue = normalizedPhase(time: t, duration: cycleDuration)
            let phase = currentPhase(for: phaseValue)

            ZStack {

                let s = scale(for: phaseValue)

                Circle()
                    .stroke(sizeColor(for: s).opacity(0.3), lineWidth: 2)
                    .frame(width: 260, height: 260)
                    .scaleEffect(s)
                    .accessibilityHidden(true)

                Circle()
                    .stroke(sizeColor(for: s).opacity(0.6), lineWidth: 3)
                    .frame(width: 220, height: 220)
                    .scaleEffect(s)
                    .accessibilityHidden(true)

                Circle()
                    .fill(sizeColor(for: s))
                    .frame(width: 170, height: 170)
                    .scaleEffect(s)
                    .accessibilityHidden(true)

                phaseLabel(phase: phase)
            }
            .frame(width: 300, height: 300)
            .opacity(isRunning ? 1 : 0.4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Breathing circle")
            .accessibilityValue(phaseText(for: phase))
            .onChange(of: phase) { oldValue, newValue in
                handlePhaseChange(newValue)
            }
        }
    }

    // MARK: - Phase Label

    private func phaseLabel(phase: Phase) -> some View {
        VStack(spacing: 3) {
            Text(sanskritText(for: phase))
                .font(.headline)
                .foregroundColor(.white)
            Text(phaseText(for: phase))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .accessibilityHidden(true) // announced by parent accessibilityValue
    }

    // MARK: Phase Logic

    private func normalizedPhase(time: TimeInterval, duration: Double) -> Double {
        (time.truncatingRemainder(dividingBy: duration)) / duration
    }

    private func currentPhase(for value: Double) -> Phase {
        switch value {
        case 0.0..<0.4:
            return .inhale
        case 0.4..<0.6:
            return .hold
        default:
            return .exhale
        }
    }

    private func scale(for value: Double) -> CGFloat {
        switch value {
        case 0.0..<0.4:
            return 0.85 + (value / 0.4) * 0.3
        case 0.4..<0.6:
            return 1.15
        default:
            return 1.15 - ((value - 0.6) / 0.4) * 0.3
        }
    }

    private func phaseText(for phase: Phase) -> String {
        switch phase {
        case .inhale: return "Inhale"
        case .hold:   return "Hold"
        case .exhale: return "Exhale"
        }
    }

    /// Interpolates between two colours based on the circle's current scale.
    private func sizeColor(for s: CGFloat) -> Color {
        let minScale: CGFloat = 0.85
        let maxScale: CGFloat = 1.15
        let t = min(1.0, max(0.0, Double((s - minScale) / (maxScale - minScale))))
        func lerp(_ a: Double, _ b: Double) -> Double { a + (b - a) * t }

        switch mode {
        case .calm:
            // Saffron (amber) at rest → bright marigold at full inhale
            return Color(hue: lerp(0.06, 0.09), saturation: lerp(0.85, 0.95), brightness: lerp(0.60, 0.95))
        case .focus:
            // Deep lapis at rest → bright indigo at full inhale
            return Color(hue: lerp(0.70, 0.65), saturation: lerp(0.85, 0.70), brightness: lerp(0.40, 0.88))
        case .sleep:
            // Deep maroon at rest → soft rose at full inhale
            return Color(hue: lerp(0.91, 0.87), saturation: lerp(0.70, 0.45), brightness: lerp(0.30, 0.72))
        }
    }

    private func sanskritText(for phase: Phase) -> String {
        switch phase {
        case .inhale: return "Puraka"
        case .hold:   return "Kumbhaka"
        case .exhale: return "Rechaka"
        }
    }

    // MARK: Timing

    private var cycleDuration: Double {
        switch mode {
        case .calm: return 10
        case .focus: return 9
        case .sleep: return 12
        }
    }

    private var inhaleDuration: Double { cycleDuration * 0.4 }
    private var exhaleDuration: Double { cycleDuration * 0.4 }

    // MARK: Phase Audio Guidance & Haptics

    private func handlePhaseChange(_ phase: Phase) {
        guard isRunning else { return }

        // Trigger subtle haptic feedback on every phase change
        if phase != lastPhase {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }

        let guidanceMode = AudioGuidanceMode(rawValue: audioGuidanceMode) ?? .off
        guard guidanceMode != .off else { return }
        guard phase != lastPhase else { return }

        lastPhase = phase

        switch guidanceMode {
        case .tones:
            switch phase {
            case .inhale: SoundManager.shared.playInhaleSequence(duration: inhaleDuration)
            case .hold:   SoundManager.shared.playHold()
            case .exhale: SoundManager.shared.playExhaleSequence(duration: exhaleDuration)
            }
        case .speech:
            switch phase {
            case .inhale: VoiceGuidanceManager.shared.speak("Breathe in")
            case .hold:   VoiceGuidanceManager.shared.speak("Gently hold")
            case .exhale: VoiceGuidanceManager.shared.speak("Breathe out")
            }
        case .off:
            break
        }
    }
}

