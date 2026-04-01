import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showInfo = false

    @AppStorage("audioGuidanceMode") var audioGuidanceMode: String =
        AudioGuidanceMode.off.rawValue
    @AppStorage("appTheme") var appTheme: String = AppTheme.dark.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenShantiInfo") private var hasSeenShantiInfo = false
    @AppStorage("hasSeenDharanaInfo") private var hasSeenDharanaInfo = false
    @AppStorage("hasSeenNidraInfo") private var hasSeenNidraInfo = false

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
                        ForEach(AudioGuidanceMode.allCases, id: \.rawValue) {
                            mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        resetApp()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset App")
                            Spacer()
                        }
                    }
                }
                Section(header: Text("About")) {
                    Button {
                        showInfo = true
                    } label: {
                        Label("About Shwaas", systemImage: "info.circle")
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
                    .preferredColorScheme(
                        AppTheme(rawValue: appTheme)?.colorScheme
                    )
                    .id(appTheme)
            }
        }
    }

    private var guidanceModeCaption: String {
        switch AudioGuidanceMode(rawValue: audioGuidanceMode) ?? .off {
        case .off:
            return "Silent practice."
        case .tones:
            return "A continuous, breath-synced swell of pink noise."
        case .speech:
            return
                "A calm voice guiding each phase (Breathe In, Pause, Release)."
        }
    }

    private func resetApp() {
        hasSeenOnboarding = false
        hasSeenShantiInfo = false
        hasSeenDharanaInfo = false
        hasSeenNidraInfo = false
        audioGuidanceMode = AudioGuidanceMode.off.rawValue
        appTheme = AppTheme.dark.rawValue
        dismiss()
    }
}

#Preview {
    SettingsView()
}
