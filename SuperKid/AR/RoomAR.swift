import ARKit
import Combine
import RealityKit
import SwiftUI

enum FireClue: String, CaseIterable, Identifiable {
    case smoke = "Smoke"
    case sparks = "Sparks"
    case scorchedMark = "Scorch mark"

    var id: Self { self }

    var icon: String {
        switch self {
        case .smoke: "smoke.fill"
        case .sparks: "sparkles"
        case .scorchedMark: "flame.fill"
        }
    }

    var offset: SIMD3<Float> {
        switch self {
        case .smoke: [-0.27, 0.22, 0]
        case .sparks: [0.27, 0.17, 0]
        case .scorchedMark: [0, 0.06, 0.23]
        }
    }
}

struct ARMetrics: Equatable {
    var fireAngle: Double = 0
    var exitAngle: Double = 0
    var cluePoints: [FireClue: CGPoint] = [:]
    var height: Double?
    var exitDistance: Double = .infinity
}

@MainActor
final class RoomAR: NSObject, ObservableObject {
    let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)

    @Published private(set) var tracking = false
    @Published private(set) var trackingNeedsReset = false
    @Published private(set) var hasPlane = false
    @Published private(set) var hasExitCandidate = false
    @Published private(set) var firePlaced = false
    @Published private(set) var exitPlaced = false
    @Published private(set) var metrics = ARMetrics()

    private var scanning = false
    private var timer: Timer?
    private var frameBeforeReset: TimeInterval = 0
    private var fireAnchor: AnchorEntity?
    private var flame: Entity?
    private var exitAnchor: AnchorEntity?

    override init() {
        super.init()
        view.session.delegateQueue = .main
        view.session.delegate = self
        view.renderOptions.insert(.disableMotionBlur)
    }

    func start() {
        guard timer == nil else { return }
        reset()
        let timer = Timer(timeInterval: 1 / 20, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.sampleFrame()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        view.session.pause()
        tracking = false
        hasPlane = false
        hasExitCandidate = false
    }

    func reset() {
        fireAnchor?.removeFromParent()
        exitAnchor?.removeFromParent()
        fireAnchor = nil
        flame = nil
        exitAnchor = nil
        firePlaced = false
        exitPlaced = false
        hasPlane = false
        hasExitCandidate = false
        tracking = false
        metrics = ARMetrics()

        guard ARWorldTrackingConfiguration.isSupported else {
            trackingNeedsReset = true
            return
        }
        trackingNeedsReset = false
        frameBeforeReset = view.session.currentFrame?.timestamp ?? 0
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func setScanning(_ enabled: Bool) {
        scanning = enabled
        if !enabled {
            hasPlane = false
            hasExitCandidate = false
        }
    }

    func placeFire() {
        guard let hit = centerHit() else { return }
        fireAnchor?.removeFromParent()
        let anchor = AnchorEntity(world: hit.worldTransform.translation)
        if let camera = view.session.currentFrame?.camera {
            let facing = camera.transform.columns.2
            anchor.orientation = simd_quatf(angle: atan2(facing.x, facing.z), axis: [0, 1, 0])
        }
        let pan = ModelEntity(
            mesh: .generateBox(size: [0.24, 0.035, 0.24], cornerRadius: 0.016),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]
        )
        pan.position.y = 0.022
        anchor.addChild(pan)

        let flame = Entity()
        flame.position.y = 0.04
        let center = flameLobe(color: .white, scale: [0.065, 0.145, 0.061], angle: -0.12)
        let left = flameLobe(color: .lightGray, scale: [0.048, 0.094, 0.05], angle: 0.3)
        let right = flameLobe(color: .lightGray, scale: [0.046, 0.1, 0.05], angle: -0.35)
        left.position.x = -0.048
        right.position.x = 0.048
        flame.addChild(left)
        flame.addChild(center)
        flame.addChild(right)
        anchor.addChild(flame)

        view.scene.addAnchor(anchor)
        fireAnchor = anchor
        if let exitAnchor,
           Double(anchor.position.y - exitAnchor.position.y) < Tuning.minimumTableElevation {
            exitAnchor.removeFromParent()
            self.exitAnchor = nil
            exitPlaced = false
        }
        self.flame = flame
        firePlaced = true
    }

    func placeExit() {
        guard let hit = exitHit() else { return }
        exitAnchor?.removeFromParent()
        let anchor = AnchorEntity(world: hit.worldTransform.translation)
        let marker = ModelEntity(
            mesh: .generateBox(size: [0.36, 0.012, 0.36], cornerRadius: 0.005),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
        marker.position.y = 0.012
        anchor.addChild(marker)
        view.scene.addAnchor(anchor)
        exitAnchor = anchor
        exitPlaced = true
    }

    func setSpread(_ stage: Int) {
        let spreadScale = 1 + Float(max(0, stage)) * 0.4
        flame?.scale = .init(repeating: spreadScale)
    }

    private func flameLobe(color: UIColor, scale: SIMD3<Float>, angle: Float) -> ModelEntity {
        let lobe = ModelEntity(
            mesh: .generateSphere(radius: 1),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        lobe.scale = scale
        lobe.position.y = scale.y * 0.83
        lobe.orientation = simd_quatf(angle: angle, axis: [0, 0, 1])
        return lobe
    }

    private func centerHit() -> ARRaycastResult? {
        guard tracking, !view.bounds.isEmpty else { return nil }
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        return view.raycast(from: center, allowing: .existingPlaneGeometry, alignment: .horizontal).first
    }

    private func exitHit() -> ARRaycastResult? {
        guard tracking, !view.bounds.isEmpty else { return nil }
        if let hit = centerHit() {
            return isBelowFire(hit) ? hit : nil
        }

        // The detected floor can extend beyond the currently mapped polygon.
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        return view.raycast(from: center, allowing: .existingPlaneInfinite, alignment: .horizontal)
            .first(where: isBelowFire)
    }

    private func isBelowFire(_ hit: ARRaycastResult) -> Bool {
        guard let fireAnchor else { return false }
        return Double(fireAnchor.position(relativeTo: nil).y - hit.worldTransform.translation.y)
            >= Tuning.minimumTableElevation
    }

    private func sampleFrame() {
        guard !trackingNeedsReset,
              let frame = view.session.currentFrame, frame.timestamp > frameBeforeReset,
              case .normal = frame.camera.trackingState else {
            if tracking { tracking = false }
            if hasPlane { hasPlane = false }
            if hasExitCandidate { hasExitCandidate = false }
            return
        }

        if !tracking { tracking = true }
        let centerHasPlane = scanning && centerHit() != nil
        let centerHasExit = scanning && !exitPlaced && exitHit() != nil
        if centerHasPlane != hasPlane { hasPlane = centerHasPlane }
        if centerHasExit != hasExitCandidate { hasExitCandidate = centerHasExit }
        updateMetrics(frame.camera)
    }

    private func updateMetrics(_ camera: ARCamera) {
        let position = camera.transform.translation
        let cameraZ = camera.transform.columns.2
        let forward = SIMD2<Float>(-cameraZ.x, -cameraZ.z)
        var next = ARMetrics()

        if let fireAnchor {
            let fire = fireAnchor.position(relativeTo: nil)
            next.fireAngle = compassAngle(from: position, toward: fire, forward: forward)
            if !view.bounds.isEmpty {
                let backward = SIMD3(cameraZ.x, cameraZ.y, cameraZ.z)
                for clue in FireClue.allCases {
                    let worldPoint = fireAnchor.convert(position: clue.offset, to: nil)
                    guard simd_dot(worldPoint - position, backward) < 0,
                          let point = view.project(worldPoint) else { continue }
                    let x = (point.x - view.bounds.minX) / view.bounds.width
                    let y = (point.y - view.bounds.minY) / view.bounds.height
                    guard (0...1).contains(x), (0...1).contains(y) else { continue }
                    next.cluePoints[clue] = CGPoint(x: x, y: y)
                }
            }
        }

        if let exitAnchor {
            let exit = exitAnchor.position(relativeTo: nil)
            next.exitAngle = compassAngle(from: position, toward: exit, forward: forward)
            next.exitDistance = horizontalDistance(position, exit)
            next.height = Double(position.y - exit.y)
        }

        if next != metrics { metrics = next }
    }

    private func compassAngle(from position: SIMD3<Float>, toward target: SIMD3<Float>, forward: SIMD2<Float>) -> Double {
        let direction = SIMD2<Float>(target.x - position.x, target.z - position.z)
        let right = SIMD2<Float>(-forward.y, forward.x)
        return Double(atan2(simd_dot(direction, right), simd_dot(direction, forward)))
    }

    private func horizontalDistance(_ first: SIMD3<Float>, _ second: SIMD3<Float>) -> Double {
        Double(simd_distance(SIMD2(first.x, first.z), SIMD2(second.x, second.z)))
    }

    private func requireRescan() {
        trackingNeedsReset = true
        tracking = false
        hasPlane = false
        hasExitCandidate = false
    }
}

extension RoomAR: ARSessionDelegate {
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        MainActor.assumeIsolated { requireRescan() }
    }

    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        MainActor.assumeIsolated { requireRescan() }
    }
}

private extension simd_float4x4 {
    var translation: SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}

struct RoomCamera: UIViewRepresentable {
    let room: RoomAR

    func makeUIView(context: Context) -> ARView { room.view }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
