# Classical Charades candidate editorial audit — second pass

Original main commit 0490b43da806ac7610245f99a59867c997e9b34d, original blob 436bb449842d4720d9a1bde340e964ec029de5b3. Full 600-row original dataset parsed. The five problematic categories total 342 cards (57%): 103 everyday actions, 64 funny/awkward, 76 Zimbabwean situations, 64 African situations, 35 relationship/social. Additional generic technology and biblical stories were removed. Original difficulty 308 easy / 227 medium / 65 hard.

## Mapping

| Disposition | Count |
|---|---:|
| RETAIN | 72 |
| REPLACE | 429 |
| REFINE | 99 |

Original ID coverage: 600. RETAIN = same answer and category, REFINE = wording or category change without replacing underlying identity, REPLACE = different concept, including story-to-character. Original stable IDs preserved where mapped identity survived; genuinely replaced slots have successor IDs. The second pass replaced 47 candidates, notably weak celebrity, game, title and general-knowledge candidates, and adjusted 6 difficulty assignments to recover quotas. Some strong prior IDs could not be recovered because replacements were made after slot mapping; check log before further edits.

## Current distributions

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


The candidate contains established names, titles, expressions, nouns, games and activities. Landmark, Cultural Symbol, Sports Team, Historical Figure, Food, Dance and Traditional Game are additional context labels. These broaden the audience's knowledge pathways and were chosen rather than forcing weak local celebrity names. Regional targets remain unmet; labels classify regional origin/relevance, not familiarity. Native-language accuracy and cross-linguistic fairness require review.

## Quality and limitations

Two single-editor passes, not independent agents. First pass curated explicit prompt/hint candidates, normalized and mapped them; second pass addressed conspicuous weak items, sports-personality underrepresentation, regional gaps and Bible identity mapping. Quantitative scoring remains heuristic; individual ratings not independently established. Mean 83.48%; 65 provisional rubric failures. Neither the 92% editorial quality target nor all individual gates is satisfied. This is a draft candidate, not a release deck. Some remaining musicians, athletes, local programmes and abstract proverbs have weak convergence. Related titles/characters and similar games still need human semantic review; no claims of complete semantic de-duplication. No measured familiarity, human playtesting, exhaustive named-source verification or Flutter runtime execution. Review and retest failures rather than upgrading ratings to make targets pass.

## Second-pass replacements

| First candidate | Revised candidate |
|---|---|
| The Spiderwick Chronicles | Sarafina! |
| The Golden Compass | Mr. Bones |
| The Good Doctor | Victoria Falls |
| Grey's Anatomy | Great Zimbabwe |
| House | Chiremba Balancing Rocks |
| National Geographic | Lake Kariba |
| The Flintstones | The Floor Is Lava |
| Barack Obama | Usain Bolt |
| Steve Jobs | Kirsty Coventry |
| Elon Musk | Michael Jordan |
| Bill Gates | Muhammad Ali |
| Mark Zuckerberg | Serena Williams |
| Oprah Winfrey | Siya Kolisi |
| Simon Cowell | Stephen Curry |
| Burna Boy | Mo Salah |
| Diamond Platnumz | Didier Drogba |
| Fela Kuti | Eliud Kipchoge |
| Perfect | The Three Musketeers |
| Butter | Walking on Sunshine |
| Dynamite | Here Comes the Sun |
| EA Sports FC | Lionel Messi |
| PUBG Mobile | Tiger Woods |
| Call of Duty | Mike Tyson |
| Clash of Clans | Zimbabwe Bird |
| Clash Royale | Chara Chimwe Hachitswanyi Inda |
| Free Fire | Izandla Ziyagezana |
| The Fisherman and His Wife | Treasure Island |
| Mancala | Jerusarema Dance |
| Like a Bull in a China Shop | Rume Rimwe Harikombi Churu |
| Out of the Frying Pan into the Fire | Kandiro Kanoenda Kunobva Kamwe |
| Cross That Bridge When You Come to It | Umuntu Ngumuntu Ngabantu |
| Armageddon | The Woman King |
| War of the Worlds | Tsotsi |
| Pacific Rim | District 9 |
| Real Steel | Queen of Katwe |
| The Lego Movie | Chicken Run |
| Odie | Anansi |
| Orchestra Conductor | Djembe |
| Veterinarian | Kora |
| Beekeeper | Vuvuzela |
| Metal Detector | Bunny Chow |
| Bricklayer | Duri neMutswi |
| Mechanic | Ngoma |
| Arm Wrestling | Morabaraba |
| Fencing | Capoeira |
| Horse Racing | Springboks |
| Dwayne Johnson | Shaka Zulu |
