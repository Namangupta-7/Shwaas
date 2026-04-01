import AVFoundation

@MainActor
final class VoiceGuidanceManager {

    static let shared = VoiceGuidanceManager()

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        SoundManager.ensureAudioSessionActive()

        if synthesizer.isSpeaking {

            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)

        utterance.rate = 0.32

        utterance.pitchMultiplier = 1.08

        utterance.volume = 0.75

        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.2

        if let samantha = AVSpeechSynthesisVoice(
            identifier: "com.apple.ttsbundle.Samantha-compact"
        ) {
            utterance.voice = samantha
        } else if let ukVoice = AVSpeechSynthesisVoice(language: "en-GB") {
            utterance.voice = ukVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
