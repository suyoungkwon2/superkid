import AVFoundation
import SwiftUI

@MainActor
final class Mission: ObservableObject {
    enum Step: Equatable {
        case scan, processing, setup, safety, find, shout, low, door, outside, call, spread, rewind, result
    }

    static let questions = ["What is happening?", "Where are you?", "Who are you?"]
    static let safetyChecks = [
        "The floor is clear", "I have room to walk",
        "A grown-up is nearby", "I know where to stop"
    ]

    let room = RoomAR()
    let audio = MissionAudio()
    @Published private(set) var step: Step = .scan
    @Published private(set) var teacher = ""
    @Published private(set) var progress = 0.0
    @Published private(set) var spreadStage = 0
    @Published private(set) var foundClues: Set<FireClue> = []
    @Published private(set) var answer = 0
    @Published private(set) var paused = false
    @Published private(set) var cameraReady = false
    @Published private(set) var audioError = false
    @Published private(set) var permissionMessage: String?
    @Published var checked: Set<Int> = []

    private var elapsed = 0.0
    private var held = 0.0
    private var quietGap = 0.0
    private var upright = 0.0
    private var startHeight: Double?
    private var audioReadyAt: TimeInterval?
    private var needsSilence = true
    private var lastTick: TimeInterval?
    private var inactive = false

    var lowLimit: Double? { startHeight.map { $0 * Tuning.lowHeightRatio } }

