# Validation report — candidate, 2026-11-25

Executed JavaScript structural checks against serialized JSONL before commit (not the Python program and not Flutter). Results:

- Card count: 600; unique normalized prompts: 600.
- Unique IDs: 600; original mapping coverage: 600.
- Structural errors: 0; normalized alias collisions: 0.
- All records have original required keys, supported category, 3.1.0 schema, valid difficulty, computed word count, canonical alias and two or more hints.
- Bible subset checked against explicit character allowlist; no story prompts.
- Adapter inspection: app/tool/build_content.dart emits id,p,c,d, with c=playableCategory; play_charades.dart renders category/difficulty and FitText. No Dart execution, device layout testing, deck selection or gameplay test performed.

## Counts

| Category | Count |
|---|---:|
| Movies | 95 |
| Television programmes and series | 55 |
| Fictional and animated characters | 90 |
| Famous people and celebrities | 35 |
| Songs and musical works | 45 |
| Sports and sporting personalities | 55 |
| Internet personalities and gaming | 40 |
| Bible characters | 38 |
| Books and literature | 20 |
| Established idioms and popular expressions | 72 |
| Animals, objects and occupations | 55 |

| Player-facing category | Count |
|---|---:|
| Movie | 95 |
| TV Show | 55 |
| Fictional Character | 90 |
| Musician | 15 |
| Comedian | 5 |
| Famous Person | 15 |
| Song | 45 |
| Sport | 28 |
| Sporting Activity | 17 |
| Traditional Game | 5 |
| Dance | 4 |
| Sports Personality | 1 |
| Video Game | 32 |
| Internet Personality | 3 |
| Internet Meme | 5 |
| Bible Character | 38 |
| Book | 20 |
| Idiom | 72 |
| Animal | 23 |
| Occupation | 18 |
| Object | 9 |
| Food | 5 |

| Difficulty | Count |
|---|---:|
| easy | 180 |
| medium | 300 |
| hard | 120 |

| Region | Count |
|---|---:|
| international | 548 |
| africa-regional | 25 |
| zimbabwe-national | 27 |

## Editorial estimates (not measured)

| Score | Cards |
|---|---:|
| 62 | 36 |
| 63 | 23 |
| 84 | 335 |
| 85 | 27 |
| 89 | 177 |
| 90 | 2 |

Mean: 83.42%. Provisional threshold failures: 59. All are drafts, even those whose heuristic estimates pass. This is not release validation; 92% target and human testing remain outstanding.

Flagged prompts: The Spiderwick Chronicles; The Golden Compass; The Flintstones; The Simpsons; The Good Doctor; Grey's Anatomy; House; National Geographic; The Queen; Uzalo; Skeem Saam; Gringo; Barack Obama; Steve Jobs; Elon Musk; Bill Gates; Mark Zuckerberg; Oprah Winfrey; Simon Cowell; Jah Prayzah; Oliver Mtukudzi; Winky D; Thomas Mapfumo; Tongai Moyo; Madam Boss; Mai Titi; Comic Pastor; Fela Kuti; Brenda Fassie; Miriam Makeba; Hugh Masekela; Burna Boy; Diamond Platnumz; Shape of You; Perfect; Butter; Dynamite; Mudhara Vachauya; Mafaro; Kure Kure; Musarova Bigman; Neria; EA Sports FC; PUBG Mobile; Call of Duty; Clash of Clans; Clash Royale; Free Fire; MrBeast; IShowSpeed; Sarah; Isaac; Joseph; Miriam; Ruth; Naomi; Thomas; Mary Magdalene; The Fisherman and His Wife.

Semantic concerns: related films/characters and similar TV titles may share mime pathways; broad musician/athlete identities, abstract expressions and local-language variants need direct review. Automated normalization is not semantic verification. Python validator provided but not executed in this environment.
