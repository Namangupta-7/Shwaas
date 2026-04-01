import SwiftUI
import Observation

@Observable @MainActor
class SettingsViewModel {
    
    var audioGuidanceMode: String {
        didSet {
            UserDefaults.standard.set(audioGuidanceMode, forKey: "audioGuidanceMode")
        }
    }
    
    var appTheme: String {
        didSet {
            UserDefaults.standard.set(appTheme, forKey: "appTheme")
        }
    }
    
    var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    
    var hasSeenShantiInfo: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenShantiInfo, forKey: "hasSeenShantiInfo")
        }
    }
    
    var hasSeenDharanaInfo: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenDharanaInfo, forKey: "hasSeenDharanaInfo")
        }
    }
    
    var hasSeenNidraInfo: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenNidraInfo, forKey: "hasSeenNidraInfo")
        }
    }

    init() {
        self.audioGuidanceMode = UserDefaults.standard.string(forKey: "audioGuidanceMode") ?? AudioGuidanceMode.off.rawValue
        self.appTheme = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.dark.rawValue
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        self.hasSeenShantiInfo = UserDefaults.standard.bool(forKey: "hasSeenShantiInfo")
        self.hasSeenDharanaInfo = UserDefaults.standard.bool(forKey: "hasSeenDharanaInfo")
        self.hasSeenNidraInfo = UserDefaults.standard.bool(forKey: "hasSeenNidraInfo")
    }

    var guidanceModeCaption: String {
        switch AudioGuidanceMode(rawValue: audioGuidanceMode) ?? .off {
        case .off:
            return "Silent practice."
        case .tones:
            return "A continuous, breath-synced swell of pink noise."
        case .speech:
            return "A calm voice guiding each phase (Breathe In, Pause, Release)."
        }
    }

    func resetApp(dismissAction: @escaping () -> Void) {
        hasSeenOnboarding = false
        hasSeenShantiInfo = false
        hasSeenDharanaInfo = false
        hasSeenNidraInfo = false
        audioGuidanceMode = AudioGuidanceMode.off.rawValue
        appTheme = AppTheme.dark.rawValue
        dismissAction()
    }
}