    func startScan() async {
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            permissionMessage = "Turn on Camera in Settings to scan the room."
            return
        }
        permissionMessage = nil
        cameraReady = true
        room.start()
        room.setScanning(true)
        say("Point the tablet at the room and walk slowly.")
    }

    func finishScan() {
        guard ready, room.firePlaced, room.exitPlaced else { return }
        room.setScanning(false)
        go(.processing)
    }

    func allowMicrophone() async {
        guard await audio.requestMicrophone() else {
            permissionMessage = "Turn on Microphone in Settings to practice your shout."
            return
        }
        permissionMessage = nil
        go(.safety)
    }

    func begin() {
        guard validStartSpot, checked.count == Self.safetyChecks.count,
              let height = room.metrics.height, height > 0 else { return }
        foundClues.removeAll()
        startHeight = height
        go(.find)
    }

    func collect(_ clue: FireClue) {
        guard step == .find, ready, !paused, !inactive,
              room.metrics.cluePoints[clue] != nil,
              foundClues.insert(clue).inserted else { return }
        if foundClues.count == FireClue.allCases.count { go(.shout) }
    }

    func openDoor() { if step == .door { go(.outside) } }
    func startCall() {
        guard step == .outside else { return }
        answer = 0
        go(.call)
    }

    func endCall() {
        guard step == .call, answer == Self.questions.count, !audio.isSpeaking else { return }
        go(.result)
    }

    func retry() {
        guard ready, step == .rewind else { return }
        room.setSpread(0)
        go(.low)
    }

    func retryAudio() {
        audioError = false
        audioReadyAt = nil
        needsSilence = true
    }

    func rescan() {
        guard cameraReady else {
            go(.scan)
            return
        }
        checked.removeAll()
        paused = false
        permissionMessage = nil
        room.reset()
        room.setScanning(true)
        go(.scan)
        say("Point the tablet at the room and walk slowly.")
    }

    func togglePause() {
        paused.toggle()
        lastTick = nil
        if paused { audio.stop() }
        else if !teacher.isEmpty { say(teacher) }
    }

    func setActive(_ active: Bool) {
        inactive = !active
        lastTick = nil
        if !active {
            audio.stop()
            held = 0
            quietGap = 0
            upright = 0
            audioReadyAt = nil
            needsSilence = true
        }
    }

    func tick(now: TimeInterval) {
        let dt = lastTick.map { min(max(now - $0, 0), Tuning.updateInterval * 2) } ?? 0
        lastTick = now
        guard !paused, !inactive else { return }
        if room.trackingNeedsReset {
            audio.stop()
            return
        }
        if step == .processing, elapsed >= Tuning.scanConfirmationDuration {
            go(.setup)
            return
        }
        if requiresTracking && !ready {
            held = 0
            quietGap = 0
            upright = 0
            progress = 0
            return
        }
        elapsed += dt
        switch step {
        case .shout:
            if listen(now: now, dt: dt, threshold: Tuning.shoutThreshold, duration: Tuning.shoutDuration) {
                go(.low)
            } else if elapsed >= Tuning.quietReminderTime, audio.isListening, held == 0 {
                elapsed = 0
                say("Louder! Like someone is in the next room.")
            }
        case .low:
            guard let height = room.metrics.height, let lowLimit else { return }
            let isLow = height <= lowLimit
            upright = isLow || audio.isSpeaking ? 0 : upright + dt
            let arrivedLow = isLow && room.metrics.exitDistance <= Tuning.arrivalRadius
            if hold(arrivedLow, duration: Tuning.lowArrivalDuration, dt: dt) { go(.door) }
            else if upright >= Tuning.uprightGraceTime { go(.spread) }
        case .call:
            guard answer < Self.questions.count else { return }
            if listen(now: now, dt: dt, threshold: Tuning.speechThreshold, duration: Tuning.speechDuration) {
                answer += 1
                elapsed = 0
                say(answer == Self.questions.count ? "Thank you. You can end the practice call now." : Self.questions[answer])
            } else if elapsed >= Tuning.quietReminderTime, audio.isListening, held == 0 {
                elapsed = 0
                say(Self.questions[answer])
            }
        case .spread:
            if elapsed >= Tuning.spreadInterval {
                elapsed = 0
                if spreadStage == 3 { go(.rewind) }
                else {
                    spreadStage += 1
                    room.setSpread(spreadStage)
                }
            }
        default: break
        }
    }

    var validStartSpot: Bool {
        ready && (room.metrics.height ?? 0) > 0 && room.metrics.exitDistance >= Tuning.minimumRouteDistance
    }

    var ready: Bool { room.tracking && !room.trackingNeedsReset }
    var requiresTracking: Bool { [.safety, .find, .shout, .low].contains(step) }

    private func go(_ next: Step) {
        audio.stop()
        step = next
        elapsed = 0
        held = 0
        quietGap = 0
        upright = 0
        progress = 0
        audioError = false
        audioReadyAt = nil
        needsSilence = true
        switch next {
        case .scan: teacher = ""
        case .processing: teacher = ""
        case .setup: say("You're ready!")
        case .safety: say("Let's check your space first.")
        case .find:
            say("Follow the arrow to the practice spot. Tap all three fire clues.")
            audio.playPracticeAlarm()
        case .shout: say("Tell everyone at home! Loud!")
        case .low: say("Stay low and follow the arrow to the front door.")
        case .door: say("You're at the front door! Tap it to open.")
        case .outside: say("You made it out! Never go back in.")
        case .call: say("911, what's your emergency? " + Self.questions[0])
        case .spread:
            spreadStage = 1
            room.setSpread(spreadStage)
            say("Oh no, the fire is growing!")
        case .rewind: say("Let's go back to that moment.")
        case .result: teacher = ""
        }
    }

    private func say(_ line: String) {
        teacher = line
        held = 0
        quietGap = 0
        progress = 0
        audioReadyAt = nil
        needsSilence = true
        audio.speak(line)
    }

    private func hold(_ condition: Bool, duration: Double, dt: Double) -> Bool {
        held = condition ? held + dt : 0
        progress = min(held / duration, 1)
        return held >= duration
    }

    private func listen(now: TimeInterval, dt: Double, threshold: Double, duration: Double) -> Bool {
        guard !audio.isSpeaking, !audioError else { return false }
        let readyAt = audioReadyAt ?? (now + Tuning.audioSettlingTime)
        audioReadyAt = readyAt
        guard now >= readyAt else { return false }
        if !audio.isListening {
            do { try audio.listen() }
            catch { audioError = true }
            return false
        }
        if step == .call && needsSilence {
            if audio.level < threshold { needsSilence = false }
            return false
        }
        let loudEnough = audio.level >= threshold
        if step == .shout {
            quietGap = loudEnough ? 0 : quietGap + dt
            if !loudEnough && quietGap <= Tuning.shoutGapTolerance { return false }
        }
        return hold(loudEnough, duration: duration, dt: dt)
    }
}
