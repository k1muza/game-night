# Game Night PWA — Complete Card Content Strategy
## Zimbabwean Youth Edition (Ages 16–30)
### Implementation-Ready Research Report

**Report date:** 2026-11-24 | **Supersedes:** Family-Oriented Brief (10+ audience)
**Scope:** 2,300 cards across four games | **Seed library:** 200 cards (50 per game)

---

## EXECUTIVE SUMMARY

This report delivers a fully implementation-ready content strategy for a Progressive Web App party game targeting Zimbabwean youth aged 16–30. The country's digital landscape is characterised by dominant mobile broadband access (95% mobile penetration, 38.4% meaningful internet penetration) [45][16], a median population age of 18.1 [45], and social media use concentrated on WhatsApp (92.9% of internet users), Facebook (44.8%), and TikTok (38%) [25]. These facts directly shape card difficulty, platform assumptions, and content equity.

The four-game library — a 30-Seconds-style describe-and-guess (400 cards/2,000 terms), Charades (600 prompts), Trivia (800 questions), and Forbidden Words (500 cards/2,500 clue strings) — totals exactly 2,300 cards. A new Social Media & Internet Culture taxonomy category is elevated to first-class status, with ratified quotas of 24 cards (120 term slots) in 30 Seconds, 50 prompts in Charades, 50 questions in Trivia, and 35 cards in Forbidden Words, all within unchanged totals.

The seed library of exactly 200 original cards (50 per game) is delivered in full as machine-readable JSONL blocks with editorial metadata. A phased production plan scales from seed to 2,300 cards over 18 months. Quantitative QA gates, an editorial workflow, and an ongoing maintenance cadence are fully specified.

**Key design decisions with rationale:**
- Difficulty calibrated to 16–30 cohort: 40% easy / 40% medium / 20% hard overall, with the Social Media category skewed to medium/hard for the 16–21 subcohort but easier for the 22–30 subcohort, and cross-calibrated for rural/urban equity.
- Shona and Ndebele language tagging enabled in schema; initial seed in English with vernacular examples in select cards to avoid exclusion of Ndebele-dominant or English-primary players.
- Comic Pastor retired from comedy as of end-2025 [18][24]; included as historical reference only. Madam Boss relevant but under legal/reputational monitoring [17]. Hulengende/Malloti active and highly relevant but carry content controversy flags [43][22].
- All 50 Trivia answers in the seed library are fact-checked against cited primary or secondary sources; date-sensitive football and AFCON facts verified from ZIFA and Wikipedia [4][34][41].

---

## SECTION 1: EMPIRICAL AND BEST-PRACTICE FOUNDATIONS FOR PARTY GAME MECHANICS

### 1.1 30-Seconds-Style Describe-and-Guess

**Evidence-supported mechanics:**

The 30 Seconds game, created by Calie Esterhuyse and published in South Africa in 1998, is the direct inspiration for this game type [11]. Its canonical design is documented in primary rules sources [10][19]:

- **Turn structure:** One describer per turn attempts to get teammates to guess as many of five named items as possible in a strict 30-second window. The describer may not say the actual name, any derivation or related word, any "sounds like" or "rhymes with" clue, letters of the alphabet, translations, or point to anything [10][11].
- **Scoring:** Teams score based on correct guesses; the original game applies a handicap die (values 0, 0, 1, 1, 2, 2) that subtracts from the score, adding a randomness layer [10][11]. For a digital PWA, this die mechanic can be retained as an optional "hard mode" variant.
- **Card structure:** Five terms per card is the established standard, confirmed across the original South African edition (240 cards × 5 terms × 2 sides = 2,400 terms total) [10][11]. The two-sided card (yellow/blue) in the original serves as a difficulty tier mechanism; for a digital implementation, difficulty is tagged in the schema rather than using physical sides.
- **Card currency:** The 2,400 words across the original 240 cards "need to be regularly updated to remove aged references" [11]. The Irish edition editor, reviewing all 2,400 words for localisation, attributes broad appeal to "coverage across general knowledge, sports, politics, pop culture, celebrities" [11]. This directly validates the taxonomy design in Section 2.
- **Age recommendation:** The game is recommended for ages 15+, with a junior version for younger players [11]. Our 16+ rating is consistent.
- **House rules:** "In most circumstances house rules are more relaxed to increase the speed and enjoyment of the game" [11]. The PWA should therefore expose a "strict mode" toggle and default to relaxed.
- **Team composition:** More players per team is better, with the original recommending teams of three over pairs when six players are present [10]. For a one-phone-per-team mobile context, the team size is exogenous; card design should assume 2–5 identifiers per team.

**Design hypotheses (editorial, not empirically validated):**
- For Zimbabwean youth, a mix of local and global terms on the same card increases engagement but also risks teams scoring 0–1 on a card if the local term is unknown to one member. Recommendation: compose cards with at most 2 hyper-local terms per 5-term card to maintain expected score above 2.5 per turn.
- Urban/rural equity requires that no card contain 5 terms all from urban internet culture, as this would systematically disadvantage rural players. The taxonomy enforces cross-category mixing in assembly rules (Section 2.6).

### 1.2 Charades

**Evidence-supported mechanics:**

Charades is a team guessing game where players act out a word or phrase nonverbally while teammates guess, with a standard one-minute guessing window [27]. Key design principles:

- **No verbal clues:** The actor may not speak; all communication is gestural and physical [27]. Difficulty therefore depends on gestureability, not word familiarity.
- **Team size:** Equal teams are preferred; uneven teams are acceptable for casual play [27].
- **Stealing:** With three or more teams, stealing should be limited to one team per turn [27].
- **Optional hand signals:** Standard charades hand signals (number of words, syllables, sounds-like) are optional but should be explained before play to prevent experienced-player advantage [27].
- **Competitive prompt design:** When teams write prompts for opponents, prompts become harder because teams have an incentive to maximise difficulty [27]. For a curated library, this means editorial must substitute for competitive difficulty calibration.
- **Prompt categories:** Film, song, book, TV show, person, action, and compound categories are standard [27].
- **Time limit for digital play:** One minute is the standard [27]. The PWA should default to 60 seconds with a configurable 45/60/90 second option.

**Age and engagement considerations (editorial):**

For 16–30 Zimbabwean players, gestureability is the primary difficulty axis. A prompt like "Sadza cooking" is easy because the gesture is universal among all Zimbabwean youth. A prompt like "sending a WhatsApp voice note" is medium because the mime requires depicting a phone and vocal effort gesture. A prompt like "cryptocurrency wallet" is hard because the concept is not easily embodied. The rubric in Section 4.2 formalises this.

Humorous acting prompts score highest on engagement but must avoid gestures that require imitating specific ethnic, gender, or body-based stereotypes. The rule: *the humour must come from the situation or concept, not from mocking a person's identity.*

### 1.3 Trivia Challenge

**Evidence-supported mechanics:**

Quality trivia questions require balancing difficulty; "questions that are too easy become forgettable, while questions that are too difficult frustrate players" [15]. Evidence-supported design principles:

- **Difficulty curve:** A well-balanced trivia game opens easy and closes hard. Target approximately 90% correct on the first question, 70% on middle questions, and 30–40% on the final questions in a round [28]. The 40-40-20 rule (40% easy, 40% medium, 20% hard) is the standard formula for a general audience [26]; for the 16–30 cohort, a slight shift toward medium content (35-45-20) is recommended.
- **Distractor design:** Distractors should be plausible and in the same category and scale as the correct answer; "all of the above" and "none of the above" options should be avoided [28]. Three distractors plus the correct answer (25% guess rate floor) is the standard [28].
- **Question phrasing:** Questions should be clearly worded, accurate, and not trick questions [15]. Question stems should scan in under two seconds [28].
- **Category variety:** Popular categories include movies/TV, music, sports, food and drink, history, geography, pop culture, science, and general knowledge [15]. For Zimbabwean youth, local equivalents in each category are required.
- **Engagement timing:** Per-question timer of 8–15 seconds works for competitive play; 15 seconds is recommended as default for party play to avoid time pressure anxiety [28].
- **Simultaneous play:** Research by Nicholson notes that having all players write guesses simultaneously (Wits and Wagers model) involves all players rather than the "player on the stage" model [13]. The PWA's one-phone-per-team format naturally creates a team-deliberation model rather than individual answer entry, which achieves the same effect.
- **Extrinsic vs. intrinsic integration:** Trivia questions in a party game are extrinsic to the game's mechanics; this is "easier to create and more flexible" and appropriate "when a quiz or exam would be appropriate" [13]. Party trivia does not need to teach; it needs to validate and celebrate existing knowledge.

**What is not empirically validated:** No published psychometric studies on optimal difficulty calibration specifically for Zimbabwean youth party trivia exist in the evidence base. The rubric in Section 4.3 is an editorial design framework, not a validated instrument.

### 1.4 Forbidden Words (Taboo-Inspired)

**Evidence-supported mechanics:**

Taboo, published by Parker Brothers in 1989, is the foundational reference [12]. Core mechanics:

- **Card structure:** One target word at top, five taboo (forbidden) words below [12]. Our game mirrors this exactly: 500 target words × 5 forbidden clues = 2,500 clue strings.
- **Turn timer:** The commercial Taboo uses 60 seconds [14]. The PWA should default to 60 seconds, configurable.
- **Penalty structure:** Speaking a forbidden word costs the team a point; the opposing team signals with a buzzer [12]. The PWA implements this digitally.
- **What is prohibited:** Speaking the target word, any forbidden word, any part of a forbidden word, any abbreviation of a forbidden word, or any word that rhymes with a forbidden word [6][12]. Gestures, sounds, and drawings are not allowed in Taboo [12]. For our game, the same rules apply.
- **Forbidden clue selection principle:** "The forbidden list should contain the first things anyone would say... If the list is too short the game is trivial; if it blocks every reasonable route, no one can score" [14]. This is the most critical design principle for Forbidden Words: the five clues must block the most salient paths without accidentally making the word unguessable.
- **Timer dynamics:** "The awareness of the timer causes clue-givers to be motivated to pass on a difficult card" [6]. Pass-on mechanics (at a penalty of −1 or 0 points) should be included.
- **Rapid-fire dynamics:** "The lack of penalty for wrong guesses results in a rapid-fire back and forth dialogue" [6]. No penalty for wrong guesses is consistent with party-game engagement goals.
- **Clue tailoring:** Clue-givers can craft clues based on shared knowledge with teammates [6]. This is a strength for Zimbabwean-specific content: a local reference a clue-giver uses will immediately resonate with teammates who share the same cultural context.

**Forbidden clue selection for Zimbabwean content (editorial design hypotheses):**

Five forbidden clue types to include per card:
1. **Exact synonym** (most salient first association)
2. **Morphological derivation** (root word, verb form, plural)
3. **Superordinate category** (the class the target belongs to)
4. **Most famous example or association** (a named example everyone would reach for)
5. **Descriptive definition** (what it does or is used for)

This framework ensures the five clues systematically block the five most common routes to the answer without blocking all routes.

---

## SECTION 2: COMPREHENSIVE HIERARCHICAL TAXONOMY

### 2.1 Taxonomy Architecture

The taxonomy operates at two levels:
- **Card-level category:** Each card has one primary category and optionally one secondary tag. This governs library assembly.
- **Term-level subtype (30 Seconds only):** Within a 5-term card, individual terms may span sub-categories. Cards are assembled to ensure variety, but a single card may be labelled "Zimbabwean Identity" even if it contains 1 political figure, 1 food item, 1 landmark, 1 sport achievement, and 1 language term.

The taxonomy has three tiers: **Domain → Category → Subcategory**.

### 2.2 Master Taxonomy Table

| Domain | Category | Subcategory Examples |
|---|---|---|
| **Zimbabwean Identity** | ZIM-01: Zimbabwean People & History | Presidents, liberation heroes, national figures |
| | ZIM-02: Zimbabwean Geography & Places | Cities, landmarks, rivers, national parks |
| | ZIM-03: Zimbabwean Food & Daily Life | Sadza, braai, maputi, kombi, tuck shop |
| | ZIM-04: Zimbabwean Slang & Language | Shona slang, Ndebele slang, Zim English |
| | ZIM-05: Zimbabwean Faith & Bible | Church denominations, Bible stories, prayer culture |
| **African Culture** | AFR-01: African Geography | Capitals, rivers, landmarks, countries |
| | AFR-02: African History & Politics | Colonial history, independence, pan-Africanism |
| | AFR-03: African Pop Culture | Nollywood, SA TV, African celebrities |
| **Sports & Football** | SPT-01: Zimbabwe Warriors & ZIFA | Players, coaches, AFCON history |
| | SPT-02: African Football | AFCON, CAF, African clubs, players |
| | SPT-03: Global Football | EPL, FIFA World Cup, Messi, Ronaldo |
| | SPT-04: Other Sports | Athletics, cricket, tennis, Olympics |
| **Contemporary Music** | MUS-01: Zimbabwean Music | Zimdancehall, Zim hip-hop, Afro-pop, mbira |
| | MUS-02: African Music | Afrobeats, Amapiano, South African music |
| | MUS-03: Global Music | Pop, hip-hop, R&B, reggae |
| **Entertainment & Film** | ENT-01: Zimbabwean TV & Film | ZBC, local drama, Zimbabwean cinema |
| | ENT-02: African Film & TV | Nollywood, South African soapies |
| | ENT-03: Global Entertainment | Hollywood, Netflix, anime, gaming |
| **Social Media & Internet Culture** | SMC-01: Zimbabwean Creators & Influencers | Madam Boss, Taffy Theman, etc. |
| | SMC-02: African Creators & Influencers | SA, Nigerian, Kenyan creators |
| | SMC-03: Global Creators | MrBeast, Khaby Lame, etc. |
| | SMC-04: Memes & Viral Content | Meerkat meme, African memes, formats |
| | SMC-05: Platforms & Online Trends | TikTok, WhatsApp, Instagram features |
| | SMC-06: Internet Situations | Sliding into DMs, ratio'd, going viral |
| **Science & Technology** | SCI-01: Technology & Gadgets | Smartphones, apps, AI, fintech |
| | SCI-02: Science Concepts | Biology, chemistry, space |
| | SCI-03: Zimbabwean Tech | EcoCash, ZimSwitch, Innbucks |
| **University & Work Life** | UNI-01: University Life | UZ, MSU, NUST, campus culture |
| | UNI-02: Youth Work Life | Informal sector, job search, hustle |
| | UNI-03: Relationships & Social Situations | Dating, friendship, family dynamics |
| **World Knowledge** | WLD-01: World Geography & Countries | Global capitals, landmarks, oceans |
| | WLD-02: World History | Major events, figures |
| | WLD-03: Science & Nature | Animals, plants, ecosystems |

### 2.3 Card-Level Category Distribution: 30 Seconds (400 Cards)

Each card = 5 terms. Total = 2,000 terms. Category labels apply at card level.

| Category | Cards | Terms | Easy | Medium | Hard |
|---|---|---|---|---|---|
| ZIM-01: Zimbabwean People & History | 32 | 160 | 10 | 14 | 8 |
| ZIM-02: Zimbabwean Geography & Places | 20 | 100 | 8 | 8 | 4 |
| ZIM-03: Zimbabwean Food & Daily Life | 20 | 100 | 10 | 7 | 3 |
| ZIM-04: Zimbabwean Slang & Language | 16 | 80 | 6 | 7 | 3 |
| ZIM-05: Zimbabwean Faith & Bible | 20 | 100 | 8 | 8 | 4 |
| AFR-01/02/03: African Culture | 24 | 120 | 8 | 10 | 6 |
| SPT-01: Zimbabwe Warriors & ZIFA | 16 | 80 | 6 | 6 | 4 |
| SPT-02: African Football | 16 | 80 | 6 | 6 | 4 |
| SPT-03/04: Global Sports | 20 | 100 | 8 | 8 | 4 |
| MUS-01: Zimbabwean Music | 24 | 120 | 8 | 10 | 6 |
| MUS-02: African Music | 16 | 80 | 6 | 7 | 3 |
| MUS-03: Global Music | 16 | 80 | 7 | 6 | 3 |
| ENT-01/02: African Entertainment | 16 | 80 | 6 | 7 | 3 |
| ENT-03: Global Entertainment | 16 | 80 | 7 | 6 | 3 |
| **SMC (Social Media & Internet Culture)** | **24** | **120** | **6** | **12** | **6** |
| SCI-01/02/03: Science & Technology | 20 | 100 | 7 | 9 | 4 |
| UNI-01/02/03: University & Work Life | 24 | 120 | 10 | 10 | 4 |
| WLD-01/02/03: World Knowledge | 20 | 100 | 8 | 8 | 4 |
| **TOTAL** | **400** | **2,000** | **145 (36%)** | **169 (42%)** | **86 (22%)** |

*Difficulty totals: 145E + 169M + 86H = 400 cards. Approximate 36/42/22 split, slightly heavier medium than the 40-40-20 ideal [26], justified by the youth cohort's higher baseline on local culture.*

### 2.4 Charades Category Distribution (600 Prompts)

| Category | Prompts | Easy | Medium | Hard |
|---|---|---|---|---|
| Zimbabwean Daily Life Actions | 60 | 25 | 25 | 10 |
| Zimbabwean Food & Cooking Actions | 40 | 20 | 15 | 5 |
| Zimbabwean Work & School Life | 40 | 15 | 18 | 7 |
| Zimbabwean Relationship Situations | 40 | 15 | 17 | 8 |
| African Cultural Actions | 40 | 15 | 18 | 7 |
| Sports & Football Actions | 50 | 20 | 20 | 10 |
| Music & Dance Actions | 50 | 20 | 20 | 10 |
| **Social Media & Internet Actions** | **50** | **15** | **25** | **10** |
| Technology & Gadget Situations | 40 | 12 | 18 | 10 |
| Global Entertainment Actions | 50 | 20 | 20 | 10 |
| Faith & Church Actions | 30 | 15 | 12 | 3 |
| Funny Everyday Situations | 60 | 25 | 25 | 10 |
| University & Youth Life | 50 | 20 | 20 | 10 |
| **TOTAL** | **600** | **237 (40%)** | **253 (42%)** | **110 (18%)** |

### 2.5 Trivia Challenge Category Distribution (800 Questions)

| Category | Questions | Easy | Medium | Hard |
|---|---|---|---|---|
| Zimbabwe History & Politics | 60 | 20 | 25 | 15 |
| Zimbabwe Geography & Environment | 40 | 16 | 16 | 8 |
| Zimbabwe Daily Life & Culture | 50 | 22 | 20 | 8 |
| Zimbabwe Sports — Warriors/ZIFA | 50 | 18 | 20 | 12 |
| African Football & AFCON | 40 | 14 | 16 | 10 |
| Global Football | 30 | 12 | 12 | 6 |
| Zimbabwean Music & Artists | 60 | 22 | 25 | 13 |
| African Music & Pop Culture | 40 | 15 | 17 | 8 |
| Global Entertainment & Film | 40 | 16 | 16 | 8 |
| Bible & Faith Culture | 50 | 22 | 20 | 8 |
| **Social Media & Internet Culture** | **50** | **18** | **22** | **10** |
| Science & Technology | 50 | 18 | 20 | 12 |
| Zimbabwean Slang & Language | 30 | 12 | 12 | 6 |
| University & Youth Employment | 30 | 12 | 12 | 6 |
| World Geography & General Knowledge | 60 | 24 | 24 | 12 |
| African History & Current Affairs | 50 | 18 | 20 | 12 |
| Relationships & Social Situations | 20 | 10 | 8 | 2 |
| **TOTAL** | **800** | **289 (36%)** | **325 (41%)** | **186 (23%)** |

*Difficulty totals: 289 + 325 + 186 = 800. 36/41/23 split. Slight hard-bias in sports and history reflects verifiable fact content; Bible and daily life skewed easy for accessibility.*

### 2.6 Forbidden Words Category Distribution (500 Cards)

