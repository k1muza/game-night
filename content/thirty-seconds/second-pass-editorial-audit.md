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
