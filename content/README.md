# Game Night content library

## Canonical layout

Each game has its own directory. `cards.jsonl` is the sole canonical candidate deck for that game: UTF-8 JSON Lines, one complete card per line. Never combine the earlier initial-library drafts with these decks.

```text
content/
  README.md
  manifest.json
  thirty-seconds/
    cards.jsonl
  charades/
    cards.jsonl
  trivia/
    cards.jsonl
  forbidden-words/
    cards.jsonl
  schemas/
    draft-v1.1.schema.json
```

Put future per-game QA reports, evidence files, category allocations and game-specific schemas beside the corresponding deck. Put shared schemas and contracts in schemas/. Avoid duplicate decks or files at repository root.

## Inventory and provenance

| Game | Cards | Imported schema version |
|---|---:|---|
| 30-Second Sprint | 400 | 1.2.0 |
| Charades | 600 | 2.0.0 |
| Trivia | 800 | 1.1.0 |
| Tabuu | 500 | 1.0.0 |
| Total | 2,300 | |

All deck blobs are preserved byte for byte. manifest.json records their source branches and Git blob hashes at import. Update the manifest when deliberately revising a dataset.

- PRs #2 and #3 supplied identical Forbidden Words blobs; keep exactly one copy.
- PR #3 supplied the Sprint and Charades Deep Research uploads.
- Trivia production (PR #4) was based on the excluded initial-library branch. Only its two changed files were integrated: the 800-card Trivia replacement and the updated draft v1.1 authoring schema. Its inherited draft decks, validator and README were not imported.
- The excluded content/initial-library branch and its PR #1 remain untouched.

## Status and release gates

The complete library is a candidate dataset, not an approved runtime deck. The four source schemas differ. schemas/draft-v1.1.schema.json preserves the authoring schema from Trivia production for reference; it is not yet a unified validator for all four datasets.

Trivia contains 258 records labelled verified and 542 labelled plausible-unverified by the source dataset. These labels have not been independently confirmed during this integration. Require source verification, semantic review and editorial approval before release.

Next steps: establish a unified discriminated card contract with per-game fields; write migration and validation tests; resolve semantic duplicates, difficulty and cultural balance; independently verify trivia and named references; playtest; publish only approved content. Keep source data and editorial metadata server-side when it contains hidden answers or clues.
