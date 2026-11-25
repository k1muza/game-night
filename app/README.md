# Game Night — single-device Flutter mobile and web app

Four party games on **one phone**, passed around the room: 30-Second Sprint, Charades, Trivia Challenge and Forbidden Words. No accounts, rooms, pairing or backend. Installable, and playable offline once loaded.

The card decks are **candidate drafts** (see `../content/README.md`). The app is suitable for development and private playtesting, not release.

## Run it

```sh
cd app
flutter pub get
dart run tool/build_content.dart     # validate ../content and write assets/decks/*.json
flutter run -d chrome                # development

dart run tool/build_web.dart         # release build + offline service worker → build/web
```

`assets/decks/` is generated and git-ignored: `content/*/cards.jsonl` stays the single source of truth.

## Native builds

```sh
flutter run -d <android-device>
flutter build apk --release
flutter build appbundle --release
flutter build web --release --no-web-resources-cdn
```

Android and web builds regenerate and validate `assets/decks/` before compilation.
The Android application ID is `com.gamenight.app`; the iOS bundle identifier is
`com.gamenight.app`. No signing keys or passwords are committed.

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Web: `build/web`

For Android distribution, configure a production keystore in `android/key.properties`
and Gradle. iOS builds require macOS and Xcode with Apple signing configured.

## Tests

```sh
flutter test                         # unit + widget tests (fake clock, no real waiting)

dart run tool/build_web.dart         # browser tests run against the release build
cd e2e && npm ci && npx playwright install chromium
npx playwright test tests/gameplay.spec.ts      # journeys, refresh, resume, offline
npx playwright test tests/screenshots.spec.ts   # writes e2e/shots/<viewport>/*.png
```

| Suite | What it covers |
|---|---|
| `test/session_controller_test.dart` | Session creation, team config, rotation, rounds, every game's scoring, timer expiry at the exact deadline, no scoring after expiry, no duplicate scoring, pause/resume, Sprint marking and correction, Trivia answer randomisation, correct/wrong/timeout, equal difficulty per round, repetition prevention, exhaustion + explicit reshuffle, cross-session freshness, persistence and restore (between turns, mid-turn, after the deadline), winners and ties, early end |
| `test/app_flow_test.dart` | Home → setup defaults → handover hides the card → play; Time! splash, late-tap guard, wake lock; double-tap can't skip results or start the next clock; Resume/Discard; refresh mid-turn; Trivia reveal; paused overlay |
| `test/content_test.dart` | 2,300 cards match the manifest, IDs preserved, no editorial keys in runtime decks |
| `e2e/tests/gameplay.spec.ts` | Real Chromium, release build, Pixel-class viewport: full journeys for all four games, concealment during handover, refresh mid-turn (no time gained), refresh between turns + Resume, discard confirmation, **offline play after first load**, 360×640 layout |

## Architecture

```
lib/
  model/        GameKind (per-game rules/meta), cards + ContentLibrary (runtime adapters)
  session/      Session state (JSON-serialisable), SessionController (all rules),
                DeckPlanner (draw order, difficulty balance), SessionStore (localStorage)
  services/     Fx: Web Audio cues, vibration, screen wake lock (no-op off-web)
  theme/        Design tokens transcribed from design/design-system/tokens.json
  ui/widgets/   GnButton, chips, score strip, ring/bar timers, FitText, glyphs/shapes
  ui/screens/   home, setup, handover(+countdown), play_* per game, rapid (shared
                Charades/Forbidden layout), turn_results, final_results, sheets
tool/           build_content.dart (adapter + validator), build_web.dart (release + SW),
                icons/ (renders PWA icons from the in-app logo painter)
web_sw/         service-worker template
e2e/            Playwright tests + tiny static server
```

**One controller, plain Dart.** `SessionController` (a `ChangeNotifier`) owns every rule. Each method checks the current phase first, so invalid transitions and double scoring are impossible by construction; the UI only calls methods and renders state. No state-management framework.

**Lifecycle.** `ready → playing → turnResults → ready … → gameResults` (Setup is a screen before the session exists). A round ends when every team has played once; the game ends after `rounds × teams` turns, so every team gets the same number of turns.

**Timer.** The turn stores an absolute `deadlineMs`, never a counter. `remainingMs()` is computed from the clock; `tick()` settles expiry exactly once (it changes the phase). Every scoring action calls `tick()` first, so a tap that lands after the deadline is ignored even if no frame has run. Refresh and backgrounding can't add time; pause stores the remaining time explicitly. The clock is injectable, so tests advance a fake clock instead of waiting.

