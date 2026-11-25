# Validation report

Executed JavaScript checks against original and final blobs on 2026-11-25:

```json
{
  "cards": 500,
  "ids": 500,
  "targets": 500,
  "clues": 500,
  "pathways": 500,
  "details": 500,
  "version": 500,
  "lexicalFlags": 0,
  "traceability": 500
}
```

All 500 cards and 1,500 paths scanned. Whole-word and simple English suffix heuristic yielded 0 flags. This does NOT verify target components within compounds, rhymes, every derivative, Shona/Ndebele translation or practical solvability. Shared draft v1.1 schema is a different version from this dataset; no external schema validator or Dart build executed. The existing schema version, field layout, card counts and adapter contract were preserved. Reproducible script supplied, not run independently. Human playtesting and independent review outstanding.
