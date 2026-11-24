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


# Contemporary popular culture refinement — 25 November 2026

Base 9462a219a957e28cf1fd0c7a9738dfbac4f7104c; exactly 45 targeted replacements; 65 previously flagged cards reviewed. Original and previous branch identities recorded in contemporary-refinement-log.jsonl. Existing canonical schema and all unchanged IDs preserved. No game UI or other dataset changes. Draft only.

| Player-facing category | Before | After | Flexible target |
|---|---:|---:|---:|
| Internet Personality | 3 | 13 | 20 |
| Musician | 12 | 31 | 30 |
| Comedian | 5 | 11 | 10 |
| Famous Person | 7 | 11 | 10 |

| Regional classification | Before | After |
|---|---:|---:|
| international | 519 | 489 |
| africa-regional | 40 | 61 |
| zimbabwe-national | 41 | 50 |

Combined Zimbabwean and African representation: 111/600 (18.50%). Region denotes origin or primary cultural association, not audience survey evidence. Targets were not forced with poor candidates. Internet creator counts include a channel-host brand (Magriza Made Me Cook) as an accepted host alias. Additional cultural labels remain clear. Some artists are deliberately retained with flags, and some new ones also have low convergence scores. No attempt to claim 92% by recoding estimates.

## Changed answers

| Previous answer | New answer | Category | Region | Provisional score |
|---|---|---|---|---:|
| Green Lantern | Laiza the Mop Driver | Internet Personality | zimbabwe-national | 76% |
| Hawkeye | Magriza Made Me Cook | Internet Personality | zimbabwe-national | 66% |
| Rocket Raccoon | Jadrolita | Internet Personality | africa-regional | 80% |
| Mr. Potato Head | William Last KRM | Internet Personality | africa-regional | 70% |
| Pluto | Wian | Internet Personality | africa-regional | 70% |
| Sylvester | Zach King | Internet Personality | international | 80% |
| Goofy | Dream | Internet Personality | international | 75% |
| Squidward | Salt Bae | Internet Personality | international | 88% |
| Jafar | Poco Lee | Internet Personality | africa-regional | 70% |
| The Penguins of Madagascar | Enzo Ishall | Musician | zimbabwe-national | 88% |
| Miraculous: Tales of Ladybug & Cat Noir | Hope Masike | Musician | zimbabwe-national | 76% |
| Blue Planet | Minister Michael Mahendere | Musician | zimbabwe-national | 71% |
| The Amazing Race | Nathaniel Bassey | Musician | africa-regional | 85% |
| The Great British Bake Off | Tyla | Musician | africa-regional | 92% |
| Young Sheldon | Uncle Waffles | Musician | africa-regional | 88% |
| Formula 1: Drive to Survive | Kamo Mphela | Musician | africa-regional | 76% |
| Arrow | Davido | Musician | africa-regional | 84% |
| Family Guy | Kizz Daniel | Musician | africa-regional | 88% |
| Shape of You | Rema | Musician | africa-regional | 81% |
| Photograph | Sinach | Musician | africa-regional | 71% |
| Counting Stars | PSY | Musician | international | 91% |
| Dancing Queen | Beyoncé | Musician | international | 87% |
| This Little Light of Mine | Shakira | Musician | international | 87% |
| The Big Bang Theory | Sabhuku Vharazipi | Comedian | zimbabwe-national | 81% |
| Skeem Saam | Mama Vee | Comedian | zimbabwe-national | 75% |
| The Queen | Comic Elder | Comedian | zimbabwe-national | 81% |
| Uzalo | Oga Sabinus | Comedian | africa-regional | 88% |
| Albus Dumbledore | Brain Jotter | Comedian | africa-regional | 88% |
| Hagrid | Lasisi Elenu | Comedian | africa-regional | 76% |
| Dobby | Pawpaw (Osita Iheme) | Famous Person | africa-regional | 75% |
| Robin | Dwayne Johnson | Famous Person | international | 96% |
| Ant-Man | John Cena | Famous Person | international | 96% |
| Isaac | Tshwala Bam | Dance | africa-regional | 84% |
| Miriam | Shaku Shaku | Dance | africa-regional | 76% |
| Ruth | Zanku | Dance | africa-regional | 76% |
| Thomas | Pantsula | Dance | africa-regional | 81% |
| The Writing on the Wall | Makhadzi | Musician | africa-regional | 70% |
| Mafaro | Killer T | Musician | zimbabwe-national | 71% |
| Musarova Bigman | Charles Charamba | Musician | zimbabwe-national | 71% |
| The Simpsons | Zlatan Ibile | Musician | africa-regional | 76% |
| The Fresh Prince of Bel-Air | Will Smith | Famous Person | international | 88% |
| Brooklyn Nine-Nine | Kai Cenat | Internet Personality | international | 65% |
| Ariel | African Queen | Song | africa-regional | 81% |
| Road Runner | Amapiano | Music Genre | africa-regional | 75% |
| The Lion Sleeps Tonight | Mkhululi Bhebhe | Musician | zimbabwe-national | 66% |

