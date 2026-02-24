import SwiftUI

struct OnboardingView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Animated gradient background that shifts with each page
            LinearGradient(
                colors: backgroundColors[currentPage],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    card1.tag(0)
                    card2.tag(1)
                    card3.tag(2)
                    card4.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page dots + next/begin button
                VStack(spacing: 20) {
                    // Dot indicators
                    HStack(spacing: 8) {
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(i == currentPage ? Color.white : Color.white.opacity(0.35))
                                .frame(width: i == currentPage ? 10 : 7, height: i == currentPage ? 10 : 7)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    Button(action: advance) {
                        Text(currentPage == 3 ? "Begin" : "Next")
                            .fontWeight(.semibold)
                            .foregroundColor(buttonTextColor)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(Color.white)
                            )
                    }
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Cards

    private var card1: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("श्वास")
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(.white)

            Text("Shwaas")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.85))

            Spacer().frame(height: 8)

            Text("\"Chale vāte chalaṁ chittam\nnishchale nishchalaṁ bhavet.\"")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 32)

            Text("When the breath moves, the mind moves.\nWhen the breath is still, the mind is still.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Text("— Hatha Yoga Pradipika, 15th century")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private var card2: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Three Practices")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)

            Text("Each rooted in a different intention")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)

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
            }
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    private var card3: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Sound Guidance")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)

            Text("Choose what you hear during practice")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)

            VStack(spacing: 20) {
                audioRow(icon: "speaker.slash.fill", title: "Off",    description: "Pure silence")
                audioRow(icon: "waveform",           title: "Noise",  description: "Pink noise follows your breath — swells on inhale, dissolves on hold")
                audioRow(icon: "mic.fill",           title: "Speech", description: "A gentle voice guides each phase")
            }
            .padding(.horizontal, 28)

            Spacer()

            Text("You can change this anytime from Settings.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var card4: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "rectangle.landscape.rotate")
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(.white)
                .padding(.bottom, 24)

            Text("Desk Mode")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)

            Text("For your nightstand or desk")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)

            Text("Turn your device sideways during a session. The interface adapts instantly, giving the breath room to expand while keeping the time clearly visible.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .padding(.bottom, 60)

            Spacer()
        }
    }

    // MARK: - Reusable Rows

    private func practiceRow(icon: String, sanskrit: String, english: String, description: String) -> some View {
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

    private func audioRow(icon: String, title: String, description: String) -> some View {
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

    // MARK: - Helpers

    private func advance() {
        if currentPage < 3 {
            withAnimation { currentPage += 1 }
        } else {
            withAnimation { hasSeenOnboarding = true }
        }
    }

    private let backgroundColors: [[Color]] = [
        // Page 1: Saffron / Amber (matches Shanti)
        [Color(hue: 0.08, saturation: 0.75, brightness: 0.92),
         Color(hue: 0.04, saturation: 0.85, brightness: 0.55)],
        
        // Page 2: Lapis Indigo (matches Dharana)
        [Color(hue: 0.67, saturation: 0.78, brightness: 0.72),
         Color(hue: 0.71, saturation: 0.85, brightness: 0.35)],
        
        // Page 3: Deep Maroon (matches Nidra)
        [Color(hue: 0.88, saturation: 0.58, brightness: 0.52),
         Color(hue: 0.92, saturation: 0.70, brightness: 0.12)],
        
        // Page 4: Deep Teal/Pine (Grounded, focus)
        [Color(hue: 0.48, saturation: 0.68, brightness: 0.48),
         Color(hue: 0.52, saturation: 0.82, brightness: 0.18)]
    ]

    private var buttonTextColor: Color {
        backgroundColors[currentPage][1]
    }
}

#Preview {
    OnboardingView()
}
