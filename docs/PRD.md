# Project 2 PRD — Practice-Based Emergency Game for Kids

Version 2.8 · Nov 19, 2026 · @Su Young
Main use case: kitchen fire

## Decisions so far

- **Audience:** children aged 7–10. English only.
- **Device:** tablet (iPad).
- **Structure:** two stages. A character-led **Skill Lab** on screen, then an AR **Home Mission** where the child acts it out. (Stage names are working names.)
- **Two characters.** The **teacher** guides the child through everything and is not customizable. The child's own **character** (the avatar) is the one the child picks, names and dresses up. Neither looks like a person. On screen we simply say "character".
- **Voice:** every teacher line is shown in a speech bubble and also spoken aloud.
- **Main use case:** kitchen fire, with three levels: stove pan fire, microwave fire, oven fire. Maps are story situations: "Fire in the kitchen!" (playable), "Dad collapsed!" and "A tornado is coming!" (coming soon).
- **Fire approach:** escape first, for small fires too. The child learns to get away and call for help, and learns a short list of things never to do. The child is never taught any way to fight or put out a fire, including actions that are fine for adults.
- **Core flow:** find the fire → shout to alert others → stay low and go → call 911 from a safe place.
- **Moving low:** the child stays low and moves, and may carry the tablet in one hand. In Skill Lab the child practices this with on-screen arrow keys. The game checks how low using the tablet's height and, where the iPad supports it, the child's head height from the front camera.
- **Failure:** the fire spreads through the house, then the teacher rewinds to the moment to try again.
- **Rewards:** every step done correctly earns **marbles**. Marbles buy outfits for the child's character. Clearing a level earns a **badge**.
- **911:** always a simulated phone call inside the game. No real call is ever placed.
- **First-time setup, once only:** a parent signs up and, at the same time, approves the camera and microphone permissions (the screen only says a parent must sign up, with no adult quiz); the child then makes a character and meets the teacher; the route areas of the home are scanned once and never again: the front door, living room, kitchen and bathroom. Other rooms, such as bedrooms, are not scanned. One scan screen serves both child and grown-up; the game then processes the scan.
- **After setup:** a repeating loop of map, level, Skill Lab, Home Mission and rewards. Gameplay is always one child.
- **Removed:** surprise drills, and checking whether a door is hot (not needed for a kitchen fire).

## Overview

**We are designing a tablet game that helps children aged 7–10 turn emergency safety from something they know into something they can actually do.** The game has two stages. In **Skill Lab**, a character teacher and simple games teach the key skills. In **Home Mission**, the child uses the tablet camera (AR) and rehearses the same skills with their own body, in their own home.

The first topic we build end to end is a **kitchen fire**, played across three levels. Each level gets a little harder and must be cleared to unlock the next. As they play, the child earns marbles for every step done right, spends them on outfits for their own character, and collects a badge for each level cleared.

*One line: A game that rehearses emergencies in your own home, so that when one happens, your body already knows what to do.*

## Problem

**Children often know what to do in an emergency but don't do it when the moment comes.** That gap matters more as more children spend time at home without a parent.

- **More time without a parent.** In most families with children, both parents work. After-school programs don't reach every child, so many spend part of the day with a sibling, a grandparent or no adult at all.
- **Knowing is not doing.** A child can say "call 911" or "get out and stay out", yet freeze, skip a step or get the order wrong when it is real.
- **Today's teaching stops at knowledge.** School visits, videos and worksheets explain the rules. Watching someone else do it does little to change what a child does.
- **Families rarely practice.** Many households have an emergency plan; far fewer have ever practiced it.

**The opportunity:** give children the missing piece, which is repeated practice in the space where they would need it, with feedback, without depending on a parent to run it.

## Who it's for

**Children aged 7–10, ideally before they are ever left alone.** The game prepares them in advance.

- **Player.** One child plays at a time. An adult may or may not be nearby.
- **Parent.** A parent creates the account, once, and approves the camera and microphone permissions at the same time. The parent may also help with the home scan, but the child can do it alone.
- **Device and place.** A tablet used at home, mostly in the after-school hours.
- **Language.** English only. The teacher speaks every instruction, and on-screen text is kept short.
- **Parents in gameplay.** Parents are not part of the gameplay loop.

## Goal and design principles

