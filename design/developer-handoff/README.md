# Developer handoff

Full board: `Spec-Handoff.png`. Tokens: `../design-system/tokens.json` and `tokens.css` (`--gn-*`).

## Session state machine (all games)
lobby → ready → playing.turnIntro → playing.handover → playing.countdown → playing.active → playing.timeUp → playing.review → roundResults → (next turn | leaderboard | gameOver) → lobby. `paused` is an overlay state that freezes the server clock.
Trivia replaces handover and review with questionIntro → answering → locked → reveal → explanation.

## Visibility rules (server-enforced)
- Hidden card payloads (Sprint terms, Charades prompt, Forbidden target and clues) go only to the active player's socket and an authorised referee socket. Shared-screen clients never subscribe.
- Charades opponents get the prompt only through hold-to-peek, which is off in strict rooms.
- Trivia answers and team picks are sent only after the answer window closes.
- Editorial fields (sampleValidClues, solvabilityCheck, editorialNotes, mimeHints except the opt-in "idea" hint) stay on the server.
- Buzzes can be undone only from the referee device (5 s). Review edits and score edits need approval from an opposing team.

## Platform
Wake Lock API; drift-corrected server clock (endAt); WebSocket event log with idempotent IDs; service worker that caches the shell and decks for offline Quick Play; navigator.vibrate is optional (iOS has none); 100dvh and safe-area insets; self-hosted subset fonts. Budgets: JS ≤ 150 KB gz, fonts ≤ 80 KB.

## Components
GnButton, GnTimer, GnHandoverGate, GnTermRow, GnAnswerTile, GnPromptCard, GnForbiddenCard, GnBuzzer, GnScoreStrip, GnLeaderboard, GnTeamBadge, GnSheet, GnToast, GnEmpty. Props are listed on the board.
