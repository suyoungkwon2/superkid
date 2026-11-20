import AVFoundation
import Combine

@MainActor
final class MissionAudio: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var level = -100.0
    @Published private(set) var isSpeaking = false
    @Published private(set) var isListening = false

    private let session = AVAudioSession.sharedInstance()
    private let synthesizer = AVSpeechSynthesizer()
    private var alarm: AVAudioPlayer?
    private var engine: AVAudioEngine?
    private var recordingID: UUID?
    private var speechID: ObjectIdentifier?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func requestMicrophone() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func speak(_ text: String) {
        stopListening()
        speechID = nil
        synthesizer.stopSpeaking(at: .immediate)

        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechID = ObjectIdentifier(utterance)
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func playPracticeAlarm() {
        guard let url = Bundle.main.url(forResource: "practice-alarm", withExtension: "wav") else { return }
        alarm = try? AVAudioPlayer(contentsOf: url)
        alarm?.play()
    }

    func listen() throws {
        guard !isSpeaking, !isListening else { return }
        guard AVAudioApplication.shared.recordPermission == .granted else {
            throw MicrophoneError.permissionRequired
        }

        let inputEngine = AVAudioEngine()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
        try session.setActive(true)

        let input = inputEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            deactivateSession()
            throw MicrophoneError.inputUnavailable
        }

        let id = UUID()
        input.installTap(onBus: 0, bufferSize: 1_024, format: format) { @Sendable [weak self] buffer, _ in
            let decibels = MissionAudio.decibels(in: buffer)
            Task { @MainActor [weak self] in
                // A callback can already be queued when the tap is removed.
                guard let self, self.recordingID == id else { return }
                self.level = decibels
            }
        }

        do {
            try inputEngine.start()
        } catch {
            input.removeTap(onBus: 0)
            deactivateSession()
            throw error
        }

        engine = inputEngine
        recordingID = id
        isListening = true
    }

    func stopListening() {
        if let engine {
            recordingID = nil
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
            self.engine = nil
            deactivateSession()
        }
        isListening = false
        level = -100
    }

    func stop() {
        alarm?.stop()
        alarm = nil
        stopListening()
        speechID = nil
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        deactivateSession()
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance
    ) {
        reportSpeechEnd(ObjectIdentifier(utterance))
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance
    ) {
        reportSpeechEnd(ObjectIdentifier(utterance))
    }

    private nonisolated func reportSpeechEnd(_ id: ObjectIdentifier) {
        Task { @MainActor [weak self] in
            guard let self, self.speechID == id else { return }
            self.speechID = nil
            self.deactivateSession()
            self.isSpeaking = false
        }
    }

    private func deactivateSession() {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    private nonisolated static func decibels(in buffer: AVAudioPCMBuffer) -> Double {
        let frameCount = Int(buffer.frameLength)
        guard let channels = buffer.floatChannelData, frameCount > 0 else { return -100 }

        // RMS is calculated from the first input channel. Audio is never stored.
        let samples = channels[0]
        let stride = buffer.stride
        var sumOfSquares = 0.0
        for frame in 0..<frameCount {
            let sample = Double(samples[frame * stride])
            sumOfSquares += sample * sample
        }
        let meanSquare = sumOfSquares / Double(frameCount)
        return max(-100, 10 * log10(meanSquare))
    }
}

private enum MicrophoneError: LocalizedError {
    case permissionRequired
    case inputUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionRequired:
            "Allow microphone access in Settings to continue."
        case .inputUnavailable:
            "The microphone is unavailable. Try again."
        }
    }
}
