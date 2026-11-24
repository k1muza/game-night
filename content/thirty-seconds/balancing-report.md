# Sprint v2 competitive balancing

Source commit 10ea0f712d00acc56fa77db155d8e1dd7a71d1fd, blob 6ad582dc9a58b31eb7e0acdb604c0289a7ecef23. Original 400 cards: 160 with 3E/2M, 80 with 2E/3M, 80 with 1E/4M, 80 with 1E/2M/2H; original difficulty 800/1040/160. Revised: 800/800/400, every card 2E/2M/1H.

Method: deterministic xorshift32 seed 20261124, shuffle within difficulty, initialise 400 equal-composition cards, 100,000 attempted within-difficulty swaps using simulated annealing and hill climbing. Objective = 1000 times aggregate hard-style violations plus solve-time deviation (target 29 seconds), proper noun concentration, regional variety, local concentration, accessibility and category diversity. Domain and people classifications are proxies. Semantic checks use curated family groups and canonical prefix matches, not exhaustive review.

Time assumptions 3.5/6/10 seconds easy/medium/hard, +1 specialist, +0.5 long. Not actual rounds or predicted scores. Empirical simulations and card editorial scores not completed. Original enriched metric backfill not completed. All cards are draft.

```json
{
  "sourceBlob": "6ad582dc9a58b31eb7e0acdb604c0289a7ecef23",
  "cards": 400,
  "terms": 2000,
  "dispositions": {
    "REFINE": 533,
    "REPLACE": 74,
    "RETAIN": 1393
  },
  "difficulty": {
    "easy": 800,
    "hard": 400,
    "medium": 800
  },
  "regions": {
    "african": 415,
    "global": 861,
    "zimbabwe-national": 724
  },
  "categories": {
    "AFR-01": 77,
    "AFR-02": 25,
    "AFR-03": 35,
    "ENT-01": 37,
    "ENT-02": 60,
    "ENT-03": 154,
    "MUS-01": 91,
    "MUS-02": 111,
    "MUS-03": 130,
    "SCI-01": 54,
    "SCI-02": 45,
    "SCI-03": 19,
    "SMC-01": 11,
    "SMC-02": 20,
    "SMC-03": 20,
    "SMC-04": 22,
    "SMC-05": 24,
    "SMC-06": 21,
    "SPT-01": 52,
    "SPT-02": 85,
    "SPT-03": 100,
    "SPT-04": 93,
    "UNI-01": 43,
    "UNI-02": 44,
    "UNI-03": 45,
    "WLD-01": 40,
    "WLD-02": 25,
    "WLD-03": 35,
    "ZIM-01": 98,
    "ZIM-02": 88,
    "ZIM-03": 126,
    "ZIM-04": 65,
    "ZIM-05": 105
  },
  "specialist": {
    "false": 1906,
    "true": 94
  },
  "pathways": {
    "pending-concrete-pathways": 1926,
    "proposed-not-independently-verified": 74
  },
  "verification": {
    "source-linked-limited-review": 1,
    "unverified": 1999
  },
  "termScores": {
    "59": 41,
    "62": 111,
    "63": 1,
    "64": 58,
    "65": 38,
    "66": 26,
    "67": 141,
    "68": 112,
    "69": 32,
    "70": 235,
    "71": 561,
    "72": 91,
    "73": 49,
    "74": 67,
    "75": 385,
    "76": 7,
    "78": 45
  },
  "categoryDiversity": {
    "5": 400
  },
  "properNouns": {
    "3": 336,
    "4": 64
  },
  "specialistCards": {
    "0": 306,
    "1": 94
  },
  "accessible": {
    "2": 324,
    "3": 73,
    "4": 3
  },
  "times": {
    "29": 258,
    "30": 93,
    "29.5": 48,
    "30.5": 1
  },
  "errors": [],
  "examples": [
    [
      "Boxing (easy)",
      "Herentals (medium)",
      "Katy Perry (medium)",
      "Queen Sono (hard)",
      "Joshua Nkomo (easy)"
    ],
    [
      "Fried bream (easy)",
      "Pastor Charles Charamba (medium)",
      "Wrestling (easy)",
      "Dangote (medium)",
      "Weekend Special (hard)"
    ],
    [
      "System Tazvida (hard)",
      "Rangers (easy)",
      "Night shift (easy)",
      "National Heroes Acre (medium)",
      "Pinterest (medium)"
    ]
  ]
}
```
