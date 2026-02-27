import AVFoundation

extension AVAudioPCMBuffer: @retroactive @unchecked Sendable {}

@MainActor
final class SoundManager {

    static let shared = SoundManager()

    private let engine     = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let mixerNode  = AVAudioMixerNode()

    private let buildQueue = DispatchQueue(label: "SoundManager.build", qos: .userInitiated)

    private init() {
        engine.attach(playerNode)
        engine.attach(mixerNode)
        engine.connect(playerNode, to: mixerNode, format: nil)
        engine.connect(mixerNode, to: engine.mainMixerNode, format: nil)

        SoundManager.ensureAudioSessionActive()

        do {
            try engine.start()
        } catch {
            print("Audio engine failed:", error)
        }
    }

    static func ensureAudioSessionActive() {
        do {

            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate AVAudioSession:", error)
        }
    }

    func cancelPending() {
        buildQueue.async { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {

                self.playerNode.stop()
                self.engine.pause()
            }
        }
    }

    private struct PinkState {
        var b0 = 0.0, b1 = 0.0, b2 = 0.0, b3 = 0.0, b4 = 0.0, b5 = 0.0, b6 = 0.0
        var seed: UInt64 = 0x123456789ABCDEF0

        mutating func next() -> Double {
            seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17
            let w = Double(Int64(bitPattern: seed)) / Double(Int64.max)
            b0 =  0.99886 * b0 + w * 0.0555179
            b1 =  0.99332 * b1 + w * 0.0750759
            b2 =  0.96900 * b2 + w * 0.1538520
            b3 =  0.86650 * b3 + w * 0.3104856
            b4 =  0.55000 * b4 + w * 0.5329522
            b5 = -0.76160 * b5 - w * 0.0168980
            let p = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) / 6.5
            b6 = w * 0.115926
            return p
        }
    }

    enum Shape { case swell, fade, bell }

    nonisolated private func buildBuffer(duration: Double, shape: Shape,
                             amplitude: Float = 0.22) -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        let total = Int(frameCount)

        for channel in 0..<2 {
            let ch = buffer.floatChannelData![channel]
            var pink = PinkState()
            if channel == 1 { pink.seed = 0xFEDCBA9876543210 }

            for frame in 0..<total {
                let progress = total > 1 ? Double(frame) / Double(total - 1) : 0
                let env: Double
                switch shape {
                case .swell: env = sin(progress * .pi / 2)
                case .fade:  env = cos(progress * .pi / 2)
                case .bell:  env = sin(progress * .pi)
                }
                ch[frame] = Float(pink.next() * env) * amplitude
            }
        }
        return buffer
    }

    private func asyncPlay(duration: Double, shape: Shape, amplitude: Float = 0.22) {
        buildQueue.async { [weak self] in
            guard let self else { return }

            guard let buf = self.buildBuffer(duration: duration, shape: shape, amplitude: amplitude)
            else { return }
            DispatchQueue.main.async {

//                guard self.engine.isRunning else { return }
                
                if !self.engine.isRunning {
                    do {
                        try self.engine.start()
                    } catch {
                        print("Engine restart failed:", error)
                        return
                    }
                }

                self.playerNode.stop()
                self.playerNode.scheduleBuffer(buf, at: nil, options: [])
                self.playerNode.play()
            }
        }
    }

    func playInhaleSequence(duration: Double) {

        asyncPlay(duration: duration, shape: .bell)
    }

    func playHold() {

    }

    func playExhaleSequence(duration: Double) {
        asyncPlay(duration: duration, shape: .fade)
    }

    func playComplete() {
        buildQueue.async { [weak self] in
            guard let self else { return }
            guard let buf1 = self.buildBuffer(duration: 1.2, shape: .swell, amplitude: 0.18),
                  let buf2 = self.buildBuffer(duration: 2.0, shape: .fade,  amplitude: 0.18)
            else { return }
            DispatchQueue.main.async {
                self.playerNode.stop()
                self.playerNode.scheduleBuffer(buf1, at: nil, options: [])
                self.playerNode.scheduleBuffer(buf2, at: nil, options: [])
                self.playerNode.play()
            }
        }
    }
    
    func hardStop() {
        playerNode.stop()
        playerNode.reset()
        engine.pause()
    }
}
