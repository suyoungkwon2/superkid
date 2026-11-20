# Screens

Source: Figma wireframes ("SuperKid, wireframe draft", iPad landscape 1194x834,
grayscale). Gray boxes in the wireframes are placeholders for illustration or the
camera. The game title is SuperKid. Stage names are working names. English only, ages 7-10.

Each screen below gives: purpose, on-screen text (as in the wireframe), and behavior.
Teacher lines marked (T) are shown in a speech bubble AND spoken aloud.
The "Figma frame" line says which frame in `docs/wireframes/` shows it.

## Note on screen IDs
The first-time flow was reordered after the wireframe labels were made. Permissions now
come right after parent sign-up so the parent approves them in the same sitting.
Use the **new IDs** below in code. Figma frame labels still carry the old IDs for three screens.

| New ID | Screen | Figma frame label |
|---|---|---|
| A1 | Splash | A1 Splash |
| A2 | Parent sign-up | A2 Parent sign-up |
| A3 | Permissions | A5 Permissions (camera, mic) |
| A4 | Make your character | A3 Make your character |
| A5 | Meet the teacher | A4 Meet the teacher |
| A6 | Home scan | A6 Home scan |
| A7 | Processing the scan | A7 Processing the scan |
| A8 | Setup done | A8 Setup done |

## Flow overview
```
First time:  A1 -> A2 -> A3 -> A4 -> A5 -> A6 -> A7 -> A8 -> B1
Every time:  B1 Home -> B2 Level select -> (Skill Lab L1..L5b, not in demo) -> Home Mission M0..M5 -> R -> B2/B1
Wardrobe:    B1 <-> B3
Fail path:   during M1..M5 -> F1 fire spreads -> F2 rewind -> back to the failed step
```
HUD on all Home Mission screens: step indicator "1 Find fire | 2 Shout | 3 Stay low & go | 4 Call 911",
a Pause button, and "Marbles (number)".

---

## A. First-time flow (demo: screens only, no real logic)

### A1 Splash
- Text: game title "SuperKid", "Start", "Ages 7-10 · English". Shows the teacher and "My character" placeholders.
- Behavior: Start goes to A2 on first launch, to B1 afterwards.

### A2 Parent sign-up
- Text: "Parent sign-up", "A parent needs to sign up.", fields Email / Password / Confirm password,
  checkbox "I am the parent or guardian", button "Create account".
- Behavior: No adult quiz. The child does not use this screen. Demo: any input continues.

### A3 Permissions
- Text: "Let's turn on two things". Card "Camera: To see your room and play with AR" [Allow].
  Card "Microphone: To hear your shout" [Allow].
- Behavior: Real iOS permission prompts for camera and microphone. A parent may help.
  If denied, the teacher explains why it is needed and how to turn it on in Settings.
  Without the microphone the shout step cannot run. Add `NSCameraUsageDescription` and
  `NSMicrophoneUsageDescription` to Info.plist.

### A4 Make your character
- Text: "Pick your character" (Character 1 to 4), "Name your character", field "Tap here and type a nickname", "Next".
- Behavior: Child picks one of four placeholder characters and types a nickname. The
  on-screen keyboard slides up when the name field is tapped. Save to local storage.
  Neither character looks like a person.

### A5 Meet the teacher
- Text: (T) "Hi, ___! From today, I'll teach you how to stay safe in dangerous situations." (___ is the nickname).
  Shows "Teacher" and "Your character" side by side, button "Let's go", speaker icon.
- Behavior: Teacher is fixed (not customizable). Line is spoken aloud.

### A6 Home scan (visual only in the demo)
- Text: top chip "Home scan · Living room". Right-hand checklist "Rooms to scan":
  Front door, Living room, Kitchen, Bathroom (states done / current / todo).
  (T) "Point the tablet at the room and walk slowly." Buttons "Start scan" / "Stop scan".
