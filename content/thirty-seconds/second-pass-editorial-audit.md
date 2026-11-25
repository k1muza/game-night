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
