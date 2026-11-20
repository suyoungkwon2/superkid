# SuperKid: AR kitchen-fire safety game for children

## What we are building (the game is called "SuperKid")
An iPad game for children aged 7-10 that teaches kitchen-fire escape by having the
child act it out with their body in their own home. The tablet camera shows the real
room (AR) and the game adds a virtual fire, a compass arrow, smoke and a teacher.

Four steps, always in this order:
1. Find the fire (follow a compass arrow, sweep the tablet)
2. Shout "Fire!" (judged by microphone loudness, not by words)
3. Stay low and go (move to the front door with the tablet held low)
4. Call 911 from a safe place (simulated call screen only)

The immediate goal is a **demo for a class presentation, week of Dec 8, 2026
(no later than Dec 11)**. This is a prototype, not a shippable product.

Read these before planning or coding:
- `docs/DEMO_SCOPE.md`: exactly what is in and out of the demo. Start here.
- `docs/SCREENS.md`: every screen, its on-screen text and behavior.
- `docs/PRD.md`: full product requirements (v2.8) and design principles.
- `docs/wireframes/`: grayscale wireframe PNGs, one per screen (named by screen ID, e.g. `M3.png`).

## Target device and constraints (most important)
- Test device: **iPad Pro 11-inch, 2018** (A12X). It has a TrueDepth (Face ID) front
  camera. It has **NO LiDAR**.
- Do NOT use LiDAR-only APIs: no `RoomPlan`, no scene reconstruction / mesh, no
  `ARWorldTrackingConfiguration.sceneReconstruction`, no depth-based occlusion.
- Use plain ARKit world tracking with plane detection (horizontal planes).
- iPadOS: the iPad will be updated to the latest version it supports (exact version
  to be confirmed). Set the deployment target to iOS 17.0. Do not use APIs newer than
  iOS 17 without asking first. Xcode must be new enough to support the iPad's iPadOS.
- Orientation: iPad landscape (wireframes are 1194x834).
- A second device, an iPad Pro 12.9-inch 2022 (M2, has LiDAR), may be used for development
  and speed checks. The demo must still run on the 2018 11-inch.
- The developer is working alone and is not an experienced programmer. Prefer simple,
  readable code over clever abstractions. Explain non-obvious choices in short comments.

## Tech stack
- Swift 5.9+, SwiftUI for 2D screens, ARKit + RealityKit for AR (`ARView`
  wrapped in `UIViewRepresentable`).
- Audio: `AVAudioEngine` for microphone loudness (RMS/dB). `AVSpeechSynthesizer` for
  the teacher's voice (en-US) unless recorded audio files are added.
- No third-party packages unless the user agrees first. No backend, no accounts, no
  network. Store progress with `UserDefaults` or a small local JSON file.
- Project created in Xcode (iOS App, SwiftUI), product name `SuperKid`. Xcode 16+ folder-synchronized groups
  mean new files in the app folder are picked up automatically.

## Rules for working in this repo
- Work in small milestones. Each milestone must run on the iPad and be checkable by
  eye. After each one, tell the user exactly what to test on the device.
- One feature per file where reasonable. Suggested layout: `App/`, `Screens/`
  (SwiftUI screens, named by screen ID), `AR/` (AR view, fire, compass, route),
  `Services/` (microphone, speech, height tracking), `Config/Tuning.swift`.
- Put every tunable number (shout loudness threshold, "low" height ratio, smoke
  timings, fire-spread timers, marble prices) in `Config/Tuning.swift` so the user can
  adjust them on site without touching logic.
- All on-screen text and spoken lines are **English only**, short, child-friendly
  (ages 7-10). The exact lines are in `docs/SCREENS.md`.
- Every teacher line is shown in a speech bubble AND spoken aloud.
- Use grayscale placeholder shapes for art (gray boxes, circles, SF Symbols) as in
  the wireframes. Do not generate or download art assets without asking.
- After code changes, make sure the project builds (`xcodebuild -scheme <name> -destination 'generic/platform=iOS' build`).
  Running on the iPad is done by the user from Xcode. If a build fails, fix it before
  reporting back. Commit to git after each working milestone.
- Ask before adding dependencies, changing the deployment target, or restructuring.

## Hard safety and product rules (never break these)
- The fire is **always virtual**. The game never asks a child to go near a real stove,
  never teaches any way to put out a fire, and never shows harm to people or pets.
- The 911 call is **always simulated**. Never place a real call. Never use
  `tel:` URLs or CallKit for 911.
- The child never actually leaves the house. The way out is a graphic door on screen.
- Tone is calm and encouraging. A mistake makes the fire spread; the teacher rewinds
  ("Let's go back to that moment"). Never blame, never scare.
- No leaderboards. No points for speed. No reward for going near the fire.
- Moving while looking at a tablet is a trip risk: keep the safety-check screen (M0)
  and keep movement slow-paced. An adult should be nearby during demos.
- No personal data collection. The parent sign-up screen is a placeholder in the demo.

## Vocabulary
- **Teacher**: fixed guide character, not customizable, speaks every instruction.
- **Character**: the child's own avatar (picked and named by the child). On screen
  we say "character", never "animal" or "avatar".
- **Skill Lab** (stage 1): on-screen mini-games. Designed but NOT in the live demo.
- **Home Mission** (stage 2): the AR stage. This is the demo.
- **Marbles**: currency earned per correct step; buys outfits.
- **Badge**: earned for clearing a level.
