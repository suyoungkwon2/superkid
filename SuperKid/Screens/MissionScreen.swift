import Combine
import SwiftUI
import UIKit

@MainActor
struct MissionScreen: View {
    @StateObject private var mission = Mission()
    @Environment(\.scenePhase) private var scenePhase
    private let clock = Timer.publish(every: Tuning.updateInterval, on: .main, in: .common).autoconnect()

    var body: some View {
        MissionLayout(mission: mission, room: mission.room, audio: mission.audio)
            .onReceive(clock) { _ in mission.tick(now: ProcessInfo.processInfo.systemUptime) }
            .onChange(of: scenePhase, initial: true) { _, phase in mission.setActive(phase == .active) }
    }
}

@MainActor
private struct MissionLayout: View {
    @ObservedObject var mission: Mission
    @ObservedObject var room: RoomAR
    @ObservedObject var audio: MissionAudio
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            Color(white: 0.14).ignoresSafeArea()
            if mission.cameraReady {
                RoomCamera(room: room).ignoresSafeArea().accessibilityHidden(true)
            }
            if mission.step == .scan && mission.cameraReady && !room.exitPlaced {
                Image(systemName: "viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(scanTargetReady ? .white : .gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
            if [.processing, .setup, .outside, .call, .spread, .rewind, .result].contains(mission.step) {
                Color.black.opacity(0.66).ignoresSafeArea()
            }
            if mission.step == .low {
                VStack {
                    LinearGradient(colors: [.black.opacity(0.65), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 170)
                    Spacer()
                }
                .ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
            }

            VStack(spacing: 14) {
                header
                Spacer(minLength: 8)
                content
                Spacer(minLength: 8)
                footer
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .disabled(mission.paused || room.trackingNeedsReset)

            if mission.step == .find && mission.ready && !mission.paused {
                clueOverlay
            }

            if room.trackingNeedsReset {
                overlay("Scan the room again", button: "Restart scan", action: mission.rescan)
            } else if mission.paused {
                overlay("Paused", button: "Resume", action: mission.togglePause)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mission.step)
        .foregroundStyle(.white)
        .tint(.white)
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private var header: some View {
        HStack(spacing: 10) {
            if [.scan, .processing, .setup].contains(mission.step) {
                chip("Room scan", active: true)
            } else {
                Button("Pause", action: mission.togglePause)
                chip("1 Find fire", active: mission.step == .find)
                chip("2 Shout", active: mission.step == .shout)
                chip("3 Stay low & go", active: [.low, .door, .outside, .spread, .rewind].contains(mission.step))
                chip("4 Call 911", active: mission.step == .call)
            }
            Spacer()
            if mission.cameraReady && !mission.ready && mission.step != .result {
                chip("Hold still while tracking recovers", active: false)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let message = mission.permissionMessage {
                HStack {
                    Text(message)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                }
                .padding(12).background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
            }
            if !mission.teacher.isEmpty {
                HStack(spacing: 12) {
                    Label("Teacher", systemImage: "person.crop.circle")
                        .font(.headline)
                    Text(mission.teacher)
                }
                .padding(12).background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var content: some View {
        switch mission.step {
        case .scan:
            scan
        case .processing:
            panel {
                Text("Checking the practice spots").font(.largeTitle.bold())
                ProgressView()
                Button("Restart scan", action: mission.rescan)
            }
        case .setup:
            panel {
                Text("You're ready!").font(.largeTitle.bold())
                Label("Fire spot set", systemImage: "checkmark")
                Label("Exit spot set", systemImage: "checkmark")
                Button("Continue to safety check") { Task { await mission.allowMicrophone() } }
                Button("Restart scan", action: mission.rescan)
            }
        case .safety:
            panel {
                Text("Quick safety check").font(.largeTitle.bold())
                Text("The fire in this game is virtual.")
                ForEach(Array(Mission.safetyChecks.enumerated()), id: \.offset) { index, title in
                    Button {
                        if mission.checked.contains(index) { mission.checked.remove(index) }
                        else { mission.checked.insert(index) }
                    } label: {
                        Label(title, systemImage: mission.checked.contains(index) ? "checkmark.square.fill" : "square")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if mission.ready && !mission.validStartSpot {
                    Text("Start at least a step away from the marked exit.")
                }
                Button("I'm ready", action: mission.begin)
                    .disabled(!mission.validStartSpot || mission.checked.count != Mission.safetyChecks.count)
                Button("Restart scan", action: mission.rescan)
            }
            .frame(maxWidth: 440)
        case .find:
            VStack(spacing: 10) {
                chip("Find the fire clues", active: true)
                direction(room.metrics.fireAngle, label: "Fire direction")
                chip("\(mission.foundClues.count) / \(FireClue.allCases.count) found", active: false)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .allowsHitTesting(false)
        case .shout:
            panel {
                Text("Shout ‘FIRE!’").font(.largeTitle.bold())
                meter(threshold: Tuning.shoutThreshold)
            }
            .frame(maxWidth: 360)
        case .low:
            VStack(spacing: 12) {
                chip("Stay low!", active: true)
                direction(room.metrics.exitAngle, label: "Exit direction")
                chip("Follow the arrow to the front door", active: false)
                if let height = room.metrics.height, let limit = mission.lowLimit, limit > 0 {
                    VStack {
                        Text(height <= limit ? "Tablet height · Low zone" : "Tablet height · Lower the tablet")
                        ProgressView(value: min(max(height / (limit * 2), 0), 1))
                    }
                    .padding(12).frame(width: 290)
                    .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))
                }
            }
        case .door:
            panel {
                Text("Tap the door").font(.largeTitle.bold())
                Button(action: mission.openDoor) {
                    Image(systemName: "door.left.hand.closed").font(.system(size: 108))
                        .padding(16).accessibilityLabel("Open the practice door")
                }
            }
        case .outside:
            panel {
                Image(systemName: "door.left.hand.open").font(.system(size: 96))
                Text("You're outside!").font(.largeTitle.bold())
                Button("Next: call 911", action: mission.startCall)
            }
        case .call:
            HStack(spacing: 16) {
                panel {
                    Text("Practice call · nothing is really dialed").font(.subheadline)
                    Image(systemName: "phone.circle").font(.system(size: 58))
                    Text("Emergency 911").font(.largeTitle.bold())
                    if mission.answer < Mission.questions.count {
                        meter(threshold: Tuning.speechThreshold)
                    } else {
                        Button("End practice call", action: mission.endCall)
                            .disabled(audio.isSpeaking)
                    }
                }
                panel {
                    Text("Say each thing aloud").font(.title2.bold())
                    ForEach(Array(Mission.questions.enumerated()), id: \.offset) { index, question in
                        Label(question, systemImage: index < mission.answer ? "checkmark.circle.fill" : "puzzlepiece")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.white.opacity(index == mission.answer ? 0.24 : 0.08),
                                        in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(maxWidth: 810)
        case .spread:
            panel {
                Text("The fire is spreading").font(.largeTitle.bold())
                Text("The tablet was above the low zone.")
                HStack {
                    ForEach(Array(["Kitchen", "Hallway", "Living room"].enumerated()), id: \.offset) { index, title in
                        chip(title, active: index < mission.spreadStage)
                    }
                }
            }
        case .rewind:
            panel {
                Text("Rewind").font(.largeTitle.bold())
                Text("Try this: keep the tablet low as you move.")
                Button("Try again", action: mission.retry).disabled(!mission.ready)
                Button("Restart scan", action: mission.rescan)
            }
        case .result:
            panel {
                Label("Level 1 clear!", systemImage: "rosette").font(.largeTitle.bold())
                ForEach(["Find the fire", "Shout", "Stay low and go", "Practice call"], id: \.self) {
                    Label($0, systemImage: "checkmark.circle.fill")
                }
                Button("Scan again", action: mission.rescan)
            }
        }
    }

    @ViewBuilder
    private var scan: some View {
        if !mission.cameraReady {
            panel {
                Text("SuperKid").font(.largeTitle.bold())
                Text("Scan a room")
                Button("Start scan") { Task { await mission.startScan() } }
            }
        } else {
            HStack {
                Spacer()
                panel {
                    if room.exitPlaced {
                        Text("Practice spots set").font(.title2.bold())
                        Label("Fire spot set", systemImage: "checkmark")
                        Label("Exit spot set", systemImage: "checkmark")
                        Button("Finish scan", action: mission.finishScan)
                            .disabled(!mission.ready)
                    } else {
                        Text(room.firePlaced ? "2. Set the exit spot" : "1. Set the fire spot")
                            .font(.title2.bold())
                        Text(scanInstruction).multilineTextAlignment(.center)
                        Button(room.firePlaced ? "Set exit spot" : "Set fire spot") {
                            if room.firePlaced { room.placeExit() }
                            else { room.placeFire() }
                        }
                        .disabled(!scanTargetReady)
                    }
                    if room.firePlaced {
                        Button("Restart scan", action: mission.rescan)
                    }
                }
                .frame(width: 280)
            }
        }
    }

    private var clueOverlay: some View {
        GeometryReader { geometry in
            ForEach(FireClue.allCases) { clue in
                if let point = room.metrics.cluePoints[clue], !mission.foundClues.contains(clue) {
                    Button {
                        mission.collect(clue)
                    } label: {
                        Image(systemName: clue.icon)
                            .font(.title2.bold())
                            .frame(width: 52, height: 52)
                            .foregroundStyle(.black)
                            .background(.white, in: Circle())
                            .shadow(radius: 5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(clue.rawValue)
                    .position(
                        x: point.x * geometry.size.width,
                        y: point.y * geometry.size.height
                    )
                }
            }
        }
        .ignoresSafeArea()
    }

    private var scanTargetReady: Bool {
        room.firePlaced ? room.hasExitCandidate : room.hasPlane
    }

    private var scanInstruction: String {
        if !mission.ready {
            return "Move the tablet slowly until tracking is ready."
        }
        if scanTargetReady {
            return room.firePlaced ? "Floor detected. Set the exit spot." : "Surface detected. Set the fire spot on the table."
        }
        if !room.firePlaced {
            return "Aim at a clear spot on a table. Sweep slowly until the target turns white."
        }
        if room.hasPlane {
            return "Aim down at the floor in front of the door. If the fire is on the floor, restart and place it on a table."
        }
        return "Sweep slowly over the floor in front of the door until the target turns white."
    }

    private func meter(threshold: Double) -> some View {
        VStack(spacing: 10) {
            if mission.audioError {
                Text("The microphone stopped.")
                Button("Try microphone again", action: mission.retryAudio)
            } else {
                Text(audio.isListening ? "Listening…" : "Listen to the prompt")
                ProgressView(value: min(max((audio.level + 65) / (threshold + 65), 0), 1))
                    .accessibilityLabel("Microphone level")
            }
        }
    }

    private func direction(_ angle: Double, label: String) -> some View {
        Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 64))
            .rotationEffect(.radians(angle))
            .shadow(radius: 4)
            .opacity(mission.ready ? 1 : 0)
            .accessibilityLabel(label)
    }

    private func chip(_ title: String, active: Bool) -> some View {
        Text(title)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(active ? .black : .white)
            .background(active ? Color.white : Color.black.opacity(0.72), in: Capsule())
    }

    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 14, content: content)
            .padding(22)
            .background(.black.opacity(0.78), in: RoundedRectangle(cornerRadius: 20))
    }

    private func overlay(_ title: String, button: String, action: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.68).ignoresSafeArea()
            panel {
                Text(title).font(.largeTitle.bold())
                Button(button, action: action)
            }
        }
    }
}
