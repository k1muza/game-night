# Game Night — Local Referee Mode

**Version:** 1.0  
**Status:** Proposed  
**Repository:** `k1muza/game-night`  
**Platform:** Native Flutter (Android and iOS)  
**Initial games:** 30-Second Sprint and Tabuu

## 1. Executive summary

Game Night currently operates as a single-device party game, with local scoring, timers, card presentation and session management. Tabuu requires independent monitoring of forbidden words, while Sprint benefits from verification of correct guesses and prohibited clues. Local Referee Mode adds an optional second device with a synchronised referee interface over local Wi-Fi or a mobile hotspot. No internet, accounts or cloud backend are required.

## 2. Objectives and scope

Primary objectives: competitive fairness, independent rule enforcement, less interaction required from the clue-giver, fewer scoring disputes, synchronised cards, offline play and preservation of existing single-device gameplay.

Secondary objectives: reusable networking infrastructure, future support for other games, tournament and audience-display extensions, and minimal operational cost.

Out of scope for v1: internet multiplayer, accounts, cloud sessions, Bluetooth, speech recognition or AI refereeing, multiple concurrent referees, tournament management and public leaderboards.

## 3. Gameplay modes

### Classic Mode

Default mode. Existing single-device gameplay remains unchanged across all four games. No pairing or network required.

### Referee Mode

Two devices participate in a local session.

- **Host:** game configuration, teams, session persistence, card selection, authoritative timer and scoring, turn progression, clue-giver interface and validation of referee actions.
- **Referee:** active card display, rule monitoring, authorised scoring, violation reporting and turn review. No independent scoring engine, deck selection or overall game progression.

## 4. User experience

- Home: subordinate **Join as Referee** action.
- Setup for Sprint and Tabuu: Classic (one phone) or Referee (two phones), with a short explanation.
- Host pairing screen: selected game, same-Wi-Fi/hotspot instructions, QR code, host and referee connection status, manual fallback, cancel and continue in Classic Mode. No manual port configuration required.
- Referee pairing: scan QR or enter connection details manually; request camera permission only on selecting scanning; allow cancellation.
- Once connected, host displays Referee Connected, referee sees selected game, both show status; host continues normal gameplay. Pair once per session.
- Handover: both devices show upcoming team and waiting state, without revealing the next card. Only host starts turn. Both then receive the active card and authoritative timer state.

## 5. 30-Second Sprint

### Host interface

Active team, countdown, five terms and context labels, guessed-term status, existing Skip Card control and connection indicator. While connected, term-scoring controls are read-only; host retains authorised session-level controls and can explicitly take over if referee disconnects.

### Referee interface

Same card, context labels, active team, countdown, guessed-term status, violation controls and connection status.

### Referee-controlled scoring

Each term has three states: Pending, Correct and Disqualified. Referee marks guesses or disqualifies a term; host applies authoritative score calculation. Disqualified terms cannot earn points unless the decision is reversed.

Referee may disqualify for saying the target, prohibited components, translations or obvious derivatives, spelling or other clues prohibited by the displayed rules. Human judgment, not automated detection.

Referee may correct term marks within the active turn. After expiry, use controlled turn review. When all five terms are correct or disqualified, host applies existing card progression rules, sends the next card or results and retains the original deadline. Preserve existing scoring, skip and progression mechanics; prevent simultaneous independent scoring.

## 6. Tabuu

Host displays active team, countdown, target, five forbidden words, Pass, Got It and connection indicator. Referee displays identical target and forbidden words, active team, timer, prominent BUZZ and status.

Referee buzzes when a prohibited word is spoken, also enforcing applicable rules on translations, derivatives, target aliases and spelling.

BUZZ processing: send session/turn/card-instance identity, validate at host, apply existing penalty and scoring rules, advance where required, synchronise updated state and provide visual/audio feedback. A delayed or duplicated buzz must not penalise a subsequent card.

Clue-giver may mark Got It. Referee can flag disputed results during controlled correction window. Preserve existing Tabuu scoring and undo semantics rather than inventing new penalties.

## 7. Turn review and dispute resolution

Both devices show synchronised results. Sprint: presented, correct, disqualified and unanswered terms and points. Tabuu: correct, passed and buzzed targets and points.

Referee may request corrections before host confirms turn. Host settles final score; ordinary controls cannot modify historical results after settlement. Reuse existing turn-results UI where practical.

