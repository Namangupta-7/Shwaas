import SwiftUI
import UIKit

struct BreathingView: View {

    let mode: BreathingMode

    @State private var isRunning = false
    @State private var hasStarted = false
    @State private var showStartMessage = false
    @State private var showCompletion = false
    @State private var completedMinutes = 0

    @State private var selectedMinutes: Double = 2
    @State private var totalTime = 120
    @State private var timeRemaining = 120

    @State private var timer: Timer?
    @State private var showModeInfo = false

    @AppStorage private var hasSeenShantiInfo: Bool
    @AppStorage private var hasSeenDharanaInfo: Bool
    @AppStorage private var hasSeenNidraInfo: Bool

    init(mode: BreathingMode) {
        self.mode = mode

        _hasSeenShantiInfo = AppStorage(wrappedValue: false, "hasSeenShantiInfo")
        _hasSeenDharanaInfo = AppStorage(wrappedValue: false, "hasSeenDharanaInfo")
        _hasSeenNidraInfo = AppStorage(wrappedValue: false, "hasSeenNidraInfo")
    }

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass)   private var vSizeClass

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

            if showStartMessage {
                ZStack {
                    backgroundColor.ignoresSafeArea()

                    Text("Let’s begin.")
                        .font(.system(size: 28, weight: .thin))
                        .italic()
                        .foregroundColor(.primary.opacity(0.8))
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            checkFirstLaunch()
        }
        .sheet(isPresented: $showModeInfo) {
            ModeInfoView(mode: mode)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showModeInfo = true
                } label: {
                    Image(systemName: "info")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .accessibilityLabel("Mode Information")
                }
            }
        }
        .onDisappear {
            SoundManager.shared.hardStop()
        }
    }

    private func checkFirstLaunch() {
        switch mode {
        case .calm:
            if !hasSeenShantiInfo {
                showModeInfo = true
                hasSeenShantiInfo = true
            }
        case .focus:
            if !hasSeenDharanaInfo {
                showModeInfo = true
                hasSeenDharanaInfo = true
            }
        case .sleep:
            if !hasSeenNidraInfo {
                showModeInfo = true
                hasSeenNidraInfo = true
            }
        }
    }

    private var portraitLayout: some View {
        VStack {

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

            if !isRunning && !hasStarted {
                VStack(spacing: 8) {
                    Text("Session Length: \(Int(selectedMinutes)) min")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Slider(value: $selectedMinutes, in: 1...5, step: 1)
                        .onChange(of: selectedMinutes) { newValue in
                            if newValue == 1 || newValue == 5 {
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                            }
                            resetTimer()
                        }
                        .accessibilityLabel("Session length")
                        .accessibilityValue("\(Int(selectedMinutes)) minutes")
                }
                .padding(.bottom, 12)
            }

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

    private var landscapeLayout: some View {
        HStack(spacing: 0) {

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
                                .onChange(of: selectedMinutes) { newValue in
                                    if newValue == 1 || newValue == 5 {
                                        let generator = UISelectionFeedbackGenerator()
                                        generator.selectionChanged()
                                    }
                                    resetTimer()
                                }
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

    private var seekBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                Capsule()
                    .fill(Color.primary.opacity(0.12))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.primary.opacity(0.55))
                    .frame(width: geo.size.width * CGFloat(progress), height: 6)

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

        withAnimation(.easeInOut(duration: 0.8)) {
            showStartMessage = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showStartMessage = false
            }

            isRunning = true
            totalTime = Int(selectedMinutes) * 60
            timeRemaining = totalTime

            let startGenerator = UIImpactFeedbackGenerator(style: .medium)
            startGenerator.prepare()
            startGenerator.impactOccurred()

            startTimer()
        }
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
        case .calm:  return BreathingMode.calm.color.opacity(0.08)
        case .focus: return Color.indigo.opacity(0.12)
        case .sleep: return Color(hue: 0.88, saturation: 0.60, brightness: 0.70).opacity(0.10)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

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

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 40, height: 1)
                    .padding(.vertical, 28)

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
