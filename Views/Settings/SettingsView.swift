import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showInfo = false

    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $viewModel.appTheme) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(
                    header: Text("Practice"),
                    footer: Text(viewModel.guidanceModeCaption)
                ) {
                    Picker("Audio Guidance", selection: $viewModel.audioGuidanceMode) {
                        ForEach(AudioGuidanceMode.allCases, id: \.rawValue) {
                            mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.resetApp(dismissAction: { dismiss() })
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
                        AppTheme(rawValue: viewModel.appTheme)?.colorScheme
                    )
                    .id(viewModel.appTheme)
            }
        }
    }
}

#Preview {
    SettingsView()
}
