import SwiftUI

@main
struct MyApp: App {
    @AppStorage("appTheme") var appThemeTitle: String = "Dark"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appThemeTitle {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
}
 