**Our goal is behavior, not knowledge: the child performs every step correctly in a realistic moment.**

1. **Practice, not watching.** Every skill ends with the child doing it.
2. **Learn on screen, act with the body.** Skill Lab can use taps and drags for knowledge and decisions. In Home Mission, the safety actions are never taps.
3. **In the child's own home.** AR uses the real home and the real route to the front door. The child never actually leaves the house: the way out is a graphic door.
4. **The same move as in real life.** Look for the fire, say "Fire!" out loud, stay low and move, speak to the 911 operator.
5. **The child moves, the character guides.** The teacher shows and encourages; it never does the action for the child.
6. **Escape first, never fight the fire.** Small or large, the child's job is to get away and get help.
7. **Voice first.** Every teacher line is spoken and also shown in a speech bubble. The child can follow the whole mission by sound if they are not looking at the screen.
8. **Feedback on every attempt.** The child always knows which steps were right and what to fix. A mistake makes the fire spread, and the teacher rewinds to try again.
9. **Confidence, not fear.** Calm, encouraging tone. Stylized visuals, no harm shown to people or pets.
10. **Safe by design.** The fire is always virtual. The child is never asked to go near the real stove. The 911 call is always simulated. Rewards are never given for speed alone or for going near the fire.

## Characters

- **The teacher.** Cute and clean in look, friendly and educational in tone. Short spoken sentences, encouraging, never scary, never blames. Guides onboarding, Skill Lab and Home Mission. Not customizable.
- **The player's character.** Picked and named by the child at first launch. The child buys outfits for it with marbles and collects badges on it. It appears on the home screen and on the result screen.

Names and looks are still to be decided.

## Core experience: two stages

| | Stage 1 · Skill Lab (working name) | Stage 2 · Home Mission (working name) |
|---|---|---|
| **Purpose** | Learn the key skills and facts through play | Rehearse them for real with the whole body |
| **Format** | Graphics and character-based game on the tablet screen | AR: the child points the tablet camera at their real space and acts |
| **Child does** | Taps, drags, chooses, uses arrow keys, shouts and speaks with the teacher | Looks, shouts, stays low and moves, speaks the 911 call |
| **Teacher** | Explains, demonstrates, reacts to choices | Coaches by voice, gives feedback after each step |
| **Ends when** | The child has completed the level's mini-games | Every step of the flow is done correctly |

Stage names are still open. Options: Stage 1 "Skill Lab", "Training Camp", "Hero School"; Stage 2 "Home Mission", "Try It for Real", "Real Run".

A level is cleared when the child finishes both stages for it. Skill Lab always comes before Home Mission for a level.

## Main use case: kitchen fire

**The situation:** a fire starts at the stove or a kitchen appliance, often around dinner time when cooking fires peak. The child is at home. The game uses the same four-step flow at every level.

| Step | Skill Lab: what the child learns | Home Mission: what the child does for real | How the game checks |
|---|---|---|---|
| **1. Find the fire** | A hidden-object game: the screen says how many fire signs to find (flames, smoke, alarm), with no list and a generous countdown. Each find is explained by the teacher, for example: when a fire starts, smoke starts too, and breathing smoke is very dangerous. | The alarm sounds and a compass arrow points toward the fire. The child follows it with the tablet until the virtual fire is found. Never has to get close to the real stove. | Camera aim reaches the fire; the child stays in the safe zone |
| **2. Shout to alert** | Why shouting "Fire!" matters: it warns anyone else at home. The child just shouts; there is no mic button, the tablet listens by itself. | Says "Fire!" loudly and clearly. | Microphone loudness |
| **3. Stay low and go** | Practice with on-screen arrow keys: hold down to crouch, press right to move. Walking upright in the smoke drains the Life bar. Never go back in. | Virtual smoke fills the upper space. The child stays low and moves along the route to the front door, with voice guidance throughout. The child may carry the tablet in one hand. | Tablet height and, where supported, head height stay low while moving along the route to the front door |
| **4. Call 911 from a safe place** | The teacher first explains what 911 is, that you call after you are out, and what to say. This is one screen. A second screen then shows a real-looking phone call in progress, and the child says each piece aloud; each answer fits a puzzle piece in the margin: what is happening, where you are (address), who you are. Don't hang up until told to. | At the front door a graphic door appears. The child taps it, it opens to an "outside" scene (the child never goes outside for real), and the child makes the simulated call on a real-looking phone call screen, with the same puzzle in the margin. | Correct number, address spoken, situation stated, call not ended early |