- Behavior (real product): camera fills the screen, buttons on top. One screen for child and
  grown-up. Per room: Start scan, Stop scan. Other rooms are skipped. Done once.
  Demo: show the screen; the scan is not actually performed (no LiDAR on the demo iPad).

### A7 Processing the scan (visual only)
- Text: "Building your home...", "This takes a little while". (T) "I'm building a model of your home. Almost there!"
- Behavior: Progress bar, auto-advances to A8. The child never marks the front door or a safe spot.

### A8 Setup done
- Text: "You're ready!", "Character / Permissions / Home scan" checkmarks, "Go to Home".
- Behavior: Goes to B1.

---

## B. Repeating loop hubs

### B1 Home and map select
- Text: "Hi, {nickname}!", buttons "Wardrobe", "Badges", settings icon. Shows "My character (with outfit)".
  "Your badges" row (badge slots). "Choose a map": card "Fire in the kitchen!" (Levels 1-3, playable),
  "Dad collapsed! · Coming soon", "A tornado is coming! · Coming soon". Button "Play". "Marbles (number)".
- Behavior: Play on the kitchen map goes to B2. Coming-soon maps are not tappable.

### B2 Level select (map path)
- Text: "Fire in the kitchen!", "Back", marbles. A board-game style path with levels 1, 2, 3 (2 and 3 locked),
  a badge slot for each level, "My character", button "Play Level 1".
- Behavior: A level unlocks when the previous one is cleared (all four steps done correctly once).
  Tapping a locked level: the teacher explains what to finish first.

### B3 Wardrobe and badge board
- Text: "Closet & badges", "Back to Home", marbles. Left: "My character (wearing outfit)" and the nickname.
  "Outfits - Buy with marbles - Owned": Hero cap 5, Scarf 8, Cape 8, Boots 10, Goggles 10, Backpack.
  "Badges - One per level cleared": Level 1, Level 2, Level 3, Map 2, Map 3.
- Behavior: Buying costs marbles; not enough marbles means the item stays locked and shows its price.
  Prices above are placeholders. Demo: static or very simple.

---

## L. Skill Lab (designed, NOT in the live demo)
HUD: "Skill Lab · Level 1 · Step N of 5", marbles. All teacher lines spoken.

- **L1 Fire signs (hidden-object game):** kitchen scene. "Find 3 fire signs" (only the count is shown, no list),
  generous countdown "Time left", "Found" tally. (T) "Good job! When a fire starts, smoke starts too.
  Breathing smoke is really dangerous." Step clear gives a marble.
- **L2 Never-do choices:** full-screen kitchen fire with four buttons on top: "Pour water on it", "Carry the pan outside",
  "Move away and get out", "Hide in a room". After a tap the teacher answers in a bubble, e.g.
  (T) "No! Never use water or flour on a cooking fire. It can make things worse." The game never shows how to put out a fire.
- **L3 Shout "Fire!" (hands-free):** "Shout 'FIRE!'", loudness meter "Loud enough", "Listening...", "No button. Just shout!"
  (T) "Louder! Like someone is in the next room." Judged by volume only.
- **L4 Stay low and go (arrow keys):** on-screen arrows. Hold down arrow to crouch, then right arrow to move.
  "Smoke stays up high", Life bar. "Standing up in smoke = Life goes down". (T) "Hold down to crouch, then press right to go. Walking upright hurts!"
- **L5a Call 911, teacher shows what to say:** (T) "This is 911. Call it when someone is in danger, after you are out. Tell them three things."
  1 "What is happening?" "There is a fire in my kitchen." 2 "Where are you?" "My address is ..." 3 "Who are you?" "My name is ..."
  "Stay on the phone. Don't hang up until the operator says so." Button "Try it".
- **L5b Call 911, the child tries it:** real-looking phone call screen: "Practice call · nothing is really dialed",
  "Emergency 911", "Connected · 00:12", "Operator: '911, what's your emergency?'", Mute / Keypad / Speaker / End.
  Margin puzzle "Say each thing aloud": What is happening? / Where are you? / Who are you? Each correct answer fits a puzzle piece.

