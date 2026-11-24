# Validation report — contemporary refinement, 2026-11-25

Supersedes the second-pass current counts. Executed JavaScript validation against serialized JSONL in the working environment; 0 structural errors. Exactly 600 rows, 600 unique IDs, 600 normalized unique prompts; all 600 original mapping IDs and all 600 current successors unique; no cross-card normalized alias collisions. All old unchanged IDs retained, all prior 65 flagged cards reviewed, all records draft. Checked existing fields, schema 3.1.0, gameType, category, difficulty, canonical answer, aliases, word count, two hints, scenario prefix, Bible character allowlist, exact successor prompt and difficulty, difficulty histogram. Heuristic checks are not semantic verification.

| Player-facing category | Cards |
|---|---:|
| Movie | 95 |
| TV Show | 35 |
| Musician | 31 |
| Comedian | 11 |
| Internet Personality | 13 |
| Famous Person | 11 |
| Landmark | 4 |
| Fictional Character | 74 |
| Song | 37 |
| Music Genre | 1 |
| Historical Figure | 1 |
| Sports Personality | 14 |
| Book | 21 |
| Sport | 27 |
| Sporting Activity | 16 |
| Sports Team | 1 |
| Traditional Game | 5 |
| Dance | 9 |
| Video Game | 26 |
| Cultural Symbol | 1 |
| Proverb | 5 |
| Internet Meme | 5 |
| Bible Character | 34 |
| Idiom | 68 |
| Animal | 23 |
| Occupation | 13 |
| Object | 13 |
| Food | 6 |

| Production category | Cards |
|---|---:|
| Movies | 95 |
| Television programmes and series | 35 |
| Famous people and celebrities | 54 |
| Internet personalities and gaming | 44 |
| Established cultural references | 10 |
| Fictional and animated characters | 74 |
| Songs and musical works | 37 |
| Sports and sporting personalities | 68 |
| Books and literature | 21 |
| Established idioms and popular expressions | 73 |
| Bible characters | 34 |
| Animals, objects and occupations | 55 |

| Difficulty | Cards |
|---|---:|
| easy | 180 |
| medium | 300 |
| hard | 120 |

| Region | Cards |
|---|---:|
| international | 489 |
| africa-regional | 61 |
| zimbabwe-national | 50 |

| Disposition | Cards |
|---|---:|
| RETAIN | 72 |
| REPLACE | 429 |
| REFINE | 99 |

Provisional threshold failures: 76; heuristic average 83.47%. 92% target not attained. Failed cards: Sarafina!; Mr. Bones; The Woman King; Tsotsi; District 9; Queen of Katwe; Zlatan Ibile; Kai Cenat; Victoria Falls; Great Zimbabwe; Chiremba Balancing Rocks; Kamo Mphela; Minister Michael Mahendere; Lake Kariba; Hope Masike; Mama Vee; Gringo; Laiza the Mop Driver; Magriza Made Me Cook; Lasisi Elenu; Pawpaw (Osita Iheme); Amapiano; Dream; Wian; Poco Lee; William Last KRM; Shaka Zulu; Kirsty Coventry; Serena Williams; Siya Kolisi; Jah Prayzah; Oliver Mtukudzi; Winky D; Thomas Mapfumo; Tongai Moyo; Madam Boss; Mai Titi; Comic Pastor; Eliud Kipchoge; Brenda Fassie; Miriam Makeba; Hugh Masekela; Mo Salah; Didier Drogba; Mkhululi Bhebhe; Sinach; Mudhara Vachauya; Killer T; Kure Kure; Charles Charamba; Neria; Springboks; Morabaraba; Jerusarema Dance; Lionel Messi; Tiger Woods; Mike Tyson; Zimbabwe Bird; Chara Chimwe Hachitswanyi Inda; Izandla Ziyagezana; MrBeast; IShowSpeed; Sarah; Joseph; Shaku Shaku; Zanku; Naomi; Mary Magdalene; Kandiro Kanoenda Kunobva Kamwe; Makhadzi; Umuntu Ngumuntu Ngabantu; Rume Rimwe Harikombi Churu; Kora; Duri neMutswi; Ngoma; Djembe.

## Runtime

Existing adapter reads cardId, gameType, schemaVersion, prompt, playableCategory and difficulty; runtime strips hints. No code/UI changes. Python validator provided and maintained but not executed here. Dart/Flutter tests not executed. Named-reference verification limited, human recognition, semantic overlap and difficulty validation pending. ReleaseReady remains false. No independent agents or human playtest claims.
