# Second-pass editorial audit — checkpoint 001

Status: INCOMPLETE; no release or merge recommendation. Baseline: 40433f79879edcc95fedc1fc628515603de458ef. Batch 001 covers source rows 1–100 inclusive. All decisions are staged in the log rather than applied to playable data. Full-bank quota balancing and semantic review must precede deck regeneration.

## Scoring anchors (1–5; higher is stronger)

| Criterion | Weight | 1 | 2 | 3 | 4 | 5 |
|---|---:|---|---|---|---|---|
| Describability | 30 | No workable route | One narrow route | Several related cues | Multiple useful routes | Immediate independent routes |
| Familiarity | 25 | Very obscure | Niche | Mixed audience | Widely known | Near-universal within target audience |
| Entertainment | 15 | Frustrating | Limited | Neutral | Engaging | Highly social or memorable |
| Distinctiveness | 10 | Ambiguous | Frequent confusion | Needs context | Usually unique | Immediately differentiated |
| Cultural relevance | 10 | Remote | Weak | General | Relevant | Strong shared relevance |
| Longevity | 5 | Fleeting | Short-lived | Uncertain | Durable | Evergreen |
| Language accessibility | 5 | Inaccessible | Difficult | Moderate | Accessible | Natural everyday wording |

Weighted score = sum(weight × score / 5), 0–100 scale (minimum 20). Estimates are author judgments, not measured familiarity, and not comparable to legacy heuristic scores. Flags override aggregate scores. No independent review.

## Baseline inventory (read from committed terms)

2,000 terms; 800 easy, 800 medium, 400 hard; 659 Zimbabwe, 422 broader Africa, 919 global; 1,209 proper-noun flags; 46 specialist flags; 147 with at least three existing pathways. Regional field mixes association with origin and should not be treated as an origin-only metric.

## Batch 001 results

```json
{
  "records": 100,
  "dispositions": {
    "RETAIN": 41,
    "REFINE": 38,
    "FLAG FOR HUMAN REVIEW": 21
  },
  "previousDifficulty": {
    "easy": 39,
    "medium": 42,
    "hard": 19
  },
  "proposedDifficulty": {
    "easy": 36,
    "medium": 34,
    "hard": 30
  },
  "difficultyCorrections": 38,
  "threePathways": 98,
  "unflaggedThreePathways": 79,
  "mean": 85.03,
  "properBefore": 60,
  "properProposed": 64
}
```

Remaining source rows 101–2000 not individually reviewed in this pass. Flagged rows require further review even when three proposed pathways exist. Proposed category labels and regional changes require global taxonomy review. Proposed difficulty is independent of quotas. Some clues remain closely related; do not treat raw count as final quality acceptance. No replacements committed to playable data; no card regeneration. No final quality rating.

## Checkpoint 002 — source rows 101–200

{
  "records": 100,
  "dispositions": {
    "REFINE": 36,
    "RETAIN": 48,
    "FLAG FOR HUMAN REVIEW": 16
  },
  "previousDifficulty": {
    "easy": 46,
    "medium": 40,
    "hard": 14
  },
  "proposedDifficulty": {
    "easy": 43,
    "hard": 18,
    "medium": 39
  },
  "difficultyCorrections": 28,
  "threePathways": 100,
  "unflaggedThreePathways": 84,
  "mean": 89.68,
  "properBefore": 62,
  "properProposed": 66
}

### Cumulative checkpoints 001–002

```json
{
  "records": 200,
  "dispositions": {
    "RETAIN": 89,
    "REFINE": 74,
    "FLAG FOR HUMAN REVIEW": 37
  },
  "previousDifficulty": {
    "easy": 85,
    "medium": 82,
    "hard": 33
  },
  "proposedDifficulty": {
    "easy": 79,
    "medium": 73,
    "hard": 48
  },
  "difficultyCorrections": 66,
  "threePathways": 198,
  "unflaggedThreePathways": 163,
  "mean": 87.355,
  "properBefore": 122,
  "properProposed": 130
}
```

Supersedes checkpoint 001 progress counts. Rows 201–2000 outstanding. All proposals staged; no final quota balancing. Universal concepts previously coded Zimbabwean due to local relevance need consistent global review: retain local-association information separately before changing region. Named brands and entertainment titles should be counted as proper names consistently, even if this temporarily increases the count. Do not force geographic or proper-name targets by incorrect classification.

Potential overlap: Elijah/Elisha (distinct stories but avoid same card), Funke Akindele/Jenifa's Diary, Chicken Inn FC/restaurant chain, Hwange town/park/club, named musician and associated hit. These are candidate constraints, not full-bank collision results.

