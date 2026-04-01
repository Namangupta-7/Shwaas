import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass
    @Environment(\.dismiss) private var dismiss

    private var isLandscape: Bool {
        hSizeClass == .regular || vSizeClass == .compact
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack {
            LinearGradient(
                colors: viewModel.backgroundColor(for: viewModel.currentPage),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: viewModel.currentPage)

            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPage) {
                    card1.tag(0)
                    card2.tag(1)
                    card3.tag(2)
                    card4.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(
                                    i == viewModel.currentPage
                                        ? Color.white
                                        : Color.white.opacity(0.35)
                                )
                                .frame(
                                    width: i == viewModel.currentPage ? 10 : 7,
                                    height: i == viewModel.currentPage ? 10 : 7
                                )
                                .animation(
                                    .spring(response: 0.3),
                                    value: viewModel.currentPage
                                )
                        }
                    }

                    Button(action: { viewModel.advance(dismissAction: { dismiss() }) }) {
                        Text(viewModel.currentPage == 3 ? "Begin" : "Next")
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.currentButtonTextColor)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(Color.white)
                            )
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
        }
    }

    private var card1: some View {
        ScrollView(showsIndicators: false) {
            let content = VStack(spacing: 20) {
                Text("श्वास")
                    .font(.system(size: isLandscape ? 96 : 72, weight: .thin))
                    .foregroundColor(.white)

                Text("Shwaas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.85))

                Spacer().frame(height: 8)

                Text(
                    "\"Chale vāte chalaṁ chittam\nnishchale nishchalaṁ bhavet.\""
                )
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, isLandscape ? 0 : 32)

                Text("When the breath is steady, the mind becomes steady.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, isLandscape ? 0 : 32)

                Text("— Hatha Yoga Pradipika, 15th century")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }

            if isLandscape {
                HStack(spacing: 60) {
                    content
                    Spacer()
                }
                .padding(60)
                .frame(minHeight: 400)
            } else {
                VStack {
                    Spacer()
                    content
                    Spacer()
                }
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.7
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var card2: some View {
        ScrollView(showsIndicators: false) {
            if isLandscape {
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Three Practices")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("A return to breath")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 16) {
                        practiceRow(
                            icon: "leaf.fill",
                            sanskrit: "Shanti",
                            english: "Calm",
                            description: "Cultivating inner stillness"
                        )
                        practiceRow(
                            icon: "scope",
                            sanskrit: "Dharana",
                            english: "Focus",
                            description: "Steady attention through breath"
                        )
                        practiceRow(
                            icon: "moon.stars.fill",
                            sanskrit: "Nidra",
                            english: "Sleep",
                            description: "Gentle descent into rest"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(60)
                .frame(minHeight: 400)
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Text("Three Practices").font(.title).fontWeight(.bold)
                        .foregroundColor(.white).padding(.bottom, 8)
                    Text("A return to breath").font(.subheadline)
                        .foregroundColor(.white.opacity(0.7)).padding(
                            .bottom,
                            40
                        )
                    VStack(spacing: 20) {
                        practiceRow(
                            icon: "leaf.fill",
                            sanskrit: "Shanti",
                            english: "Calm",
                            description: "Cultivating inner stillness"
                        )
                        practiceRow(
                            icon: "scope",
                            sanskrit: "Dharana",
                            english: "Focus",
                            description: "Steady attention through breath"
                        )
                        practiceRow(
                            icon: "moon.stars.fill",
                            sanskrit: "Nidra",
                            english: "Sleep",
                            description: "Gentle descent into rest"
                        )
                    }.padding(.horizontal, 28)
                    Spacer()
                }
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.7
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var card3: some View {
        ScrollView(showsIndicators: false) {
            if isLandscape {
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sound Guidance")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Choose what you hear during practice")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 16) {
                        audioRow(
                            icon: "speaker.slash.fill",
                            title: "Off",
                            description: "Pure silence"
                        )
                        audioRow(
                            icon: "waveform",
                            title: "Noise",
                            description: "Pink noise follows your breath"
                        )
                        audioRow(
                            icon: "mic.fill",
                            title: "Speech",
                            description: "A gentle voice guides each phase"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(60)
                .frame(minHeight: 400)
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Text("Sound Guidance").font(.title).fontWeight(.bold)
                        .foregroundColor(.white).padding(.bottom, 8)
                    Text("Choose what you hear during practice").font(
                        .subheadline
                    ).foregroundColor(.white.opacity(0.7)).padding(.bottom, 40)
                    VStack(spacing: 16) {
                        audioRow(
                            icon: "speaker.slash.fill",
                            title: "Off",
                            description: "Pure silence"
                        )
                        audioRow(
                            icon: "waveform",
                            title: "Noise",
                            description:
                                "Pink noise follows your breath — swells as you breathe in, dissolves on pause"
                        )
                        audioRow(
                            icon: "mic.fill",
                            title: "Speech",
                            description: "A gentle voice guides each phase"
                        )
                    }.padding(.horizontal, 28)
                    Spacer()
                }
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.7
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var card4: some View {
        ScrollView(showsIndicators: false) {
            if isLandscape {
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 24) {
                        Image(systemName: "rectangle.landscape.rotate")
                            .font(.system(size: 80, weight: .thin))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Desk Mode")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("For your nightstand or desk")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(
                        "Turn your device sideways during a session. The interface adapts instantly, giving the breath room to expand while keeping the time clearly visible."
                    )
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(60)
                .frame(minHeight: 400)
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Image(systemName: "rectangle.landscape.rotate").font(
                        .system(size: 64, weight: .thin)
                    ).foregroundColor(.white).padding(.bottom, 24)
                    Text("Desk Mode").font(.title).fontWeight(.bold)
                        .foregroundColor(.white).padding(.bottom, 8)
                    Text("For your nightstand or desk").font(.subheadline)
                        .foregroundColor(.white.opacity(0.7)).padding(
                            .bottom,
                            40
                        )
                    Text(
                        "Rotate your device to enter Desk Mode. This gives the breath space to expand visually, allowing you to practice without holding your device."
                    )
                    .font(.body).foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center).lineSpacing(6).padding(
                        .horizontal,
                        32
                    ).padding(.bottom, 60)
                    Spacer()
                }
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.7
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func practiceRow(
        icon: String,
        sanskrit: String,
        english: String,
        description: String
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(sanskrit)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("· \(english)")
                        .foregroundColor(.white.opacity(0.6))
                }
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    private func audioRow(icon: String, title: String, description: String)
        -> some View
    {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    OnboardingView()
}