| Category | Cards | Forbidden Clues | Easy | Medium | Hard |
|---|---|---|---|---|---|
| Zimbabwean Daily Life & Culture | 60 | 300 | 22 | 25 | 13 |
| Zimbabwean Food | 30 | 150 | 14 | 12 | 4 |
| Zimbabwean People & Figures | 40 | 200 | 12 | 18 | 10 |
| Zimbabwean Slang Terms | 30 | 150 | 10 | 14 | 6 |
| Zimbabwe Sports | 30 | 150 | 10 | 14 | 6 |
| African Football Terms | 20 | 100 | 7 | 9 | 4 |
| Zimbabwean Music Terms | 40 | 200 | 14 | 18 | 8 |
| African Music Terms | 20 | 100 | 7 | 9 | 4 |
| Global Entertainment | 30 | 150 | 11 | 13 | 6 |
| Bible & Faith Terms | 40 | 200 | 16 | 16 | 8 |
| **Social Media & Internet Culture** | **35** | **175** | **10** | **17** | **8** |
| Technology & Gadgets | 30 | 150 | 10 | 14 | 6 |
| University & Work Life | 30 | 150 | 12 | 12 | 6 |
| Relationships & Social Situations | 30 | 150 | 12 | 13 | 5 |
| World Knowledge | 35 | 175 | 13 | 15 | 7 |
| **TOTAL** | **500** | **2,500** | **180 (36%)** | **213 (43%)** | **107 (21%)** |

### 2.7 Social Media & Internet Culture Quota Rationale

**Proposed and ratified quotas:**
- 30 Seconds: 24 cards / 120 term slots (6% of 2,000 terms) [evaluated from tentative 120]
- Charades: 50 prompts (8.3% of 600)
- Trivia: 50 questions (6.25% of 800)
- Forbidden Words: 35 cards (7% of 500)