## Review of all prior provisional failures

| Prompt | Decision | Rationale |
|---|---|---|
| Sarafina! | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| Mr. Bones | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| The Woman King | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| Tsotsi | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| District 9 | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| Queen of Katwe | retain-flagged | Retain established African film for regional diversity; test title-specific convergence. |
| The Simpsons | replace | Targeted enrichment; see replacement mapping. |
| Victoria Falls | retain-refine-hints | Keep iconic landmark; possible generic waterfall guess. |
| Great Zimbabwe | retain-refine-hints | Specific visual architecture; preserve but do not inflate score. |
| Chiremba Balancing Rocks | retain-refine-hints | Banknote link adds a local cue; keep flag pending recognition. |
| Lake Kariba | retain-flagged | Not selected for limited replacement budget; still requires human recognition and convergence review. |
| The Queen | replace | Targeted enrichment; see replacement mapping. |
| Uzalo | replace | Targeted enrichment; see replacement mapping. |
| Skeem Saam | replace | Targeted enrichment; see replacement mapping. |
| Gringo | retain-refine-hints | Legacy Zimbabwean reference; candidate remains flagged. |
| Shaka Zulu | retain-flagged | Not selected for limited replacement budget; still requires human recognition and convergence review. |
| Kirsty Coventry | retain-refine-hints | Zimbabwean relevance high; signature remains insufficiently distinctive. |
| Serena Williams | retain-refine-hints | Still overlaps tennis athletes. |
| Siya Kolisi | retain-flagged | Recognisable athlete with recorded gesture pathway but overlaps with athletes in same sport; test independently. |
| Jah Prayzah | retain-refine-hints | The artist's documented military-style stage identity distinguishes him; keep same identity. |
| Oliver Mtukudzi | retain-refine-hints | Preserve local classic; title clue remains weak. |
| Winky D | retain-refine-hints | Youth relevance supported, but second route remains weak; keep prior score. |
| Thomas Mapfumo | retain-flagged | Established local or regional music identity; test signature-pathway convergence rather than relying on genre. |
| Tongai Moyo | retain-flagged | Established local or regional music identity; test signature-pathway convergence rather than relying on genre. |
| Madam Boss | retain-refine-hints | Specific skit identification remains uncertain. |
| Mai Titi | retain-refine-hints | Keep culturally relevant but still flagged. |
| Comic Pastor | retain-refine-hints | Preserve Zimbabwean comedy history; avoid religious mockery. |
| Eliud Kipchoge | retain-flagged | Recognisable athlete with recorded gesture pathway but overlaps with athletes in same sport; test independently. |
| Brenda Fassie | retain-flagged | Established local or regional music identity; test signature-pathway convergence rather than relying on genre. |
| Miriam Makeba | retain-flagged | Established local or regional music identity; test signature-pathway convergence rather than relying on genre. |
| Hugh Masekela | retain-flagged | Established local or regional music identity; test signature-pathway convergence rather than relying on genre. |
| Mo Salah | retain-refine-hints | Distinct celebration, but no independent test. |
| Didier Drogba | retain-flagged | Recognisable athlete with recorded gesture pathway but overlaps with athletes in same sport; test independently. |
| Shape of You | replace | Targeted enrichment; see replacement mapping. |
| Mudhara Vachauya | retain-flagged | Preserve established regional song where practical; title-based gestures must be checked without singing. |
| Mafaro | replace | Targeted enrichment; see replacement mapping. |
| Kure Kure | retain-flagged | Preserve established regional song where practical; title-based gestures must be checked without singing. |
| Musarova Bigman | replace | Targeted enrichment; see replacement mapping. |
| Neria | retain-flagged | Preserve established regional song where practical; title-based gestures must be checked without singing. |
| Springboks | retain-flagged | Not selected for limited replacement budget; still requires human recognition and convergence review. |
| Morabaraba | retain-flagged | Not selected for limited replacement budget; still requires human recognition and convergence review. |
| Jerusarema Dance | retain-refine-hints | Preserve cultural relevance; local dance practitioner should verify. |
| Lionel Messi | retain-flagged | Recognisable athlete with recorded gesture pathway but overlaps with athletes in same sport; test independently. |
| Tiger Woods | retain-flagged | Recognisable athlete with recorded gesture pathway but overlaps with athletes in same sport; test independently. |
| Mike Tyson | retain-refine-hints | Keep boxing identity, no unsafe contact. |
| Zimbabwe Bird | retain-flagged | Conventional regional concept, not a scenario; confirm specific identification and language variants. |
| Chara Chimwe Hachitswanyi Inda | retain-flagged | Preserve language/cultural identity; native speakers must verify expression and gesture pathway. |
| Izandla Ziyagezana | retain-flagged | Preserve language/cultural identity; native speakers must verify expression and gesture pathway. |
| MrBeast | retain-refine-hints | Still depends on creator recognition; keep flag. |
| IShowSpeed | retain-refine-hints | 2026 Zimbabwe visit confirms local relevance; gesture may be confused with Ronaldo so retain flag. |
| Sarah | retain-flagged | Preserve specific biblical identity and scriptural pathway; test character-name convergence with church youth. |
| Isaac | replace | Targeted enrichment; see replacement mapping. |
| Joseph | retain-refine-hints | Specific Old Testament identity strengthened; no score change. |
| Miriam | replace | Targeted enrichment; see replacement mapping. |
| Ruth | replace | Targeted enrichment; see replacement mapping. |
| Naomi | retain-flagged | Preserve specific biblical identity and scriptural pathway; test character-name convergence with church youth. |
| Thomas | replace | Targeted enrichment; see replacement mapping. |
| Mary Magdalene | retain-flagged | Preserve specific biblical identity and scriptural pathway; test character-name convergence with church youth. |
| Kandiro Kanoenda Kunobva Kamwe | retain-flagged | Preserve language/cultural identity; native speakers must verify expression and gesture pathway. |
| Umuntu Ngumuntu Ngabantu | retain-flagged | Preserve language/cultural identity; native speakers must verify expression and gesture pathway. |
| Rume Rimwe Harikombi Churu | retain-flagged | Preserve language/cultural identity; native speakers must verify expression and gesture pathway. |
| Kora | retain-flagged | Conventional regional concept, not a scenario; confirm specific identification and language variants. |
| Duri neMutswi | retain-flagged | Conventional regional concept, not a scenario; confirm specific identification and language variants. |
| Ngoma | retain-flagged | Conventional regional concept, not a scenario; confirm specific identification and language variants. |
| Djembe | retain-flagged | Conventional regional concept, not a scenario; confirm specific identification and language variants. |

