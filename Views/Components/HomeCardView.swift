import SwiftUI

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
                MandalaView(
                    style: mandalaStyle,
                    color: gradient.first ?? .white,
                    opacity: 0.15
                )
                .frame(
                    width: geo.size.height * 1.8,
                    height: geo.size.height * 1.8
                )
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