---

## M. Home Mission (AR). THIS IS THE LIVE DEMO
Background is the live rear camera (ARView). HUD as described in the flow overview.

### M0 Safety check
- Text: "Quick safety check" with four ticks: "The floor is clear", "I have room to walk", "???", "???" (two conditions still to be decided), button "I'm ready".
  (T) "Let's check your space first." Camera view shows a play-zone outline on the floor.
- Behavior: Child confirms. Reminds that the fire is not real. Demo: a clear patch of classroom floor.

### M1 Alarm and find the fire (compass)
- Text: "ALARM! Find the fire", AR flame (virtual fire), glowing objects "Glass of water" and "Pan handle".
  (T) "Follow the compass to the fire!"
- Behavior: Alarm sound plays. A compass arrow points toward the fire. Pass: fire found from the safe zone.
  If the child hesitates too long, a teacher hint plays and the fire spreads one stage.

### M2 Shout "Fire!"
- Text: "Shout 'FIRE!'", loudness meter "Loud enough", mic indicator. AR flame stays in view.
  (T) "Tell everyone at home! Loud!"
- Behavior: Pass on loudness. Too quiet: the teacher asks again, louder; the fire waits.

### M3 Stay low and go (compass to the front door)
- Text: "Stay low!", "Front door" marker, glowing object "stay away", "Tablet height" gauge with a "Low zone",
  speaker line "Stay low... turn left... keep going", caption "Follow the arrow to the front door".
- Behavior: Virtual smoke fills the upper space. A compass arrow points to the front door. Pass: tablet height stays
  low and the child reaches the door area without going toward tempting objects. Standing up or going toward the fire
  makes the fire spread one stage; (T) "Stay low!"

### M4a Front door
- Text: "Tap the door", graphic front door (closed) at the center of the screen.
  (T) "You're at the front door! Tap it to open."
- Behavior: Tap opens the door and goes to M4b. The child never goes outside for real.

### M4b Door opened: outside
- Text: "You're outside!", graphic outside scene (door open). (T) "You made it out! Never go back in." Button "Next: call 911".

### M5 Call 911 (same call screen as L5b, over dimmed AR)
- Text and layout as L5b: "Practice call · nothing is really dialed", "Emergency 911", operator line, margin puzzle
  (What is happening / Where are you / Who are you). "Listening..." chip.
- Behavior: Simulated only, never a real call. Each spoken piece fits a puzzle piece. Pass: all pieces completed and
  the child stays on the line. If a piece is missed the operator repeats the question.

---

## F. Failure and result

### F1 Fire spreads
- Text: "You went toward the glowing pan" (reason line), spread tracker Kitchen / Hallway / Living room, AR fire grows.
  (T) "Oh no, the fire is growing!"
- Behavior: Triggers: hesitating too long, going toward the fire or a tempting object, skipping a step.
  Spread order: kitchen, hallway, living room. Calm tone, not scary. No one in the house is hurt.

### F2 Rewind
- Text: "Rewind", "Let's go back to that moment", hint "Try this: move away from the glowing glass of water.", button "Try again".
- Behavior: Shown at the last spread stage. Returns to the step where it went wrong (M1 to M5).

### R Result and rewards
- Text: "Level 1 clear!", "Your steps": Find the fire, Shout, Stay low and go, Call 911 (checked or to fix),
  "My character + Hero cap", "New!", reward icons (badge, outfit), buttons "Next level", "Wardrobe".
- Behavior: Marbles are earned for each correct step. Clearing a level (all four steps correct once) gives the level badge.
  The result screens are still being revised by the designer; the reward layout may change.

### R2 Level path after the result
- Text: "Fire in the kitchen!", "What happens next", level path 1-2-3 with badges, "Play Level 1".
- Behavior: Branches after a result: retry a failed step, unlock the next level, or finish the map (later maps "coming soon").