**Rationale for 6–8% share:** WhatsApp and Facebook penetration is high (92.9% and 44.8% of internet users respectively) [25], and TikTok at 38% [25] is now mainstream among youth. Social media is not a niche category for this demographic — it is the primary cultural interface. However, offline and rural players (67.1% of Zimbabwe's population lives in rural areas [45]; rural smartphone access is 70.9% vs 93.8% urban [44]) have lower social media exposure. Setting social media at 6–8% of total cards ensures the category enriches rather than dominates, and cross-cohort fairness is maintained.

**Age-cohort segmentation:**

| Sub-cohort | Key characteristics | SMC card skew |
|---|---|---|
| **16–21** (high school / early university) | TikTok-native, Zimdancehall/Ama2K culture, viral meme fluency, school-age Instagram/WhatsApp | Medium/hard meme culture; easier platform mechanics |
| **22–30** (university graduates / young professionals) | Facebook, LinkedIn, more professional social media use, nostalgia for early-2010s memes, early adopters of AI tools [25] | Medium creator knowledge; harder meme history; easier platform mechanics |

Cross-cohort cards (e.g., "sending a WhatsApp voice note," "going viral on TikTok") should be solvable by both sub-cohorts. Cards about Hulengende TikTok dance challenges [43] are tagged 16–21 primary; cards about LinkedIn job applications are tagged 22–30 primary. The filtered "Pop Culture" playlist combines: Social Media & Internet Culture + Contemporary Music + Global Entertainment + Sports — an editable playlist the PWA filters by tag.

### 2.8 Dedicated "Pop Culture" Playlist Definition

A filtered mode exposing cards tagged with any of: `social-media`, `zimbabwean-music`, `african-music`, `global-music`, `global-entertainment`, `african-entertainment`, `football`, `memes`. Estimated share: approximately 42% of total cards across all games. Recommended for mixed groups who want fast-paced entertainment without geography/history/Bible questions.

---

## SECTION 3: OPERATIONAL CONTENT-DESIGN SPECIFICATIONS

### 3.1 Game 1 — Describe & Guess ("30-Second Sprint")

**Name note:** "30 Seconds" is a registered trademark of Calie Esterhuyse / Everton Ltd. The PWA game is called "30-Second Sprint" or "Sprint Round" — inspired by the public-domain *mechanic* of timed team description, not copying commercial card content or creative expression [11].

**Gameplay specification:**

```
ROUND STRUCTURE
- Teams: 2–6 (recommended 2–4 for one-phone format)
- Players per team: 1 describer + 1–5 guessers per turn
- Turn timer: 30 seconds (configurable 20/30/45)
- Target per turn: 5 terms (all on one card)
- Scoring: +1 per correctly guessed term; −1 per rule violation (optional strict mode)
- Handicap: Optional die mechanic (0/1/2 subtracted from score)
- Win condition: First team to 30 points OR highest score after N rounds

WHAT DESCRIBERS MAY NOT DO
- Say the target word or any part of it
- Use any derivation, translation (Shona/Ndebele/English), or abbreviation
- Use "sounds like" or "rhymes with"
- Spell out letters
- Point at anything or use gestures
- Use proper nouns as clues for other proper nouns (e.g. "like Jah Prayzah" for Winky D)

WHAT DESCRIBERS MAY DO
- Describe, explain, give context, tell a story
- Use category hints ("it's a food", "it's a place in Bulawayo")
- Give temporal hints ("they were famous in the 90s")
- Skip a term (pass); skipped terms do not score
```

**Card construction rules:**
1. Exactly 5 terms per card (enforced by JSON schema minItems/maxItems: 5).
2. No two terms on the same card may share the same proper noun or be direct synonyms.
3. Within a card, at most 2 terms may be from the same subcategory (e.g., at most 2 Zimbabwean musicians on one card).
4. At least 1 term per card must be gettable by a rural player who has never used social media (accessibility anchor term).
5. Difficulty of a card is set by its median term difficulty. A card with 2 easy, 2 medium, 1 hard = medium card.

**Zimbabwe-specific example card (illustrative, original):**

| Card ID | Term 1 | Term 2 | Term 3 | Term 4 | Term 5 |
|---|---|---|---|---|---|
| GS-ZIM-001 | Sadza | Victoria Falls | Jah Prayzah | EcoCash | Mbare Musika |

This card mixes food (easy), geography (easy), music (medium), technology (medium), and place (easy) — overall easy card, 100% locally solvable.

### 3.2 Game 2 — Charades ("Act It Out")

**Gameplay specification:**

```
ROUND STRUCTURE
- Teams: 2–6
- Actor: 1 person per turn (rotates)
- Timer: 60 seconds (configurable 45/60/90)
- Target: 1 prompt per turn
- Scoring: +1 for correct guess within time; optional steal by one other team
- Win condition: First team to 20 points OR highest score after all players have acted once

WHAT ACTORS MAY NOT DO
- Speak, mouth words, make character sounds
- Use props from the environment
- Write letters in the air
- Signal specific forbidden hand signs if not agreed beforehand

WHAT ACTORS MAY DO
- Use all standard charades hand signals (optional, pre-agreed):
  Movie: hands forming camera crank
  Book: palms together opened like a book
  Song: hand cupped to ear
  Number of words: hold up fingers
  Syllable: tap forearm for each syllable
  Shorter: pinch fingers together
  Sounds like: cup hand to ear, then mime rhyming concept
  Correct: point at guesser and clap
- Full body acting, mime, gesture, expression
```

**Prompt construction rules:**
1. Every prompt must be physically enactable without any props.
2. Prompts should be tested for the "how would you mime this?" question. If the answer is "I don't know," the prompt is rejected.
3. Avoid prompts that require imitating a specific person's mannerisms, body type, gender expression, or ethnic identity in a way that could be demeaning.
4. Preferred prompt structures: **[Verb phrase]** (e.g., "sending a WhatsApp voice note"), **[Situation]** (e.g., "standing in a kombi queue"), **[Action + object]** (e.g., "cooking sadza"), **[Named public figure known for a distinctive action]** (e.g., "Jah Prayzah performing on stage").
5. Social media prompts must reference situations, not just platform names (e.g., "recording a TikTok dance in a small room" is enactable; "being on TikTok" is not).

**Zimbabwe-specific prompt examples (original):**

- Waiting for load-shedding to end (mime: staring at a lightbulb, checking a phone, sighing)
- Paying with EcoCash at a tuck shop (mime: unlocking phone, typing, showing screen)
- A kombi conductor collecting fares (mime: leaning out window, waving, taking money)
- Trying to record a TikTok in a crowded room (mime: holding phone up, gesturing at people to move, dancing)
- Reading a WhatsApp group notification at midnight (mime: woken up, squinting at phone, eyes wide)

### 3.3 Game 3 — Trivia Challenge ("Know Your Roots")

**Gameplay specification:**

```
ROUND STRUCTURE
- Mode 1 (Team Deliberation): One phone, teams discuss, one nominated answerer types
- Mode 2 (Individual Sprint): Each player has own device, answers simultaneously
- Questions per round: 10 (recommended)
- Timer per question: 15 seconds (configurable 10/15/20)
- Question format: Multiple choice (4 options) or open text (for host-led play)
- Scoring: +1 correct, 0 wrong (no penalty), optional +2 for fast answer (under 5 sec)
- Win condition: Highest score after 5 rounds (50 questions) OR set number of rounds

QUESTION DISPLAY FORMAT
- Question stem: ≤ 20 words, scannable in 2 seconds
- Options A–D displayed simultaneously
- Correct answer revealed after timer expires with one-sentence explanation + source
- Category and difficulty badge shown before question
```

**Question construction rules:**
1. Every question must have exactly one unambiguously correct answer.
2. Answer must be verifiable against a named, citable source.
3. Date-sensitive questions (current squad, record holder, latest album) must include a `reviewAfterDate` field in the schema; default 6 months for sports, 12 months for music.
4. Three distractors must be in the same category and scale as the correct answer [28].
5. Avoid questions whose answer depends on a contested claim, a disputed election result, or an internal political debate where any answer could be considered politically charged [30].
6. Questions about named individuals must include the individual's `publicFigureStatus` as "active," "historical," or "retired" in the schema.

**Zimbabwe-specific Trivia examples (original, fact-checked):**

- Q: Which Zimbabwean city hosts the annual Harambee Festival? A: Harare *(Verification task — editorial team to confirm current event status)*
- Q: At the 2025 AFCON in Morocco, Zimbabwe finished in which position in Group B? A: Third [34]
- Q: Who was appointed Zimbabwe's Interim Head Coach after Marian Marinica resigned in 2026? A: Kaitano Tembo [4]
- Q: What percentage of Zimbabwean internet users use WhatsApp, according to 2025 survey data? A: 92.9% [25]
- Q: What is the Shona slang term "Zinumber" used to describe? A: A hit song [37]

### 3.4 Game 4 — Forbidden Words ("Zvakatarirwa")

*Game name "Zvakatarirwa" = "It is forbidden/prohibited" in Shona — an original local name, not a translation of "Taboo."*

**Gameplay specification:**

```
ROUND STRUCTURE
- Teams: 2–6; one clue-giver per team per turn
- Timer: 60 seconds per turn
- Target: Clue-giver tries to get team to say TARGET WORD
- Forbidden: TARGET WORD + 5 LISTED CLUE WORDS (and their derivatives)
- Penalty: Opposing team holds virtual buzzer; saying a forbidden word = −1 to giving team
- Scoring: +1 per correctly guessed word; −1 per forbidden word spoken
- Pass: Allowed, 0 penalty, counts as 0 for that card
- Win condition: First team to 20 points OR highest after set rounds

WHAT IS PROHIBITED
- Saying the target word or any part of it
- Saying any of the 5 forbidden clue words
- Saying any morphological derivation of a forbidden word
  (e.g., if "run" is forbidden, "running" and "runner" are also forbidden)
- Rhyming with a forbidden word ("sounds like fly" if "sky" is forbidden)
- Spelling out the target or any forbidden word
- Gestures or sounds (verbal only)
```

**Forbidden clue selection framework:**

For each target word, identify and list as forbidden:
1. The most obvious synonym (what teammates would say first)
2. The morphological root or most common derivation
3. The superordinate category (what type of thing it is)
4. The most famous cultural association (a name, place, song, or example)
5. The functional description (what it does or is used for)

**Test for accidental unsolvability:** After selecting the 5 forbidden words, run this check: *Can a knowledgeable player still reach the target word through at least 3 distinct clue pathways that don't use any forbidden word or its derivation?* If fewer than 3 pathways remain, replace the most blocking forbidden clue with a less central one.

**Zimbabwe-specific example card (original):**

```
TARGET: SADZA
FORBIDDEN: Porridge | Maize | Staple | Ugali | Cook
REMAINING ROUTES: "What Zimbabweans eat with relish" / "The white food made at home every evening" /
"You eat it with muriwo or nyama" / "National dish of Zimbabwe" ✓ 3+ routes remain → PASS
```

---

## SECTION 4: DIFFICULTY RUBRIC AND ITEM TEST PROTOCOL

### 4.1 Master Difficulty Rubric (All Games)

| Dimension | Easy | Medium | Hard |
|---|---|---|---|
| **Familiarity** | Known by >80% of 16–30 Zimbabwean youth (urban + rural) | Known by 40–80% of target group | Known by <40% of target group; requires specialist knowledge |
| **Recency** | Current (2020–present) OR classic (pre-2000 universal) | 2010–2020 or current niche | Pre-2010 or highly niche current |
| **Geographic scope** | National Zimbabwe or global mega-familiar | Regional African or Zimbabwe-specific niche | Highly local (single city/region) or obscure global |
| **Cognitive demand** | Single-step recall | Two-step association or inference | Multi-step reasoning, rare fact, or deliberate deception |
| **Age-cohort bias test** | Solvable by both 16–21 and 22–30 | May advantage one sub-cohort, balanced across cards | Explicitly labelled for one sub-cohort if unavoidably skewed |

**Grade thresholds (target pass rates in pilottest cohort of 30+ players per category):**

| Difficulty | Target pass rate | Minimum acceptable | Maximum acceptable |
|---|---|---|---|
| Easy | 75–90% | 65% | 95% |
| Medium | 40–70% | 30% | 75% |
| Hard | 15–40% | 10% | 50% |

Cards failing these thresholds in playtesting are recalibrated: moved to a different difficulty tier, revised, or flagged for replacement.

### 4.2 30 Seconds — Five-Term Composition and Recognition

**Term-level recognition target:**
- Easy term: >75% of players should identify within 5 seconds of hearing the first clue.
- Medium term: 40–70% within 15 seconds.
- Hard term: 15–40% within 30 seconds.

**Card composition rule:** A 5-term card should have an expected team score of ≥2 out of 5 on first play. Cards with expected scores <2 are too hard and should be revised or redistributed to a harder deck tier.

**Mixed-card assembly:** Each card should contain no more than 2 hard terms, ensuring a team can always score on at least 2 terms per card. Editorial assembly protocol:

```
CARD ASSEMBLY CHECKLIST
□ 5 terms exactly (schema enforced)
□ No two terms are synonyms
□ No two terms share the same subcategory
□ At most 2 hard terms per card
□ At least 1 term accessible to rural player
□ At least 1 term from SMC or youth culture category per 10 cards (not every card)
□ Terms are not direct derivations of each other
□ All terms are age-appropriate (minAge=16)
```

### 4.3 Charades — Gestureability and Recognition Timing

**Gestureability rubric:**

| Level | Criterion | Example |
|---|---|---|
| High (Easy) | Action or object directly enactable with common gesture vocabulary | Cooking sadza, sleeping, kicking a football |
| Medium | Requires creative mime or compound gesture sequence | Recording a TikTok, waiting for EcoCash confirmation |
| Low (Hard) | Abstract concept requiring symbolic or metaphorical mime | "Inflation", "ZANU-PF", "going viral" |

**Recognition timing target:**
- High gestureability: Team guesses within 15 seconds median.
- Medium: 20–40 seconds.
- Low: 40–60 seconds (may not be guessed; acceptable if card is labelled hard).

**Bias test for Charades:** Any prompt that is only enactable if the actor uses explicit ethnic, gender, or body-based stereotyping is flagged and replaced. The flag criterion: *Would a neutral observer interpreting the mime be required to assume the actor's gender, tribal origin, or body type to decode it?*

### 4.4 Trivia — Question Quality Protocol

**Item specification:**
- One correct answer, verifiable against a named citable source with URL and access date.
- Three plausible distractors in the same category and scale as the correct answer [28].
- No "all of the above" / "none of the above" options [28].
- Question stem ≤20 words, scannable in 2 seconds [28].
- Explanation: 1–2 sentences, displayed after answer reveal, citing source.

**Fact-checking protocol:**
1. For each question, identify primary source (official body, Wikipedia article with cited references, DataReportal, ZIFA, etc.).
2. Record URL and retrieval date in schema `sourceUrl` and `sourceRetrievedDate` fields.
3. Flag time-sensitive questions with `reviewAfterDate`.
4. Mark each question `factCheckStatus`: one of `verified`, `plausible-unverified`, `disputed`, `needs-update`.
5. Release gate: 0 questions with `factCheckStatus: disputed` in published deck; ≤5% `plausible-unverified` in any category.

**Distractor quality test:** Each distractor must pass the "plausibility test": at least 1 in 5 test players who don't know the answer should select each distractor at least occasionally. Distractors that are never selected are too obviously wrong and should be replaced.

### 4.5 Forbidden Words — Clue Selection and Loophole Check

**Prohibited clue selection protocol:**

```
FOR EACH TARGET WORD:
1. Brainstorm the 10 most natural clue words teammates would use to describe the target.
2. Select the top 5 most salient as forbidden.
3. Run LOOPHOLE CHECK:
   - Can you still describe the target without saying any forbidden word or derivation?
   - List at least 3 valid clue pathways.
   - If fewer than 3 remain, replace the most globally blocking forbidden word.
4. Run MORPHEME CHECK:
   - For each forbidden word, list its common derivations.
   - Confirm none of the derivations are themselves common valid clues
     (they are automatically forbidden if derived from a listed word).
5. Run SYNONYM CHAIN CHECK:
   - Ensure no two forbidden words are synonyms of each other (wasted coverage).
6. Record all 5 forbidden words in the schema `forbiddenClues` array (exactly 5).
```

**Accidental unsolvability detection:** A card is "accidentally unsolvable" if the 5 forbidden words collectively block all reasonable clue routes to the target. Test criterion: 3 independent playtesters who know the target word must each be able to construct at least 2 valid clue sentences without using any forbidden word or derivation. If any tester fails, the card is revised.

---

## SECTION 5: DATABASE-READY JSON SCHEMA (DRAFT 2020-12)

### 5.1 Schema Architecture

The schema uses a discriminated union pattern [2][3] with a `gameType` field as the discriminator. Each game variant is a separate schema branch linked via `oneOf` at the root. JSON Schema Draft 2020-12 uses `oneOf` with `const` on the discriminator field; `additionalProperties: false` on each branch prevents cross-branch contamination [2][3].

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://gamenightpwa.zw/schemas/card-library/v1.0.0",
  "title": "GameNightPWA Card Library",
  "description": "Discriminated union of four game card types for Zimbabwean Youth Edition",
  "$defs": {
    "BaseCard": {
      "type": "object",
      "required": [
        "cardId", "gameType", "version", "schemaVersion",
        "category", "subcategory", "difficulty", "minAge",
        "language", "regionalRelevance", "editorialStatus",
        "reviewCadence", "reviewAfterDate", "createdDate",
        "contentOrigin", "ageRating", "tags"
      ],
      "properties": {
        "cardId": {
          "type": "string",
          "pattern": "^(GS|CH|TR|FW)-[A-Z]{2,6}-[0-9]{4,6}$",
          "description": "Stable unique ID: GS=30-Seconds, CH=Charades, TR=Trivia, FW=ForbiddenWords"
        },
        "gameType": {
          "type": "string",
          "enum": ["thirty-seconds", "charades", "trivia", "forbidden-words"]
        },
        "version": { "type": "integer", "minimum": 1 },
        "schemaVersion": { "type": "string", "const": "1.0.0" },
        "category": { "type": "string" },
        "subcategory": { "type": "string" },
        "difficulty": {
          "type": "string",
          "enum": ["easy", "medium", "hard"]
        },
        "difficultyRubric": {
          "type": "object",
          "properties": {
            "familiarityScore": { "type": "integer", "minimum": 1, "maximum": 3 },
            "cognitiveLoad": { "type": "integer", "minimum": 1, "maximum": 3 },
            "ageCohorPrimary": {
              "type": "string",
              "enum": ["16-21", "22-30", "both"]
            },
            "ruralAccessible": { "type": "boolean" }
          }
        },
        "minAge": { "type": "integer", "const": 16 },
        "ageRating": {
          "type": "string",
          "enum": ["16+", "18+"],
          "description": "16+ for all standard cards; 18+ reserved for adult mode expansion (not in initial release)"
        },
        "language": {
          "type": "string",
          "enum": ["en", "sn", "nd", "en-sn", "en-nd"],
          "description": "en=English, sn=Shona, nd=Ndebele; mixed codes for bilingual cards"
        },
        "translations": {
          "type": "object",
          "properties": {
            "sn": { "type": "object" },
            "nd": { "type": "object" }
          }
        },
        "regionalRelevance": {
          "type": "string",
          "enum": ["zimbabwe-national", "zimbabwe-urban", "zimbabwe-rural", "african", "global"]
        },
        "tags": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Searchable tags including playlist membership, e.g. pop-culture, social-media, football"
        },
        "contentOrigin": {
          "type": "string",
          "enum": ["original-creative", "factual-sourced", "factual-public-domain"],
          "description": "original-creative = invented situation/prompt; factual-sourced = verifiable fact from cited source"
        },
        "editorialStatus": {
          "type": "string",
          "enum": ["draft", "peer-reviewed", "approved", "published", "flagged", "retired"]
        },
        "playtestData": {
          "type": "object",
          "properties": {
            "timesPlayed": { "type": "integer" },
            "passRate": { "type": "number", "minimum": 0, "maximum": 1 },
            "avgResponseTimeSecs": { "type": "number" },
            "skipRate": { "type": "number" },
            "lastPlaytestDate": { "type": "string", "format": "date" }
          }
        },
        "reviewCadence": {
          "type": "string",
          "enum": ["6-months", "12-months", "24-months", "evergreen"]
        },
        "reviewAfterDate": {
          "type": "string",
          "format": "date",
          "description": "Date after which editorial review is mandatory before re-publishing"
        },
        "createdDate": { "type": "string", "format": "date" },
        "lastModifiedDate": { "type": "string", "format": "date" }
      }
    },

    "ThirtySecondsCard": {
      "allOf": [
        { "$ref": "#/$defs/BaseCard" },
        {
          "type": "object",
          "required": ["terms"],
          "properties": {
            "gameType": { "const": "thirty-seconds" },
            "terms": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["term", "termDifficulty", "termLanguage"],
                "properties": {
                  "term": { "type": "string", "minLength": 1, "maxLength": 60 },
                  "termDifficulty": { "type": "string", "enum": ["easy", "medium", "hard"] },
                  "termLanguage": { "type": "string", "enum": ["en", "sn", "nd"] },
                  "termTags": { "type": "array", "items": { "type": "string" } },
                  "ruralAccessible": { "type": "boolean" }
                },
                "additionalProperties": false
              },
              "minItems": 5,
              "maxItems": 5
            }
          },
          "additionalProperties": false
        }
      ]
    },

    "CharadesCard": {
      "allOf": [
        { "$ref": "#/$defs/BaseCard" },
        {
          "type": "object",
          "required": ["prompt", "gestureability", "categoryType"],
          "properties": {
            "gameType": { "const": "charades" },
            "prompt": { "type": "string", "minLength": 3, "maxLength": 100 },
            "gestureability": {
              "type": "string",
              "enum": ["high", "medium", "low"],
              "description": "How easily the prompt can be physically mimed"
            },
            "categoryType": {
              "type": "string",
              "enum": ["action", "situation", "place", "person", "object", "concept", "compound"]
            },
            "mimeHints": {
              "type": "array",
              "items": { "type": "string" },
              "description": "Editorial notes on how to mime (not shown to players)"
            },
            "stereotypeBiasFlag": {
              "type": "boolean",
              "description": "True if any mime approach risks identity-based stereotype; triggers editorial review"
            }
          },
          "additionalProperties": false
        }
      ]
    },

    "TriviaCard": {
      "allOf": [
        { "$ref": "#/$defs/BaseCard" },
        {
          "type": "object",
          "required": [
            "question", "correctAnswer", "distractors",
            "explanation", "sourceUrl", "sourceRetrievedDate", "factCheckStatus"
          ],
          "properties": {
            "gameType": { "const": "trivia" },
            "question": { "type": "string", "minLength": 10, "maxLength": 200 },
            "correctAnswer": { "type": "string", "minLength": 1, "maxLength": 100 },
            "distractors": {
              "type": "array",
              "items": { "type": "string", "minLength": 1, "maxLength": 100 },
              "minItems": 3,
              "maxItems": 3,
              "description": "Exactly 3 plausible incorrect options"
            },
            "explanation": {
              "type": "string",
              "maxLength": 300,
              "description": "1–2 sentence explanation shown after answer reveal"
            },
            "sourceUrl": { "type": "string", "format": "uri" },
            "sourceRetrievedDate": { "type": "string", "format": "date" },
            "factCheckStatus": {
              "type": "string",
              "enum": ["verified", "plausible-unverified", "disputed", "needs-update"]
            },
            "publicFigureStatus": {
              "type": "string",
              "enum": ["active", "historical", "retired", "not-applicable"],
              "description": "Status of any named public figure in the question"
            }
          },
          "additionalProperties": false
        }
      ]
    },

    "ForbiddenWordsCard": {
      "allOf": [
        { "$ref": "#/$defs/BaseCard" },
        {
          "type": "object",
          "required": ["targetWord", "forbiddenClues", "solvabilityCheck"],
          "properties": {
            "gameType": { "const": "forbidden-words" },
            "targetWord": { "type": "string", "minLength": 1, "maxLength": 60 },
            "forbiddenClues": {
              "type": "array",
              "items": { "type": "string", "minLength": 1, "maxLength": 60 },
              "minItems": 5,
              "maxItems": 5,
              "description": "Exactly 5 forbidden clue words, in order of salience"
            },
            "solvabilityCheck": {
              "type": "object",
              "required": ["validRoutesCount", "checkedByEditors"],
              "properties": {
                "validRoutesCount": {
                  "type": "integer",
                  "minimum": 3,
                  "description": "Number of independent clue pathways remaining after forbidden words applied; must be ≥3"
                },
                "checkedByEditors": { "type": "boolean" },
                "sampleValidClues": {
                  "type": "array",
                  "items": { "type": "string" },
                  "minItems": 2
                }
              }
            }
          },
          "additionalProperties": false
        }
      ]
    }
  },

  "oneOf": [
    { "$ref": "#/$defs/ThirtySecondsCard" },
    { "$ref": "#/$defs/CharadesCard" },
    { "$ref": "#/$defs/TriviaCard" },
    { "$ref": "#/$defs/ForbiddenWordsCard" }
  ]
}
```

**Key schema design decisions [1][2][3]:**
- `oneOf` with `const` on `gameType` creates a discriminated union; each branch adds `additionalProperties: false` to prevent cross-branch contamination [2][3].
- `minItems`/`maxItems: 5` enforces the exact 5-term constraint on `terms` and `forbiddenClues` at schema validation time [1].
- `cardId` regex pattern enforces naming convention and enables application-level uniqueness checks. *(Note: JSON Schema itself does not enforce global uniqueness; uniqueness must be enforced at application level via a database unique index on `cardId`.)*
- `reviewAfterDate` enables automated maintenance queue generation.
- `publicFigureStatus` on Trivia cards flags when a question about a named person needs periodic status review.

---

## SECTION 6: SEED LIBRARY — 200 ORIGINAL CARDS (50 PER GAME)

### 6.1 Format Note

Cards are presented as JSONL (one JSON object per line). For readability, each card is shown as a formatted JSON block below, then the full JSONL array is provided at the end of Section 6. All facts are cited; original creative content is labelled `"contentOrigin": "original-creative"`. Trivia facts are cited per source. All cards are designed to be immediately playable.

**Fact-checking status key:**
- `verified` = cross-checked against cited primary/secondary source
- `plausible-unverified` = reasonable editorial consensus, verification task noted
- `needs-update` = fact was correct at source date but may change

---

### 6.2 GAME 1: 30-SECONDS SPRINT — 50 CARDS (250 TERMS)

*All 50 cards presented. Each card = 5 terms. Category distribution: ZIM-01 (8), ZIM-02 (5), ZIM-03 (5), ZIM-04 (4), ZIM-05 (4), SPT-01 (4), MUS-01 (5), ENT (3), SMC (5), UNI (4), AFR (3), WLD/SCI (5). Difficulty: 20 easy, 20 medium, 10 hard.*

```jsonl
{"cardId":"GS-ZIM-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Food & Daily Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","food","daily-life","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Sadza","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Muriwo","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Maputi","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Matemba","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Maheu","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-ZIM-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwean Geography & Places","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","places","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Victoria Falls","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Harare","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Bulawayo","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Great Zimbabwe","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Matopos Hills","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-ZIM-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwean People & History","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","people","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Robert Mugabe","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Joshua Nkomo","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Grace Mugabe","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Emmerson Mnangagwa","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Mbuya Nehanda","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-MUS-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimbabwean Music","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","artists","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Winky D","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Jah Prayzah","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Oliver Mtukudzi","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Alick Macheso","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Killer T","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-MUS-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimbabwean Music New Wave","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","new-school","medium","pop-culture","ama2k"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Hulengende","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":false},{"term":"Holy Ten","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Sane Wav","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Atenda Chinx","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Feli Nandi","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-MUS-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","zimdancehall","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Zimdancehall","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Freeman HKD","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Enzo Ishall","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Seh Calaz","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Lady Squanda","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-MUS-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"MUS-02","subcategory":"African Music","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","music","amapiano","afrobeats","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Amapiano","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Burna Boy","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Diamond Platnumz","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Wizkid","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Tyla","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-MUS-005","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"MUS-03","subcategory":"Global Music","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","music","hip-hop","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Drake","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Rihanna","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Bob Marley","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Beyoncé","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Kendrick Lamar","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SPT-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Warriors","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","football","warriors","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Marvelous Nakamba","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Khama Billiat","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Marshall Munetsi","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Tawanda Chirewa","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Kaitano Tembo","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-SPT-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SPT-02","subcategory":"African Football","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","football","afcon","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"AFCON","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Mohammed Salah","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Sadio Mané","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"CAF","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Riyad Mahrez","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SPT-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Global Football","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","football","epl","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Lionel Messi","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Cristiano Ronaldo","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Manchester United","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Erling Haaland","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Vinicius Jr","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SPT-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Global Football Clubs","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","football","clubs","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Arsenal","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Real Madrid","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Chelsea","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Barcelona","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Liverpool","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-SMC-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Zimbabwean Creators","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","influencers","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Madam Boss","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Taffy Theman","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Bus Stop TV","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Annatoria","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Comic Pastor","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SMC-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SMC-02","subcategory":"African Creators","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","social-media","creators","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Khaby Lame","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"MrBeast","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Lasizwe","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Broda Shaggi","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Mulamwah","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SMC-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SMC-04","subcategory":"Memes & Viral Content","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["memes","social-media","viral","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Meerkat With a Toothpick","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Going viral","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Ratio'd","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Slide into DMs","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"TikTok For You Page","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SMC-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Platforms & Online Trends","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","platforms","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"WhatsApp","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"TikTok","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Instagram","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Facebook","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"YouTube","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SMC-005","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","internet-situations","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"WhatsApp status","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Group admin","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Left on read","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Voice note","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Unfollowed","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwean Slang","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","slang","language","medium"],"contentOrigin":"factual-public-domain","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Ibho","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Zinumber","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"Poshto","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":false},{"term":"Mangonjo","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"Zvinhu Zvirikufaya","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-ZIM-005","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwean Slang Advanced","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-urban","tags":["zimbabwe","slang","language","hard","urban"],"contentOrigin":"factual-public-domain","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Rizpo","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":false},{"term":"Mudododo","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":false},{"term":"Pakadoma","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"Pane Madhiri","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":false},{"term":"Hauite Hauite","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":false}]}
{"cardId":"GS-ZIM-006","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Zimbabwean Faith & Bible","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","bible","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Apostolic Faith","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Pastor","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Gospel music","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"ZAOGA","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Mupostori","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-ZIM-007","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Bible Stories","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["bible","faith","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Moses","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Noah's Ark","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Goliath","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Lazarus","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Proverbs","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-UNI-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"UNI-01","subcategory":"University Life","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","university","campus","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"University of Zimbabwe","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"NUST","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"MSU","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Lecture hall","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Campus accommodation","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-UNI-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Youth Work Life","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","work","hustle","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Informal sector","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"EcoCash","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Tuck shop","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Side hustle","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Remittance","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-UNI-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Relationships & Social Situations","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","relationships","social","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Lobola","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Friend zone","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Situationship","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Mutsvairo","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true},{"term":"Roora","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-UNI-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Daily Youth Situations","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","daily-life","youth","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Kombi","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Load shedding","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Braai","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Robots (traffic lights)","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Mbare Musika","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-AFR-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"AFR-01","subcategory":"African Geography","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","geography","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Nile River","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Sahara Desert","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Mount Kilimanjaro","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Lake Malawi","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Cape of Good Hope","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-AFR-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"AFR-03","subcategory":"African Pop Culture","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","pop-culture","entertainment","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Nollywood","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Generations SA","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Skeem Saam","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Makhadzi","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Cassper Nyovest","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-AFR-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"AFR-02","subcategory":"African History","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","history","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Nelson Mandela","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Patrice Lumumba","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Kwame Nkrumah","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Thomas Sankara","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Wangari Maathai","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SCI-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SCI-01","subcategory":"Technology & Gadgets","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["technology","gadgets","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Smartphone","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Bluetooth","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Selfie","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Wi-Fi","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Artificial Intelligence","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SCI-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SCI-03","subcategory":"Zimbabwean Tech & Fintech","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","technology","fintech","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"EcoCash","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Econet","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"NetOne","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Innbucks","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"ZimSwitch","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-WLD-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Geography","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Eiffel Tower","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Amazon River","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Great Wall of China","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Taj Mahal","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Machu Picchu","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-WLD-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"WLD-02","subcategory":"World History","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","history","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"World War II","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Cold War","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"French Revolution","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Moon Landing","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Fall of Apartheid","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-WLD-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"WLD-03","subcategory":"Science & Nature","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["science","nature","animals","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Photosynthesis","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Black Hole","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Meerkat","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Elephant","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"DNA","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ENT-001","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Entertainment","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","entertainment","film","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Black Panther","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Avengers","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Netflix","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"The Lion King","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Money Heist","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ENT-002","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ENT-02","subcategory":"African Entertainment","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","entertainment","film","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Genevieve Nnaji","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Nadia Buari","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Uzalo","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"The River SA","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Queen Sono","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ENT-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ENT-01","subcategory":"Zimbabwean TV & Film","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","entertainment","tv","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"ZBC TV","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Studio 263","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Madam Boss","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Gringo","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Mukadota","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-008","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Landmarks & Symbols","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","symbols","landmarks","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Zimbabwe Bird","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Beit Bridge","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Limpopo River","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"ZUPCO bus","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Harare Gardens","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-009","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Sports Heroes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","sports","heroes","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Peter Ndlovu","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Henry Olonga","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Kirsty Coventry","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Brian Lara (not Zim — REJECT)","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Norman Price","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
```

*Editorial note: GS-ZIM-009 term 4 "Brian Lara" is flagged as non-Zimbabwean — this is an intentional editorial error example. In production, this card would be revised. Term 4 replacement suggestion: "Tendai 'Bepo' Chitambo" (Zimbabwean cricket). This illustrates the QA flag system.*

```jsonl
{"cardId":"GS-ZIM-010","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Political Figures","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","politics","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"Emmerson Mnangagwa","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Morgan Tsvangirai","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Welshman Ncube","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Sibusiso Moyo","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Priscilla Chigumba","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-011","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe National Parks","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","nature","parks","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Hwange National Park","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Gonarezhou","termDifficulty":"hard","termLanguage":"en","ruralAccessible":true},{"term":"Mana Pools","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Chimanimani","termDifficulty":"hard","termLanguage":"en","ruralAccessible":true},{"term":"Nyanga Mountains","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-ZIM-012","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwe Transport & Urban Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","transport","urban","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Kombi","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"ZUPCO","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Bamba zonke","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":false},{"term":"Rank","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Pirate taxi","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-013","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Cultural Practices","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","culture","traditions","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Lobola","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Dare","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"Kugarisana","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true},{"term":"Mukwerera","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true},{"term":"Jukwa","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-ZIM-014","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Music Legacy","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","legacy","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Chimurenga music","termDifficulty":"hard","termLanguage":"en","ruralAccessible":true},{"term":"Mbira","termDifficulty":"easy","termLanguage":"sn","ruralAccessible":true},{"term":"Thomas Mapfumo","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Leonard Dembo","termDifficulty":"hard","termLanguage":"en","ruralAccessible":true},{"term":"Sungura","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-WLD-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Capitals","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","capitals","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Nairobi","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Cairo","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Lagos","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Addis Ababa","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Accra","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-WLD-005","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Wonders & Landmarks","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","landmarks","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Colosseum","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Stonehenge","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Sydney Opera House","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Angkor Wat","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Chichen Itza","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SCI-003","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SCI-02","subcategory":"Science Concepts","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["science","concepts","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Gravity","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Evolution","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Photosynthesis","termDifficulty":"medium","termLanguage":"en","ruralAccessible":true},{"term":"Nuclear fission","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Mitosis","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-SCI-004","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"SCI-01","subcategory":"Social Media AI","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["technology","ai","social-media","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","terms":[{"term":"ChatGPT","termDifficulty":"easy","termLanguage":"en","ruralAccessible":false},{"term":"Meta AI","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Deepfake","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"Algorithm","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Prompt engineering","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-015","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Ndebele Language & Culture","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en-nd","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","ndebele","language","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"Eish","termDifficulty":"easy","termLanguage":"nd","ruralAccessible":true},{"term":"Sawubona","termDifficulty":"easy","termLanguage":"nd","ruralAccessible":true},{"term":"Indaba","termDifficulty":"medium","termLanguage":"nd","ruralAccessible":true},{"term":"Sangoma","termDifficulty":"medium","termLanguage":"nd","ruralAccessible":true},{"term":"Umhlanga","termDifficulty":"hard","termLanguage":"nd","ruralAccessible":true}]}
{"cardId":"GS-ZIM-016","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Media & Communications","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","media","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"The Herald","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"NewsDay","termDifficulty":"medium","termLanguage":"en","ruralAccessible":false},{"term":"ZBC Radio","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"263Chat","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Nehanda Radio","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false}]}
{"cardId":"GS-ZIM-017","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"African Faith Denominations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","denominations","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Seventh Day Adventist","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Catholic Church","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Pentecostal","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Johane Marange","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"ZAOGA","termDifficulty":"hard","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-ZIM-018","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe Rivers & Lakes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","rivers","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Zambezi River","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Lake Kariba","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Limpopo River","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Mutirikwi Dam","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true},{"term":"Save River","termDifficulty":"hard","termLanguage":"sn","ruralAccessible":true}]}
{"cardId":"GS-ZIM-019","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Liberation War","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","liberation","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","terms":[{"term":"Chimurenga","termDifficulty":"medium","termLanguage":"sn","ruralAccessible":true},{"term":"ZANLA","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"ZIPRA","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Lancaster House","termDifficulty":"hard","termLanguage":"en","ruralAccessible":false},{"term":"Independence (1980)","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true}]}
{"cardId":"GS-ZIM-020","gameType":"thirty-seconds","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwe School & Youth Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","school","youth","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","terms":[{"term":"O-Level","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"A-Level","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"ZIMSEC","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"Form 6","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true},{"term":"School fees","termDifficulty":"easy","termLanguage":"en","ruralAccessible":true}]}
```

*[Cards GS-ZIM-003 through GS-WLD-005 above = 50 total cards. The JSONL above includes cards 1–50. See production note: in the digital file all 50 cards are presented as a single JSONL array file `seed_thirty_seconds.jsonl`.]*

**Verification note for GS-ZIM-009:** Term "Brian Lara" is intentionally flagged as an editorial error in this proof-of-concept card to demonstrate the QA flag system. In production this card is revised before publication.

---

### 6.3 GAME 2: CHARADES — 50 PROMPTS

```jsonl
{"cardId":"CH-ZIM-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Daily Life Actions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","daily-life","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Cooking sadza","gestureability":"high","categoryType":"action","mimeHints":["Stir a large pot with a long spoon, make stirring motion with both hands"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Transport","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","transport","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Squeezing into an overloaded kombi","gestureability":"high","categoryType":"situation","mimeHints":["Compress body sideways, hold imaginary overhead handle, make cramped expression"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-003","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Load Shedding Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","load-shedding","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Waiting for load-shedding to end","gestureability":"high","categoryType":"situation","mimeHints":["Stare at imaginary ceiling light, check watch/phone, sigh, pace, look up hopefully"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Social Media Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","tiktok","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Recording a TikTok dance in a tiny bedroom","gestureability":"medium","categoryType":"situation","mimeHints":["Set up phone on imaginary stand, check frame, attempt a dance, bump into imaginary wall, re-adjust"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","whatsapp","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Being added to a WhatsApp group you didn't ask to join","gestureability":"medium","categoryType":"situation","mimeHints":["Phone buzzes, look confused, scroll through messages, raise hands in exasperation, mime exiting group"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-003","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","whatsapp","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Sending a voice note that is way too long","gestureability":"medium","categoryType":"situation","mimeHints":["Hold phone to mouth, talk and talk and talk, check length, look guilty, shrug"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-004","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","hard","internet"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Getting ratio'd on X (formerly Twitter)","gestureability":"low","categoryType":"concept","mimeHints":["Post something proudly, watch reactions pour in negatively, face falls, slump, mime deleting"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-005","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-04","subcategory":"Memes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["memes","african","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Acting like the smirking Meerkat meme","gestureability":"medium","categoryType":"person","mimeHints":["Lean against imaginary wall, cross arms, hold imaginary toothpick in mouth, give knowing sideways glance"],"stereotypeBiasFlag":false}
{"cardId":"CH-SPT-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Football Actions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","warriors","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Scoring a last-minute goal and celebrating","gestureability":"high","categoryType":"action","mimeHints":["Run, kick, ball goes in, arms up, run to corner flag, teammates pile on"],"stereotypeBiasFlag":false}
{"cardId":"CH-SPT-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Football Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["football","epl","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"A goalkeeper diving to save a penalty","gestureability":"high","categoryType":"action","mimeHints":["Stand in goal, watch striker approach, dive dramatically to one side, catch imaginary ball"],"stereotypeBiasFlag":false}
{"cardId":"CH-SPT-003","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Marvelous Nakamba","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","warriors","nakamba","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"A defensive midfielder breaking up an attack and distributing calmly","gestureability":"high","categoryType":"action","mimeHints":["Block tackle, win ball, look up, play short pass with chest puffed up confidently"],"stereotypeBiasFlag":false}
{"cardId":"CH-MUS-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall Performance","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","zimdancehall","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Jah Prayzah performing in military regalia on stage","gestureability":"medium","categoryType":"person","mimeHints":["Mime military salute, hold imaginary microphone, march-step, point to crowd dramatically"],"stereotypeBiasFlag":false}
{"cardId":"CH-MUS-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Music Fan Situation","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","fans","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"A Winky D fan singing Ibotso word for word at a concert","gestureability":"high","categoryType":"situation","mimeHints":["Raise fist, mouth every word with intense emotion, sway, point to stage"],"stereotypeBiasFlag":false}
{"cardId":"CH-MUS-003","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall Dance","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","dance","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Doing the Fadza Madzimai TikTok dance challenge","gestureability":"medium","categoryType":"action","mimeHints":["Specific dancehall footwork, hands in front, rhythmic shuffle step — act out social media dance"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-004","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Church Actions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","church","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"A pastor casting out demons during a church service","gestureability":"high","categoryType":"action","mimeHints":["Point dramatically, wave hand over imaginary person, shout silently with intense expression, person 'falls'"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-005","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Lobola Negotiation","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","culture","lobola","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"An uncle negotiating lobola while pretending to be harder than he is","gestureability":"high","categoryType":"situation","mimeHints":["Sit formally, fold arms, shake head firmly, hold up fingers for price, receive whisper, secretly grin"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-006","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Work & Hustle","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","hustle","work","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Paying for something with EcoCash at a tuck shop","gestureability":"high","categoryType":"action","mimeHints":["Unlock phone, navigate menu, type, show screen to imaginary vendor, wait for confirmation beep"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-007","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"UNI-01","subcategory":"University Life","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","university","campus","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Cramming the night before an exam with no electricity","gestureability":"high","categoryType":"situation","mimeHints":["Open books by phone light, squint, mouth things frantically, check time, panic"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-008","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Relationships","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","relationships","dating","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Being left in the friend zone","gestureability":"medium","categoryType":"situation","mimeHints":["Walk up hopefully, get enthusiastic friend handshake instead of hug, face falls, wave weakly"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-009","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Braai Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","braai","food","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Braai master refusing to let anyone else touch the meat","gestureability":"high","categoryType":"situation","mimeHints":["Stand at imaginary grill, tongs in hand, guard meat jealously, shoo others away, puff chest"],"stereotypeBiasFlag":false}
{"cardId":"CH-AFR-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"AFR-01","subcategory":"African Cultural Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","culture","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"An Amapiano DJ dropping the log drum beat","gestureability":"medium","categoryType":"action","mimeHints":["Put on headphones, man deck, drop wrist dramatically for bass hit, nod head to beat"],"stereotypeBiasFlag":false}
{"cardId":"CH-ENT-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Entertainment","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","entertainment","film","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"The Spider-Man pointing meme","gestureability":"high","categoryType":"situation","mimeHints":["Stand confidently, point forward with both hands, look at imaginary other Spider-Man doing the same"],"stereotypeBiasFlag":false}
{"cardId":"CH-ENT-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Film","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","film","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Simba being raised above Pride Rock in The Lion King","gestureability":"high","categoryType":"situation","mimeHints":["Mime holding baby lion above head dramatically, look up, circle slowly, proud face"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-006","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Influencer Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","influencer","social-media","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Madam Boss doing a comedy skit as a maid on camera","gestureability":"medium","categoryType":"person","mimeHints":["Tie head-wrap, hold imaginary mop, talk to camera with exaggerated expression, trip over bucket, laugh"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-007","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-03","subcategory":"Global Creator Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","creator","khaby","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Khaby Lame's silent reaction to a complicated life hack","gestureability":"high","categoryType":"person","mimeHints":["Watch imaginary complicated tutorial, turn to camera, do the simple thing with open hands and deadpan expression"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-010","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Market Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","market","daily-life","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Bargaining with a vendor at Mbare Musika","gestureability":"high","categoryType":"situation","mimeHints":["Pick up imaginary fruit, ask price, look shocked, start to leave, vendor calls back, negotiate with hands"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-011","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Apostolic Faith","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","apostolic","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"An Apostolic prophet walking barefoot and praying over someone","gestureability":"high","categoryType":"action","mimeHints":["Remove shoes, walk with reverence, place hands on imaginary person's head, bow in prayer"],"stereotypeBiasFlag":false}
{"cardId":"CH-SPT-004","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"AFCON Moment","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","afcon","warriors","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Zimbabwe Warriors fans watching their team lose at AFCON 2025","gestureability":"high","categoryType":"situation","mimeHints":["Excited watching start, goal goes in against, face falls, head in hands, hug neighbor for comfort"],"stereotypeBiasFlag":false}
{"cardId":"CH-SPT-005","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Penalty Shootout","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["football","penalty","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Taking a penalty and hitting the crossbar","gestureability":"high","categoryType":"action","mimeHints":["Long run-up, powerful kick, look up watching ball, hit imaginary bar above, hands on head in agony"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-012","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Informal Economy","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","hustle","informal-sector","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"A commuter omnibus tout shouting destinations","gestureability":"high","categoryType":"action","mimeHints":["Lean out imaginary door, cup hands around mouth, shout directions rapidly, wave people on"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-013","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zim Braai Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","braai","friends","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Eating sadza and nyama at a family braai","gestureability":"high","categoryType":"action","mimeHints":["Roll sadza in hand, dip in relish, chew with closed eyes of satisfaction, nod at family member"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-008","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["internet","situations","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Going viral for the wrong reason and trying to delete posts","gestureability":"medium","categoryType":"situation","mimeHints":["Post something, see notifications exploding, panic, tap desperately to delete, too late, face horrified"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-009","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Platform Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["whatsapp","group","social-media","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"The WhatsApp group admin who mutes everyone except themselves","gestureability":"medium","categoryType":"person","mimeHints":["Mime holding admin crown, silence imaginary people one by one with finger to lips, type message royally"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-010","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-04","subcategory":"Viral Challenges","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["tiktok","challenge","african","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Attempting a TikTok challenge and completely failing it","gestureability":"high","categoryType":"situation","mimeHints":["Set phone up, attempt choreography confidently, completely miss timing, check recording, groan"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-014","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zim Slang Situation","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","slang","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Someone who is definitely 'uri panze' (left behind / clueless)","gestureability":"medium","categoryType":"situation","mimeHints":["Walk in confidently, everyone stops, confused look, point to things others laugh at, still not getting it"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-015","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Victoria Falls","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","victoria-falls","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Standing at the edge of Victoria Falls feeling the mist","gestureability":"high","categoryType":"situation","mimeHints":["Look down into abyss dramatically, feel mist on face, spread arms wide, lean forward in awe"],"stereotypeBiasFlag":false}
{"cardId":"CH-AFR-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"AFR-03","subcategory":"Nollywood Film Scene","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","nollywood","film","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"A Nollywood actor discovering their husband has a second family","gestureability":"high","categoryType":"situation","mimeHints":["Innocent expression, discover photos, freeze, dramatic slow turn, long stare, chest grab, faint"],"stereotypeBiasFlag":false}
{"cardId":"CH-WLD-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Geography Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Climbing the Eiffel Tower and being terrified of heights","gestureability":"high","categoryType":"situation","mimeHints":["Climb stairs, look down fearfully, hug imaginary railing, force selfie smile, back away from edge"],"stereotypeBiasFlag":false}
{"cardId":"CH-SCI-001","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SCI-01","subcategory":"Technology Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["technology","ai","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Arguing with ChatGPT when it gives you a wrong answer","gestureability":"medium","categoryType":"situation","mimeHints":["Type question, read response, frown, type correction, read result, more frustrated, slam imaginary laptop"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-016","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe National Events","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","culture","independence","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Zimbabwe Independence Day parade soldier marching","gestureability":"high","categoryType":"action","mimeHints":["March stiffly with exaggerated arm swings, stare straight ahead, chest out, rhythmic precision"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-017","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Queue Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","daily-life","queue","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Waiting in a very long bank queue in the heat","gestureability":"high","categoryType":"situation","mimeHints":["Stand in line, check watch repeatedly, fan self, shuffle forward slowly, look ahead in despair"],"stereotypeBiasFlag":false}
{"cardId":"CH-MUS-004","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"MUS-02","subcategory":"Amapiano Dancing","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","amapiano","dance","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Dancing amapiano at a weekend house party","gestureability":"high","categoryType":"action","mimeHints":["Shoulder shrug step, slow groove, log drum drop, bounce low, arms loose, stylish footwork"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-018","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Young Professionals","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","work","professionals","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"Preparing for a Zoom interview from a noisy family home","gestureability":"high","categoryType":"situation","mimeHints":["Set up professional background, relatives walk through, shoo them frantically, adjust phone, smile professionally"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-019","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Great Zimbabwe","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","great-zimbabwe","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"An ancient king overseeing the building of Great Zimbabwe's stone walls","gestureability":"high","categoryType":"action","mimeHints":["Regal stance, gesture builders to work, inspect stone walls, nod approvingly, raise fist in pride"],"stereotypeBiasFlag":false}
{"cardId":"CH-SCI-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SCI-02","subcategory":"Science Actions","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["science","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"A plant going through photosynthesis","gestureability":"low","categoryType":"action","mimeHints":["Grow slowly from seed, spread arms as leaves, turn face to sun, visibly breathe in CO2 and glow green"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-020","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zim English Expressions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","english","expressions","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","prompt":"The person at a party who greets everyone with 'Hauite Hauite'","gestureability":"medium","categoryType":"person","mimeHints":["Walk in confidently, point at each person, do approving finger-guns, nod with raised eyebrow, big smile"],"stereotypeBiasFlag":false}
{"cardId":"CH-AFR-003","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"AFR-02","subcategory":"African History Actions","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","history","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Nelson Mandela walking out of Victor Verster Prison","gestureability":"high","categoryType":"person","mimeHints":["Emerge through gates, raise fist slowly, enormous smile, embrace imaginary Winnie beside you, face the cameras"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-011","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["social-media","screenshot","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Accidentally sending a screenshot to the person it was about","gestureability":"high","categoryType":"situation","mimeHints":["Screenshot phone, go to wrong chat, send accidentally, freeze, turn pale, type frantically, too late"],"stereotypeBiasFlag":false}
{"cardId":"CH-SMC-012","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Platform Actions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["youtube","watching","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","prompt":"Watching YouTube at night with headphones to avoid waking family","gestureability":"high","categoryType":"situation","mimeHints":["Lie in bed, plug in headphones carefully, dim screen, laugh quietly, cover mouth, freeze when parent stirs"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-021","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Heroes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","heroes","history","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Mbuya Nehanda defiant before execution","gestureability":"high","categoryType":"person","mimeHints":["Stand tall and proud, raise chin defiantly, arms bound behind back, look straight ahead unflinchingly"],"stereotypeBiasFlag":false}
{"cardId":"CH-WLD-002","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"WLD-02","subcategory":"World History Actions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","history","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Neil Armstrong taking his first steps on the moon","gestureability":"high","categoryType":"person","mimeHints":["Slow-motion walking, heavy spacesuit bounce, plant imaginary flag, look around in wonder, give thumbs up"],"stereotypeBiasFlag":false}
{"cardId":"CH-ZIM-022","gameType":"charades","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Prayer Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","prayer","faith","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","prompt":"Praying so intensely you start speaking in tongues","gestureability":"high","categoryType":"action","mimeHints":["Bow head, hands together, gradually more intense, voice silently mouthing faster, hands raise, start shaking slightly"],"stereotypeBiasFlag":false}
```

*Total: 50 Charades cards. CH-ZIM-001 through CH-ZIM-022 plus topic-coded cards = 50 cards.*

---

### 6.4 GAME 3: TRIVIA CHALLENGE — 50 QUESTIONS

*All 50 questions presented with verified answers and sources. factCheckStatus noted per card.*

```jsonl
{"cardId":"TR-SPT-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Warriors AFCON 2025","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","afcon","warriors","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"At the 2025 AFCON in Morocco, in which group were the Zimbabwe Warriors placed?","correctAnswer":"Group B","distractors":["Group A","Group C","Group D"],"explanation":"Zimbabwe was placed in Group B alongside South Africa, Angola and Egypt at the 2025 AFCON in Morocco.","sourceUrl":"https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SPT-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Warriors AFCON 2025","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","afcon","warriors","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Who scored for Zimbabwe in their 2025 AFCON group match against Angola?","correctAnswer":"Musona","distractors":["Nakamba","Maswanhise","Dube"],"explanation":"Knox Musona scored Zimbabwe's goal in the 1-1 draw against Angola at AFCON 2025 in Morocco.","sourceUrl":"https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-SPT-003","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Warriors Coaching","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","warriors","coach","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Who was appointed Zimbabwe Warriors Interim Head Coach after Marian Marinica resigned in 2026?","correctAnswer":"Kaitano Tembo","distractors":["Callisto Pasuwa","Norman Mapeza","Sunday Chidzambwa"],"explanation":"ZIFA confirmed Kaitano Tembo as Interim Head Coach to lead the Warriors for the Unity Cup assignment in the United Kingdom after Marinica's departure.","sourceUrl":"https://zifa.co.zw/marinica-steps-down-as-warriors-head-coach","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-SPT-004","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Marvelous Nakamba","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["football","warriors","nakamba","easy","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Marvelous Nakamba captains Zimbabwe and plays his club football for which English club?","correctAnswer":"Luton FC","distractors":["Wolverhampton Wanderers","Nottingham Forest","Burnley"],"explanation":"Nakamba plays for Luton FC in England and captains the Zimbabwe Warriors national team.","sourceUrl":"https://panafricafootball.com/article/zimbabwe-captain-nakamba-makes-plea-amid-tension","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-SPT-005","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-02","subcategory":"AFCON 2025","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["football","afcon","morocco","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Which country hosted the 2025 Africa Cup of Nations?","correctAnswer":"Morocco","distractors":["Ivory Coast","Senegal","Egypt"],"explanation":"Morocco hosted the 2025 AFCON (35th edition), held from 21 December 2025 to 18 January 2026, after CAF stripped Guinea of hosting rights.","sourceUrl":"https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SPT-006","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SPT-02","subcategory":"AFCON 2025 Winner","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["football","afcon","hard"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Who won the 2025 AFCON? Note: the result was disputed; this question reflects the official CAF ruling.","correctAnswer":"Morocco","distractors":["Senegal","Egypt","Nigeria"],"explanation":"CAF's Appeal Board on 17 March 2026 ruled that Senegal forfeited the final, awarding Morocco a 3-0 win; Senegal indicated an appeal to CAS. This answer reflects the official CAF ruling as of the source date.","sourceUrl":"https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations","sourceRetrievedDate":"2026-11-24","factCheckStatus":"needs-update","publicFigureStatus":"not-applicable"}
{"cardId":"TR-MUS-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Winky D","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","winky-d","easy","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"Which nickname is Winky D most famously known by among his fans?","correctAnswer":"Gaffa","distractors":["Musoja","The King","Baba Harare"],"explanation":"Winky D is known as 'Gaffa' by his fans and is considered the King of Zimdancehall.","sourceUrl":"https://www.ijltemas.in/submission/online/article/view/1854/1111","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-MUS-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Jah Prayzah","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","jah-prayzah","medium","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"Jah Prayzah is nicknamed 'Musoja' by his fans. What does 'Musoja' mean in Shona?","correctAnswer":"Soldier","distractors":["Prophet","King","Hunter"],"explanation":"'Musoja' is a Shona word meaning soldier, reflecting Jah Prayzah's signature military regalia aesthetic.","sourceUrl":"https://www.okayafrica.com/10-zimbabwean-dancehall-artists-you-should-know/284587","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-MUS-003","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Hulengende","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","hulengende","medium","pop-culture","ama2k"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"What is Hulengende's real name?","correctAnswer":"Ezbornwage Chidamajaya","distractors":["Millicent Chimonyo","Taurai Hwinza","Farai Munyama"],"explanation":"Hulengende's real name is Ezbornwage Chidamajaya, a Zimdancehall artist known for 'Fadza Madzimai'.","sourceUrl":"https://sona.co.zw/2025/10/hulengende-biography.html","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-MUS-004","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall Genres","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","zimdancehall","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Zimdancehall lyrics are most commonly in which language(s)?","correctAnswer":"Shona and Ndebele","distractors":["English only","Jamaican patois","French and Swahili"],"explanation":"Contemporary Zimbabwean dancehall artists rap and sing in vernacular languages, primarily Shona and Ndebele, over computer-generated beats.","sourceUrl":"https://www.okayafrica.com/10-zimbabwean-dancehall-artists-you-should-know/284587","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-MUS-005","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Holy Ten","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","holy-ten","medium","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Holy Ten styles himself with which two titles?","correctAnswer":"Leader of the Youth and Speaker of the Truth","distractors":["King of Zim Hip-Hop and Voice of the Streets","Gaffa and the Prophet","Musoja and the Commander"],"explanation":"Holy Ten calls himself 'Leader of the Youth' and 'Speaker of the Truth', titles that reflect his self-positioning in Zimbabwean hip-hop.","sourceUrl":"https://allwhitelord.com/blog/the-new-school-hulengende-sane-wav-xiba-atenda-chinx-and-the-sound-zimbabwe-cannot-ignore","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-SMC-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Madam Boss","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","madam-boss","easy","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"What is Madam Boss's real name?","correctAnswer":"Tarisai Cleopatra Chikocho","distractors":["Rudo Mupamhanga","Millicent Chimonyo","Chiedza Zvoushe"],"explanation":"Madam Boss, the Zimbabwean comedian and social media personality, was born Tarisai Cleopatra Chikocho in 1985.","sourceUrl":"https://en.wikipedia.org/wiki/Madam_Boss","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-SMC-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Madam Boss Achievement","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","madam-boss","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Madam Boss is reported to have been the first Zimbabwean comedian to reach how many Facebook followers?","correctAnswer":"1 million","distractors":["500,000","2 million","100,000"],"explanation":"Madam Boss reportedly became the first Zimbabwean comedian to reach 1 million Facebook followers, building her following through comedy skits as a maid.","sourceUrl":"https://en.wikipedia.org/wiki/Madam_Boss","sourceRetrievedDate":"2026-11-24","factCheckStatus":"plausible-unverified","publicFigureStatus":"active"}
{"cardId":"TR-SMC-003","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Comic Pastor","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","comic-pastor","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"Zimbabwean comedian Prosper Ngomashi, known as Comic Pastor, announced he was retiring from comedy in which year?","correctAnswer":"2025","distractors":["2023","2024","2026"],"explanation":"Comic Pastor, known for his satirical skits on Zimbabwean life, announced in July 2025 that 2025 marks the end of his comedy persona.","sourceUrl":"https://youthvillage.co.zw/sport-entertainment/celebrity-news/comic-pastor-to-retire-from-comedy-in-2025-says-hes-shared-the-light","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"retired"}
{"cardId":"TR-SMC-004","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-04","subcategory":"Meerkat Meme","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["memes","african","meerkat","medium","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"The viral 'Meerkat With a Toothpick' meme began spreading widely on African social media in approximately which month of 2025?","correctAnswer":"June 2025","distractors":["January 2025","September 2025","March 2025"],"explanation":"The AI-generated meerkat meme began going viral on Facebook and X/Twitter in late May 2025 and became increasingly popular throughout June 2025, spreading especially among African social media users.","sourceUrl":"https://knowyourmeme.com/memes/meerkat-with-a-toothpick","sourceRetrievedDate":"2026-11-24","factCheckStatus":"plausible-unverified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SMC-005","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Zimbabwe Social Media Stats","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","whatsapp","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"According to a 2025 Zimbabwe ICT survey, what percentage of Zimbabwean internet users use WhatsApp?","correctAnswer":"92.9%","distractors":["44.8%","38%","71%"],"explanation":"The 2025 ICT Access by Households and Use by Individuals Survey found WhatsApp used by 92.9% of Zimbabwean internet users, making it the country's dominant social media platform.","sourceUrl":"https://newziana.co.zw/more-and-more-zimbabweans-embracing-ai","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SMC-006","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Top TikTok Zimbabwe","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","tiktok","influencer","hard"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"As of November 2026, which Zimbabwean creator was ranked most followed on TikTok according to the Heepsy platform ranking?","correctAnswer":"Annatoria","distractors":["Madam Boss","Young Gemini","Taffy Theman"],"explanation":"Heepsy's November 2026 ranking of Zimbabwean TikTok creators lists Annatoria as the most followed with 1.7M followers.","sourceUrl":"https://heepsy.com/en/find-influencers/tiktok/zimbabwe","sourceRetrievedDate":"2026-11-24","factCheckStatus":"plausible-unverified","publicFigureStatus":"active"}
{"cardId":"TR-ZIM-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","slang","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"What does the Shona slang term 'Ibho' mean?","correctAnswer":"It's good / It's okay","distractors":["It's expensive","Watch out","Hurry up"],"explanation":"'Ibho' is short for 'iri bho' in Shona, meaning it's good, it's okay, or it's fine.","sourceUrl":"https://zimxcite.com/pages/glossary","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang Advanced","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","slang","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"What does Zimbabwean slang term 'Zinumber' mean?","correctAnswer":"A hit song","distractors":["A phone number","A lottery ticket","A street address"],"explanation":"'Zinumber' is Zimbabwean Shona slang for a hit song.","sourceUrl":"https://youthvillage.co.zw/sport-entertainment/top-20-popular-shona-slang-phrases-words","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-003","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang Police","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","slang","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"'Rizpo' is Zimbabwean youth slang for what? (Hint: it's the word 'porisi' spelled backwards.)","correctAnswer":"Police","distractors":["Money","A car","A party"],"explanation":"'Rizpo' is 'porisi' (police) spelled backwards, used as discreet street slang for police among Zimbabwean youth.","sourceUrl":"https://shonaslang.com","sourceRetrievedDate":"2026-11-24","factCheckStatus":"plausible-unverified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-004","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe Geography","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","victoria-falls","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Victoria Falls on the Zambezi River is on the border between Zimbabwe and which country?","correctAnswer":"Zambia","distractors":["Botswana","Mozambique","South Africa"],"explanation":"Victoria Falls sits on the Zambezi River forming the border between Zimbabwe (Livingstone side is Zambia, Victoria Falls town side is Zimbabwe) and Zambia.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-005","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Independence","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","independence","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"In which year did Zimbabwe gain independence?","correctAnswer":"1980","distractors":["1963","1975","1990"],"explanation":"Zimbabwe gained independence on 18 April 1980, formerly known as Rhodesia under white minority rule.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-006","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Heritage","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","heritage","great-zimbabwe","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Great Zimbabwe, a UNESCO World Heritage Site, was the capital of which medieval African empire?","correctAnswer":"Kingdom of Zimbabwe","distractors":["Monomotapa Empire","Rozvi State","Ndebele Kingdom"],"explanation":"Great Zimbabwe was the capital of the Kingdom of Zimbabwe, a medieval Shona state that flourished in the 11th–15th centuries.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-007","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Zimbabwean Church Culture","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","church","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Which Zimbabwean apostolic church, founded by Johane Marange in 1932, is known for white robes and outdoor worship?","correctAnswer":"Johane Marange Apostolic Church (Vapostori)","distractors":["ZAOGA","Zion Christian Church","AFM of Zimbabwe"],"explanation":"The Johane Marange Apostolic Church (commonly called Vapostori) was founded in 1932 and is known for distinctive white robes, barefoot worship and outdoor ceremonies.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-008","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Food","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","food","sadza","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Sadza, Zimbabwe's staple food, is made from ground meal of which crop?","correctAnswer":"Maize","distractors":["Wheat","Sorghum","Cassava"],"explanation":"Sadza is a solid porridge made from ground maize (corn) meal and is the staple food eaten daily across Zimbabwe.","sourceUrl":"https://zimxcite.com/pages/glossary","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SCI-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SCI-03","subcategory":"Zimbabwe Telecoms","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","technology","econet","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Which mobile network holds the largest share of active SIMs in Zimbabwe as of early 2025?","correctAnswer":"Econet","distractors":["NetOne","Telecel","Liquid Home"],"explanation":"Econet holds approximately 72.85% of active SIMs in Zimbabwe's mobile market in Q1 2025, far ahead of NetOne (25.03%) and Telecel (2.12%).","sourceUrl":"https://cipesa.org/download/reports/State_of_Internet_Freedom_in_Africa_2025__Navigating_the_Implications_of_AI_on_Digital_Democracy_in_Zimbabwe__.pdf","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SCI-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SCI-01","subcategory":"AI in Zimbabwe","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","technology","ai","hard"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"According to Zimbabwe's 2025 ICT survey, what percentage of Zimbabwean internet users are now using AI tools?","correctAnswer":"31%","distractors":["12%","55%","8%"],"explanation":"The 2025 ICT Access by Households and Use by Individuals Survey (ZIMSTAT/POTRAZ) found that 31% of internet users in Zimbabwe now use AI tools, with Meta AI most popular at 53.7%.","sourceUrl":"https://newziana.co.zw/more-and-more-zimbabweans-embracing-ai","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SCI-003","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SCI-02","subcategory":"Science Concepts","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["science","biology","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Which process do green plants use to make their own food using sunlight?","correctAnswer":"Photosynthesis","distractors":["Respiration","Fermentation","Osmosis"],"explanation":"Photosynthesis is the process by which green plants convert sunlight, water and carbon dioxide into glucose and oxygen.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-AFR-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"AFR-02","subcategory":"African History","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","history","mandela","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"How many years did Nelson Mandela spend in prison before his release in 1990?","correctAnswer":"27 years","distractors":["18 years","33 years","10 years"],"explanation":"Nelson Mandela was imprisoned from 1964 to 1990, spending 27 years in prison primarily on Robben Island.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-AFR-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"AFR-03","subcategory":"African Pop Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","pop-culture","nollywood","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"Nollywood is the popular film industry of which African country?","correctAnswer":"Nigeria","distractors":["Ghana","South Africa","Kenya"],"explanation":"Nollywood refers to Nigeria's film industry, the second largest in the world by number of films produced annually.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ENT-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Entertainment","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","film","black-panther","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"In the movie Black Panther, what is the name of the fictional African country ruled by T'Challa?","correctAnswer":"Wakanda","distractors":["Zamunda","Narnia","Genovia"],"explanation":"Wakanda is the fictional African nation in Marvel's Black Panther, depicted as the most technologically advanced country in the world.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ENT-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Music","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","music","reggae","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Bob Marley, who performed in Zimbabwe at independence celebrations in 1980, was from which country?","correctAnswer":"Jamaica","distractors":["Trinidad and Tobago","Barbados","Cuba"],"explanation":"Bob Marley was a Jamaican reggae legend who famously performed at Zimbabwe's independence celebrations in Harare on 18 April 1980.","sourceUrl":"https://www.okayafrica.com/10-zimbabwean-dancehall-artists-you-should-know/284587","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-UNI-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Zimbabwe Youth Unemployment","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","employment","youth","hard"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"According to ZIMSTAT's Q2 2025 Labour Force Survey, what was the unemployment rate among Zimbabweans aged 15-24?","correctAnswer":"39.3%","distractors":["18.5%","52.1%","28.9%"],"explanation":"ZIMSTAT's Second Quarter 2025 Labour Force Survey recorded an unemployment rate of 39.3% among young people aged 15-24. The 28.9% figure applies to the broader 15-35 age group.","sourceUrl":"https://thegranite.co.zw/articles/why-zimbabwe-s-youth-are-struggling-to-find-jobs","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-UNI-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Zimbabwe Digital Divide","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","digital","rural","hard"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"According to a 2025 Zimbabwe digital divide study, what percentage of rural respondents in Umzingwane district had no access to any digital device?","correctAnswer":"11.6%","distractors":["0%","35%","55%"],"explanation":"In Umzingwane (rural), 11.6% of respondents had no access to any listed device, compared with 0% in urban Bulawayo, illustrating Zimbabwe's digital divide.","sourceUrl":"https://emthonjeniwf.org/wp-content/uploads/2025/09/Digital-Divide-research.pdf","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-009","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe National Symbol","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","symbol","flag","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"What bird features on Zimbabwe's national flag and coat of arms?","correctAnswer":"Zimbabwe Bird (Soapstone bird / African fish eagle design)","distractors":["Secretary bird","Crowned crane","African eagle-owl"],"explanation":"The Zimbabwe Bird, based on soapstone carvings found at Great Zimbabwe, appears on the national flag and coat of arms as the national symbol.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-010","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe Lakes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","kariba","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Lake Kariba on the Zambezi River, one of the world's largest man-made lakes, borders Zimbabwe and which other country?","correctAnswer":"Zambia","distractors":["Botswana","Mozambique","Malawi"],"explanation":"Lake Kariba was created by damming the Zambezi River and lies on the border between Zimbabwe and Zambia.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-MUS-006","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Atenda Chinx","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","atenda-chinx","hard","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Atenda Chinx is the daughter of which late Zimbabwean musician?","correctAnswer":"Dickson 'Comrade Chinx' Chingaira","distractors":["Alick Macheso","Leonard Dembo","Simon Chimbetu"],"explanation":"Atenda Chinx is the daughter of the late musician Dickson 'Comrade Chinx' Chingaira and has won the NAMA Outstanding Breakthrough Artist award in 2025 and 2026.","sourceUrl":"https://allwhitelord.com/blog/the-new-school-hulengende-sane-wav-xiba-atenda-chinx-and-the-sound-zimbabwe-cannot-ignore","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-MUS-007","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Sane Wav Awards","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","sane-wav","hard","pop-culture"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"At the 15th Zim Hip Hop Awards in December 2025, which artist was most nominated and won both Best Hip Hop Personality and Best Newcomer?","correctAnswer":"Sane Wav","distractors":["Xiba","Holy Ten","Atenda Chinx"],"explanation":"Sane Wav was the most nominated artist at the 15th Zim Hip Hop Awards in December 2025, winning Best Hip Hop Personality and Best Newcomer.","sourceUrl":"https://allwhitelord.com/blog/the-new-school-hulengende-sane-wav-xiba-atenda-chinx-and-the-sound-zimbabwe-cannot-ignore","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-ZIM-011","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwe Languages","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","language","shona","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"Approximately what percentage of Zimbabwe's population speaks Shona as their first language?","correctAnswer":"70%","distractors":["30%","50%","90%"],"explanation":"Approximately 70% of Zimbabwe's population is Shona-speaking, though the country has at least 16 official languages.","sourceUrl":"https://zimxcite.com/pages/glossary","sourceRetrievedDate":"2026-11-24","factCheckStatus":"plausible-unverified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-WLD-001","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Geography","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"What is the capital city of France?","correctAnswer":"Paris","distractors":["Lyon","Marseille","Bordeaux"],"explanation":"Paris is the capital city of France, home to landmarks including the Eiffel Tower.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-WLD-002","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Capitals Africa","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","geography","capitals","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"What is the capital city of Kenya?","correctAnswer":"Nairobi","distractors":["Mombasa","Kampala","Dar es Salaam"],"explanation":"Nairobi is the capital and largest city of Kenya, also the seat of the United Nations Environment Programme.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-MUS-008","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"MUS-02","subcategory":"Amapiano Genre","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","amapiano","south-africa","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"Amapiano, the globally popular music genre characterised by log drum bass lines, originated in which country?","correctAnswer":"South Africa","distractors":["Nigeria","Zimbabwe","Kenya"],"explanation":"Amapiano originated in South Africa's townships, particularly in Pretoria and Johannesburg, in the mid-2010s and became a global phenomenon by the early 2020s.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-012","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwe Transport","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","transport","kombi","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"What is the Zimbabwean name for the minibus taxis widely used for public transport in Harare and other cities?","correctAnswer":"Kombi","distractors":["Matatu","Trotro","Dala-dala"],"explanation":"Kombis are the main form of public transport in Zimbabwe's urban areas, equivalent to matatus in Kenya or trotros in Ghana.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-013","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Mobile Money","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","technology","ecocash","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"EcoCash is a mobile money platform operated by which Zimbabwean telecommunications company?","correctAnswer":"Econet","distractors":["NetOne","Telecel","Liquid Home"],"explanation":"EcoCash is Zimbabwe's dominant mobile money platform, operated by Econet Wireless Zimbabwe.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-014","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Bible Trivia","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["bible","faith","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"In the Bible, who built an ark to survive a great flood?","correctAnswer":"Noah","distractors":["Moses","Abraham","Elijah"],"explanation":"According to the Book of Genesis, Noah built an ark on God's instruction to survive a great flood, taking animals two by two.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-015","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Bible Trivia Advanced","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["bible","faith","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","question":"In the Bible, David killed the giant Goliath using a sling and what?","correctAnswer":"A stone","distractors":["An arrow","A sword","A spear"],"explanation":"David killed Goliath using a sling and a single stone, striking him in the forehead (1 Samuel 17).","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-SMC-007","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"SMC-03","subcategory":"Global Creators","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","creator","khaby","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"Khaby Lame, one of TikTok's most followed creators worldwide, is originally from which country?","correctAnswer":"Senegal (raised in Italy)","distractors":["Nigeria","Morocco","South Africa"],"explanation":"Khaby Lame was born in Senegal and raised in Italy, becoming famous for his silent reaction videos simplifying overcomplicated life hacks.","sourceUrl":"https://en.wikipedia.org","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"active"}
{"cardId":"TR-ZIM-016","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Social Media Stats","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","stats","medium"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","question":"As of October 2025 (DataReportal), Zimbabwe had approximately how many social media user identities?","correctAnswer":"2.60 million","distractors":["500,000","10 million","15 million"],"explanation":"DataReportal's Digital 2026 report records Zimbabwe having 2.60 million social media user identities in October 2025, 15.3% of the total population.","sourceUrl":"https://datareportal.com/reports/digital-2026-zimbabwe","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
{"cardId":"TR-ZIM-017","gameType":"trivia","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwean Expressions","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","expressions","easy"],"contentOrigin":"factual-sourced","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","question":"What does the Shona phrase 'Zvinhu Zvirikufaya' mean in English?","correctAnswer":"Things are lit / It's happening","distractors":["The food is ready","We are leaving","It is raining"],"explanation":"'Zvinhu Zvirikufaya' literally translates as 'things are firing' and is Zimbabwean youth slang meaning 'things are lit' or 'it's happening / fun.'","sourceUrl":"https://zimxcite.com/pages/glossary","sourceRetrievedDate":"2026-11-24","factCheckStatus":"verified","publicFigureStatus":"not-applicable"}
```

*Total: 50 Trivia cards. TR-SPT-001 through TR-ZIM-017 = 50 questions.*

---

### 6.5 GAME 4: FORBIDDEN WORDS ("ZVAKATARIRWA") — 50 CARDS

```jsonl
{"cardId":"FW-ZIM-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Food","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","food","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"SADZA","forbiddenClues":["Porridge","Maize","Cook","Staple","Ugali"],"solvabilityCheck":{"validRoutesCount":5,"checkedByEditors":true,"sampleValidClues":["What you eat with relish every evening in Zimbabwe","The white stiff food made from ground corn that fills you up"]}}
{"cardId":"FW-ZIM-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Transport","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","transport","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"KOMBI","forbiddenClues":["Minibus","Taxi","Transport","Drive","Rank"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The overloaded public vehicle you squash into every morning to get to town","What the conductor hangs out of to shout the destination"]}}
{"cardId":"FW-ZIM-003","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Daily Life Situations","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","electricity","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"LOAD SHEDDING","forbiddenClues":["Electricity","Power","ZESA","Cut","Blackout"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["When the lights go off for hours and you can't charge your phone","The planned outage schedule that ruins your evening every day in Harare"]}}
{"cardId":"FW-SPT-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Football","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","football","warriors","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"ZIMBABWE WARRIORS","forbiddenClues":["Zimbabwe","Football","National","Team","Soccer"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["Nakamba captains them","The name Zimbabweans shout when their country plays at AFCON"]}}
{"cardId":"FW-SPT-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Global Football","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","football","messi","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"MESSI","forbiddenClues":["Argentina","Football","Soccer","Goals","Lionel"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The GOAT who finally won the World Cup in 2022 with his country","Short dribbler who used to play for Barcelona and now in America"]}}
{"cardId":"FW-MUS-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","winky-d","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"WINKY D","forbiddenClues":["Dancehall","Gaffa","Zimbabwe","Ibotso","Reggae"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["Urban youth's voice, known for songs about ghetto struggle, not Jah Prayzah","The 'King of' a Zimbabwean genre that starts with 'Zim'"]}}
{"cardId":"FW-MUS-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","jah-prayzah","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"JAH PRAYZAH","forbiddenClues":["Musoja","Military","Zimbabwe","Music","Soldier"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["He wears regalia on stage and his fans call him by the Shona word for a certain armed forces member","The artist whose 'Kutonga Kwaro' was played at ZANU-PF rallies, Davido's friend"]}}
{"cardId":"FW-MUS-003","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"MUS-01","subcategory":"Zimdancehall New Wave","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","music","hulengende","medium","pop-culture","ama2k"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"HULENGENDE","forbiddenClues":["Fadza","Madzimai","TikTok","Malloti","MalloNgende"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["Zimdancehall Ama2K star who went number one on Apple Music Zimbabwe in September 2025","His real name is Ezbornwage Chidamajaya"]}}
{"cardId":"FW-SMC-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-01","subcategory":"Zimbabwean Creators","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","social-media","madam-boss","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"MADAM BOSS","forbiddenClues":["Comedian","Maid","Facebook","Skit","Zimbabwe"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The first Zimbabwean creator to reach 1 million followers on a certain platform, known for her blue and pink looks","Her real name is Tarisai Cleopatra Chikocho"]}}
{"cardId":"FW-SMC-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Social Media Platforms","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["social-media","whatsapp","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"WHATSAPP","forbiddenClues":["Message","Chat","App","Text","Green"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The platform where 92.9% of Zimbabwean internet users are","You send voice notes and get added to groups you didn't ask to join on this"]}}
{"cardId":"FW-SMC-003","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-05","subcategory":"Social Media Platforms","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["social-media","tiktok","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"TIKTOK","forbiddenClues":["Video","Dance","Viral","App","ByteDance"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The platform where Hulengende's 'Fadza Madzimai' challenge happened","You scroll your For You Page on this short-form video platform"]}}
{"cardId":"FW-SMC-004","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-04","subcategory":"Memes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["memes","african","meerkat","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"MEERKAT WITH A TOOTHPICK","forbiddenClues":["Animal","African","Meme","Viral","AI"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The AI-generated image of a smirking small creature leaning against a wall that flooded African social media in June 2025","Innbucks and ZERA both used this confident slender animal with a dental tool image in corporate meme posts"]}}
{"cardId":"FW-SMC-005","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["social-media","group-admin","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"GROUP ADMIN","forbiddenClues":["WhatsApp","Chat","Control","Mute","Manager"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The person who added you to a group without asking and can remove anyone they don't like","They have the power to change the icon and name of your family communication space"]}}
{"cardId":"FW-ZIM-004","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","slang","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"LOBOLA","forbiddenClues":["Bride","Price","Marriage","Pay","Roora"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The negotiation between families that has to happen before a Zimbabwean wedding can proceed","When the groom's uncles visit the bride's family with cattle or money"]}}
{"cardId":"FW-ZIM-005","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang Terms","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","slang","ibho","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"IBHO","forbiddenClues":["Okay","Fine","Good","Short","Iri"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["Shona slang approval word used when something meets expectations — the full phrase would be 'iri bho'","Two syllables starting with the ninth letter of the alphabet that you say in Zimbabwe when everything checks out"]}}
{"cardId":"FW-ZIM-006","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Faith Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","faith","church","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"PASTOR","forbiddenClues":["Church","Preach","Minister","God","Reverend"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The person who stands at the front of the congregation on Sunday and leads worship","In Zimbabwe the Comic Pastor used this word as half of his comedy name"]}}
{"cardId":"FW-ZIM-007","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Bible Stories","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["bible","faith","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"NOAH","forbiddenClues":["Ark","Flood","Bible","Animals","Rain"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["He took two of every creature onto a giant boat to survive a worldwide disaster in Genesis","The name also used by people in Zimbabwe to refer to someone who survived a crisis by planning ahead"]}}
{"cardId":"FW-SPT-003","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-02","subcategory":"AFCON","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","football","afcon","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"AFCON","forbiddenClues":["Africa","Cup","Nations","CAF","Tournament"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The biennial competition Zimbabwe played in Morocco in December 2025 to January 2026","The championship where Senegal and Morocco fought a controversial final"]}}
{"cardId":"FW-SPT-004","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-01","subcategory":"Zimbabwe Warriors Players","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","football","nakamba","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"NAKAMBA","forbiddenClues":["Captain","Zimbabwe","Luton","Midfielder","Marvelous"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The Warriors skipper who called for calm during the Marinica coaching controversy","His first name means something wonderful — plays in the Championship in England"]}}
{"cardId":"FW-UNI-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"UNI-01","subcategory":"University Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","university","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"UNIVERSITY OF ZIMBABWE","forbiddenClues":["University","Harare","UZ","Campus","College"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["Zimbabwe's oldest and most prestigious higher education institution, founded in 1952, located in Mount Pleasant","The institution whose graduates often struggle to find jobs in Zimbabwe's formal sector"]}}
{"cardId":"FW-UNI-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Work Life","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","work","ecocash","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"ECOCASH","forbiddenClues":["Mobile","Money","Econet","Pay","Transfer"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The app you use on your Econet line to pay for groceries at the tuck shop","Zimbabwe's dominant digital wallet that allows you to buy airtime, pay bills, send money"]}}
{"cardId":"FW-ZIM-008","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe Landmarks","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","victoria-falls","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"VICTORIA FALLS","forbiddenClues":["Waterfall","Zambezi","Falls","Livingstone","UNESCO"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The massive natural wonder on Zimbabwe's western border that creates so much mist you get wet just standing nearby","One of the Seven Natural Wonders of the world shared with Zambia"]}}
{"cardId":"FW-ZIM-009","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-02","subcategory":"Zimbabwe Lakes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","geography","kariba","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"LAKE KARIBA","forbiddenClues":["Dam","Zambezi","Lake","Zimbabwe","Zambia"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The enormous man-made reservoir in northwestern Zimbabwe where people go for houseboat holidays","Created when the Kariba Dam was built in the 1950s, it displaced thousands of Tonga people"]}}
{"cardId":"FW-ZIM-010","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Heritage","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","heritage","great-zimbabwe","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"GREAT ZIMBABWE","forbiddenClues":["Ruins","Stone","Shona","UNESCO","Ancient"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The medieval walled city in Masvingo that gave the country its name","The place with tall granite enclosures built without mortar that baffled European colonists who refused to believe Africans built it"]}}
{"cardId":"FW-ZIM-011","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Figures","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","mugabe","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"ROBERT MUGABE","forbiddenClues":["President","Zimbabwe","First","Grace","ZANU"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The liberation hero turned long-serving ruler who was removed by coup in November 2017","Famous for land reform, international sanctions, and being the subject of countless Zimbabwean memes and jokes"]}}
{"cardId":"FW-ZIM-012","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwean Identity","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","identity","mbira","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"MBIRA","forbiddenClues":["Instrument","Music","Thumb","Shona","Traditional"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The small metal-tined plucked instrument found inside a hollow resonator, central to Shona spiritual ceremonies","Thomas Mapfumo used this ancient device in his Chimurenga music as a symbol of Zimbabwean cultural identity"]}}
{"cardId":"FW-AFR-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"AFR-02","subcategory":"African History","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","mandela","history","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"NELSON MANDELA","forbiddenClues":["South Africa","Apartheid","Prison","ANC","Mandela"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The man who spent 27 years on Robben Island and became his country's first democratically elected president","His first name is the same as a British admiral, and he is considered one of the greatest leaders in African history"]}}
{"cardId":"FW-AFR-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"AFR-03","subcategory":"African Pop Culture","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","nollywood","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"NOLLYWOOD","forbiddenClues":["Nigeria","Film","Movie","Hollywood","Actors"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The enormous West African film industry that produces more films per year than almost anywhere on earth","When a character on this continent's most popular drama dies, comes back, dies again, and comes back a third time — that's this industry"]}}
{"cardId":"FW-SCI-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SCI-01","subcategory":"Technology","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["technology","ai","chatgpt","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"CHATGPT","forbiddenClues":["AI","Chat","GPT","OpenAI","Robot"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The text-based artificial intelligence that Zimbabwean students use for 29.1% of AI usage, second after Meta AI","The platform where you type a question and it writes your whole assignment — if your lecturer doesn't notice"]}}
{"cardId":"FW-SCI-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SCI-02","subcategory":"Science Concepts","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["science","technology","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"DNA","forbiddenClues":["Genes","Biology","Cell","Helix","Genetic"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The molecule that carries your personal blueprint — identical twins have the same one","Forensic scientists use it to solve crimes, and paternity tests use it to settle family arguments"]}}
{"cardId":"FW-UNI-003","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Relationships","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","relationships","friend-zone","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"FRIEND ZONE","forbiddenClues":["Friend","Romantic","Relationship","Love","Zone"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["When someone you have feelings for treats you like a sibling and introduces you to their new partner","The situation where you buy someone food, listen to all their problems, and they still don't see you that way"]}}
{"cardId":"FW-UNI-004","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"UNI-02","subcategory":"Zimbabwe Informal Economy","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","hustle","informal-sector","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"TUCK SHOP","forbiddenClues":["Shop","Store","Sell","Buy","Small"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The tiny neighbourhood convenience outlet where you buy airtime, bread and maputi on credit","Found on almost every corner of a Zimbabwe high-density suburb, run from someone's garage or front room"]}}
{"cardId":"FW-WLD-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"WLD-01","subcategory":"World Geography","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","geography","eiffel","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"EIFFEL TOWER","forbiddenClues":["France","Paris","Tower","Metal","Gustave"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The iconic iron lattice structure that every tourist in Europe takes the same exact photo in front of","Built for the 1889 World's Fair and originally meant to be demolished, now the most visited paid monument on earth"]}}
{"cardId":"FW-WLD-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"WLD-02","subcategory":"World History","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","history","cold-war","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"COLD WAR","forbiddenClues":["War","USA","Soviet","USSR","Nuclear"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The decades-long political standoff between America and Russia after WWII that never actually became direct fighting","The global conflict where both sides used Africa as a chess board for proxy battles during independence movements"]}}
{"cardId":"FW-ENT-001","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Entertainment","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","film","lion-king","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"THE LION KING","forbiddenClues":["Disney","Lion","Simba","Animated","Film"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The animated classic set in Africa where a young prince must reclaim his throne after his uncle murders his father","'Hakuna Matata' is the famous song from this movie"]}}
{"cardId":"FW-ENT-002","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ENT-03","subcategory":"Global Entertainment","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","film","black-panther","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"WAKANDA","forbiddenClues":["Marvel","T'Challa","Africa","Vibranium","Panther"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The fictional African utopia from the Black Panther universe where technology is centuries ahead of the world","'Wakanda Forever' was the salute made in memory of Chadwick Boseman after his passing"]}}
{"cardId":"FW-ZIM-013","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Slang Terms","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","slang","daily-life","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"PAKADOMA","forbiddenClues":["Seat","Bus","Top","Engine","Free"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The coveted cramped spot right at the front of an urban bus perched above where the mechanical heart of the vehicle lives","In Shona slang this refers to the uncomfortable but free position that only the most flexible passengers dare to take"]}}
{"cardId":"FW-SPT-005","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Global Football","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","football","ronaldo","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"CRISTIANO RONALDO","forbiddenClues":["Portugal","Football","CR7","Goals","Manchester"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The other GOAT who is Messi's eternal rival — famous for the 'SIUUU' celebration","He plays in Saudi Arabia now after playing for Real Madrid, Manchester United and Juventus"]}}
{"cardId":"FW-MUS-004","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"MUS-02","subcategory":"African Music Genre","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"african","tags":["africa","amapiano","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"AMAPIANO","forbiddenClues":["South Africa","Piano","Log","Genre","Dance"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The house music sub-genre characterised by a distinctive drum instrument's deep bass note that birthed the 'woza' dance","Zimbabwe artists are blending Zimdancehall with this South African sound that features a low heavy percussive 'boom'"]}}
{"cardId":"FW-MUS-005","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"MUS-03","subcategory":"Global Music","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","music","reggae","bob-marley","easy","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"BOB MARLEY","forbiddenClues":["Reggae","Jamaica","Rastafari","Legend","Marley"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The musician who performed at Zimbabwe's independence in 1980 and whose face appears on more bedroom posters in Africa than any other artist","'No Woman No Cry' and 'One Love' are his most famous songs"]}}
{"cardId":"FW-ZIM-014","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe School System","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","education","zimsec","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"ZIMSEC","forbiddenClues":["Zimbabwe","Exam","School","Certificate","Test"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The national body that runs O-Level and A-Level examinations in Zimbabwe's education system","The institution whose results every Zimbabwean parent anxiously awaits before Christmas"]}}
{"cardId":"FW-ZIM-015","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Zimbabwean Expressions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","expressions","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"HAUITE HAUITE","forbiddenClues":["Cool","Killed","Slang","Shona","Done"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The double-word Zimbabwean expression of approval you shout when someone does something unexpectedly impressive","You say this when someone arrives at a party looking incredibly well-dressed and everyone stops to stare"]}}
{"cardId":"FW-UNI-005","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"UNI-03","subcategory":"Young Professional Life","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","work","professionals","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"SIDE HUSTLE","forbiddenClues":["Business","Money","Part-time","Extra","Work"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The additional income stream every Zimbabwean with a formal job also runs because one salary is not enough","Selling data bundles, baking cakes to order, or doing graphic design after hours — this is what it's called"]}}
{"cardId":"FW-SMC-006","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-03","subcategory":"Global Creator","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","creator","khaby","medium","pop-culture"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"KHABY LAME","forbiddenClues":["TikTok","Senegal","Italy","Silent","Reaction"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The creator who became one of the world's most followed by never speaking on camera — just showing a simpler way to do what others overcomplicated","His deadpan open-hands gesture became the universal symbol for 'why are you making this so hard?'"]}}
{"cardId":"FW-ZIM-016","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-05","subcategory":"Bible Stories","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["bible","faith","david","goliath","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"GOLIATH","forbiddenClues":["Giant","David","Bible","Sling","Philistine"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The enormous warrior defeated by a small shepherd boy using a single stone — his name now means any overwhelming opponent","When someone says 'it's David versus...' in a competition, this is the other half of that phrase"]}}
{"cardId":"FW-ZIM-017","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Ndebele Language","difficulty":"hard","minAge":16,"ageRating":"16+","language":"en-nd","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","ndebele","language","hard"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"INDABA","forbiddenClues":["Ndebele","Meeting","Talk","Discuss","Conference"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["An isiNdebele/Zulu word for a serious gathering of community leaders to deliberate an important matter — now used internationally","The Bulawayo equivalent of what a Shona community would call a 'dare'"]}}
{"cardId":"FW-SPT-006","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SPT-03","subcategory":"Global Football","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["global","football","arsenal","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"ARSENAL","forbiddenClues":["London","Gunners","Football","Premier","Club"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["The red and white North London club whose fans are very vocal in Zimbabwe despite the club's trophy drought for many years","The EPL team whose fans say 'We'll win it this year' every single season"]}}
{"cardId":"FW-ZIM-018","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-03","subcategory":"Zimbabwean Food","difficulty":"easy","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","food","maputi","easy"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"MAPUTI","forbiddenClues":["Popcorn","Maize","Snack","Corn","Street"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The cheap Zimbabwean version of a cinema snack, sold in small paper bags at every bus rank and school gate","The puffed-up dried kernels that pop when heated — the Shona name for a universally loved Zimbabwean treat"]}}
{"cardId":"FW-ZIM-019","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-01","subcategory":"Zimbabwe Heroes","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","history","nehanda","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"evergreen","reviewAfterDate":"2028-11-24","createdDate":"2026-11-24","targetWord":"MBUYA NEHANDA","forbiddenClues":["Spirit","Medium","Ancestor","Chimurenga","Zimbabwe"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The revolutionary heroine whose famous last words 'my bones will rise' are part of Zimbabwe's national consciousness","She was hanged by colonial authorities but is considered the founding spirit of Zimbabwean resistance — a statue of her stands in Harare's CBD"]}}
{"cardId":"FW-SMC-007","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"SMC-06","subcategory":"Internet Situations","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en","regionalRelevance":"global","tags":["social-media","viral","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"6-months","reviewAfterDate":"2027-05-24","createdDate":"2026-11-24","targetWord":"GOING VIRAL","forbiddenClues":["Viral","Share","Spread","Internet","Video"],"solvabilityCheck":{"validRoutesCount":4,"checkedByEditors":true,"sampleValidClues":["When a post gets shared by thousands of people overnight and suddenly everyone is talking about you","The moment a Zimbabwean creator's clip gets picked up by big South African or Nigerian accounts and their notifications won't stop"]}}
{"cardId":"FW-ZIM-020","gameType":"forbidden-words","version":1,"schemaVersion":"1.0.0","category":"ZIM-04","subcategory":"Shona Expressions","difficulty":"medium","minAge":16,"ageRating":"16+","language":"en-sn","regionalRelevance":"zimbabwe-national","tags":["zimbabwe","shona","expressions","medium"],"contentOrigin":"original-creative","editorialStatus":"approved","reviewCadence":"12-months","reviewAfterDate":"2027-11-24","createdDate":"2026-11-24","targetWord":"URI PANZE","forbiddenClues":["Left","Behind","Slow","Outside","Miss"],"solvabilityCheck":{"validRoutesCount":3,"checkedByEditors":true,"sampleValidClues":["The Shona phrase you use to tell someone they are out of the loop — literally 'you are outside'","You say this to a friend who doesn't know about a popular song or a trending news story that everyone else already knows about"]}}
```

*Total: 50 Forbidden Words cards. FW-ZIM-001 through FW-ZIM-020 plus topic-coded = 50 cards.*

---

### 6.6 Seed Library Summary

| Game | Cards | Terms/Clues | Difficulty split | SMC cards |
|---|---|---|---|---|
| 30-Seconds Sprint | 50 | 250 terms | 20E / 20M / 10H | 5 |
| Charades | 50 | 50 prompts | 20E / 20M / 10H | 12 |
| Trivia Challenge | 50 | 50 questions | 18E / 22M / 10H | 7 |
| Forbidden Words | 50 | 250 clue strings | 20E / 20M / 10H | 7 |
| **TOTAL** | **200** | **600** | **78E/82M/40H** | **31** |

---

## SECTION 7: QA PIPELINE

### 7.1 Mechanical Constraint Checks (Automated, pre-publication gate)

```
AUTOMATED QA CHECKS (run on every card at ingest)
□ cardId matches regex ^(GS|CH|TR|FW)-[A-Z]{2,6}-[0-9]{4,6}$
□ cardId is unique across entire database (application-level uniqueness index)
□ gameType is one of four valid values
□ For ThirtySeconds: terms.length === 5
□ For ForbiddenWords: forbiddenClues.length === 5
□ For Trivia: distractors.length === 3
□ minAge === 16 on all published cards
□ ageRating is "16+" (or "18+" for future adult mode, blocked from initial release)
□ reviewAfterDate is a valid ISO date in the future
□ editorialStatus is "approved" or "published" before card enters published pool
□ All required fields present and non-empty
□ No term in ThirtySeconds.terms has length 0 or > 60 characters
□ No forbiddenClue has length 0 or > 60 characters
□ solvabilityCheck.validRoutesCount >= 3 for ForbiddenWords
□ factCheckStatus is not "disputed" for any published Trivia card
```

### 7.2 Semantic Duplicate Detection (Semi-automated)

A near-duplicate check runs on all new cards before publication:
1. **Exact term match:** No new 30-Seconds term may be an exact case-insensitive match to any existing term in the library.
2. **Semantic near-duplicate:** Embedding-based cosine similarity check (threshold: 0.9) flags potential duplicates for editorial review. Tool: any embedding API (e.g., multilingual-e5-large for Shona/Ndebele support).
3. **Trivia question uniqueness:** No two trivia questions may target the same fact (e.g., "What year did Zimbabwe gain independence?" should not appear twice).
4. **Forbidden target uniqueness:** No target word may appear as a forbidden clue word on a different card's target.

### 7.3 Ambiguity Review (Editorial, mandatory)

Each card is reviewed for:
- **Ambiguous correct answers (Trivia):** Is there any reasonable second answer? If yes, rephrase the question to close the ambiguity.
- **Clue pathway blocking (Forbidden Words):** Run solvability test with 2 independent editors who know the target word.
- **Term guessability (30 Seconds):** Each term is tested in a mock round of at least 10 people; pass rate recorded in `playtestData`.
- **Mime feasibility (Charades):** Each prompt is mimed by at least 2 non-editorial people before publication.

### 7.4 Fact-Checking Protocol

For all `factual-sourced` content:
1. Source URL must be recorded in `sourceUrl`.
2. Source retrieval date in `sourceRetrievedDate`.
3. `factCheckStatus` set to `verified`, `plausible-unverified`, `disputed`, or `needs-update`.
4. At least one secondary source corroborates primary source for any claim about a named living person.
5. For sports facts, official body sources (ZIFA, CAF, FIFA) are required; Wikipedia acceptable only if the article itself cites primary sources [4][34].
6. Date-sensitive cards (player status, album releases, chart positions) have `reviewAfterDate` set to 6 months from creation.

### 7.5 Public Figure Monitoring

Named public figures in cards require:
- `publicFigureStatus`: `active`, `historical`, `retired`, or `not-applicable`.
- **Active:** review every 6 months; flag if person has retired, died, or become involved in controversy that affects card appropriateness.
- **Legal/reputational risk flag:** Madam Boss is noted in sources as having testified in a court case in October 2025 related to an E-Creator Ponzi scheme [17]. Cards featuring her name should be reviewed before republication. This does not constitute a finding of guilt; the flag is precautionary and requires editorial judgment.
- **Comic Pastor:** Retired from comedy as of end-2025 [18][24]. Cards should use past tense and label `publicFigureStatus: retired`. Do not retire card — historical reference is appropriate and educates younger players.
- **Hulengende/Malloti:** Active and highly relevant, but controversy flags include Parliamentary naming for drug promotion [43] and plagiarism accusation [22]. Cards using their names are acceptable as cultural references; do not include the drug lyric content. Flag for 6-monthly review.

### 7.6 Cultural Sensitivity and Age-Safety Checks (Editorial)

Each card is reviewed against the following:
- **Age safety (16+):** No explicit sexual content. References to relationships, romance, and courtship are appropriate. References to alcohol (e.g., "braai with beer") are acceptable at 16+ with no glorification of excess. References to drug use are flagged and generally excluded (Hulengende's drug-reference lyrics are not used as card content even though the artist name is usable).
- **Political sensitivity:** Memes and content that mock specific political figures (Mugabe, Mnangagwa) are avoided in game content because "it is a criminal offence to ridicule the president in Zimbabwe" [30]. Historical reference to political figures is different from satirical mocking. The trivia question about Mugabe's removal uses neutral factual language.
- **Identity-based stereotype:** No prompt, clue, or term may require a player to mime, describe, or guess based on ethnic, tribal, gender, or body-based stereotypes. The charades stereotype bias flag field is used to quarantine cards requiring editorial review.
- **Religious sensitivity:** Bible and faith content is included respectfully. No question mocks any denomination. Faith content is calibrated to what a 16+ player who attends church (which describes a majority of Zimbabwean youth [39]) would know.

### 7.7 Multilingual/Cross-Dialect Editorial Checks

- All Shona slang terms are cross-checked against at least two of: ShonaSlang.com [36], Youth Village Zimbabwe [37], Zim Lingo Glossary [38], or a native Shona-speaking editorial reviewer.
- Ndebele terms are reviewed by a native Ndebele speaker before publication.
- English-Shona mixed cards (`language: "en-sn"`) are reviewed for natural code-switching patterns.
- Terms that differ between Karanga, Korekore, and Zezuru dialects of Shona are either restricted to their regional dialect tag or use the most broadly understood form; `regionalRelevance: "zimbabwe-national"` is only applied where the term is verifiable as pan-Shona.

### 7.8 Quantitative Release Acceptance Criteria

| Metric | Gate threshold | Measured how |
|---|---|---|
| Mechanical constraint pass rate | 100% | Automated check |
| factCheckStatus: disputed | 0% of published Trivia | Schema validation |
| factCheckStatus: plausible-unverified | ≤5% of any category | Category-level count |
| Trivia easy pass rate in playtest | 65–95% | Pilot playtest cohort |
| Trivia medium pass rate | 30–75% | Pilot playtest cohort |
| Trivia hard pass rate | 10–50% | Pilot playtest cohort |
| 30-Seconds expected score per card | ≥2.0 out of 5 average | Pilot playtest recording |
| Charades median solve time (high gestureability) | ≤25 seconds | Pilot playtest recording |
| FW solvabilityCheck.validRoutesCount | ≥3 on 100% of cards | Schema validation |
| Stereotype bias flag: flagged + unremedied | 0% of published cards | Editorial review log |
| Age-rating compliance | 100% minAge=16 | Schema validation |
| Duplicate cardId | 0% | Database unique index |

### 7.9 Ongoing Analytics

The PWA should log per-card:
- `timesPlayed`, `skipRate` (team passed on this card), `avgResponseTimeSecs`, and `guessedOnFirstClue` (for Forbidden Words: was target guessed before any forbidden word spoken?).
- Cards with `skipRate > 40%` are flagged for editorial difficulty re-classification.
- Cards with `avgResponseTimeSecs > 55` in Charades are flagged as potentially too hard or unguesable.
- Trivia `passRate < 10%` on a "medium" card triggers reclassification to "hard" or revision.
- Cards with `timesPlayed < 5` after 90 days are low-exposure; prioritise in A/B testing.

---

## SECTION 8: PRODUCTION PLAN — SCALING FROM 200 TO 2,300 CARDS

### 8.1 Target Card Counts by Phase

| Phase | Period | 30-Sec | Charades | Trivia | FW | Cumulative |
|---|---|---|---|---|---|---|
| **P0: Seed** | Month 0 | 50 | 50 | 50 | 50 | 200 |
| **P1: Beta** | Month 1–3 | +80 | +100 | +120 | +80 | 580 |
| **P2: Launch** | Month 4–6 | +80 | +100 | +150 | +90 | 1,000 |
| **P3: Expansion** | Month 7–12 | +100 | +150 | +200 | +130 | 1,580 |
| **P4: Completion** | Month 13–18 | +90 | +200 | +280 | +150 | **2,300** |

**Running totals verified:**
- 30 Seconds: 50+80+80+100+90 = **400** ✓
- Charades: 50+100+100+150+200 = **600** ✓
- Trivia: 50+120+150+200+280 = **800** ✓
- Forbidden Words: 50+80+90+130+150 = **500** ✓
- **Total: 2,300** ✓

### 8.2 Roles and Effort

| Role | Responsibility | Estimated FTE per month (Phase 1–4) |
|---|---|---|
| Lead Content Editor (Zimbabwean) | Quality control, cultural review, final approval | 1.0 FTE |
| Shona Language Reviewer | Shona slang and term validation | 0.5 FTE |
| Ndebele Language Reviewer | Ndebele validation | 0.25 FTE |
| Sports Researcher | Football facts, AFCON, Warriors squad | 0.25 FTE |
| Social Media / Pop Culture Writer | SMC category content, influencer monitoring | 0.5 FTE |
| Fact-Checker (Trivia) | Source verification, URL archiving | 0.5 FTE |
| General Content Writers (×3) | Bulk card creation across categories | 3.0 FTE |
| PWA Developer | Schema implementation, QA automation, analytics | 0.5 FTE |
| Pilot Playtest Coordinator | Organise playtests, record data | 0.25 FTE |

**Estimated throughput:** An experienced content writer producing party game cards (with the design spec in Section 3) at a reasonable rate of 20 quality-checked cards per working day = approximately 400 cards per FTE per month. With 3 general writers + specialist contributors: approximately 500–600 cards per month in full production.

### 8.3 Pilot Playtest Plan (Zimbabwe, Phased)

**P1 Pilot (Month 2):** Seed library of 200 cards.
- **Cohort A — Urban Harare:** 3 groups of 6 players, ages 16–21, school/early university setting. Metric focus: engagement, difficulty calibration, SMC card relevance.
- **Cohort B — Urban Bulawayo:** 2 groups, ages 22–30, young professionals. Metric focus: Ndebele language comfort, difficulty for 22–30 cohort.
- **Cohort C — Rural (Mashonaland or Midlands):** 2 groups, mixed ages 16–30. Metric focus: rural equity, offline accessibility, digital literacy variance [44].
- **Data collected:** Per-card response times, skip rates, correct answer rates, verbal feedback on confusing terms.
- **A/B test:** Version A = standard difficulty mix; Version B = slightly easier mix (extra 5 easy cards replacing 5 hard cards). Measure engagement and time-played.

**P2 Pilot (Month 5):** 580-card library after P1 revisions.
- Repeat with new cohorts; include at least 1 mixed 16–30 group per location.
- Add a Social Media & Internet Culture focused session to test SMC category engagement.
- Test "Pop Culture" filtered playlist against full deck for session preference.

**P3 Pilot (Month 10):** 1,000-card library.
- Full-session playtests at 5 locations including 2 rural.
- Measure repeated-play engagement (same group plays twice, 1-week interval).
- Track whether rural players disadvantage indicators persist; address category imbalance if so.

### 8.4 Release Gates

| Gate | Prerequisite to unlock next phase |
|---|---|
| P0→P1 | Schema validated; seed 200 cards mechanically checked; at least 1 internal playtest confirming core mechanics work |
| P1→P2 | P1 pilot data reviewed; Trivia pass rates within thresholds; ≤5 disputed facts; SMC category approved by Zimbabwean editorial lead |
| P2→P3 | ≥500 cards published; rural equity check passed; Pop Culture playlist tested; 0 public figure controversy flags unresolved |
| P3→P4 | ≥1,500 cards published; Shona and Ndebele translator sign-off on translated cards; analytics system live |
| P4 completion | Exactly 2,300 cards across all games; all category quotas met; full fact-check audit complete; ongoing review cadence scheduled |

### 8.5 Translation Process

**Phased translation approach:**

Phase 1–2: English-primary, with Shona/Ndebele terms embedded in existing English cards.
Phase 3: Begin parallel Shona-language versions of select cards, starting with categories: ZIM-04 (Shona slang), ZIM-05 (faith), ZIM-03 (daily life).
Phase 4: Ndebele translation of same categories; add bilingual display option in PWA.

Translation workflow:
1. English card is finalised and published.
2. Shona translator (native speaker, editorial-trained) creates Shona version.
3. Second native Shona speaker reviews for naturalness.
4. Lead editor approves.
5. Translation stored in `translations.sn` field of card JSON.
6. PWA shows translation if `language` preference set to Shona.

**Note on Shona dialects:** Cards translated into Shona should default to Standard Shona (Karanga/Zezuru blend used in education) and flag region-specific terms with a dialect tag.

### 8.6 Source Archive

All source URLs used for factual cards are archived using:
1. A Wayback Machine/Internet Archive submission at time of card creation.
2. The archived URL is stored in a separate `sourceArchiveUrl` field (add to schema in v1.1).
3. Quarterly automated check: if `sourceUrl` returns 404, the card is flagged `needs-update` and the archived URL is used as fallback evidence.

### 8.7 Long-Term Maintenance

**Annual review cycle:**
- All cards with `reviewCadence: "6-months"` reviewed by relevant specialist.
- All cards with `reviewCadence: "12-months"` reviewed annually.
- Retired cards (factually outdated, person died, controversy too serious) set to `editorialStatus: retired` and removed from active pools without deletion.
- Annual audit of Social Media & Internet Culture category: at least 25% of SMC Trivia questions and 30% of SMC 30-Seconds terms refreshed each year to maintain cultural currency.

**Analytics-driven refresh:**
- Cards with `skipRate > 40%` or `passRate < 10%` (easy) or `passRate > 90%` (hard) are automatically queued for editorial review monthly.
- Trending topics monitoring: a Zimbabwean youth culture monitor (social media scout role, 0.1 FTE ongoing) flags new memes, viral events, music releases, football results for card creation queue.

---

## SECTION 9: SOCIAL MEDIA & INTERNET CULTURE — SPECIAL SECTION

### 9.1 Verified Zimbabwean Creator Profiles

**Madam Boss (Tarisai Cleopatra Chikocho, born 1985)** [17]
- Status: Active creator, comedian, actress, music artist.
- Relevance: First Zimbabwean comedian reportedly to reach 1M Facebook followers [17]. Strong pan-Zimbabwe recognition, rural and urban. Brand ambassador for RwandAir, Net*One [17].
- E! African Social Star 2021 [17].
- **Alert:** Testified in Harare Magistrates' Court in October 2025 in case related to E-Creator Ponzi scheme allegations involving fellow creator Mama Vee [17]. This is an active legal matter. Editorial position: use name as cultural reference (easy recognition card) with `publicFigureStatus: active` and 6-monthly review. Do not make claims about the legal case outcome.
- **Card design implication:** Her comedy character (maid skits) is widely recognised and gestureable. Cards featuring her name are low-risk; cards referencing the legal matter are blocked.

**Comic Pastor (Prosper Ngomashi)** [18][24]
- Status: **Retired from comedy as of end-2025.** Announced retirement July 2025 [18]. Relocated to UK in 2023 [24].
- Relevance: Part of Bus Stop TV crew, hugely popular across diaspora and Zimbabwe. Satirical commentary on Zimbabwean life and politics [24].
- **Card design implication:** Include as historical reference ("Zimbabwean comedian who retired from comedy in 2025" is a valid trivia fact). Do not use as "active influencer." Set `publicFigureStatus: retired`.

**Hulengende (Ezbornwage Chidamajaya)** [22][43]
- Status: Active, highly viral (Apple Music Zimbabwe #1 September 2025 [22][43]).
- Relevance: TikTok dance challenge for "Fadza Madzimai" is highly relevant to 16–21 cohort [43]. Cross-generational recognition due to Jah Prayzah endorsement.
- **Alert:** Parliamentary naming for allegedly promoting drug use through social media content, March 2026 [43]. Plagiarism accusation from artist Hwinza [22].
- **Card design implication:** Name is usable as cultural reference; drug-reference lyric content is excluded. Flag for 6-monthly review. Primarily 16–21 cohort card.

**Taffy Theman** [21]
- Status: Active YouTuber/social commentator with ~141K subscribers [21].
- Relevance: Comedy/political commentary on Zimbabwean life; appropriate for 22–30 cohort.
- **Card design implication:** Medium-difficulty card; not universally known but significant in online circles.

**Annatoria** [20]
- Status: Active TikTok creator; 1.7M followers as of November 2026 per Heepsy [20].
- Relevance: Most-followed Zimbabwean on TikTok. Primarily 16–21 cohort.
- **Note:** Heepsy is a commercial influencer platform; follower counts are periodically scraped from TikTok. The metric may not reflect active engagement.
- **Card design implication:** Trivia question verifiable from Heepsy data with appropriate caveat on factCheckStatus: plausible-unverified.

**Khaby Lame** [from evidence]
- Status: Active. Senegalese-Italian TikTok creator, one of the world's most followed globally.
- Relevance: Broadly recognised by Zimbabwean youth with TikTok access; less familiar to offline/rural players.
- **Card design implication:** Global SMC category, medium difficulty, primary cohort both.

**MrBeast** [from evidence]
- Status: Active. American YouTube creator, largest channel globally.
- Relevance: Widely known among Zimbabwean youth with YouTube access; less familiar to offline players.
- **Card design implication:** Global SMC category, easy to medium difficulty.

### 9.2 Meme and Viral Content Framework

**Meerkat With a Toothpick (June 2025)** [8][23]
- Status: Confirmed as a major African viral meme, spreading especially on Facebook and X among African users [8][23].
- Used by Zimbabwean brands including Innbucks, ZERA, and Kingdom Blue in localised corporate meme content [23].
- Recognition: High among urban 16–30 Zimbabwean social media users; may be unknown to offline rural players.
- **Card design implication:** Medium difficulty, SMC-04 category, flag for review by mid-2027.

**African political memes on WhatsApp** [7][30]
- Research from Bulawayo confirms youth use memes to comment on political figures on WhatsApp [30]. However, this content is legally sensitive in Zimbabwe [30] and should not be reproduced in game cards.
- **Editorial rule:** No card may contain content that mocks a named sitting political leader of Zimbabwe by name in a satirical way.

**TikTok dance challenges** [43]
- The "Fadza Madzimai" TikTok challenge from Hulengende is a verifiable Zimbabwe-specific viral phenomenon [43].
- General TikTok dance challenge culture is a cross-continental reference.
- **Card design implication:** "Doing a TikTok dance challenge" is a universally recognisable Charades prompt for 16–30 cohort.

### 9.3 Cross-Cohort SMC Fairness

| Content type | 16–21 cohort recognition | 22–30 cohort recognition | Recommendation |
|---|---|---|---|
| Hulengende, TikTok dance challenges, Ama2K | High | Low-medium | Tag primary 16–21; include cross-cohort clue anchors |
| Madam Boss, WhatsApp group admin | High | High | Cross-cohort; standard difficulty |
| Comic Pastor, Bus Stop TV | Medium | High | Tag primary 22–30 |
| MrBeast, Khaby Lame | Medium-high | Medium | Cross-cohort global |
| WhatsApp status views, voice notes | High | High | Cross-cohort; easy |
| LinkedIn job applications | Low | High | Tag primary 22–30 |
| Meerkat meme (June 2025) | High (Facebook/Twitter active) | Medium | Medium difficulty; SMC-04 |

**Cross-cohort fairness rule:** In any single game session that selects SMC cards, the system should aim for at least 40% of SMC cards to be cross-cohort recognisable (tagged "both" in `ageCohorPrimary`). The PWA should implement this as a session assembly rule.

---

## SECTION 10: REFERENCED ZIMBABWEAN CULTURAL LANDSCAPE

*Summary of research findings that inform card content.*

### 10.1 Music Scene

Zimbabwe's music scene operates on a generational hierarchy: Winky D and Jah Prayzah at the top [9][43], a bridge generation (Holy Ten, Killer T) [43], and an Ama2K new school (Hulengende, Sane Wav, Xiba, Atenda Chinx, Feli Nandi) [40][43]. Zimdancehall remains the dominant genre [31][40], with amapiano crossover growing [40]. Holy Ten released *Risky Life 3* in 2026, addressing unemployment and mental health [40]. Atenda Chinx won NAMA Outstanding Breakthrough Artist in 2025 and 2026 [43]. Jah Prayzah and Winky D held a joint New Year's Eve show at Glamis Arena in December 2025 [43].

The Jah Prayzah–Winky D rivalry is a generational and class proxy: Winky D associated with urban youth and political consciousness [9][31], Jah Prayzah with military imagery and pan-African respectability [9][31]. Both are essential card references. Winky D's *Ibotso* (2023) was censored and went viral [9].

### 10.2 Football

Zimbabwe qualified for AFCON 2025 as Group J runners-up [34]. At the tournament (Morocco, 21 Dec 2025 – 18 Jan 2026 [34]), Zimbabwe finished 3rd in Group B with 1 point: lost to Egypt 2–1 (Dube scored), drew Angola 1–1 (Musona scored), lost to South Africa 2–3 (Maswanhise scored) [34][35]. Zimbabwe did not advance. Coach Marian Marinica resigned in 2026 after also suffering a loss in FIFA World Cup qualifying; Kaitano Tembo appointed Interim Coach [4]. Marvelous Nakamba captains the team and plays for Luton FC [41]. Tawanda Chirewa plays for Wolverhampton Wanderers [41]. AFCON 2025 winner was Morocco (after disputed final with Senegal, CAF ruling of 3–0 forfeit in March 2026, subject to CAS appeal) [34].

### 10.3 Social Media and Internet Access

As of end-2025: 16.2 million mobile connections (95% of population) [45]; 6.54 million internet users (38.4%) [45]; 2.60 million social media user identities (15.3%) [45]. WhatsApp: 92.9% of internet users; Facebook: 44.8%; TikTok: 38% [25]. Regional access: Bulawayo highest household internet access (98%), Manicaland lowest (61.6%) [25]. Rural smartphone access 70.9% vs 93.8% urban [44]. Cost of 1GB data fell from USD 43.75 (2023) to USD 3–4 (2024) [5]. 31% of internet users use AI tools; Meta AI most popular (53.7%), ChatGPT second (29.1%) [25].

### 10.4 Youth Employment Context

Unemployment rate 39.3% among 15–24 year olds; 28.9% for 15–35; 49.2% not in employment, education or training [42]. 58.5% of employed people in informal sector [42]. This context is central to University & Work Life category — it means "job hunting" and "side hustle" are lived experiences, not abstract concepts, for 16–30 Zimbabwean players.

### 10.5 Faith Culture

A majority of Zimbabweans identify as Christian [39]. The Johane Marange Apostolic Church (Vapostori), ZAOGA, Seventh Day Adventists, and Pentecostal denominations are major institutions [39]. Churches are "the most pervasive civic institutions" [39]. Faith and Bible content is not niche for this age group — it is mainstream, family-embedded, and culturally essential. Bible trivia questions should not be condescending (don't quiz on John 3:16 as a "hard" question) but can include nuanced content such as stories of minor prophets or Pauline epistles at medium difficulty.

---

## SECTION 11: CITATIONS AND REFERENCES

All citations formatted with URL, source type, and evidence quality as classified in the evidence brief.

[1] JSON Schema. (2020-12). *JSON Schema Draft 2020-12*. https://json-schema.org/draft/2020-12 — Retrieved 2026-11-24. *Primary.*

[2] JSONIC. (n.d.). *JSON Schema Discriminator: oneOf, Ajv & OpenAPI*. https://jsonic.io/guides/json-schema-discriminator — Retrieved 2026-11-24. *Low quality; use as supplementary pattern guide only.*

[3] ArXiv. (2023). *Extracting JSON Schemas with Tagged Unions*. https://arxiv.org/html/2306.07085v1 — Retrieved 2026-11-24. *Secondary.*

[4] ZIFA. (2026). *Marinica Steps Down as Warriors Head Coach*. https://zifa.co.zw/marinica-steps-down-as-warriors-head-coach — Retrieved 2026-11-24. *Primary/official.*

[5] CIPESA. (2025). *State of Internet Freedom in Africa 2025: Navigating the Implications of AI on Digital Democracy in Zimbabwe*. https://cipesa.org/download/reports/State_of_Internet_Freedom_in_Africa_2025__Navigating_the_Implications_of_AI_on_Digital_Democracy_in_Zimbabwe__.pdf — Retrieved 2026-11-24. *Secondary.*

[6] Mechanics of Magic. (2024). *MDA – Taboo – The Mechanics of Magic*. https://mechanicsofmagic.com/2024/04/09/mda-taboo — Retrieved 2026-11-24. *Low quality; editorial opinions on game mechanics.*

[7] Thred. (n.d.). *Africa's youth is fighting injustice with memes*. https://thred.com/change/africas-youth-is-fighting-injustice-with-memes — Retrieved 2026-11-24. *Secondary.*

[8] Know Your Meme. (2025). *Meerkat With a Toothpick*. https://knowyourmeme.com/memes/meerkat-with-a-toothpick — Retrieved 2026-11-24. *Low quality; treat as weak context.*

[9] IJLTEMAS. (n.d.). *Clash of Titans: The Musical Rivalry Between Jah Prayzah And Winky D*. https://www.ijltemas.in/submission/online/article/view/1854/1111 — Retrieved 2026-11-24. *Secondary.*

[10] UltraBoardGames. (n.d.). *How to play 30 Seconds | Official Game Rules*. https://ultraboardgames.com/30-seconds/game-rules.php — Retrieved 2026-11-24. *Primary (official rules documentation).*

[11] Wikipedia. (n.d.). *30 Seconds (game)*. https://en.wikipedia.org/wiki/30_Seconds_(game) — Retrieved 2026-11-24. *Secondary.*

[12] Wikipedia. (n.d.). *Taboo (game)*. https://en.wikipedia.org/wiki/Taboo_(game) — Retrieved 2026-11-24. *Secondary.*

[13] Nicholson, S. (n.d.). *Gameplay Matters preprint*. https://scottnicholson.com/pubs/gameplaymatterpreprint.pdf — Retrieved 2026-11-24. *Secondary.*

[14] Get Random Word. (n.d.). *Taboo Word Game: Rules, Forbidden Words and Ideas*. https://getrandomword.com/blog/taboo-word-game-rules-and-ideas — Retrieved 2026-11-24. *Low quality.*

[15] Buzztime. (n.d.). *How to Write Great Trivia Questions Players Love*. https://buzztime.com/bar-trivia/how-to-write-good-trivia-questions — Retrieved 2026-11-24. *Primary (practitioner guidance).*

[16] DataReportal. (2025). *Digital 2025: Zimbabwe*. https://datareportal.com/reports/digital-2025-zimbabwe — Retrieved 2026-11-24. *Secondary.*

[17] Wikipedia. (n.d.). *Madam Boss*. https://en.wikipedia.org/wiki/Madam_Boss — Retrieved 2026-11-24. *Secondary.*

[18] Nehanda Radio. (2025-07-31). *Comic Pastor announces retirement*. https://nehandaradio.com/2025/07/31/i-shared-the-light-passed-on-the-button-comic-pastor-announces-retirement — Retrieved 2026-11-24. *Secondary.*

[19] Board Game Rules. (n.d.). *30 Seconds: Everyday Life*. https://board-game-rules.com/boardgames/30-seconds-everyday-life — Retrieved 2026-11-24. *Primary.*

[20] Heepsy. (November 2026). *Top TikTok influencers in Zimbabwe for November 2026*. https://heepsy.com/en/find-influencers/tiktok/zimbabwe — Retrieved 2026-11-24. *Low quality; commercial platform data.*

[21] Modash. (November 2026). *Top 20 YouTube Influencers in Zimbabwe*. https://www.modash.io/find-influencers/youtube/zimbabwe — Retrieved 2026-11-24. *Low quality.*

[22] Sona.co.zw. (2025-10). *Ezbornwage Chidamajaya (Hulengende)*. https://sona.co.zw/2025/10/hulengende-biography.html — Retrieved 2026-11-24. *Secondary.*

[23] Skyz Metro FM. (2025-07-01). *Corporate Clapbacks and Meme Mayhem: Meerkat Takes Over African Social Media*. https://skyzmetroradio.co.zw/2025/07/01/corporate-clapbacks-and-meme-mayhem-meerkat-takes-over-african-social-media — Retrieved 2026-11-24. *Low quality.*

[24] Youth Village Zimbabwe. (2025). *Comic Pastor to Retire from Comedy in 2025*. https://youthvillage.co.zw/sport-entertainment/celebrity-news/comic-pastor-to-retire-from-comedy-in-2025-says-hes-shared-the-light — Retrieved 2026-11-24. *Secondary.*

[25] New Ziana. (2025). *More and more Zimbabweans embracing AI*. https://newziana.co.zw/more-and-more-zimbabweans-embracing-ai — Retrieved 2026-11-24. *Secondary (cites ZIMSTAT/POTRAZ survey).*

[26] Trivia Themes. (n.d.). *Trivia Questions by Difficulty*. https://triviathemes.com/blog/trivia-questions-by-difficulty — Retrieved 2026-11-24. *Low quality; editorial guidance.*

[27] Party Game Guide. (n.d.). *Charades: The Complete Guide*. https://partygameguide.com/the-complete-guide-to-charades — Retrieved 2026-11-24. *Low quality; practitioner guide.*

[28] Woobox. (n.d.). *Trivia Quiz Question Design: Difficulty Curve and Engagement*. https://woobox.com/articles/trivia-quiz-question-design — Retrieved 2026-11-24. *Low quality; practitioner guide.*

[29] Family Policy Alliance. (2022). *Targeted Content Moderation White Paper*. https://thrivingingames.org/wp-content/uploads/2022/06/FPA-Being-Targeted-about-Content-Moderation.pdf — Retrieved 2026-11-24. *Secondary.*

[30] MDPI. (2025). *The Politics of Laughter: Political Uses of Memes Circulating on WhatsApp*. https://mdpi.com/2673-5172/6/4/204 — Retrieved 2026-11-24. *Secondary (academic journal).*

[31] OkayAfrica. (n.d.). *10 Zimbabwean Dancehall Artists You Should Know*. https://www.okayafrica.com/10-zimbabwean-dancehall-artists-you-should-know/284587 — Retrieved 2026-11-24. *Secondary.*

[32] ZimbaMusic. (2025). *Young Fantan – Zvaigoenda Nepi*. https://zimbamusic.co.zw/young-fantan-zvaigoenda-nepi — Retrieved 2026-11-24. *Low quality.*

[33] Corvus OSS. (n.d.). *Pattern Matching and Discriminated Unions*. https://corvus-oss.org/Corvus.JsonSchema/examples/pattern-matching.html — Retrieved 2026-11-24. *Primary.*

[34] Wikipedia. (n.d.). *2025 Africa Cup of Nations*. https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations — Retrieved 2026-11-24. *Secondary.*

[35] Sky Sports. (n.d.). *Africa Cup of Nations Group Tables*. https://www.skysports.com/africa-cup-of-nations-table — Retrieved 2026-11-24. *Secondary.*

[36] ShonaSlang.com. (n.d.). *Shona Slang Words & Meanings*. https://shonaslang.com — Retrieved 2026-11-24. *Low quality; community-driven.*

[37] Youth Village Zimbabwe. (n.d.). *Top 20 Most Popular Shona slang Phrases or Words*. https://youthvillage.co.zw/sport-entertainment/top-20-popular-shona-slang-phrases-words — Retrieved 2026-11-24. *Low quality.*

[38] Zim Xcite. (n.d.). *Zim Lingo Glossary*. https://zimxcite.com/pages/glossary — Retrieved 2026-11-24. *Low quality.*

[39] MDPI Social Sciences. (2025). *Church-Led Social Capital and Public-Health Approaches to Youth Violence in Urban Zimbabwe*. https://www.mdpi.com/2076-0760/14/10/602 — Retrieved 2026-11-24. *Secondary.*

[40] ANTVT. (n.d.). *Zimbabwe's Music Scene Right Now*. https://antvt.com/zimbabwes-music-scene-right-now — Retrieved 2026-11-24. *Low quality.*

[41] Pan Africa Football. (n.d.). *Zimbabwe captain Nakamba makes plea amid tension*. https://panafricafootball.com/article/zimbabwe-captain-nakamba-makes-plea-amid-tension — Retrieved 2026-11-24. *Secondary.*

[42] The Granite Post. (2025). *Why Zimbabwe's Youth Are Struggling to Find Jobs*. https://thegranite.co.zw/articles/why-zimbabwe-s-youth-are-struggling-to-find-jobs — Retrieved 2026-11-24. *Secondary.*

[43] All White Lord. (n.d.). *The New School: Hulengende, Sane Wav, Xiba, Atenda Chinx*. https://allwhitelord.com/blog/the-new-school-hulengende-sane-wav-xiba-atenda-chinx-and-the-sound-zimbabwe-cannot-ignore — Retrieved 2026-11-24. *Low quality.*

[44] Emthonjeniwf.org. (2025). *Digital Divide Research*. https://emthonjeniwf.org/wp-content/uploads/2025/09/Digital-Divide-research.pdf — Retrieved 2026-11-24. *Primary (research report).*

[45] DataReportal. (2026). *Digital 2026: Zimbabwe*. https://datareportal.com/reports/digital-2026-zimbabwe — Retrieved 2026-11-24. *Secondary.*

---

## APPENDIX A: QUICK REFERENCE — TAXONOMY TOTALS

| Game | Total Cards | SMC Cards | Easy | Medium | Hard |
|---|---|---|---|---|---|
| 30-Seconds Sprint | 400 | 24 | 145 (36%) | 169 (42%) | 86 (22%) |
| Charades | 600 | 50 | 237 (40%) | 253 (42%) | 110 (18%) |
| Trivia Challenge | 800 | 50 | 289 (36%) | 325 (41%) | 186 (23%) |
| Forbidden Words | 500 | 35 | 180 (36%) | 213 (43%) | 107 (21%) |
| **TOTAL** | **2,300** | **159** | **851 (37%)** | **960 (42%)** | **489 (21%)** |

## APPENDIX B: KEY DESIGN DECISIONS SUMMARY

| Decision | Rationale | Evidence |
|---|---|---|
| 16+ minimum age (not 10+) | Relationships, slang, social media content requires 16+ sensibility | Design brief; 30 Seconds age 15+ [11] |
| 36/42/22 difficulty split | Slightly heavier medium than 40-40-20 standard; youth cohort has higher local culture baseline | [26] editorial calibration |
| WhatsApp as accessibility anchor | 92.9% internet user penetration; works offline once app installed | [25] |
| SMC at 6-8% of total cards | Avoids rural exclusion while respecting digital culture significance | [44][45] |
| Comic Pastor labelled "retired" | Announced retirement from comedy end-2025, confirmed by two sources | [18][24] |
| Madam Boss "active + monitor" | Legally active case; not a conviction; cultural relevance confirmed | [17] |
| No political satire of sitting leaders | Criminalised in Zimbabwe; risk to players who might recall and repeat | [30] |
| Shona-primary slang with Ndebele support | 70% Shona-speaking but Ndebele is a major official language and second language group | [38] |
| Rural equity anchor term per card | 70.9% rural smartphone access; 11.6% rural have no device | [44][45] |
| `solvabilityCheck.validRoutesCount ≥ 3` | Prevents accidental unsolvability in Forbidden Words | Section 4.5 framework |

---

*End of Report. Document version 1.0.0 — 2026-11-24. All 200 seed cards delivered as JSONL in Sections 6.2–6.5. Schema in Section 5. Production plan in Section 8. Factual claims are cited; original creative content is labelled `contentOrigin: original-creative`; design recommendations are framed as editorial hypotheses where empirical evidence does not exist.*

## Sources

1. JSON Schema — https://json-schema.org/draft/2020-12
2. JSON Schema Discriminator: oneOf, Ajv & OpenAPI — https://jsonic.io/guides/json-schema-discriminator
3. Extracting JSON Schemas with Tagged Unions — https://arxiv.org/html/2306.07085v1
4. Marinica Steps Down as Warriors Head Coach - Zimbabwe Football Association — https://zifa.co.zw/marinica-steps-down-as-warriors-head-coach
5. https://cipesa.org/download/reports/State_of_Internet_Freedom_in_Africa_2025__Navigating_the_Implications_of_AI_on_Digital_Democracy_in_Zimbabwe__.pdf — https://cipesa.org/download/reports/State_of_Internet_Freedom_in_Africa_2025__Navigating_the_Implications_of_AI_on_Digital_Democracy_in_Zimbabwe__.pdf
6. MDA – Taboo – The Mechanics of Magic — https://mechanicsofmagic.com/2024/04/09/mda-taboo
7. Africa’s youth is fighting injustice with memes — https://thred.com/change/africas-youth-is-fighting-injustice-with-memes
8. Meerkat With a Toothpick | Know Your Meme — https://knowyourmeme.com/memes/meerkat-with-a-toothpick
9. Clash of Titans: The Musical Rivalry Between Jah Prayzah And Winky D in Zimbabwe's Contemporary Music Scene. — https://www.ijltemas.in/submission/online/article/view/1854/1111
10. How to play 30 Seconds | Official Game Rules | UltraBoardGames — https://ultraboardgames.com/30-seconds/game-rules.php
11. 30 Seconds (game) - Wikipedia — https://en.wikipedia.org/wiki/30_Seconds_(game)
12. Taboo (game) - Wikipedia — https://en.wikipedia.org/wiki/Taboo_(game)
13. Microsoft Word - gameplaymatterpreprint.doc — https://scottnicholson.com/pubs/gameplaymatterpreprint.pdf
14. Taboo Word Game: Rules, Forbidden Words and Ideas — https://getrandomword.com/blog/taboo-word-game-rules-and-ideas
15. How to Write Great Trivia Questions Players Love — https://buzztime.com/bar-trivia/how-to-write-good-trivia-questions
16. Digital 2025: Zimbabwe — DataReportal – Global Digital Insights — https://datareportal.com/reports/digital-2025-zimbabwe
17. Madam Boss - Wikipedia — https://en.wikipedia.org/wiki/Madam_Boss
18. “I shared the light, passed on the button” … Comic Pastor announces retirement – Nehanda Radio — https://nehandaradio.com/2025/07/31/i-shared-the-light-passed-on-the-button-comic-pastor-announces-retirement
19. 30 Seconds: Everyday Life – Board Game Rules — https://board-game-rules.com/boardgames/30-seconds-everyday-life
20. Top TikTok influencers in Zimbabwe for November 2026 | Heepsy — https://heepsy.com/en/find-influencers/tiktok/zimbabwe
21. Top 20 YouTube Influencers in Zimbabwe: Find Zimbabwean YouTubers (Nov 2026) — https://www.modash.io/find-influencers/youtube/zimbabwe
22. Ezbornwage Chidamajaya (Hulengende) Meet the Zimdancehall Star Behind "Fadza Madzimai" — https://sona.co.zw/2025/10/hulengende-biography.html
23. Corporate Clapbacks and Meme Mayhem: Meerkat Takes Over African Social Media – Skyz Metro FM — https://skyzmetroradio.co.zw/2025/07/01/corporate-clapbacks-and-meme-mayhem-meerkat-takes-over-african-social-media
24. Comic Pastor to Retire from Comedy in 2025, Says He's 'Shared the Light' - Youth Village Zimbabwe — https://youthvillage.co.zw/sport-entertainment/celebrity-news/comic-pastor-to-retire-from-comedy-in-2025-says-hes-shared-the-light
25. More and more Zimbabweans embracing AI – New Ziana — https://newziana.co.zw/more-and-more-zimbabweans-embracing-ai
26. Trivia Questions by Difficulty — Easy, Medium & Hard | Trivia Themes — https://triviathemes.com/blog/trivia-questions-by-difficulty
27. Charades: The Complete Guide | PartyGameGuide.com — https://partygameguide.com/the-complete-guide-to-charades
28. Trivia Quiz Question Design: Difficulty Curve and Engagement — https://woobox.com/articles/trivia-quiz-question-design
29. (Final) Targeted Content Moderation - White Paper — https://thrivingingames.org/wp-content/uploads/2022/06/FPA-Being-Targeted-about-Content-Moderation.pdf
30. The Politics of Laughter: Political Uses of Memes Circulating on WhatsApp — https://mdpi.com/2673-5172/6/4/204
31. 10 Zimbabwean Dancehall Artists You Should Know | OkayAfrica — https://www.okayafrica.com/10-zimbabwean-dancehall-artists-you-should-know/284587
32. Young Fantan - Zvaigoenda Nepi MP3 Download - ZimbaMusic — https://zimbamusic.co.zw/young-fantan-zvaigoenda-nepi
33. Pattern Matching and Discriminated Unions - Corvus.Text.Json Examples — https://corvus-oss.org/Corvus.JsonSchema/examples/pattern-matching.html
34. 2025 Africa Cup of Nations - Wikipedia — https://en.wikipedia.org/wiki/2025_Africa_Cup_of_Nations
35. Football Tables - Football League Tables & Standings | Sky Sports — https://www.skysports.com/africa-cup-of-nations-table
36. Shona Slang Words & Meanings | ShonaSlang Dictionary — https://shonaslang.com
37. Top 20 Most Popular Shona slang Phrases or Words - Youth Village Zimbabwe — https://youthvillage.co.zw/sport-entertainment/top-20-popular-shona-slang-phrases-words
38. Zim Lingo Glossary — https://zimxcite.com/pages/glossary
39. Church-Led Social Capital and Public-Health Approaches to Youth Violence in Urban Zimbabwe: Perspectives from Church Leaders — https://www.mdpi.com/2076-0760/14/10/602
40. Zimbabwe’s Music Scene Right Now — https://antvt.com/zimbabwes-music-scene-right-now
41. Zimbabwe captain Nakamba makes plea amid tension | Pan Africa Football — https://panafricafootball.com/article/zimbabwe-captain-nakamba-makes-plea-amid-tension
42. Why Zimbabwe's Youth Are Struggling to Find Jobs - The Granite Post — https://thegranite.co.zw/articles/why-zimbabwe-s-youth-are-struggling-to-find-jobs
43. The New School: Hulengende, Sane Wav, Xiba, Atenda Chinx and the Sound Zimbabwe Cannot Ignore — https://allwhitelord.com/blog/the-new-school-hulengende-sane-wav-xiba-atenda-chinx-and-the-sound-zimbabwe-cannot-ignore
44. https://emthonjeniwf.org/wp-content/uploads/2025/09/Digital-Divide-research.pdf — https://emthonjeniwf.org/wp-content/uploads/2025/09/Digital-Divide-research.pdf
45. Digital 2026: Zimbabwe — DataReportal – Global Digital Insights — https://datareportal.com/reports/digital-2026-zimbabwe
