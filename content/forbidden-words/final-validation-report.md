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

## Final readback and alias-overlap caveat

Committed deck, audit and chained revision log read back from GitHub. Checks: `{"count":500,"uniqueIds":500,"uniqueTargets":500,"clues":2500,"pathways":1500,"trace":true,"auditMatch":true,"changes":186}`. No exact cross-card alias collisions, but **22 within-card exact alias/restriction overlaps** remain. These are separate from pathway leakage: a referee may already disallow an answer alias, making a slot redundant. Review against the actual multilingual game rules; do not automatically strip translation reminders without testing. The score snapshot precedes this supplementary finding, which is an additional release gate.

- Chitofu: stove
- Mupinyi: screwdriver
- Matombo: stones
- Mutsago: pillow
- Matemba: kapenta
- Mupunga: rice
- Chibage: maize
- Chibage: corn
- Munyemba: cowpeas
- Mbuya Nehanda: Charwe
- Siyabonga: thank you
- Salibonani: hello
- Yebo: yes
- Chokwadi: truth
- Dynamos: DeMbare
- Highlanders: Bosso
- CAPS United: Green Machine
- CAPS United: Makepekepe
- Artificial intelligence: AI
- Curriculum vitae: CV
- Curriculum vitae: resume
- Oxygen: O2

Potential alias-component overlap: Lake Malawi / Lake Nyasa / Nyasa. Native Shona and Ndebele speakers should verify alias equivalence, natural code-switching, morphology, pronunciation and translation leakage. During trials, allow natural explanations in agreed languages; disallow answer aliases, direct translations, obvious derivatives and listed restrictions; adjudicate ambiguous cases consistently rather than ban arbitrary substrings. No native-speaker sign-off was obtained.