## 8. Networking architecture

Use local IP WebSockets on shared Wi-Fi or mobile hotspot, offline, supporting Android-to-Android, iOS-to-iOS and cross-platform connections subject to network configuration.

Host: embedded `dart:io` `HttpServer` and `WebSocketTransformer`, temporary authentication, connection lifecycle, authoritative snapshots, command validation and reconnection.

Referee: WebSocket client, authentication, snapshots, state rendering, authorised actions and connection monitoring.

Existing `SessionController` remains authoritative. All gameplay mutations pass through validated controller actions. Referee holds a read-only projection, not a separate gameplay engine.

Suggested components: `LocalSessionServer`, `LocalSessionClient`, `SessionProtocol`, `PairingService`, `RefereeSessionController`, `RefereeState`, `ConnectionHealthMonitor` and game-specific screen adapters. Adapt names to repository conventions. Separate transport from presentation and scoring.

## 9. Pairing and authentication

QR code contains protocol version, IP, port, session identifier and cryptographically random temporary token. Assign port dynamically where practical. Example:

```json
{
  "v": 1,
  "host": "192.168.1.10",
  "port": 8765,
  "sessionId": "session-example",
  "token": "temporary-random-token"
}
```

Manual fallback displays address, port and temporary pairing code, authenticating without permanent credentials.

One active referee in v1. Unauthorised clients receive no card or session information. Tokens must be secure, temporary, session-specific and invalidated on end, cancellation or reset. A new client cannot silently replace an active referee.

Unencrypted local WebSockets are not confidential on untrusted networks; tokens do not encrypt transport. Intended for trusted in-person gatherings. Transmit only authorised current gameplay state, not personal information, unnecessary device identifiers, unused decks, editorial metadata or unrelated state.

## 10. Communication protocol

Versioned JSON envelope (illustrative):

```json
{
  "protocolVersion": 1,
  "type": "referee_action",
  "sessionId": "session-example",
  "turnId": "turn-003",
  "cardId": "card-0149",
  "cardInstanceId": "instance-008",
  "messageId": "unique-message-id",
  "stateVersion": 42,
  "payload": {}
}
```

Host-to-referee events:

- connection_accepted, connection_rejected
- session_snapshot, turn_ready, turn_started, card_changed
- term_state_changed, score_updated
- timer_paused, timer_resumed
- turn_ended, turn_review, turn_settled, game_ended
- action_result, heartbeat

Referee-to-host events:

- authenticate, request_snapshot
- mark_term_correct, mark_term_pending, disqualify_term
- buzz, request_correction, confirm_review, heartbeat

Every action is validated for session, authentication, game type, turn, card instance, permission, phase, target term, duplicate message ID and timer/review restrictions. Invalid actions must not mutate state.

Canonical card ID is insufficient because a card may recur; assign a unique instance ID to each presentation. Host state version increases monotonically after accepted mutations. Referee identifies stale updates and requests a full snapshot on reconnection or inconsistency. Unique message IDs and retained action-processing history ensure idempotency.

## 11. Timer synchronisation

Host is the sole timer authority. Referee estimates display countdown from authoritative remaining duration, phase, pause state, state version and timing reference where appropriate. Periodic synchronisation accounts for latency; do not transmit per-frame ticks.

At expiry, both devices show ended state. Host rejects ordinary gameplay commands received after its deadline; exceptional corrections use explicit turn review. Referee timestamps are not authoritative evidence.

## 12. Connection loss and recovery

Both devices indicate Connecting, Connected, Reconnecting and Disconnected. Heartbeats and transport lifecycle detect loss.

On confirmed loss during an active turn, host automatically pauses and offers reconnect, continue in Classic Mode or end turn subject to existing confirmation rules. Referee attempts reconnect and must not queue gameplay commands for later submission.

Reconnect authenticates and restores authoritative card, timer, scores and term states without duplicate actions. Host explicitly resumes.

Classic fallback restores local scoring, disconnects referee, invalidates credentials, preserves session and blocks further remote commands.

Handle backgrounding, screen locking, network/hotspot changes, process termination and shutdown. Do not assume host server runs continuously in background; pause and reconnect as necessary.

## 13. Platform requirements

**Android:** required network and camera permissions, local network requirements per OS/target SDK; verify Wi-Fi, hotspot host/client, denied permissions, backgrounding and wake lock.

