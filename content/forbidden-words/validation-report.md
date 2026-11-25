# Validation report — second pass

Actual checks executed against candidate deck before commit. 
```json
{
  "cards": 500,
  "ids": 500,
  "targets": 500,
  "clueSets": 500,
  "paths": 500,
  "matchingDetails": 500,
  "difficulty": 500,
  "schemaVersion": 500,
  "traceability": 500,
  "lexicalFlags": 0
}
```
All 1,500 routes scanned for normalized phrases and simple English stems; 0 flags. All retained/revised IDs traceable. This does not guarantee correct compound/derivative handling, practical solvability, multilingual adjudication, semantic nonduplication, factual accuracy or full schema compliance. No external JSON Schema runner or Dart build executed; shared v1.1 schema is not designed for this v1.0.0 deck. The Python validator is included but not independently executed. Single-agent review only; no human playtesting. Candidate only.
