# Local Referee hotspot and lifecycle behavior

## Network discovery

The host server listens on all IPv4 interfaces and the QR/manual host address is
selected from private IPv4 interfaces. Interface discovery:

- excludes loopback and link-local addresses;
- excludes common VPN/tunnel interface name patterns;
- includes Wi-Fi, hotspot/AP, Ethernet, and other private local interfaces;
- ranks common mobile-hotspot subnets before generic/private interface names.

Connection health is established by the WebSocket handshake and signed heartbeat,
not by `ConnectivityResult.wifi` alone. Connectivity change events only trigger
an immediate health/reconnect check.

The same implementation supports:

- host phone hotspot, referee joins as a LAN client;
- referee phone hotspot, host joins through the referee's private host address;
- a shared Wi-Fi router.

Mobile data can remain disabled when the operating system permits both phones to
join the same hotspot or LAN. Internet and cloud services are not used.

## Lifecycle behavior

Temporary backgrounding is represented by signed `background` and `resume`
protocol messages. The active turn pauses while a participant is unavailable,
and is saved immediately by the app lifecycle handler.

On foreground resume, the service:

1. performs an immediate WebSocket and heartbeat health check;
2. cancels stale reconnect timers before starting a fresh attempt;
3. resets exhausted reconnect counters;
4. reconnects with the existing pairing credentials, without a QR scan;
5. requests a fresh snapshot from the host; and
6. restarts heartbeat and action replay handling only for the live socket.

Temporary 5-second, 30-second, 2-minute, and 5-minute background tests should
preserve the original turn deadline and reconcile from the authoritative host
snapshot. Physical-device/OS limitations can still interrupt WebSockets in
some power-saving states; in that case the existing reconnect and recovery UI
remains available.

## Process termination

If Android or iOS terminates the app process, in-memory pairing credentials and
WebSocket state are lost. On startup, the saved referee session is safely
restored as Classic Mode in [main.dart](../app/lib/main.dart). The next game
requires a normal pairing/QR flow.

## Known platform considerations

- iOS Personal Hotspot and Android tethering can expose private AP/interface
  names and addresses that differ by manufacturer and iOS/Android version.
- Some Android OEMs restrict tethered LAN sockets or suspend them aggressively
  during deep backgrounding.
- iOS Low Power Mode and background-app suspension may delay socket delivery;
  foreground resume performs the authoritative health check.
- VPN or per-app VPN tunneling must be disabled because it can route or shield
  the private host address even though a LAN interface remains available.
- Cellular-only network interfaces are not accepted as WebSocket hosts. Pairing
  must use the shared hotspot/router private IPv4 network.

## Implementation report

Validated in this workspace on 2026-11-26:

- Flutter analysis completed with no errors and 18 existing informational lints.
- The full Flutter test suite passes with 87 tests, including focused tests for:
  - referee indicator rebuild/reduced-motion behavior;
  - background invalidation/recovery and client reconnect suppression while backgrounded (waiting past the reconnect timer);
  - rejecting stale `snapshot_ack` messages while the referee remains unavailable in the background;
  - joining a second referee session after closing the first with clean heartbeat teardown;
  - sustained multi-second referee gameplay updates alongside periodic heartbeats;
  - remote referee `BUZZ` double-tap debounce, disabled controls on pause/expiry/sync/missing card while preserving turn-review controls, and graceful conflict exception handling;
  - explicit host correction acknowledgement before `confirmReview()` score settlement and correction-state reset between sessions; and
  - Classic Mode backgrounding.
- Android release build completed successfully as `build/app/outputs/flutter-apk/app-release.apk` (66.3MB).
- Physical hotspot and app-switch durations (5 seconds, 30 seconds, 2 minutes,
  and 5 minutes) require device-level verification and are not claimed from
  simulator-only tests. The implementation report and code document the required
  foreground health check and snapshot re-synchronization behavior.
