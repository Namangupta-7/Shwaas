import SwiftUI

struct StateCardView: View {

    let title: String
    let subtitle: String
    let description: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))

            Text(description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(gradient)
        .cornerRadius(22)
    }
}