### Never-do list (taught in Skill Lab)

The fire graphic fills the screen with the choice buttons on top. After each choice the teacher answers in a speech bubble (spoken too). Children see two groups of choices and the result of each:

- **Never do, makes it worse:** pour water or flour on a cooking fire; move or carry a burning pan; open the microwave or oven door; go back inside; stop to grab things or make a call while escaping; hide.
- **Best choice:** move away, get out, call 911 from outside.

The game does not show or teach any way for a child to put the fire out. The "never do" actions are only shown and chosen on screen. The child never practices them for real, and the consequences are shown calmly and briefly.

### Levels

Each level has a different fire, and the fire decides which wrong action is most tempting. The right answer is always the same four steps.

| Level | Fire | Tempting wrong action | What is new |
|---|---|---|---|
| **1** | Pan fire on the stove | Pour water on it, move the pan | A clear route and light smoke |
| **2** | Microwave fire | Open the door to look | Smoke starts to fill the room |
| **3** | Oven fire | Open the door | Heavy smoke, so the child must stay low for the whole route |

In Home Mission, tempting objects glow in the scene (a glass of water, the pan handle, the appliance door). The child earns credit by not going toward them and by moving away instead. A level is cleared when all four steps are done correctly once. The next level then unlocks.

### When the child gets it wrong: the fire spreads

- Hesitating too long, going toward the fire or a tempting object, or skipping a step makes the fire spread: kitchen, then hallway, then living room.
- When the spread reaches the last stage, the teacher says "Let's go back to that moment" and rewinds to the step where it went wrong.
- Spread is a consequence, never a punishment. No one in the house is hurt, and the teacher never blames the child.
- Speed matters only a little. The game must never reward skipping steps to go faster.

### Rewards

All rewards go to the child's own character.

- **Marbles.** The currency. Earned each time a step is done correctly (find the fire, shout, stay low and go, call 911), in Skill Lab and in Home Mission. Marble amounts per step are still to be set.
- **Outfits.** Bought with marbles in the wardrobe and worn by the character. The wireframes use placeholder prices of about 5 to 10 marbles (hero cap, scarf, cape, boots, goggles, backpack).
- **Level badges.** Collectible, in the spirit of scout badges. Clearing a level (all four steps done correctly once) earns that level's badge. The badge board also has slots for the later maps. Badge names and art are placeholders.
- **No** leaderboards, no points for speed, and no reward for going near the fire.

## System flow (draft for wireframing)

The flow has two parts: a **first-time flow** that happens once, and a **repeating loop** that the child returns to every time.

### A. First-time flow (once)

| # | Step | Who | What happens | Saved | If something goes wrong |
|---|---|---|---|---|---|
| A1 | Download and open | Adult or child | Splash screen | none | none |
| A2 | Parent sign-up | **Parent only** | The screen says a parent needs to sign up; the parent creates the account. No adult quiz | Account | Sign-up abandoned: the game stays on this screen |
| A3 | Permissions | Parent, right after sign-up | Camera and microphone requests, each with a short spoken reason. The parent approves them at sign-up time, so the child is never stopped by a system prompt | Permission status | Denied: the teacher explains why it is needed and how to turn it on. Without the microphone the shout step cannot run |
| A4 | Make the character | Child | Pick a character and type a nickname (the keyboard slides up when the name field is tapped) | Character, nickname | none |
| A5 | Meet the teacher | Child | The teacher greets the child by nickname and says the whole game in one line, for example: "Hi, ___! From today, I'll teach you how to stay safe in dangerous situations." | none | none |
| A6 | Home scan | Child, with a grown-up if they like (same screen) | The camera fills the screen with buttons on top. A checklist shows the front door, living room, kitchen and bathroom; in each room the child taps Start scan and Stop scan. Other rooms are skipped. Done once | Home scan | Scan fails or is incomplete: resume from the last room. Too dark: the teacher asks to turn on lights. Child stops partway: progress is kept |
| A7 | Processing the scan | System | A wait screen ("Building your home…") while the game turns the scan into a home model and works out the route from the kitchen to the front door. The child does not mark the front door or a safe spot | Home model, route | Processing fails: the teacher asks to scan the room again |
| A8 | Ready | Child | The teacher says setup is done and shows the home screen | Setup complete | none |

