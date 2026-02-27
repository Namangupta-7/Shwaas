import CoreHaptics
import Foundation

final class HapticManager: @unchecked Sendable {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            try engine?.start()

            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart engine: \(error)")
                }
            }
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func startOmVibration() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            try engine?.start()
        } catch {
            print("Engine failed to start: \(error)")
        }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)

        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)

        do {
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play Om pattern: \(error.localizedDescription)")
        }
    }

    func stopOmVibration() {
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to stop Om pattern: \(error.localizedDescription)")
        }
    }
}