**Persistence.** The whole session (teams, scores, round, active team, current turn and its deadline, draw queues, used IDs, history) is saved to localStorage after every change. Restore settles an expired deadline before anything renders.

**Content.** `tool/build_content.dart` reads the canonical JSONL, checks it against `manifest.json` (counts, schema versions, gameType, unique IDs, Sprint 2/2/1 pattern, four distinct Trivia options, five Forbidden clues…) and emits slim decks with only playable fields. Editorial notes, mime hints, sample clues, source hints, verification and quality data never reach the browser.

**Card selection.**
- Sprint: the pre-balanced v2 cards are used as authored (2 easy, 2 medium, 1 hard term).
- Charades / Forbidden Words: a mixed deck interleaves difficulty buckets by weight (Charades 50/38/12 % easy/medium/hard, Forbidden 40/45/15 %), so hard cards are spread out, not clustered.
- Trivia: each round has a difficulty pattern every team receives — mixed default is easy-or-expert + 2 medium + 2 hard (easy warm-up on odd rounds, expert finale on even), with categories varied within a turn.
- Within a session no card repeats. Cards not yet seen on this device are dealt first across sessions. When a deck runs out the app says so and offers an explicit Reshuffle — it never repeats silently.

**Offline.** Flutter no longer generates a caching service worker (its `flutter_service_worker.js` now unregisters itself), so `tool/build_web.dart` writes `sw.js`: cache-first precache of the shell, code, fonts, icons and the four decks (4.3 MB), versioned by content hash. The engine is built with `--no-web-resources-cdn` (no CDN at runtime); the page tells the worker which CanvasKit variant it loaded so only that one is cached, instead of precaching every variant (20 MB). Fonts are bundled TTFs, so Flutter never fetches fallback fonts.

## Single-device decisions