## Checkpoint 003 — source rows 201–300

```json
{
  "records": 100,
  "dispositions": {
    "FLAG FOR HUMAN REVIEW": 19,
    "RETAIN": 41,
    "REFINE": 40
  },
  "previousDifficulty": {
    "hard": 24,
    "easy": 35,
    "medium": 41
  },
  "proposedDifficulty": {
    "hard": 20,
    "easy": 37,
    "medium": 43
  },
  "difficultyCorrections": 37,
  "threePathways": 99,
  "unflaggedThreePathways": 81,
  "mean": 89.13,
  "properBefore": 67,
  "properProposed": 70
}
```

### Cumulative checkpoints 001–003

```json
{
  "records": 300,
  "dispositions": {
    "RETAIN": 130,
    "REFINE": 114,
    "FLAG FOR HUMAN REVIEW": 56
  },
  "previousDifficulty": {
    "easy": 120,
    "medium": 123,
    "hard": 57
  },
  "proposedDifficulty": {
    "easy": 116,
    "medium": 116,
    "hard": 68
  },
  "difficultyCorrections": 103,
  "threePathways": 297,
  "unflaggedThreePathways": 244,
  "mean": 87.94666666666667,
  "properBefore": 189,
  "properProposed": 200
}
```

Rows 301–2000 outstanding. Mother-in-law proposed easy rather than hard; retain comparison with Babamukuru as unresolved. Other questionable first-pass candidates reviewed here include Vosho and Biniam Girmay. No identity changes applied. Fixed literal answer-token leakage in Mutapa Empire and Great Zimbabwe clues from checkpoint 001–002. Additional literal token screen: 3 matches; further review required. Potential overlapping families: Biblical characters, musicians and songs, Matobo Hills/Rhodes grave, city/country names, footballers and clubs. Full-bank semantic review outstanding.

## Priority checkpoint 001

17 additional named examples audited out of order (all ten difficulty examples and all eleven disputed first-pass replacements now have preliminary individual records, including those already in contiguous batches). Source index remains authoritative. The eleven original/replacement comparisons are separate, provisional and not applied. Three literal token matches corrected from checkpoint 003. Remaining literal matches: [].

```json
{
  "records": 317,
  "dispositions": {
    "RETAIN": 130,
    "REFINE": 125,
    "FLAG FOR HUMAN REVIEW": 62
  },
  "previousDifficulty": {
    "easy": 120,
    "medium": 128,
    "hard": 69
  },
  "proposedDifficulty": {
    "easy": 122,
    "medium": 121,
    "hard": 74
  },
  "difficultyCorrections": 114,
  "threePathways": 313,
  "unflaggedThreePathways": 255,
  "priorPathwayOverlap": 31,
  "mean": 87.82334384858044,
  "properBefore": 197,
  "properProposed": 208
}
```

1683 current term identities not yet individually reviewed in this pass. No changes to playable bank, deck or manifest. Prioritise outstanding contiguous rows 301 onward, skipping priority rows already staged. No overall rating or final distribution claimed.

## Checkpoint 004 — source rows 301–400

99 newly assessed terms; source row 345 (Car wash) already covered by the priority batch and not duplicated. 49 retain, 22 refine, 28 flag for human review; 28 proposed difficulty corrections. All 99 have three proposed pathways. Batch mean 86.74/100, estimated, not measured. Named-entity references and narrowly local places remain important flag categories.

Cumulative: 416/2,000 individual reviews (20.8%); 179 retain, 147 refine, 90 flag; 142 difficulty corrections; 412 have three pathways, 326 unflagged; 522/2,000 distinct terms have three recorded pathways across both passes (26.1%). Proper-noun flags in reviewed subset: 264 previous, 276 proposed. Mean 87.56/100, not an overall rating. 1,584 source identities remain unassessed. Resume at row 401, skipping already audited priority rows. Playable bank and deck unchanged.

## Checkpoints 005–007 — source rows 401–700

User guidance: distinguish functional terms from exceptional entertainment and cultural relevance. Preserve completed audit records, reserve perfect scores for truly exceptional terms, and perform an explicit cross-batch score calibration before final comparison. All scores remain estimates.

| Batch | New reviews | Retain | Refine | Flag | Difficulty changes | Three pathways | Mean score |
|---|---:|---:|---:|---:|---:|---:|---:|
| 005 (401–500) | 98 | 52 | 22 | 24 | 22 | 97 | 85.37 |
| 006 (501–600) | 98 | 44 | 25 | 29 | 30 | 94 | 86.24 |
| 007 (601–700) | 100 | 47 | 21 | 32 | 33 | 100 | 85.98 |
| Total new | 296 | 143 | 68 | 85 | 85 | 291 | 85.86 |