The scan is never repeated. Later maps can add the areas they need when they are built.

### B. Repeating loop

| # | Step | What happens | Saved | If something goes wrong |
|---|---|---|---|---|
| B1 | Home | The child sees the maps ("Fire in the kitchen!" playable; "Dad collapsed!" and "A tornado is coming!" coming soon), the character, marbles, the wardrobe and the badge board | Progress | none |
| B2 | Level select | Levels shown as a path on a map, game-board style, 1 to 3, with locks and a badge slot for each level | Progress | Locked level: the teacher explains what to finish first |
| B3 | Wardrobe and badge board | Reached from Home. The child spends marbles on outfits and sees the badge board: one slot per level, plus slots for later maps | Outfits owned, marbles | Not enough marbles: the item shows its price and stays locked |
| B4 | Skill Lab | The four steps as mini-games (hidden-object game, never-do choices, hands-free shout, arrow-key practice, 911 in two screens: teacher shows what to say, then the child tries on a call screen) | Skill Lab progress | Quit midway: resume where the child left off |
| B5 | Home Mission | The four steps in AR (state flow below) | Step results | Space not safe: do not start. Permission turned off: the teacher explains. Fire spreads to the last stage: rewind |
| B6 | Result and rewards | Steps done and steps to fix, marbles earned, and the level badge | Rewards | none |
| B7 | Next | Retry the failed step, or unlock the next level. After level 3, the kitchen fire map is complete and later maps show as coming soon | Progress | none |

### C. Home Mission state flow

| State | System does | Child does | Pass condition | If not passed |
|---|---|---|---|---|
| 0. Safety check | Shows a short checklist: the floor is clear, there is room to walk, plus two more checks (to be decided). Reminds that the fire is not real | Confirms ready | Child confirms | Teacher explains again |
| 1. Alarm and find | Plays alarm; places the virtual fire (in the demo, on a desk); shows a compass arrow toward the fire | Follows the compass and sweeps the tablet to find the fire | Fire found from the safe zone | Teacher hint on where to look; fire spreads one stage if the child hesitates too long |
| 2. Shout | Prompts the child to alert others | Says "Fire!" | Loud enough | Teacher asks again, louder |
| 3. Stay low and go | Adds virtual smoke; shows and speaks the route to the front door, with a compass arrow pointing to it; shows tempting objects | Stays low, moves along the route | Tablet and head height stay low; reaches the front door; does not go toward tempting objects | Teacher says "stay low"; fire spreads one stage if the child stands up or goes toward the fire |
| 4. Out the door | Two screens: the front door at the center, then the "outside" scene after the door is tapped open. The child does not leave the house | Taps the door, stays put | Door tapped; does not go back toward the fire | Teacher reminds: never go back |
| 5. Call 911 | A real-looking phone call screen where the operator speaks; a puzzle in the margin of what is happening, where and who | Says each piece aloud; each correct answer fits a puzzle piece | All pieces completed; stays on the line | Operator repeats the question; retry |
| 6. Result | Shows steps done and steps to fix; gives marbles and the level badge | Retry or continue | All steps correct | Retry the failed step |

If the fire reaches the last spread stage at any point, the game rewinds to the step where it went wrong.

### D. Sensors and what they check (to validate in prototype)

- Home scan: the front door, living room, kitchen and bathroom, used to place the fire and work out the route from the kitchen to the front door.
- Rear camera and AR tracking: where the child is, tablet height (low or not), route progress. The tablet height is measured against the height recorded at the start of the mission, so it works for children of different sizes.
- Front camera (on iPads that support it): the child's head height relative to the tablet, combined with the tablet's position, to tell whether the child is really low and not just holding the tablet low.
- Microphone: how loud the child shouted. Judged by volume, not by recognizing words. It listens by itself, with no button to press.
- Simulated phone: screen only; no real call is ever placed.
- Audio: every cue is spoken so the child does not need to look at the screen.

### E. Screens to wireframe

*First-time flow*
1. Splash
2. Parent sign-up
3. Permissions (camera, microphone), approved by the parent
4. Make the character (character, nickname)
5. Meet the teacher
6. Home scan (one screen for child and grown-up)
7. Processing the scan
8. Setup done