| Topic | Decision |
|---|---|
| Hidden cards | Handover never builds the card. The clock starts only on the clue-giver's tap, after a 3-2-1 countdown. Pause covers the card with an opaque overlay. |
| Forbidden Words referee | The design's single-phone "over the shoulder" layout (FW10): an opposing player reaches the BUZZ strip at the top; the clue-giver's thumb has Pass / Got it at the bottom, far from it. |
| Mis-taps | Sprint terms toggle while the clock runs. Charades/Forbidden show a 4-second banner with Undo for the last action. After time runs out nothing can be scored; the Time! screen locks input for 0.9 s against late taps. |
| Trivia | Two-step select → Lock in (from the design) to prevent accidental answers by a crowd around one phone. Only a locked answer counts; at timeout the question is unanswered. No timer on the explanation; the next question's clock starts when it appears. |
| Players | No names or registration: "Pass the phone to your clue-giver". Team names are optional. |
| End game | Available from the menu with confirmation; standings are flagged "ended early" if teams had unequal turns. |
| Sprint skip | One "Skip this card" per turn, only before any term is ticked (so easy terms can't be banked across cards); clock keeps running; the skipped card is used up. Change `sprintSkipsPerTurn` for house rules. |
| Full screen | Toggle on Home and in the game menu (Fullscreen API; hidden where unsupported, e.g. iPhone Safari, where Add to Home Screen gives the same effect). The choice is remembered and re-applied on the next Start/Resume tap, since browsers drop full screen on reload. |

## Removed or deferred

Online multiplayer, WebSockets, rooms and room codes, QR joining, device pairing, host/client roles, referee and audience phones, hold-to-peek, cross-phone review approval, waiting lobbies, connection states, accounts, profiles and avatars, player names, cloud sessions, leaderboards, tournaments and cross-game scoring, share cards, speed bonuses and "worth double" finals, handicap dice, mime-hint ("Need an idea?") chips, AI/voice refereeing. No backend, database or auth was introduced. None of the design's multiplayer screens were built, so there is no dormant multiplayer code to maintain.

## Visual comparison with the design

Reference boards: `design/screens/*`, `design/design-system/DS-Gameplay.png`, `DS-Components.png`, `design/brand/*`. Screenshots: `docs/screenshots/`.

| Screen | Preserved | Changed, and why |
|---|---|---|
| Home (S03/S04) | Four tilted game cards with lip shadows, glyph tiles, game colours; wordmark with the spark over the i; Resume card with yellow border | Host/Join removed (single device); tagline added on each card (brief asked for a short description) |
| Setup (prototype Quick play, S06) | Game-colour hero with the game's motif, team rows with shape + colour, primary button in game colour with deep lip | Rounds stepper and collapsed "More options" (timer, difficulty, questions per turn) replace room/host settings |
| Handover (L01) + countdown (L03) | Tilted cream team card with the team's shape, "TEAM A'S TURN" eyebrow, score strip, game-colour CTA; cream 3-2-1 cards on the game's soft colour | Hold-to-reveal gate (L02) dropped: one "Start the clock" tap reveals; "Card stays hidden until you start" chip added |
| Sprint (SP2, L04, SP6) | 76 px cream term rows as the controls, ink checkbox, yellow fill + strike-through when guessed, ring timer, progress dots + n/5, amber warm-up in the last 5 s, "All five!" full-bleed | Dataset context labels shown under the term instead of a right-aligned chip (long terms like "Federation of Rhodesia and Nyasaland" need the width) |
| Charades (CH5–CH10) | Prompt card fills the screen with category · difficulty line, bar timer, got/skipped chips, oversized pads, card fly-out right on correct and deal-in | "Skip" labelled "Pass" (brief's terminology); "Need an idea?" mime hint omitted (brief: no editorial hints) |
| Trivia (TR3–TR8) | Shape + letter + text answer tiles (A▲ B◆ C● D■), cream "Selected", "Lock in ◆ Zambezi", green "✓ Answer", struck-through "✕ Your pick", "You got it!/So close!" titles, explanation card | Multi-team "waiting for teams", team pick summaries and speed bonus removed; "Time's up!" state added; difficulty pill shown in place of the per-question intro card |
| Forbidden (FW5, FW8, FW10) | Orange header "Get them to say" + target, cream "DON'T SAY" list with ✕ rows, red BUZZ strip at the top, Pass/Got it pads | Buzz feedback is a banner with Undo rather than a separate referee confirmation screen (FW9) |
| Time! / results / final (L05, L07, L10, L11) | Full-bleed red "Time!" with ink summary, "+4" with spark, standings with the leader in cream, "Up next", champions card with confetti in the four game colours | Review/approval step (L06) folded into results (cards list collapsed under "This turn's cards"); share card omitted |

Newly proposed (not in the boards): the paused overlay, the "deck empty" states, the 360 px adaptations, and the PWA splash (built from S01).

## Known limitations

- Content is candidate data: Trivia is recorded as `plausible-unverified`; nothing is editorially approved. Use for private playtests only.
- Answers live in the browser (localStorage and the cached decks). Concealment is visual only; a determined player can read them.
- iOS Safari has no vibration API, and wake lock needs iOS 16.4+. Sounds need a first tap (handled by Start).
- The browser Back button on Android leaves the app (the session is saved and offered for Resume). Flutter's default single-page navigation doesn't map browser history.
- First load downloads the rendering engine (CanvasKit: 5.7 MB on Chromium browsers, 7.2 MB elsewhere, before compression) on top of the 4.3 MB precache. On slow connections, open the app once on Wi-Fi before the party.
- Offline was verified in Chromium; Safari/Firefox installation and offline behaviour have not been tested on devices.
- The UI is English only (Shona/Ndebele strings were an open item in the design review).
- No real-world playtest has been run; difficulty mixes and timer lengths are editorial defaults.

## Review and verification log

- **Automated:** 52 Flutter unit/widget tests; 9 Playwright journeys plus a 24-screen capture at 390×844 and 360×740, run in headless Chromium against the release build.
- **Independent review:** one adversarial reviewer agent read the code, design boards and screenshots without seeing my conclusions. It scored the build ~82.5/100 and found no score-corrupting bug. It raised two major flow issues (double-taps carrying over between screens; a late Lock in tap skipping the Trivia reveal) and four robustness issues (dead Pause button on the Trivia reveal, crash on saved sessions with removed card IDs, a race in engine caching for offline, Trivia explanation off-screen at 360 px). All six were fixed, with regression tests where testable. Minor fixes followed: strict lock-in, accurate "ended early" text, Undo moved away from the Got it pad, the wake-lock race, the ticker idling while paused, duplicate team names, validation before writing decks, and dead code.
- **Not re-scored** after the fixes. A second review cycle and real-device playtests (Android Chrome, iOS Safari, a group of players) are the recommended next steps.
- **Still open:** text scale is capped at 1.3× to protect card layouts (below WCAG 1.4.4's 200%); pausing during Trivia gives a team unlimited discussion time (honour system).