**iOS:** local network and camera usage descriptions, appropriate network security configuration; verify permissions and cross-platform networking. Do not broadly disable transport security without necessity.

**Web:** preserve existing web build using platform abstractions around native sockets; hide or disable unsupported Referee Mode with explanation. Native Flutter is initial target.

## 14. UI requirements

Use existing design system, game colours, typography, large readable targets, high contrast, timer presentation, familiar buttons and accessible touch targets.

Purpose-built referee UI prioritises readability, minimal distractions, large scoring and violation controls, status indicators, fast feedback and prevention of repeated accidental actions. No unnecessary menus during a turn.

## 15. Persistence and content compatibility

Preserve host session restoration, persistent card queues, repetition prevention, team scores, history and configuration. Referee has no independent authoritative saved session; temporary reconnection details may be retained.

Host transmits active playable card data. Referee must not resolve IDs against its own bundled deck; compatible protocol required, identical content versions not required.

## 16. Performance targets

| Metric | Target on healthy LAN |
|---|---|
| Initial connection | Within 3 seconds |
| Card synchronisation | Within 250 ms |
| Action acknowledgement | Within 250 ms |
| Loss detection | Approximately 3 seconds |
| Reconnection | Automatic attempt without losing host state |
| Internet bandwidth | None required |

These are engineering targets, not verified guarantees.

## 17. Testing requirements

**Unit:** serialization, protocol compatibility, token generation/authentication, authorised and unauthorised actions, duplicate/stale turn and card-instance rejection, state versions, deadline restrictions, scoring permissions and termination.

**Integration:** server startup, valid/invalid pairing, snapshot sync, card progression, correct answers, violations, duplicate BUZZ, rapid actions, disconnect/reconnect, Classic fallback, multiple connections and session restoration.

**Regression:** Classic Mode across all four games; scoring, timer, pause/resume, selection, undo, persistence, transitions, exhaustion and repetition.

**Physical devices:** two Android phones on shared Wi-Fi and hotspot; Android host/iOS referee and reverse where available; internet disconnected; both screens locking; Wi-Fi loss; denied camera/local-network permission; different content versions. Record untested combinations explicitly.

## 18. Implementation phases

1. **Shared networking:** server/client, protocol, pairing/authentication, snapshots, monitoring, reconnect, platform permissions and automated network tests.
2. **Tabuu:** pairing from setup, target and forbidden words, remote BUZZ, authoritative penalties, review, recovery and integration tests.
3. **Sprint:** five-term sync, referee scoring, individual disqualification, correction, review, fallback and integration tests.
4. **Final QA:** cross-platform verification, performance, usability, regressions, documentation and physical-device playtesting.

## 19. Future extensions (not v1)

- Charades: referee correct guesses, pass/violation monitoring and scorekeeping.
- Trivia: independent answer verification, question presentation and results supervision.
- Audience display: scores, active team, remaining time and round progression; never hidden cards or answers.
- Tournament mode: permanent roles, scheduling, standings, dispute resolution and history.

## 20. Acceptance criteria

- [ ] Classic Mode remains unchanged.
- [ ] Host can start local referee session.
- [ ] QR pairing and manual fallback work.
- [ ] Both devices operate without internet.
- [ ] Referee sees identical active card; no premature reveals.
- [ ] Tabuu BUZZ processed correctly.
- [ ] Sprint terms can be marked correct or disqualified by referee.
- [ ] Host authoritative scores and timer.
- [ ] Duplicate/stale commands cannot corrupt scoring.
- [ ] Safe disconnect handling and authoritative reconnection.
- [ ] Classic fallback preserves session.
- [ ] Existing gameplay tests pass.
- [ ] Native-device compatibility documented.
- [ ] No cloud backend or recurring infrastructure costs.

## 21. Guiding principles

Host is authoritative. Referee supervises. Network transports state and authorised actions, not independent game logic. Classic Mode remains simple and available. Competitive fairness must not introduce unnecessary friction or compromise offline-first architecture.

## Key design decisions

Local Wi-Fi WebSockets; QR with manual fallback; no backend; Tabuu and Sprint first; referee-controlled Sprint scoring; host marks Tabuu guesses and referee buzzes; automatic pause on connection loss; host transmits active card; Classic Mode preserved; Bluetooth deferred.

This is a proposed design. Networking implementation, performance and physical-device compatibility have not yet been tested.
