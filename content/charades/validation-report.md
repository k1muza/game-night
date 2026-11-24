# Validation report — second pass, 2026-11-25

Executed JavaScript checks of the full serialized JSONL and revision mapping. Results: 600 valid rows, 600 distinct IDs, 600 distinct normalized canonical answers, 600 original mappings, 0 structural errors, 0 cross-card normalized alias collisions. Checked original field names, valid categories, difficulty, 3.1.0 schema, canonical alias, word count, two or more hints, draft status and biblical character scripture-locator presence. Biblical allowlist remains enforced in supplied Python validator. No banned generic category labels in generated records. This is structural validation, not semantic or audience verification.

| Production category | Cards |
|---|---:|
| Movies | 95 |
| Television programmes and series | 51 |
| Established cultural references | 5 |
| Fictional and animated characters | 90 |
| Famous people and celebrities | 25 |
| Sports and sporting personalities | 68 |
| Songs and musical works | 44 |
| Books and literature | 21 |
| Internet personalities and gaming | 34 |
| Established idioms and popular expressions | 74 |
| Bible characters | 38 |
| Animals, objects and occupations | 55 |

| Player-facing category | Cards |
|---|---:|
| Movie | 95 |
| TV Show | 51 |
| Landmark | 4 |
| Fictional Character | 90 |
| Musician | 12 |
| Comedian | 5 |
| Famous Person | 7 |
| Historical Figure | 1 |
| Sports Personality | 14 |
| Song | 44 |
| Book | 21 |
| Sport | 27 |
| Sporting Activity | 16 |
| Sports Team | 1 |
| Traditional Game | 5 |
| Dance | 5 |
| Video Game | 26 |
| Cultural Symbol | 1 |
| Proverb | 5 |
| Internet Personality | 3 |
| Internet Meme | 5 |
| Bible Character | 38 |
| Idiom | 69 |
| Animal | 23 |
| Occupation | 13 |
| Object | 13 |
| Food | 6 |

| Difficulty | Cards |
|---|---:|
| easy | 180 |
| medium | 300 |
| hard | 120 |

| Regional origin/relevance (editorial estimate) | Cards |
|---|---:|
| international | 519 |
| africa-regional | 40 |
| zimbabwe-national | 41 |


| Heuristic score | Cards |
|---|---:|
| 62 | 12 |
| 63 | 20 |
| 67 | 4 |
| 68 | 29 |
| 84 | 330 |
| 85 | 30 |
| 89 | 173 |
| 90 | 2 |

Mean 83.48%; 65 provisional threshold failures. Target 92% not met. All records remain draft.

Flagged prompts: Sarafina!; Mr. Bones; The Woman King; Tsotsi; District 9; Queen of Katwe; The Simpsons; Victoria Falls; Great Zimbabwe; Chiremba Balancing Rocks; Lake Kariba; The Queen; Uzalo; Skeem Saam; Gringo; Shaka Zulu; Kirsty Coventry; Serena Williams; Siya Kolisi; Jah Prayzah; Oliver Mtukudzi; Winky D; Thomas Mapfumo; Tongai Moyo; Madam Boss; Mai Titi; Comic Pastor; Eliud Kipchoge; Brenda Fassie; Miriam Makeba; Hugh Masekela; Mo Salah; Didier Drogba; Shape of You; Mudhara Vachauya; Mafaro; Kure Kure; Musarova Bigman; Neria; Springboks; Morabaraba; Jerusarema Dance; Lionel Messi; Tiger Woods; Mike Tyson; Zimbabwe Bird; Chara Chimwe Hachitswanyi Inda; Izandla Ziyagezana; MrBeast; IShowSpeed; Sarah; Isaac; Joseph; Miriam; Ruth; Naomi; Thomas; Mary Magdalene; Kandiro Kanoenda Kunobva Kamwe; Umuntu Ngumuntu Ngabantu; Rume Rimwe Harikombi Churu; Kora; Duri neMutswi; Ngoma; Djembe.

Flutter inspection: app/tool/build_content.dart uses gameType, schemaVersion, ID, prompt, playableCategory and difficulty. play_charades.dart renders these fields; no UI changes required. No actual Dart/Flutter execution, mobile layout check, card repetition test or Correct/Pass test performed. Runtime assets are build-generated; rerun adapter before use. Python validator supplied but not executed here. Named reference verification is limited. The original prompt audit and mapping were comprehensive in row coverage, but replacement reasons are not exhaustive individual research. Semantic overlap, pronunciation/spelling, regional language and safety remain human review gates.
