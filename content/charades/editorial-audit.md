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


# Targeted contemporary refinement — 25 November 2026

Base: 9462a219a957e28cf1fd0c7a9738dfbac4f7104c. Final comparison is against that branch head, not the intermediate candidate commit. 54 answers replaced, 546 unchanged identities with stable IDs. Two targeted passes, not independent reviewers. All 65 previous provisional failures reviewed; details in contemporary-failure-review.jsonl. Changes recorded in contemporary-refinement-log.jsonl, while revision-log.jsonl continues the full mapping to the original 600-card dataset.

| Player-facing category | Before | After | Flexible target |
|---|---:|---:|---:|
| Internet Personality | 3 | 11 | 20 |
| Musician | 12 | 28 | 30 |
| Comedian | 5 | 12 | 10 |
| Famous Person | 7 | 12 | 10 |

Additional labels Internet Creator (collective) and Online Show (title, not individual host) avoid misleading identity classifications.

| Region | Before | After |
|---|---:|---:|
| international | 519 | 481 |
| africa-regional | 40 | 63 |
| zimbabwe-national | 41 | 56 |

Regional combined 119/600 = 19.83%. Region denotes origin or major cultural association, not surveyed familiarity. Khaby Lame retains international/global classification for comparability; no quota-driven reassignment.

## Final replacement decisions

| Previous answer | New answer | Category | Provisional score |
|---|---|---|---:|
| The Croods | Ndombolo | Dance | 70% |
| Finding Dory | Dude Perfect | Internet Creator | 87% |
| The Angry Birds Movie | Wavin' Flag | Song | 89% |
| The Secret Life of Pets | Cook Off | Movie | 80% |
| The Polar Express | Bako Rangu | Song | 74% |
| Gravity | Ndinobuda Pakaoma | Song | 74% |
| The Dark Knight | Sulumani Chimbetu | Musician | 74% |
| Arrow | Davido | Musician | 84% |
| The Simpsons | Zlatan Ibile | Musician | 76% |
| Family Guy | Kizz Daniel | Musician | 88% |
| The Big Bang Theory | Sabhuku Vharazipi | Comedian | 81% |
| Brooklyn Nine-Nine | Mark Rober | Internet Personality | 79% |
| The Fresh Prince of Bel-Air | Will Smith | Famous Person | 88% |
| Young Sheldon | Uncle Waffles | Musician | 88% |
| The Amazing Race | Nathaniel Bassey | Musician | 85% |
| Formula 1: Drive to Survive | Kamo Mphela | Musician | 76% |
| The Great British Bake Off | Tyla | Musician | 92% |
| Blue Planet | Minister Michael Mahendere | Musician | 71% |
| The Penguins of Madagascar | Enzo Ishall | Musician | 88% |
| Miraculous: Tales of Ladybug & Cat Noir | Hope Masike | Musician | 76% |
| The Queen | Comic Elder | Comedian | 81% |
| Uzalo | Oga Sabinus | Comedian | 88% |
| Skeem Saam | Mama Vee | Comedian | 75% |
| Green Lantern | Laiza the Mop Driver | Internet Personality | 80% |
| Robin | Dwayne Johnson | Famous Person | 96% |
| Hawkeye | Magriza Made Me Cook | Online Show | 66% |
| Ant-Man | John Cena | Famous Person | 96% |
| Rocket Raccoon | Jadrolita | Internet Personality | 80% |
| Hagrid | Lasisi Elenu | Comedian | 76% |
| Dobby | Pawpaw (Osita Iheme) | Famous Person | 75% |
| Albus Dumbledore | Brain Jotter | Comedian | 88% |
| Ariel | African Queen | Song | 81% |
| Patrick Star | Sydney Talker | Internet Personality | 74% |
| Squidward | Salt Bae | Internet Personality | 88% |
| Mr. Krabs | Kapfupi | Comedian | 71% |
| Sylvester | Zach King | Internet Personality | 80% |
| Road Runner | Blood & Water | TV Show | 80% |
| Goofy | Dream | Internet Personality | 75% |
| Jafar | Nixxi The Codebreaker | Internet Personality | 74% |
| Dancing Queen | Beyoncé | Musician | 87% |
| The Lion Sleeps Tonight | Danai Gurira | Famous Person | 85% |
| Counting Stars | PSY | Musician | 91% |
| Shape of You | Rema | Musician | 81% |
| Photograph | Way Maker | Song | 85% |
| This Little Light of Mine | Shakira | Musician | 87% |
| Mafaro | Hello Mwari | Song | 85% |
| Musarova Bigman | Machira Chete | Song | 81% |
| Isaac | Tshwala Bam | Dance | 84% |
| Miriam | Shaku Shaku | Dance | 76% |
| Ruth | Coffin Dance | Internet Meme | 92% |
| Thomas | Pantsula | Dance | 81% |
| The Cat in the Hat | Skelewu | Dance | 70% |
| The Princess and the Pea | Shoki | Dance | 70% |
| The Writing on the Wall | Makhadzi | Musician | 70% |

