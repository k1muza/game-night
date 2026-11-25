# Native Flutter Migration Report

## Implemented

- Android native project configured for `com.gamenight.app`.
- iOS project generated with `com.gamenight.app` bundle identifier.
- Native audio cues bundled for Android and iOS through `audioplayers`.
- Independent sound and haptic preferences.
- Native wake-lock integration through `wakelock_plus`.
- Application lifecycle observer recalculates deadlines and persists state.
- Edge-to-edge system UI and branded Android launch screen.
- Branded Android and iOS app icon assets.
- Canonical content fingerprints, runtime fingerprints and diagnostics.
- Compatible saved-session fingerprint checks.
- Android build pre-step that regenerates and validates canonical decks.
- Existing Flutter Web PWA build and Playwright workflow preserved.

## Verification

- Canonical content validation: 400 Sprint, 600 Charades, 800 Trivia and 500 Forbidden Words cards.
- Flutter tests: 55 tests passed.
- Android debug APK: built successfully.
- Android release APK: built successfully with debug signing fallback.
- Android App Bundle: build reached packaging but was blocked by local native debug-symbol stripping/toolchain issue.
- Flutter Web release build: built successfully.
- Android live-device installation and iOS compilation were not available in this Windows environment.

## Remaining limitations

- A production Android keystore has not been created and the release build is not production-signed.
- iOS signing and simulator/device verification require macOS and Xcode.
- Native platform visuals and audio should receive a final pass on small and notch-equipped devices.
- Optional accelerometer Charades mode was not implemented.
