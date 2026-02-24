import SwiftUI

struct InfoView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Shwaas")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("श्वास — breath as a path inward.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Roots", systemImage: "leaf")
                            .font(.headline)

                        Text("Pranayama is one of the eight limbs of Ashtanga yoga, codified by the sage Patanjali in the Yoga Sutras over two thousand years ago. The word itself comes from Sanskrit: *prana* (life force) and *ayama* (expansion). To regulate breath was to regulate life itself.")
                            .foregroundColor(.secondary)

                        Text("The Hatha Yoga Pradipika — a 15th-century Sanskrit text — describes pranayama as the most direct means of calming the mind. Not metaphor. Practice.")
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("The Three Modes", systemImage: "circle.grid.3x3")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            breathingRow(title: "Shanti — शान्ति", subtitle: "Peace, calm")
                            breathingRow(title: "Dharana — धारणा", subtitle: "Concentration")
                            breathingRow(title: "Nidra — निद्रा", subtitle: "Yogic sleep")
                        }

                        Text("Each mode follows a different rhythm — the timing of inhale, hold, and exhale adjusted for its intention. Nidra uses the longest exhale, designed to activate the parasympathetic nervous system.")
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("The Breathing Cycle", systemImage: "arrow.3.trianglepath")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            breathingRow(title: "Puraka — पूरक", subtitle: "Inhale")
                            breathingRow(title: "Kumbhaka — कुम्भक", subtitle: "Hold")
                            breathingRow(title: "Rechaka — रेचक", subtitle: "Exhale")
                        }

                        Text("These three Sanskrit terms have been used by practitioners for millennia. Kumbhaka — the hold — is considered the most potent phase: the moment the breath, the mind, and awareness become one.")
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Sound Guidance", systemImage: "waveform")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            breathingRow(title: "Off", subtitle: "Pure silence")
                            breathingRow(title: "Noise", subtitle: "Pink noise, breath-synced")
                            breathingRow(title: "Speech", subtitle: "Spoken phase cues")
                        }

                        Text("Pink noise mirrors the acoustic texture of rain, wind, and rivers — sounds considered auspicious in many Indian traditions. Shwaas generates it in real time, shaping each burst to match the arc of your breath.")
                            .foregroundColor(.secondary)
                    }

                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
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
