# Executed validation

PASS: 0 errors from actual assembly and validation functions, after JSONL serialization and parsing of all 400 cards and 2,000 terms. Checks cover counts, normalized canonical uniqueness, IDs, exactly-once assignment, 2/2/1 difficulty, recomputed composition constraints/metrics and field presence. Canonical normalized uniqueness does not imply semantic uniqueness; domain and celebrity flags are provisional. The Python scripts launch the exact JavaScript core; core was executed in the available JS runtime, not via Python/Node CLI. No runtime application integration tests. Editorial gates, full source verification, 92% quality and card-level rubric certification are outstanding. Candidate is not release-ready.

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
