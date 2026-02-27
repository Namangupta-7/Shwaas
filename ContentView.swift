import SwiftUI

struct ContentView: View {

    @State private var showSettings = false
    @AppStorage("audioGuidanceMode") var audioGuidanceMode: String = AudioGuidanceMode.off.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") var appThemeTitle: String = "Dark"
    @State private var showOnboarding = false

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 28) {

                    VStack(alignment: .leading, spacing: 8) {

                        HStack {
                            Text("Shwaas")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .accessibilityAddTraits(.isHeader)

                            Spacer()

                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Settings")
                        }

                        Text("Pranayama — the ancient Indian art of conscious breath")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if hSizeClass == .regular {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            modeCards
                        }
                    } else {
                        VStack(spacing: 22) {
                            modeCards
                        }
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .preferredColorScheme(colorScheme)
                    .id(appThemeTitle)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
                    .preferredColorScheme(colorScheme)
                    .onDisappear {
                        hasSeenOnboarding = true
                    }
            }
            .onAppear {
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .onChange(of: hasSeenOnboarding) { newValue in
                if !newValue {
                    showOnboarding = true
                }
            }
        }
    }

    private var colorScheme: ColorScheme? {
        appThemeTitle == "Light" ? .light : .dark
    }

    @ViewBuilder
    private var modeCards: some View {
        NavigationLink {
            BreathingView(mode: .calm)
        } label: {
            HomeCardView(
                title: "Shanti",
                subtitle: "Calm",
                description: "Cultivating inner stillness",
                gradient: [BreathingMode.calm.color,
                       Color(hue: 0.04, saturation: 0.85, brightness: 0.55)],
                icon: "leaf.fill",
                mandalaStyle: .lotus
            )
        }
        .accessibilityLabel("Shanti — Calm breathing practice")

        NavigationLink {
            BreathingView(mode: .focus)
        } label: {
            HomeCardView(
                title: "Dharana",
                subtitle: "Focus",
                description: "Steady attention through breath",
                gradient: [Color(hue: 0.67, saturation: 0.78, brightness: 0.72),
                       Color(hue: 0.71, saturation: 0.85, brightness: 0.35)],
                icon: "scope",
                mandalaStyle: .yantra
            )
        }
        .accessibilityLabel("Dharana — Focus breathing practice")

        NavigationLink {
            BreathingView(mode: .sleep)
        } label: {
            HomeCardView(
                title: "Nidra",
                subtitle: "Sleep",
                description: "Gentle descent into rest",
                gradient: [Color(hue: 0.88, saturation: 0.58, brightness: 0.52),
                       Color(hue: 0.92, saturation: 0.70, brightness: 0.12)],
                icon: "moon.stars.fill",
                mandalaStyle: .chandra
            )
        }
        .accessibilityLabel("Nidra — Sleep breathing practice")
    }
}

#Preview {
    ContentView()
}

struct HomeCardView: View {

    let title: String
    let subtitle: String
    let description: String
    let gradient: [Color]
    let icon: String
    let mandalaStyle: MandalaStyle

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .accessibilityHidden(true)

            GeometryReader { geo in
                MandalaView(style: mandalaStyle, color: gradient.first ?? .white, opacity: 0.15)
                    .frame(width: geo.size.height * 1.8, height: geo.size.height * 1.8)
                    .position(x: geo.size.width - 20, y: geo.size.height / 2)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 10) {

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.85))
                        .accessibilityHidden(true)

                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                Text(description)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .frame(height: 160)
        .cornerRadius(24)
        .clipped()
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}