Review is single-editor, not independent. Source-linked mime clues describe recognised performance motifs or editorial title-wordplay, not proven distinctiveness. No score changed on retained cards. New candidates individually rated on four dimensions with explicit scores; remaining three dimensions derived conservatively from clue quality, region and accessibility. This is not comparable to the user's independent provisional 8.9/10 rating. Prior heuristic mean 83.48%; current 83.47%; prior 65 flags, current 76. Score target 92% remains unfulfilled. Difficulty carried forward from slots and swapped only among new candidates when possible; empirical calibration pending. Remaining flagged prompts: Sarafina!; Mr. Bones; The Woman King; Tsotsi; District 9; Queen of Katwe; Zlatan Ibile; Kai Cenat; Victoria Falls; Great Zimbabwe; Chiremba Balancing Rocks; Kamo Mphela; Minister Michael Mahendere; Lake Kariba; Hope Masike; Mama Vee; Gringo; Laiza the Mop Driver; Magriza Made Me Cook; Lasisi Elenu; Pawpaw (Osita Iheme); Amapiano; Dream; Wian; Poco Lee; William Last KRM; Shaka Zulu; Kirsty Coventry; Serena Williams; Siya Kolisi; Jah Prayzah; Oliver Mtukudzi; Winky D; Thomas Mapfumo; Tongai Moyo; Madam Boss; Mai Titi; Comic Pastor; Eliud Kipchoge; Brenda Fassie; Miriam Makeba; Hugh Masekela; Mo Salah; Didier Drogba; Mkhululi Bhebhe; Sinach; Mudhara Vachauya; Killer T; Kure Kure; Charles Charamba; Neria; Springboks; Morabaraba; Jerusarema Dance; Lionel Messi; Tiger Woods; Mike Tyson; Zimbabwe Bird; Chara Chimwe Hachitswanyi Inda; Izandla Ziyagezana; MrBeast; IShowSpeed; Sarah; Joseph; Shaku Shaku; Zanku; Naomi; Mary Magdalene; Kandiro Kanoenda Kunobva Kamwe; Makhadzi; Umuntu Ngumuntu Ngabantu; Rume Rimwe Harikombi Churu; Kora; Duri neMutswi; Ngoma; Djembe. Prior audit is historical; this addendum supersedes its current counts.

## Zimbabwean youth perspective

Compared with the baseline's redundant cartoons and secondary superhero characters, creator and music additions offer more opportunities to act out TikTok/YouTube identities and Afrobeats, amapiano and Zimbabwean performance motifs. Contemporary relevance is stronger, but coverage is not uniform across ages, rural/urban access and languages. Broad fame, award nominations and online reach cannot guarantee silent identification. Several local creators were rejected for voice-dependent or generic clues. Similar song and artist associations may still overlap; displayed category mitigates but does not resolve them. Retain the draft gate until representative playtests, source and safety review, and Flutter tests are complete.
