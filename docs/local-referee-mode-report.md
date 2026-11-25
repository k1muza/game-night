# Local Referee Mode — Implementation and Validation Report

## Status

Implemented on `feature/local-referee-mode`, based on `main` commit `1173dc5`.
Automated tests and Android/web release builds pass. The implementation is **not
recommended for merge yet**: real two-phone LAN play and iOS still need physical
verification.

## Delivered

- Classic remains the default. Sprint and Tabuu setup can opt into Referee Mode;
  Home has a Join as Referee entry.
- The host creates a temporary local IPv4 WebSocket session. Pairing is available
  as a QR code or manual connection details. A random temporary token protects
  the pairing, and only one referee is accepted for a session.
- A platform-conditional `dart:io` host/client implements snapshots, authenticated
  actions, acknowledgements, duplicate-action handling, stale turn/card checks,
  heartbeats, reconnect attempts, and connection status. Web uses an unsupported
  stub and retains Classic play.
- `SessionController` remains the only gameplay engine and source of truth.
  Versioned session state, turn IDs, card-instance IDs, Sprint term decisions,
  Tabuu events, and review state persist with the session.
- Sprint referees can mark correct terms, disqualify terms, and request/review
  corrections. Tabuu referees receive the active target and all five forbidden
  clues and can BUZZ. The host retains Tabuu Pass/Got It controls. Referee-mode
  scores are held for host confirmation.
- Disconnecting pauses a live host turn. Reconnection receives the current host
  snapshot; the host can resume or switch safely to Classic while preserving
  progress. A process restart loses the temporary token and restores the session
  in Classic Mode.
- Android network/camera permissions and iOS local-network/camera explanations
  are configured. Android's app-wide cleartext allowance supports the local
  `ws://` transport; the app's referee transport connects only to the local
  network. iOS allows ATS local-network traffic without enabling arbitrary
  insecure internet connections.

The canonical card library and content-generation tooling were not modified.
The content test still validates all 2,300 cards against the manifest.

## Automated validation

| Check | Result |
|---|---|
| `flutter test` | **Pass**, 69 tests. Includes all four games' Classic controller/UI regression coverage, referee-screen initialization, and content integrity. |
| Local referee WebSocket tests | **Pass**: valid/invalid authentication, no snapshot on invalid credentials, Tabuu snapshot and duplicate BUZZ, stale BUZZ after the host advances a card, disconnect/reconnect snapshot recovery, Sprint correct/disqualified actions, acceptance at 29,999 ms, rejection at the 30,000 ms deadline, correction and held-score confirmation. |
| `flutter build web --release --no-web-resources-cdn` | **Pass**. Non-fatal Flutter icon-font and Wasm dry-run notices remain. |
| Android release build | **Pass** using Android Studio JDK 21 and Gradle `assembleRelease`. APK: `app/build/app/outputs/flutter-apk/app-release.apk` (69,416,986 bytes). |
| Platform XML | **Pass**: Android manifest and iOS property list parse successfully. |
| `git diff --check` | **Pass**. |
| `flutter analyze` | No errors; exits non-zero because of 13 existing info-level `curly_braces_in_flow_control_structures` findings in unchanged code. |

Flutter Doctor reports missing Android command-line tools and unknown Android
license status in this environment, although the configured SDK and installed
Gradle toolchain completed the release build.

The APK installed successfully on the single attached Pixel 7 Pro. Interactive
UI validation was not completed: the phone remained on an unrelated foreground
screen. A screen capture returned that unrelated screen, so it was discarded;
no screenshot is included. This avoids presenting a misleading image or retaining
personal screen content.

## Architecture notes and deviations

- `SessionController` was extended rather than creating a second remote game
  engine. Referee commands carry session, turn, card-instance, state-version,
  and message identities; the host validates them before applying any mutation.
- The protocol is intentionally limited to Sprint and Tabuu, but snapshots and
  action envelopes are game-neutral enough to extend later. Charades, Trivia,
  and audience displays are not implemented.
- LAN WebSockets are unencrypted. Pair only on a trusted in-person network.
  No internet service, Bluetooth, account, or cloud dependency was added.
- Background process survival and network-change behavior depend on mobile OS
  lifecycle/network scheduling and need device testing. The UI explicitly pauses
  the host during backgrounding/disconnection.
- No iOS build was possible: this work ran on Windows, and iOS builds require
  macOS and Xcode.

## Manual verification checklist

1. Use two Android phones on the same Wi-Fi and then a mobile hotspot. Host one
   Sprint and one Tabuu game; pair once by QR and once by manual details.
2. Verify matching Sprint terms, context labels, timer and term state; test
   Correct, Disqualify, reversal, timeout review and host score confirmation.
3. Verify matching Tabuu target and five clues; test BUZZ, host Pass/Got It,
   duplicate/delayed BUZZ after card advancement, and turn review.
4. Disconnect/reconnect Wi-Fi during scoring, background and lock each phone,
   and confirm pause, recovery, score integrity, and Classic fallback.
5. Deny camera permission and verify manual pairing remains usable. Repeat on
   iOS after building on macOS/Xcode, including local-network permission prompts.

## Merge recommendation

**Hold merge pending the manual checklist**, especially two-device Wi-Fi/hotspot
testing and iOS validation. The branch has passing automated coverage and
release builds, but those do not establish device-to-device compatibility or
background/recovery behavior. No merge to `main` was performed.
