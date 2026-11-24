# Game Night content library

## Status
Batch 001: 200 newly authored **draft** records, 50 per game. No research example records were imported. Familiar names and concepts may naturally overlap. This is a candidate content set, not an approved production seed.

| Game | Drafts | Launch target | Remaining |
|---|---:|---:|---:|
| 30-Second Sprint | 50 | 400 | 350 |
| Charades | 50 | 600 | 550 |
| Trivia Challenge | 50 | 800 | 750 |
| Forbidden Words | 50 | 500 | 450 |
| Total | 200 | 2,300 | 2,100 |

## Editorial direction
Primary audience: Zimbabweans aged 16–30, with African and global references. English-first, allowing familiar Shona and Ndebele terms; verify translations with native speakers. Keep it family-friendly, humorous and inclusive. Use the research report's taxonomy codes (ZIM, AFR, SPT, MUS, ENT, SMC, SCI, UNI, WLD). Include social media creators, internet situations, music, sport, film, Bible, work, education, relationships and everyday life. Offer optional themed packs but default to varied mixed cards.

Research quota targets for social media: 24 Sprint cards/120 term slots, 50 Charades prompts, 50 Trivia questions, 35 Forbidden Words cards; track term-level coverage separately because mixed cards can contain unrelated terms. Final category quota matrix must be reconciled to exact launch totals before bulk generation; the research tables contain arithmetic shortfalls. Aim for 40/40/20 easy/medium/hard initially, then calibrate using real playtests.

## Draft contract
One JSON object per line in each file under drafts/. Stable IDs, game type, version, schema version, taxonomy category, difficulty, minimum age, language, region, tags and editorial status. The flat common schema plus variant-specific constraints uses Draft 2020-12 unevaluatedProperties, avoiding the original report's allOf/additionalProperties conflict. This is a deliberately minimal authoring schema; extend it for approved content with review dates, term-level taxonomy and aliases, age-cohort metadata, content origin and playtest metrics before release.

- Sprint: exactly five distinct terms, mixed subjects, at most two estimated hard terms, one accessible anchor. Draft difficulty labels are provisional, not measured. Hard cards cannot be defined by median difficulty while also limiting to two hard terms; use estimated combined effort and playtest score instead.
- Charades: one prompt per card, physical mime without speech or props; multiple cards may be played per 60-second turn.
- Trivia: one correct answer and three distinct distractors; randomise option order in the application. Candidate references are **not verified**. A null retrieval date means the source has not been checked in this workflow. Replace broad landing pages with precise supporting URLs and record actual retrieval dates.
- Forbidden Words: exactly five distinct forbidden clues, plus three candidate alternative clue pathways for editorial review only. checkedByEditors=false means solvability is not established. Test for derivatives, embedded forbidden expressions and unintended giveaway clues. Hide editorial hints from players.

## Release gates
1. Validate each JSONL record and unique IDs; detect case/punctuation-insensitive duplicates and near-duplicates within and across batches.
2. Peer-review difficulty, familiar language, age appropriateness, cultural breadth, category fit, and ambiguity. Specifically review any questionable creator names and vernacular terms.
3. For trivia require verified evidence, a precise source URL, retrieval date, one correct answer and plausible alternatives; exclude unverified or disputed records from production. Review time-sensitive items periodically.
4. Playtest with 16–21 and 22–30 players, including urban and rural participants and Shona/Ndebele speakers. Measure recognition, average score, skips and fairness. Calibrate difficulty and reject unactable prompts or unsolvable forbidden-word cards.
5. Publish only approved cards; drafts are not a runtime asset. Maintain a server-side deck so hidden answers are not exposed to inactive teams.

## Expansion workflow
Author batches of 50–100 per game against the remaining category/difficulty quotas, independently review each batch, run structural and duplicate checks, then approve after playtesting. Do not regenerate previous IDs or silently alter published questions. Prioritise genuine variety over padding. Complete all 2,300 cards before declaring the full library ready.

No dice or board movement is required. MVP scoring is based on correct answers, equal team turns and highest score at the end; any penalties or advanced variants need an explicit gameplay decision.
