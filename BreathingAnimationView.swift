import SwiftUI

struct BreathingAnimationView: View {

    let mode: BreathingMode
    let isRunning: Bool

    @State private var lastPhase: Phase?
    @AppStorage("audioGuidanceMode") var audioGuidanceMode: String =
        AudioGuidanceMode.off.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startTime: TimeInterval = Date()
        .timeIntervalSinceReferenceDate
    @State private var pauseOffset: TimeInterval = 0

    enum Phase {
        case inhale
        case holdFull
        case exhale
        case holdEmpty
    }

    var body: some View {

        Group {

            if reduceMotion {
                staticView
            } else {
                timerDrivenView
            }
        }
        .onDisappear {
            HapticManager.shared.stopOmVibration()
        }
        .onChange(of: isRunning) { running in
            if running {

                startTime = Date().timeIntervalSinceReferenceDate - pauseOffset

                if pauseOffset == 0 {
                    lastPhase = nil
                    handlePhaseChange(.inhale, cycleCount: 0, forceRun: true)
                }
            } else {

                let t = Date().timeIntervalSinceReferenceDate - startTime
                pauseOffset = t.truncatingRemainder(dividingBy: timing.total)

                HapticManager.shared.stopOmVibration()
                VoiceGuidanceManager.shared.stop()

                if AudioGuidanceMode(rawValue: audioGuidanceMode) == .tones {
                    SoundManager.shared.cancelPending()
                }
            }
        }
        .onAppear {
            if isRunning {
                startTime = Date().timeIntervalSinceReferenceDate
                lastPhase = nil
                handlePhaseChange(.inhale, cycleCount: 0, forceRun: true)
            }
        }
    }

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

