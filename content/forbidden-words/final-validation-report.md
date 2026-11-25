# Final validation report

Executed JavaScript checks against the final candidate:
```json
{
  "cards": 500,
  "ids": 500,
  "targets": 500,
  "clueSets": 500,
  "pathways": 500,
  "detailMatch": 500,
  "schemaVersion": 500,
  "category": 500,
  "difficulty": 500,
  "lexicalFlags": 0,
  "aliasCollisions": 0,
  "reviewedRows": 500,
  "traceableChanges": 186,
  "originalTraceability": 500,
  "successorTraceability": 500,
  "compoundFlags": 0
}
```

Lexical findings: []. Alias collisions: []. Checked all 1,500 pathways using normalised words/phrases, simple suffixes, explicit variant/derivative metadata and a selected compound mapping; manual review caught rapid/rapidly, climb/climbers, fort/fortification and target translation hints that the earlier check missed. These were addressed where accepted. Unrelated substrings not automatically banned. All 500 final editorial judgments recorded. Native-language, semantic duplication and actual gameplay remain separate; related pairs listed in editorial report. Existing Python script not run because the local environment cannot resolve github.com to retrieve the working tree; connector-based validation executed instead. New Python validator included; app Dart/Flutter build and full JSON Schema engine not run. Schema 1.0.0 preserved; adapter inspected for expected fields and category handling. Candidate remains draft.
