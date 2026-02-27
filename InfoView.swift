import SwiftUI

struct InfoView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Shwaas")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("श्वास — breath as balance.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Image("shwaas_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Why
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Why", systemImage: "sunrise")
                            .font(.headline)

                        Text("""
As a child, I watched my mother practice yoga each morning. Years later, during stress and sleeplessness, I rediscovered those same breathing rhythms.

Shwaas is my reinterpretation of that inherited calm.
""")
                        .foregroundColor(.secondary)
                    }

                    // Roots & Translation
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Reinterpreting Pranayama", systemImage: "leaf")
                            .font(.headline)

                        Text("""
Inspired by classical pranayama practices such as Sama Vritti, Nadi Shodhana, and extended calming breath cycles, Shwaas translates traditional rhythm into visual motion and guided timing.

It does not replicate tradition — it reimagines it digitally.
""")
                        .foregroundColor(.secondary)
                    }

                    // Modes
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Rhythms", systemImage: "timer")
                            .font(.headline)

                        breathingRow(title: "Shanti", subtitle: "Equal, grounding breath")
                        breathingRow(title: "Dharana", subtitle: "Focused alternating rhythm")
                        breathingRow(title: "Nidra", subtitle: "Extended calming cycle")
                    }

                    // Closing
                    VStack(alignment: .leading, spacing: 10) {
                        Label("A Quiet Practice", systemImage: "heart")
                            .font(.headline)

                        Text("""
Shwaas is not a productivity tool.

It is a pause — a reminder that breath remains our most accessible anchor.
""")
                        .foregroundColor(.secondary)
                    }

                }
                .padding(24)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }

    private func breathingRow(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(subtitle)
                .foregroundColor(.secondary)
        }
    }
}