*Repeating loop*
9. Home and map select
10. Level select (map path)
11. Wardrobe (outfits bought with marbles) and badge board
12. Skill Lab: one screen set per step (fire signs hidden-object game, never-do choices, hands-free shout, arrow-key practice, 911 puzzle)
13. Home Mission: safety check, find fire (compass), shout, stay low and go (compass), front door, outside (door opened), 911 call screen with puzzle
14. Fire spreads and rewind
15. Result and rewards, then the level path (what happens next)

### F. School demo scope (week of Dec 8)

The demo shows the AR Home Mission and the screens connected to it:

- First-time flow shown as screens: parent sign-up, character, teacher intro, scan and processing (the home scan itself is not performed live)
- Home and level select
- Level 1 in AR: a virtual fire appears on a desk in the room; the child finds it, shouts, stays low and moves along the route to the front door with voice guidance, taps the graphic door, and makes the simulated 911 call
- The fire-spread failure and rewind
- The result screen with marbles earned and the level badge
- Levels 2 and 3 shown as variations (different fire, tempting object and smoke)

Skill Lab is designed in the wireframes but is not part of the live demo: only the AR Home Mission is demonstrated. This may change after we check how hard it is to build.

## MVP scope and success measures

**The MVP is the kitchen fire topic, levels 1–3, across both stages.**

**In the MVP**

- The first-time flow, including parent sign-up, the character and the home scan (front door, living room, kitchen, bathroom)
- Skill Lab and Home Mission for the four steps at each of the three levels
- Fire-spread failure and rewind
- Marbles, outfits bought with marbles, and level badges

**Not in the MVP:** other topics and levels, parent-facing features beyond sign-up, re-scanning, any unannounced drills, and leaderboards.

**How we will know it works.** Two layers.

*Measured inside the game:*
- Share of children who finish the first-time flow, including the scan
- First-try success rate for each of the four steps
- Number of retries per step
- Level completion rate
- Where children stop playing
- Which fire-spread stage they reach

*Measured in tests with children, run by us (not part of the game):*
- A before-and-after mock emergency, with each of the four steps scored done or not done, in order
- Main measure: the share of steps done correctly after playing compared with before
- Also observed: time from the alarm to the front door, whether the child wants to play again, and whether the game can correct a mistake with no person stepping in

## Open questions and next steps

- [ ] **Home scan.** The biggest technical risk. Which iPads can do it, how long it takes for the front door, living room, kitchen and bathroom, how reliably a 7–10 year old can do it alone, and whether the scan stays accurate on later days. Also whether the game can work out a usable route from the kitchen to the front door from the scan alone.
- [ ] **Names and looks.** Final names for the two stages, the teacher, the characters, the maps and the badges.
- [ ] **Measuring "low".** Test how reliably the tablet and front camera tell a low body from a standing child holding the tablet low, with the tablet in one hand, and on the iPad model we will demo.
- [ ] **Shouting "Fire!".** We have not found an official source that backs shouting as a step for children. It helps only if someone else is at home. Keep it, but word it as alerting anyone at home.
- [ ] **AR safety and voice guidance.** A child moving while looking at a tablet. Define the safe zone, the play-space check and trip hazards, including the classroom floor for the demo. Test that the child can follow the mission by sound alone.
- [ ] **Marbles.** How many marbles each step earns, whether the placeholder outfit prices (5 to 10) fit that, and what to do about a child who replays one step only to farm marbles.
- [ ] **Safety check.** Two more conditions for the Home Mission start screen (not decided yet).
- [ ] **Graphic door.** Check that tapping a graphic door at the front door is a believable stand-in for leaving the house, so children still learn "get out and stay out".
- [ ] **Stay-low practice.** How fast Life drains when the child walks upright in Skill Lab, so it teaches without frustrating.
- [ ] **Fire-spread visuals.** Check with testing that the spread feels motivating and not scary.
- [ ] **Safe testing.** How to run before-and-after tests with children responsibly, including consent and what happens if a child gets upset.

**Next steps:** review the first-time flow and the loop with the team, then revise the wireframes in Figma and fix the result screens. The final presentation is the week of Dec 8 (no later than Dec 11); there is no class on Nov 26 and the last class is Dec 3.
