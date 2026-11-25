# Second-pass validation — priority checkpoint 001

317 records, 317 unique term IDs, 317 unique source indices. All 317 source identities matched against original branch terms. 313 have >=3 proposed clues; 255 unflagged. Literal token matches: 0; []. Morphology, synonyms, aliases, factual accuracy and semantic overlap are not certified. 1683 current terms outstanding. Prior records with >=3 pathways overlapping this audit: 31; not additive without deduplication. No playable deck changes; no regeneration or app tests. All comparisons provisional. No merge readiness.

## Checkpoint 004

416 staged records, 416 unique IDs and source indices, zero identity mismatches and zero weighted score arithmetic errors. All 99 new records have three pathways. Batch 004 literal-token check after corrections: zero matches (case-insensitive Unicode word tokens; common function words excluded). This does not test derivatives, aliases, translations or semantic equivalence. Combined deduplicated first/second-pass pathway coverage: 522/2,000; 326 unflagged complete second-pass records. 1,584 identities pending. No playable changes, app tests, full semantic review, regeneration or playtesting.

## Checkpoints 005–007

712 unique term IDs and source indices; 700 contiguous rows and 12 later priority rows. Zero identity mismatches and zero weighted arithmetic errors against the baseline term blob. New batch literal token collisions: zero after corrections (Unicode tokenisation excluding common function words and possessive s); semantic equivalents, derivatives, aliases and factual claims are not certified. 291/296 new records have at least three proposed pathways; 5 incomplete intentionally flagged. 703/712 total second-pass complete pathways, 537 unflagged; combined deduplicated coverage 804/2,000. No production changes, deck regeneration, application tests or human playtesting. Final difficulty quotas and category/semantic integrity remain pending.

## Checkpoints 008–013

Readback from Git blob after JSONL exceeded inline Contents API threshold. 1,307 unique IDs and source indices, zero source identity mismatches or weighted arithmetic errors; zero literal token matches in batches 008–013 after corrections under Unicode tokenisation with common function words excluded. 586/595 new records have three proposed pathways; nine deferred. Combined coverage 1,348/2,000. Semantic, alias, factual and derivative checks still pending. No deck regeneration or application tests.

## Full-audit and provisional selection validation

Executed against the repository blobs after checkpoint 020 and source verification (audit commit 08001fb2ad22d9baa76947cc56c436780980dd2b; shortlist clue-cleanup commit 2b8926aa8a7495dc386a072a39c2fc764c7b797c).

| Check | Result |
|---|---|
| Audit records | 2,000 |
| Source row / ID / previous term mismatches | 0 |
| Weighted arithmetic errors | 0 |
| Audit-only three-pathway coverage | 1,980/2,000 |
| Projected three-pathway coverage (79 candidates substituted) | 2,000/2,000 |
| Projected normalized canonical uniqueness | 2,000/2,000 |
| Projected canonical-to-other-retained-alias exact collisions | 0 |
| Projected literal answer-token leakage (normalized content words) | 0 |
| Shortlist positive rubric gains | 79/79 |
| Difficulty inventory | FAIL — 880 easy / 862 medium / 258 hard |
| Complete factual verification / audience testing | NOT COMPLETE |
| Semantic duplication, alias-to-alias and category verification | NOT COMPLETE |
| Regenerated production card validation | NOT RUN |

Exact-string and token checks are not semantic validation. No claims of final deck regeneration, user testing, or release readiness. Existing terms.jsonl and cards.jsonl remain unchanged.
