# Local Referee Mode — Implementation and Validation Report

## Status

Implemented on `feature/local-referee-mode`, based on `dc89423`. The host remains
the only gameplay authority. Automated tests and Android/web release builds
pass. The feature is **not merge-ready** until two-device LAN and iOS validation
are completed. No merge or pull request was created.

## Delivered

- Classic remains the default. Sprint and Tabuu support Referee setup; Home
  provides **Join as Referee**.
- The native service hosts a WebSocket on a selected private Wi-Fi IPv4 address
  and dynamic port. Pairing supports a QR token and manual address/port/one-time
  code. The web target uses an unsupported networking stub.
- Pairing uses a four-hour temporary credential, challenge-response HMAC
  authentication and signed messages. The server limits failed pairing
  attempts, allows one authenticated referee, and sends no gameplay snapshot
  before authentication.
- `SessionController` remains authoritative for session persistence, cards,
  scores, deadlines and progression. Actions carry session, turn, card-instance,
  state-version and message identities; the host checks permissions, stale
  state and deadlines before mutation. Processed action IDs are retained for the
  pairing session, with a bounded action capacity.
- Tabuu synchronises the active target and five forbidden words. The referee
  BUZZ is remote; the host retains Pass/Got It. Sprint supports referee Correct,
  Disqualify and reversal. Both games use host-confirmed turn review.
- Disconnect and background handling pause a live host turn. Reconnection
  restores host state without queuing new client actions. The host can re-pair
  or switch safely to Classic while preserving progress. A process restart
  invalidates the ephemeral credentials and restores the session in Classic.
- Screenshots of Home, Referee setup and manual joining are in
  [`docs/screenshots/`](screenshots/). They contain no live pairing credentials.
  Active referee-game screens could not be captured without a second device.

## Validation

| Check | Result |
|---|---|
| Focused Referee/controller tests | **Pass**, including manual/QR pairing, invalid credentials, duplicate and stale BUZZ, rapid Sprint actions, deadline boundary, reconnect, new-session projection reset, Classic fallback, readiness gates and restored-turn pause. |
| Full `flutter test` | **Pass**, 75 tests; includes all four Classic game regressions and the 2,300-card content integrity check. |
| `flutter analyze` | No errors. Command exits non-zero because of 18 info-level lint findings (style/null-aware collection suggestions); the analyzer reports no warnings or errors. |
| Android release | **Pass** using Android Studio JDK 21. APK: `app/build/app/outputs/flutter-apk/app-release.apk` (69,193,614 bytes), compile/target SDK 36. |
| Web release | **Pass** with `flutter build web --release --no-web-resources-cdn`. Flutter emitted non-fatal Wasm dry-run and Cupertino icon-font notices. |
| Device smoke check | Debug app launched on one Pixel 7 Pro (Android 17/API 37). Host resolved a private Wi-Fi address, opened the pairing screen, and the Classic fallback control returned to handover. This did not verify a second device or an actual remote connection. |
| Content preservation | Content build hook validated Sprint 400, Charades 600, Trivia 800 and Tabuu 500 cards. Canonical cards and generation tooling were not modified. |
| iOS | Not built: this environment is Windows and has no macOS/Xcode toolchain. iOS local-network and camera usage descriptions are present in `Info.plist`. |
| Device/network matrix | Two-phone Wi-Fi/hotspot, Android↔iOS, no-internet operation, camera-denial handling, background recovery and screen-lock behavior remain unverified. Only one Android device was available. |

`flutter analyze` findings are info-level, not compile/type errors. Flutter's
web build also printed its usual Wasm dry-run and icon-font notices; the build
completed successfully.

## Architecture and dependency decisions

- A conditional native `dart:io` WebSocket service preserves the web build.
  `connectivity_plus` is used for Wi-Fi/VPN connectivity state; the local IP is
  selected from private Wi-Fi interfaces. `network_info_plus` was not adopted
  because its platform APIs can require extra location permissions. Bonjour
  discovery was deferred; QR and manual pairing cover the v1 flow without
  extra platform setup.
- No separate remote game engine, cloud service, accounts, Bluetooth, or
  internet multiplayer were introduced. Charades, Trivia and audience displays
  remain out of scope.
- WebSockets are **authenticated and integrity-protected, not encrypted**.
  Pair only on a trusted local network. Android permits cleartext transport for
  the app because the local WebSocket uses `ws://`; the application validates
  private IPv4 pairing addresses and does not use this transport for internet
  play.
- The tested Android build targets API 36. Android 17/API 37
  [requires](https://developer.android.com/about/versions/17/behavior-changes-17#local-network-permission-required-for-apps-targeting-android-17) the new
  `ACCESS_LOCAL_NETWORK` runtime permission for apps that target API 37 or
  higher; that future target-SDK migration and prompt flow are not implemented
  or exercised here.
- The Android Gradle Plugin is 8.12.1 and the wrapper is 8.14. iOS configuration
  is present, but no iOS build or runtime compatibility is claimed.

## Manual verification checklist

1. Pair two Android devices on shared Wi-Fi, then a mobile hotspot; repeat with
   QR and manual details, with internet disabled.
2. Verify matching Sprint terms/context, timer and term state; test Correct,
   Disqualify, reversal, timeout review and host score confirmation.
3. Verify matching Tabuu target/clues; test BUZZ, host Pass/Got It, delayed and
   duplicate BUZZ, and turn review.
4. Disconnect/reconnect Wi-Fi during scoring, background and lock each phone,
   and confirm pause, recovery, score integrity and Classic fallback.
5. Deny camera permission and verify manual pairing remains available. Build
   and repeat the matrix on iOS using macOS/Xcode.
6. Before raising Android target SDK to 37, implement and test the
   `ACCESS_LOCAL_NETWORK` runtime permission flow on Android 17.

## Recommendation

**Hold merge** pending the two-device Wi-Fi/hotspot matrix, disconnection and
recovery checks, and iOS validation. The feature branch has automated and build
coverage, but those do not establish physical-device interoperability.