Cumulative: 712/2,000 individual records (35.6%), including 700 contiguous source rows and 12 later priority rows. 322 retain, 215 refine, 175 flag; 227 proposed difficulty changes. 703 second-pass records have three pathways, 537 unflagged. Combined distinct first/second-pass coverage: 804 (40.2%). 1,288 identities remain unassessed. Reviewed difficulty counts before: 287 easy, 287 medium, 138 hard; proposed: 297 easy, 270 medium, 145 hard. Reviewed proper-noun flags: 446 previous, 470 proposed. Cumulative mean 86.86/100 (not a deck rating; calibration differs). One perfect score in these 296 records (Tom and Jerry); 137 previous perfect records remain staged and require focused calibration, not repetition of the full audit. Five newly assessed identities lack sufficient pathways: Wenyasha, Estate Blues, Tanyaradzwa, Munyama, Peter Pan (music entry). Resume row 701, skipping previously assessed priorities. No production changes.

## Checkpoints 008–013 — source rows 701–1300

| Batch | New reviews | Retain | Refine | Flag | Difficulty changes | Three pathways | Mean score |
|---|---:|---:|---:|---:|---:|---:|---:|
| 008 | 99 | 38 | 25 | 36 | 37 | 97 | 86.56 |
| 009 | 98 | 38 | 32 | 28 | 34 | 97 | 86.17 |
| 010 | 98 | 43 | 20 | 35 | 21 | 95 | 86.18 |
| 011 | 100 | 34 | 28 | 38 | 35 | 98 | 85.46 |
| 012 | 100 | 52 | 27 | 21 | 32 | 99 | 86.96 |
| 013 | 100 | 43 | 33 | 24 | 36 | 100 | 87.69 |
| Total new | 595 | 248 | 165 | 182 | 195 | 586 | 86.51 |

Cumulative: 1,307/2,000 (65.35%); 1,300 contiguous source rows and seven later priority rows. 570 retain, 380 refine, 357 flag; 422 difficulty changes; 1,289 records have three pathways, 950 unflagged; combined deduplicated coverage 1,348 (67.4%). 693 remaining. Proposed reviewed difficulty counts 554 easy, 531 medium, 222 hard versus 518/533/256 original. Proper-noun flags 806 previous, 844 proposed. Mean 86.70/100, not comparable to earlier provisional deck rating. No perfect scores in batches 008–013. Earlier 137 perfect records require focused calibration. Resume row 1301, skipping priorities. Production content unchanged.

## Checkpoints 014–020 and full-audit reconciliation

The individual editorial audit is complete: 2,000 distinct source rows and IDs reviewed (1,584 additional reviews since checkpoint 004). The first-pass playable files are deliberately unchanged pending the final editorial release gate. Initial dispositions: 892 retain, 559 refine, 549 flagged; 631 difficulty corrections. Full audit score mean after focused calibration: 86.3405/100. This is a reviewer estimate, not a measured audience rating.

The focused calibration reconsidered 137 previously perfect scores; only Tom and Jerry and Jesus Christ remain at 100. Alarm clock is now 90, Traffic jam and Mother-in-law 95. Keep the individual score histories in the JSONL log.

After checking seven previously incomplete identities, the audit log contains 1,980 source terms with at least three description pathways. A separate 79-row shortlist provides the other 20 pathways and proposes replacements for 78 flagged rows and one additional weaker row. All 79 show positive score deltas under the recorded rubric (+1,662 total). The combined projected mean is 87.1715, not a release score. The shortlist is provisional, not approved production content.

Restoration proposals: Laho → Qongqothwane; Tapiwanashe Makarawu → Namib Desert (relocate the athlete into Taffy Theman’s weaker slot); Mudiwa Jani → Babamukuru (retain Mother-in-law); Dota 2 → Virtual reality headset (retain Digital detox).

Remaining editorial gate: 471 flagged source terms outside the shortlist, candidate fact and cultural-language verification, semantic overlap review, category and alias integrity, and final difficulty balancing. The 79 candidates do not meet the broader African and proper-noun targets; do not fabricate classification changes to close those gaps. Review the remaining candidates against the actual quality floor rather than forcing a replacement quota.

Source data: second-pass-refinement-log.jsonl; second-pass-replacement-candidates.jsonl; second-pass-selected-candidates.jsonl. No changes merged into main.
