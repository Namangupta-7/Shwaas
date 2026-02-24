import AVFoundation

@MainActor
final class VoiceGuidanceManager {

    static let shared = VoiceGuidanceManager()

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {

        if synthesizer.isSpeaking {
            // Stop at word boundary so the ending doesn't clip mid-syllable.
            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Slow, calm delivery.
        utterance.rate           = 0.32
        // Slightly raised pitch feels warmer and less robotic.
        utterance.pitchMultiplier = 1.08
        // Gentle volume — present but not intrusive.
        utterance.volume         = 0.75

        // Give a small breath before and after each phrase.
        utterance.preUtteranceDelay  = 0.15
        utterance.postUtteranceDelay = 0.2

        // Prefer Samantha (warm, natural-sounding US English).
        // Falls back to any en-GB voice (tends to be softer), then en-US.
        if let samantha = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
            utterance.voice = samantha
        } else if let ukVoice = AVSpeechSynthesisVoice(language: "en-GB") {
            utterance.voice = ukVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        synthesizer.speak(utterance)
    }
}
