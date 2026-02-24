import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("audioGuidanceMode") var audioGuidanceMode: String = AudioGuidanceMode.off.rawValue
    @AppStorage("appTheme") var appTheme: String = AppTheme.dark.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(
                    header: Text("Practice"),
                    footer: Text(guidanceModeCaption)
                ) {
                    Picker("Audio Guidance", selection: $audioGuidanceMode) {
                        ForEach(AudioGuidanceMode.allCases, id: \.rawValue) { mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("About")) {
                    NavigationLink(destination: InfoView()) {
                        Label("About Shwaas", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Extracted caption logic from ContentView
    private var guidanceModeCaption: String {
        switch AudioGuidanceMode(rawValue: audioGuidanceMode) ?? .off {
        case .off:
            return "Silent practice."
        case .tones:
            return "A continuous, breath-synced swell of pink noise."
        case .speech:
            return "A calm voice guiding each phase (Inhale, Hold, Exhale)."
        }
    }
}

#Preview {
    SettingsView()
}
