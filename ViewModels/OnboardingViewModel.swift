import SwiftUI
import Observation

@Observable @MainActor
class OnboardingViewModel {
    
    var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    
    var currentPage = 0
    let cardCount = 4

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    func advance(dismissAction: @escaping () -> Void) {
        if currentPage < cardCount - 1 {
            withAnimation { currentPage += 1 }
        } else {
            withAnimation {
                hasSeenOnboarding = true
                dismissAction()
            }
        }
    }

    func backgroundColor(for page: Int) -> [Color] {
        return backgroundColors[page]
    }

    private let backgroundColors: [[Color]] = [
        [
            BreathingMode.calm.color,
            Color(hue: 0.04, saturation: 0.85, brightness: 0.55),
        ],
        [
            Color(hue: 0.67, saturation: 0.78, brightness: 0.72),
            Color(hue: 0.71, saturation: 0.85, brightness: 0.35),
        ],
        [
            Color(hue: 0.88, saturation: 0.58, brightness: 0.52),
            Color(hue: 0.92, saturation: 0.70, brightness: 0.12),
        ],
        [
            Color(hue: 0.48, saturation: 0.68, brightness: 0.48),
            Color(hue: 0.52, saturation: 0.82, brightness: 0.18),
        ],
    ]

    var currentButtonTextColor: Color {
        backgroundColors[currentPage][1]
    }
}