## Quality review

Prior heuristic average 83.48%; current 83.62%. Prior 65 provisional failures; now 70. Of new replacements 21 remain flagged. Prior failure dispositions: {"retain-flagged":36,"replace":11,"retain-refine":18}. The independently supplied 8.9/10 baseline is a different assessment, not comparable to these heuristics. The 92% target is not established. No blanket rescoring. Six specific cards reassessed with explicit concrete rationale: Jah Prayzah: Military-regalia band identity explicitly documented by artist; combination of salute and musician category distinguishes him. Prior 3/5 gesture and specificity underestimated the concrete persona.; IShowSpeed: January 2026 Zimbabwe tour documents relevant recognition context; safe hand-figure backflip plus Siu in livestream context supplies two distinct signature cues. Ronaldo overlap remains a review risk.; Laiza the Mop Driver: The established name and reported mop-driver persona supply a direct, distinctive physical route. Familiarity remains 3/5, not inferred from reach.; Great Zimbabwe: Dry-stone walls plus conical tower give a specific visual combination, not merely building; cultural landmark relevance high, recognition still estimated.; Chiremba Balancing Rocks: Distinct stacked rock formation and banknote cue provide specific combination; keep subject to landmark playtest.; Joseph: Coat plus seven ears of grain and dream interpretation distinguish Joseph son of Jacob from other biblical Josephs; church-youth audience estimate only.. All other retained scores remain unchanged. Newly added identities scored conservatively; do not count fame as evidence of solvability.

Second screening removed Killer T's primarily audible signature in favour of a recognisable song title, separated the online show from its host, removed shared Zlatan/Zanku pathways, and restored two prior answers where proposed creators lacked enough specific nonverbal cues. Artist identities and dance/song cards may still share visual cues (e.g. Shakira/Waka Waka, Beyoncé/Single Ladies and PSY/Gangnam Style); shown category helps but human convergence testing remains necessary. Dances whose exact choreography has not been independently inspected remain flagged. Rejected additional high-follower personalities without distinct visual motifs; did not force Internet Personality target. Contemporary musicians and skit creators remain the key improvement, but no empirical Zimbabwean audience evidence was collected. Some older local references remain intentionally because they connect age groups and church gatherings.

## Zimbabwean youth gathering perspective

A participant can now mime the Kanjiva, Buga, Water and Unavailable performances, the silent robot persona, a mop-driver video, the Gwo Gwo Ngwo dance-comedy personality, a film actor's two roles, and established local gospel/song titles. Reduced secondary superhero, animated, television and film overlaps; preserved core titles and most specific Bible characters. A 16-year-old and a 30-year-old may differ substantially in local social media exposure, and group familiarity remains untested. More local candidates are identified in research, but those depending on voice, niche trends or generic skits were not used to satisfy quotas. All draft, releaseReady false.

Prior audit text is historical; the final tables above supersede its current counts.
