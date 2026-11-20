# Demo scope (week of Dec 8, 2026)

The demo is shown in a classroom, on an iPad Pro 11-inch (2018, no LiDAR). Skill Lab
is **not** part of the live demo. Only the AR Home Mission and the screens connected
to it are. This may change after we check how hard the AR part is to build.

## Must work live (build these for real)
Home Mission, Level 1 (stove pan fire), screens M0 to M5, plus the fail path:

| Step | What the child does | How we implement it in the demo |
|---|---|---|
| M0 Safety check | Confirms the play space | Checklist screen over the camera. Two of the four conditions are "???" placeholders |
| M1 Find the fire | Follows a compass arrow and sweeps the tablet | Detect a horizontal plane (a desk), place a virtual fire on it. On-screen arrow rotates toward the fire based on device heading vs fire position. Fire is "found" when it is near the screen center for ~1 s |
| M2 Shout | Says "Fire!" loudly | `AVAudioEngine` input level. Pass when loudness passes a threshold for ~0.5 s. No word recognition. Teacher says "Louder!" if too quiet |
| M3 Stay low and go | Moves to the front door with the tablet low | Record tablet height at mission start. "Low" = camera height below a fraction of that start height (tune in `Tuning.swift`). Compass arrow points to the door anchor. Voice guidance. Glowing tempting objects are placed near the route |
| M4a Front door | Taps a graphic door | Door graphic centered on screen, tap to open |
| M4b Door opened | Sees "outside" graphic | Static "outside" scene, teacher says never go back in |
| M5 Call 911 | Speaks the three facts | Simulated phone call screen over dimmed AR. Puzzle in the margin: what is happening / where / who. Each piece fits when the child speaks (volume only, or a simple "child is speaking" check; do not do speech recognition unless time allows) |
| F1 Fire spreads | (consequence) | If the child hesitates too long, goes toward the fire or a glowing object, or stands up while low is required: fire graphic grows. Kitchen, then hallway, then living room |
| F2 Rewind | (consequence) | At the last stage, "Let's go back to that moment" and restart from the failed step |
| R Result | Sees steps done, marbles, badge | Static summary with the earned marbles and Level 1 badge |

## Shown as screens only (no real logic)
Click-through or simple SwiftUI screens, grayscale, matching the wireframes:
- First-time flow: A1 splash, A2 parent sign-up, A3 permissions, A4 make the
  character, A5 meet the teacher, A6 home scan, A7 processing the scan, A8 setup done.
  The home scan is **not** performed live. A6 and A7 are visuals only.
- B1 home and map select, B2 level select (map path), B3 wardrobe and badge board.
- Levels 2 and 3 can be shown as variations (different fire, tempting object, smoke).
  Do not build separate logic unless time allows.

## Fixed shortcuts we are deliberately taking
- **No home scan, no route finding.** The route to the front door is a fixed point
  relative to the start position (for example "door is 3 m ahead and 1 m left of the
  start pose"), set in `Config/Tuning.swift` so it can be adjusted for the classroom.
  A short "set the door position" helper (stand at the door, tap) is a good optional
  addition because it does not need LiDAR.
- **Virtual fire placed on a desk or the floor**, whichever plane ARKit detects first.
- **Head height from the front camera is optional.** Start with tablet height only
  (rear AR tracking). Add TrueDepth face tracking only if everything else works.
- **Teacher voice** can be `AVSpeechSynthesizer` text-to-speech.
- **Marbles, outfits, badges** are local numbers and images. No real economy.

## Out of scope for the demo
Skill Lab (L1 to L5b), real home scanning, parent accounts, server or analytics,
Levels 2 and 3 as real gameplay, maps 2 and 3, wardrobe purchasing logic beyond a
static screen, any real phone call, speech recognition of words.

## Suggested milestones (about 19 days, Nov 19 to Dec 8)
1. **Week 1:** AR app runs on the 2018 iPad. Plane detection, virtual fire on a desk,
   compass arrow to the fire, microphone loudness meter, teacher bubble + voice.
   (covers M0, M1, M2)
2. **Week 2:** Low-height check, smoke visual, compass to a fixed door position,
   tempting objects, fire spread and rewind, front door and outside screens, 911
   call screen with the puzzle. (covers M3, M4a, M4b, M5, F1, F2)
3. **Week 3:** SwiftUI wireframe screens for A1 to A8, B1 to B3 and R, hook them up
   as one flow, tune thresholds in the presentation room, rehearse, record a backup
   video of a successful run.

## Fallbacks (decide early)
- If AR tracking is unstable in the classroom: use a well-lit, textured floor patch
  or a rug. Test the room in advance.
- If height detection is unreliable: use a button-free fallback such as "tablet below
  a fixed height from the floor plane" or, as a last resort, a presenter-operated
  hidden toggle.
- If the live demo fails: play the backup video and show the Figma wireframes.

## Definition of done for the demo
A person who has never seen the game can: open the app, be guided through a
setup-looking flow, start Level 1, find the virtual fire, shout, walk low to a door
position, tap the graphic door, finish the simulated 911 call, and see their marbles
and badge. They can also deliberately trigger the fire spread and rewind.
