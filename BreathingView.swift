import SwiftUI
import UIKit

struct BreathingView: View {

    let mode: BreathingMode

    @State private var isRunning = false
    @State private var hasStarted = false
    @State private var showCompletion = false
    @State private var completedMinutes = 0

    @State private var selectedMinutes: Double = 2
    @State private var totalTime = 120
    @State private var timeRemaining = 120

    @State private var timer: Timer?

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass)   private var vSizeClass

    /// True whenever the device is in landscape (iPhone or iPad).
    private var isLandscape: Bool {
        hSizeClass == .regular || vSizeClass == .compact
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }

            if showCompletion {
                completionOverlay
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Portrait Layout

    private var portraitLayout: some View {
        VStack {

            // MARK: Header
            VStack(spacing: 6) {
                Text(titleText)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // MARK: Center Breathing Area
            VStack(spacing: 30) {

                BreathingAnimationView(
                    mode: mode,
                    isRunning: isRunning
                )
                .frame(height: 320)

                Text(timeString)
                    .font(.title2)
                    .monospacedDigit()
                    .accessibilityLabel("Time remaining: \(timeString)")

                if isRunning || hasStarted {
                    seekBar
                }
            }

            Spacer()

            // MARK: Slider (only when not running)
            if !isRunning && !hasStarted {
                VStack(spacing: 8) {
                    Text("Session Length: \(Int(selectedMinutes)) min")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Slider(value: $selectedMinutes, in: 1...5, step: 1)
                        .onChange(of: selectedMinutes) { _, _ in
                            resetTimer()
                        }
                        .accessibilityLabel("Session length")
                        .accessibilityValue("\(Int(selectedMinutes)) minutes")
                }
                .padding(.bottom, 12)
            }

            // MARK: Button
            Button(action: toggleSession) {
                Text(buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Capsule().fill(Color.primary.opacity(0.15))
                    )
            }
            .accessibilityLabel(buttonTitle)
        }
        .padding()
    }

    // MARK: - Landscape / iPad Layout

    private var landscapeLayout: some View {
        let circleSize: CGFloat = vSizeClass == .compact ? 200 : 300

        return HStack(spacing: 0) {
            // Left: animation — expands to fill available space, circle centred within
            VStack {
                Spacer()
                BreathingAnimationView(
                    mode: mode,
                    isRunning: isRunning
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)

            Divider().opacity(0.2)

            // Right: controls — vertically centred
            HStack {
                Spacer(minLength: 40)
                VStack(spacing: vSizeClass == .compact ? 14 : 24) {
                    VStack(spacing: 4) {
                        Text(titleText)
                            .font(vSizeClass == .compact ? .title2 : .largeTitle)
                            .fontWeight(.bold)
                        Text(subtitleText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(timeString)
                        .font(.title2)
                        .monospacedDigit()

                    if isRunning || hasStarted {
                        seekBar
                    }

                    if !isRunning && !hasStarted {
                        VStack(spacing: 8) {
                            Text("Session Length: \(Int(selectedMinutes)) min")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Slider(value: $selectedMinutes, in: 1...5, step: 1)
                                .onChange(of: selectedMinutes) { _, _ in resetTimer() }
                        }
                    }

                    Button(action: toggleSession) {
                        Text(buttonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(Color.primary.opacity(0.15)))
                    }
                }
                .frame(maxWidth: 300)
                .padding(.trailing, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }


    // MARK: - Interactive Seek Bar

    private var seekBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.primary.opacity(0.12))
                    .frame(height: 6)

                // Fill
                Capsule()
                    .fill(Color.primary.opacity(0.55))
                    .frame(width: geo.size.width * CGFloat(progress), height: 6)

                // Thumb
                Circle()
                    .fill(Color.primary.opacity(0.8))
                    .frame(width: 18, height: 18)
                    .offset(x: geo.size.width * CGFloat(progress) - 9)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        seek(to: value.location.x / geo.size.width)
                    }
            )
        }
        .frame(height: 18)
        .padding(.horizontal)
        .accessibilityLabel("Session progress, \(Int(progress * 100)) percent elapsed")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: seek(to: CGFloat(progress) + 0.05)
            case .decrement: seek(to: CGFloat(progress) - 0.05)
            @unknown default: break
            }
        }
    }

    private func seek(to fraction: CGFloat) {
        let clamped = max(0, min(1, fraction))
        timeRemaining = Int(Double(totalTime) * Double(1 - clamped))
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // MARK: - Button Logic

    private func toggleSession() {
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

    private func startSession() {
        hasStarted = true
        isRunning = true
        totalTime = Int(selectedMinutes) * 60
        timeRemaining = totalTime

        let startGenerator = UIImpactFeedbackGenerator(style: .soft)
        startGenerator.prepare()
        startGenerator.impactOccurred()

        startTimer()
    }

    private func pauseSession() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resumeSession() {
        isRunning = true
        startTimer()
    }

    @AppStorage("audioGuidanceMode") private var audioGuidanceMode: String = AudioGuidanceMode.off.rawValue

    private func completeSession() {
        completedMinutes = Int(selectedMinutes)
        isRunning = false
        hasStarted = false
        timer?.invalidate()
        timer = nil

        let endGenerator = UINotificationFeedbackGenerator()
        endGenerator.prepare()
        endGenerator.notificationOccurred(.success)

        if AudioGuidanceMode(rawValue: audioGuidanceMode) == .tones {
            SoundManager.shared.playComplete()
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            showCompletion = true
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            MainActor.assumeIsolated {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    completeSession()
                }
            }
        }
    }

    private func resetTimer() {
        totalTime = Int(selectedMinutes) * 60
        timeRemaining = totalTime
    }

    // MARK: - Computed Properties

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1 - (Double(timeRemaining) / Double(totalTime))
    }

    private var timeString: String {
        String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    private var buttonTitle: String {
        if isRunning {
            return "Pause Practice"
        } else {
            return hasStarted ? "Resume Practice" : "Begin Practice"
        }
    }

    private var titleText: String {
        switch mode {
        case .calm: return "Shanti"
        case .focus: return "Dharana"
        case .sleep: return "Nidra"
        }
    }

    private var subtitleText: String {
        switch mode {
        case .calm: return "Cultivating inner stillness"
        case .focus: return "Steady attention through breath"
        case .sleep: return "Gentle descent into rest"
        }
    }

    private var backgroundColor: Color {
        switch mode {
        case .calm:  return Color(hue: 0.07, saturation: 0.80, brightness: 1.0).opacity(0.08)  // saffron tint
        case .focus: return Color.indigo.opacity(0.12)
        case .sleep: return Color(hue: 0.88, saturation: 0.60, brightness: 0.70).opacity(0.10) // rose tint
        }
    }

    // MARK: - Completion Overlay View

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon + title
                VStack(spacing: 16) {
                    Text(completionEmoji)
                        .font(.system(size: 64))
                        .accessibilityLabel(completionEnglish)

                    VStack(spacing: 4) {
                        Text(completionSanskrit)
                            .font(.largeTitle)
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .tracking(6)

                        Text(completionEnglish.uppercased())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.45))
                            .tracking(4)
                    }
                }

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 40, height: 1)
                    .padding(.vertical, 28)

                // Body
                VStack(spacing: 8) {
                    Text("\(completedMinutes) min of practice")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.55))

                    Text(completionMessage)
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(.horizontal, 44)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showCompletion = false
                    }
                } label: {
                    Text("Return")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                }
                .accessibilityLabel("Return to home screen")

                Spacer().frame(height: 48)
            }
        }
    }

    private var completionSanskrit: String {
        switch mode {
        case .calm:  return "Shanti"
        case .focus: return "Dharana"
        case .sleep: return "Nidra"
        }
    }

    private var completionEnglish: String {
        switch mode {
        case .calm:  return "Peace"
        case .focus: return "Clarity"
        case .sleep: return "Rest"
        }
    }

    private var completionEmoji: String {
        switch mode {
        case .calm:  return "🌿"
        case .focus: return "🔆"
        case .sleep: return "🌙"
        }
    }

    private var completionMessage: String {
        switch mode {
        case .calm:  return "Carry this stillness with you."
        case .focus: return "Your mind is clearer now. Go do great things."
        case .sleep: return "Let your breath carry you gently into rest."
        }
    }
}

