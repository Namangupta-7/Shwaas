import SwiftUI
import UIKit

struct BreathingView: View {
    @State private var viewModel: BreathingViewModel

    init(mode: BreathingMode) {
        _viewModel = State(wrappedValue: BreathingViewModel(mode: mode))
    }

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

    private var isLandscape: Bool {
        hSizeClass == .regular || vSizeClass == .compact
    }

    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }

            if viewModel.showCompletion {
                completionOverlay
                    .transition(.opacity)
            }

            if viewModel.showStartMessage {
                ZStack {
                    viewModel.backgroundColor.ignoresSafeArea()

                    Text("Let’s begin.")
                        .font(.system(size: 28, weight: .thin))
                        .italic()
                        .foregroundColor(.primary.opacity(0.8))
                        .transition(
                            .opacity.combined(with: .scale(scale: 0.98))
                        )
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            viewModel.checkFirstLaunch()
        }
        .sheet(isPresented: $viewModel.showModeInfo) {
            ModeInfoView(mode: viewModel.mode)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showModeInfo = true
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
            viewModel.hardStop()
        }
    }

    private var portraitLayout: some View {
        VStack {
            VStack(spacing: 6) {
                Text(viewModel.titleText)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(viewModel.subtitleText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 30) {
                BreathingAnimationView(
                    mode: viewModel.mode,
                    isRunning: viewModel.isRunning
                )
                .frame(height: 320)

                Text(viewModel.timeString)
                    .font(.title2)
                    .monospacedDigit()
                    .accessibilityLabel("Time remaining: \(viewModel.timeString)")

                if viewModel.isRunning || viewModel.hasStarted {
                    seekBar
                }
            }

            Spacer()

            if !viewModel.isRunning && !viewModel.hasStarted {
                VStack(spacing: 8) {
                    Text("Session Length: \(Int(viewModel.selectedMinutes)) min")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Slider(value: $viewModel.selectedMinutes, in: 1...5, step: 1)
                        .onChange(of: viewModel.selectedMinutes) { old, newValue in
                            if newValue == 1 || newValue == 5 {
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                            }
                            viewModel.resetTimer()
                        }
                        .accessibilityLabel("Session length")
                        .accessibilityValue("\(Int(viewModel.selectedMinutes)) minutes")
                }
                .padding(.bottom, 12)
            }

            Button(action: viewModel.toggleSession) {
                Text(viewModel.buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Capsule().fill(Color.primary.opacity(0.15))
                    )
            }
            .accessibilityLabel(viewModel.buttonTitle)
        }
        .padding()
    }

    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                BreathingAnimationView(
                    mode: viewModel.mode,
                    isRunning: viewModel.isRunning
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)

            Divider().opacity(0.2)

            HStack {
                Spacer(minLength: 40)
                VStack(spacing: vSizeClass == .compact ? 14 : 24) {
                    VStack(spacing: 4) {
                        Text(viewModel.titleText)
                            .font(
                                vSizeClass == .compact ? .title2 : .largeTitle
                            )
                            .fontWeight(.bold)
                        Text(viewModel.subtitleText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(viewModel.timeString)
                        .font(.title2)
                        .monospacedDigit()

                    if viewModel.isRunning || viewModel.hasStarted {
                        seekBar
                    }

                    if !viewModel.isRunning && !viewModel.hasStarted {
                        VStack(spacing: 8) {
                            Text("Session Length: \(Int(viewModel.selectedMinutes)) min")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Slider(value: $viewModel.selectedMinutes, in: 1...5, step: 1)
                                .onChange(of: viewModel.selectedMinutes) { old, newValue in
                                    if newValue == 1 || newValue == 5 {
                                        let generator =
                                            UISelectionFeedbackGenerator()
                                        generator.selectionChanged()
                                    }
                                    viewModel.resetTimer()
                                }
                        }
                    }

                    Button(action: viewModel.toggleSession) {
                        Text(viewModel.buttonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Capsule().fill(Color.primary.opacity(0.15))
                            )
                    }
                }
                .frame(maxWidth: 300)
                .padding(.trailing, 32)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
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
                    .frame(width: geo.size.width * CGFloat(viewModel.progress), height: 6)

                Circle()
                    .fill(Color.primary.opacity(0.8))
                    .frame(width: 18, height: 18)
                    .offset(x: geo.size.width * CGFloat(viewModel.progress) - 9)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.seek(to: value.location.x / geo.size.width)
                    }
            )
        }
        .frame(height: 18)
        .padding(.horizontal)
        .accessibilityLabel(
            "Session progress, \(Int(viewModel.progress * 100)) percent elapsed"
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: viewModel.seek(to: CGFloat(viewModel.progress) + 0.05)
            case .decrement: viewModel.seek(to: CGFloat(viewModel.progress) - 0.05)
            @unknown default: break
            }
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Text(viewModel.completionEmoji)
                        .font(.system(size: 64))
                        .accessibilityLabel(viewModel.completionEnglish)

                    VStack(spacing: 4) {
                        Text(viewModel.completionSanskrit)
                            .font(.largeTitle)
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .tracking(6)

                        Text(viewModel.completionEnglish.uppercased())
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
                    Text("\(viewModel.completedMinutes) min of practice")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.55))

                    Text(viewModel.completionMessage)
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
                        viewModel.showCompletion = false
                    }
                } label: {
                    Text("Return")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                        .overlay(
                            Capsule().stroke(
                                Color.white.opacity(0.25),
                                lineWidth: 1
                            )
                        )
                }
                .accessibilityLabel("Return to home screen")

                Spacer().frame(height: 48)
            }
        }
    }
}
