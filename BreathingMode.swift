import SwiftUI

enum BreathingMode {
    case calm
    case focus
    case sleep

    var iconName: String {
        switch self {
        case .calm:  return "leaf.fill"
        case .focus: return "scope"
        case .sleep: return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .calm:  return Color(hue: 0.07, saturation: 0.80, brightness: 1.0)
        case .focus: return .indigo
        case .sleep: return .purple
        }
    }
}