            phaseLabel(phase: lastPhase ?? .inhale, cycleCount: 0)
        }
        .frame(width: 300, height: 300)
        .opacity(isRunning ? 1 : 0.4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing circle")
        .accessibilityValue(
            lastPhase.map { phaseText(for: $0, cycleCount: 0) } ?? "Breathe in"
        )
    }

    private var timerDrivenView: some View {
        TimelineView(.animation) { timeline in

            let t =
                isRunning
                ? (timeline.date.timeIntervalSinceReferenceDate - startTime) : 0
            let ct = cycleTime(time: t)
            //            let phase = currentPhase(for: ct)
            let phase = isRunning ? currentPhase(for: ct) : .holdEmpty
            let currentCycle = timing.total > 0 ? Int(t / timing.total) : 0

            ZStack {

                let s = scale(for: ct)

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

                phaseLabel(phase: phase, cycleCount: currentCycle)
            }
            .frame(width: 300, height: 300)
            .opacity(isRunning ? 1 : 0.4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Breathing circle")
            .accessibilityValue(phaseText(for: phase, cycleCount: currentCycle))
            .onChange(of: phase) { newValue in
                handlePhaseChange(
                    newValue,
                    cycleCount: currentCycle,
                    forceRun: isRunning
                )
            }
        }
    }

    private func phaseLabel(phase: Phase, cycleCount: Int) -> some View {
        VStack(spacing: 3) {
            Text(sanskritText(for: phase))
                .font(.headline)
                .foregroundColor(.white)
            Text(phaseText(for: phase, cycleCount: cycleCount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .accessibilityHidden(true)
    }

    private struct CycleTiming {
        let inhale: Double
        let holdFull: Double
        let exhale: Double
        let holdEmpty: Double

        var total: Double { inhale + holdFull + exhale + holdEmpty }
    }

    private var timing: CycleTiming {
        switch mode {
        case .calm:

            return CycleTiming(inhale: 4, holdFull: 4, exhale: 4, holdEmpty: 4)
        case .focus:

            return CycleTiming(inhale: 4, holdFull: 0, exhale: 4, holdEmpty: 0)
        case .sleep:

            return CycleTiming(inhale: 4, holdFull: 7, exhale: 8, holdEmpty: 0)
        }
    }

    private func cycleTime(time: TimeInterval) -> Double {
        time.truncatingRemainder(dividingBy: timing.total)
    }

    private func currentPhase(for t: Double) -> Phase {
        let tm = timing
        if t < tm.inhale { return .inhale }
        if t < tm.inhale + tm.holdFull { return .holdFull }
        if t < tm.inhale + tm.holdFull + tm.exhale { return .exhale }
        return .holdEmpty
    }

    private func scale(for t: Double) -> CGFloat {
        let tm = timing
        let minScale: CGFloat = 0.85
        let maxScale: CGFloat = 1.15

        if t < tm.inhale {

            let progress = t / tm.inhale
            return minScale + (maxScale - minScale) * progress
        } else if t < tm.inhale + tm.holdFull {

            return maxScale
        } else if t < tm.inhale + tm.holdFull + tm.exhale {

            let progress = (t - (tm.inhale + tm.holdFull)) / tm.exhale
            return maxScale - (maxScale - minScale) * progress
        } else {

            return minScale
        }
    }

    private func phaseText(for phase: Phase, cycleCount: Int) -> String {
        switch phase {
        case .inhale:
            if mode == .focus {
                return cycleCount % 2 == 0
                    ? "Breathe In Left" : "Breathe In Right"
            }
            return "Breathe In"
        case .holdFull: return "Pause"
        case .exhale:
            if mode == .focus {
                return cycleCount % 2 == 0 ? "Release Right" : "Release Left"
            }
            return "Release"
        case .holdEmpty: return "Pause"
        }
    }

    private func sizeColor(for s: CGFloat) -> Color {
        let minScale: CGFloat = 0.85
        let maxScale: CGFloat = 1.15
        let t = min(
            1.0,
            max(0.0, Double((s - minScale) / (maxScale - minScale)))
        )
        func lerp(_ a: Double, _ b: Double) -> Double { a + (b - a) * t }

        switch mode {
        case .calm:

            return Color(
                hue: lerp(0.06, 0.09),
                saturation: lerp(0.85, 0.95),
                brightness: lerp(0.60, 0.95)
            )
        case .focus:

            return Color(
                hue: lerp(0.70, 0.65),
                saturation: lerp(0.85, 0.70),
                brightness: lerp(0.40, 0.88)
            )
        case .sleep:

            return Color(
                hue: lerp(0.91, 0.87),
                saturation: lerp(0.70, 0.45),
                brightness: lerp(0.30, 0.72)
            )
        }
    }

    private func sanskritText(for phase: Phase) -> String {
        switch phase {
        case .inhale: return "Puraka"
        case .holdFull: return "Antara Kumbhaka"
        case .exhale: return "Rechaka"
        case .holdEmpty: return "Bahya Kumbhaka"
        }
    }

    private func handlePhaseChange(
        _ phase: Phase,
        cycleCount: Int,
        forceRun: Bool = false
    ) {
        guard isRunning || forceRun else { return }

        if phase != lastPhase {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            if phase == .exhale && (mode == .calm || mode == .sleep) {
                HapticManager.shared.startOmVibration()
            } else {
                HapticManager.shared.stopOmVibration()
            }
        }

        let guidanceMode =
            AudioGuidanceMode(rawValue: audioGuidanceMode) ?? .off
        guard guidanceMode != .off else {
            lastPhase = phase
            return
        }
        guard phase != lastPhase else { return }

        lastPhase = phase

        switch guidanceMode {
        case .tones:
            switch phase {
            case .inhale:
                SoundManager.shared.playInhaleSequence(duration: timing.inhale)
            case .holdFull, .holdEmpty: SoundManager.shared.playHold()
            case .exhale:
                SoundManager.shared.playExhaleSequence(duration: timing.exhale)
            }
        case .speech:
            switch phase {
            case .inhale:
                if mode == .focus {
                    VoiceGuidanceManager.shared.speak(
                        cycleCount % 2 == 0
                            ? "Block right, breathe in left"
                            : "Block left, breathe in right"
                    )
                } else {
                    VoiceGuidanceManager.shared.speak("Breathe in")
                }
            case .holdFull: VoiceGuidanceManager.shared.speak("Pause")
            case .exhale:
                if mode == .focus {
                    VoiceGuidanceManager.shared.speak(
                        cycleCount % 2 == 0
                            ? "Block left, release right"
                            : "Block right, release left"
                    )
                } else {
                    VoiceGuidanceManager.shared.speak("Release")
                }
            case .holdEmpty: VoiceGuidanceManager.shared.speak("Pause")
            }
        case .off:
            break
        }
    }
}
