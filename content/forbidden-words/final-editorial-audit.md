# Final editorial audit — single-agent candidate

Baseline first refinement e9c5a69de80f01e15ae7ed461453ac87dfa1624a; final candidate 47ad46ae3869e00a834442e98b327ffc0a376465. All five 100-card batches individually reviewed: all 500 targets, 2,500 restrictions screened in context, 1,500 examples read and individually graded. The five batch files preserve the initial judgments before the final fixes; canonical final judgments are in final-description-pathway-audit.jsonl. 23 additional replacements, 163 same-identity changes (including difficulty and category), 98 same-target clue membership changes. 314 unchanged from the first-refinement snapshot. 94 cumulative replacements against original main. No independent review or human test. 

Scoring anchors, defined before individual review: 1 critical failure; 2 weak; 3 adequate with material reservations; 4 strong with minor caveats; 5 excellent under model-based review. Criterion-specific interpretation: clue effectiveness — wasted/unworkable (1), at least three useful restrictions (3), five natural distinct restrictions (5); familiarity — obscure (1), recognised by some cohorts (3), broadly familiar (5); pathways — no plausible route (1), two useful routes (3), three natural and distinctive routes (5); entertainment — frustrating (1), playable (3), spontaneous creativity (5); difficulty — obscurity-driven (1), plausible but uncertain (3), restriction-driven and appropriate (5); cultural relevance — alienating (1), broadly accessible (3), highly relevant (5); linguistic access — impractical (1), manageable with reservations (3), practical across intended languages (5). Scores 2/4 interpolate. Linguistic scores capped at 4 in absence of native validation; specific native-language concerns score 2–3. Weights 25/20/20/15/10/5/5. Each pathway separately graded 1 weak/questionable, 2 adequate/context-dependent, 3 strong conversational. Ratings are subjective single-agent estimates, not empirical audience familiarity or independent approval. Flag low criterion scores, weak paths, identified ambiguities or leakage irrespective of aggregate.

## Editorial outcomes
Mean 84.88% (8.49/10), not comparable to prior independent estimate and not certification. Critical flags (weak pathway or criterion <=2 or lexical finding): 86; broader human-review flags: 193. Pathway grades: {"1":34,"2":299,"3":1167}. Score bands: {"90–100":178,"80–89":171,"Below 70":89,"70–79":62}. Criterion means: {"forbiddenClueEffectiveness":4.342,"targetFamiliarity":4.344,"alternativePathwayQuality":4.042,"entertainmentPotential":4.104,"difficultyAppropriateness":4.374,"culturalRelevance":4.81,"linguisticAccessibility":3.754}. No target score forced. Critical flags veto merge approval.

## Distributions
| regionalRelevance | Original main | First refinement | Current |
|---|---:|---:|---:|
| zimbabwe-national | 274 | 240 | 225 |
| african | 43 | 64 | 80 |
| global | 183 | 196 | 195 |

| difficulty | Original main | First refinement | Current |
|---|---:|---:|---:|
| easy | 180 | 189 | 176 |
| medium | 219 | 247 | 235 |
| hard | 101 | 64 | 89 |

| productionCategory | Original main | First refinement | Current |
|---|---:|---:|---:|
| Zimbabwean Daily Life & Culture | 60 | 53 | 50 |
| Zimbabwean Food | 30 | 27 | 26 |
| Zimbabwean People & Figures | 40 | 28 | 25 |
| Zimbabwean Slang Terms | 30 | 26 | 24 |
| Zimbabwe Sports | 30 | 21 | 17 |
| African Football Terms | 20 | 16 | 14 |
| Zimbabwean Music Terms | 40 | 38 | 38 |
| African Music Terms | 20 | 31 | 28 |
| Global Entertainment | 30 | 30 | 30 |
| Bible & Faith Terms | 40 | 40 | 40 |
| Social Media & Internet Culture | 35 | 39 | 36 |
| Technology & Gadgets | 30 | 29 | 28 |
| University & Work Life | 30 | 24 | 24 |
| Relationships & Social Situations | 30 | 53 | 53 |
| World Knowledge | 35 | 45 | 27 |
| African Culture & Everyday Life | 0 | 0 | 18 |
| African Pop Culture | 0 | 0 | 6 |
| Other Sports | 0 | 0 | 4 |
| African Geography | 0 | 0 | 10 |
| African History & Politics | 0 | 0 | 2 |

Research taxonomy AFR-01/02/03 and SPT-04 reused; AFR-03 subcategories distinguish regional food, clothing, brands and transport. Existing adapter consumes productionCategory as a string; runtime build unexecuted. Region labels reflect audience relevance rather than nationality. New regional candidates need recognition testing. 

## Semantic collisions / near overlaps
- Sharp / Bho: similar slang agreement; different expressions but referee language review.
- Mudhara / Chibaba: overlapping respectful forms of address.
- Ghetto / High-density suburb: overlapping everyday meaning; distinguish colloquial vs settlement type.
- Madhiri / Side hustle: close commercial meaning; Hustle removed.
- Kente / Ankara fabric: distinguish woven patterned textile from wax-print cotton.
- WhatsApp / Group chat: app identity vs multi-participant thread.
- EcoCash / Mobile money: specific brand vs generic payment mechanism.
- Shoprite / Choppies: generic store routes can fit both brands.
- Mark Angel Comedy / Emmanuella: creator ensemble vs individual; routes too generic.
- Prayer / All-night prayer: general practice vs overnight event.
- Gospel choir / Choir practice: ensemble vs activity.
- Wedding / Wedding reception: ceremony vs subsequent gathering.
- Birthday party / Surprise party: recurring celebration vs concealed event.
- Report card / Transcript: school report vs official academic record.
- Artificial intelligence / ChatGPT: field vs product.
- Cape Town / Table Mountain: city vs peak.
- Robben Island / Nelson Mandela: place vs person.
- Read receipts / WhatsApp: feature vs app.
- Kombi / Matatu: related transport in different cultural context.
- Chitofu / Firewood: appliance vs fuel.
- Surprise / Surprise party: abstract reaction vs event.

## Critical flags
- FW-LIFE-0009 Chitubu: Shona recognition and alternate terms; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0023 Mukando: native translation and recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0024 Rusero: limited recognition among urban players; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0025 Tsoro: second route generic; weak pathways 2; weak criteria linguisticAccessibility.
- FW-LIFE-0028 Boka: vague routes depend on Harare; weak pathways 2, 3; weak criteria alternativePathwayQuality.
- FW-LIFE-0042 Hwindi: language and local role; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0044 ZUPCO: needs more distinctive route; weak pathways 3; weak criteria none.
- FW-FIN-0046 Bunny chow: unfamiliar dish for many Zimbabweans; weak pathways none; weak criteria alternativePathwayQuality.
- FW-FIN-0047 Dashiki: routes distinguish poorly from other tunics; weak pathways 2; weak criteria none.
- FW-LIFE-0048 Dare: dialect and ambiguous English dare; weak pathways none; weak criteria alternativePathwayQuality, linguisticAccessibility.
- FW-LIFE-0049 Choto: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0050 Chitofu: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0052 Mupinyi: Shona recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0053 Matombo: native translation and generic second route; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0054 Chivanhu: abstract local term; weak pathways none; weak criteria linguisticAccessibility.
- FW-FIN-0055 Ankara fabric: overlaps other patterned textile cards; weak pathways none; weak criteria alternativePathwayQuality.
- FW-LIFE-0058 Dengu: native recognition and generic third route; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0059 Mutsago: native translation; weak pathways none; weak criteria linguisticAccessibility.
- FW-LIFE-0060 Chirongo: native recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0005 Muriwo: native translation and broad first route; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0015 Mupunga: language-specific target; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0016 Mutakura: local dish and generic gathering; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0017 Nyimo: specific crop; third vague; weak pathways 3; weak criteria linguisticAccessibility.
- FW-FOOD-0018 Mufushwa: native recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0019 Derere: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0020 Chimodho: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0021 Muboora: plant-specific recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0022 Mabhanzi: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0024 Mazhanje: recognition of woodland fruit; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0026 Chibage: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0027 Zviyo: specialist crop and hard due to recognition; weak pathways none; weak criteria linguisticAccessibility.
- FW-FOOD-0029 Munyemba: specialist crop; generic descriptions; weak pathways none; weak criteria linguisticAccessibility.
- FW-PERS-0002 Oliver Mtukudzi: third generic; artist recognition; weak pathways 3; weak criteria none.
- FW-REF-0105 Comic Elder: award detail niche; generic second; weak pathways 3; weak criteria none.
- FW-PERS-0016 Sally Mugabe: weakly distinctive and birth name obscure; weak pathways 2, 3; weak criteria alternativePathwayQuality.
- FW-REF-0109 Yo Maps: regional recognition and song dependence; weak pathways none; weak criteria alternativePathwayQuality.
- FW-PERS-0021 Dambudzo Marechera: specialist literary recognition; weak pathways 3; weak criteria none.
- FW-REF-0114 Nasty C: birth name obscure and songs only; weak pathways 2; weak criteria none.
- FW-PERS-0027 Hope Masike: album obscure and third generic; weak pathways 2, 3; weak criteria alternativePathwayQuality.
- FW-PERS-0033 Cara Black: niche tennis knowledge; weak pathways none; weak criteria alternativePathwayQuality.
- FW-REF-0124 Dorcas Moyo: award and first-name hint weak; weak pathways 3; weak criteria none.
- FW-SLANG-0001 Sharp: slang synonym overlap Bho; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0002 Mudhara: local-language adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0003 Mufesi: overlapping synonyms, low clue diversity; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0004 Zvirisei: language-specific greeting; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0005 Bho: synonym saturation; overlap Sharp; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0006 Chibaba: overlap Mudhara and name use; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0009 Kudhara: native-language adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0010 Madhiri: overlap Hustle and Side hustle; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0012 Kukiya: native translation review; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0013 Kufambisa: broad meanings, formal routes; weak pathways none; weak criteria alternativePathwayQuality, linguisticAccessibility.
- FW-SLANG-0014 Kudhonza: native translation; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0015 Kushaina: native slang adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0016 Kuzama: abstract term, overlap Hustle; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0019 Kurova: multiple meanings; native review; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0020 Kuvhaira: synonyms may be justified separately; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0021 Kufara: abstract translation; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0022 Kukanga: native translation review; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0023 Kudzvanya: native translation review; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0025 Siyabonga: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0026 Salibonani: language-specific greeting, third response variable; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0027 Hamba kahle: native adjudication; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0029 Yebo: generic confirmation, hard label not warranted; weak pathways none; weak criteria linguisticAccessibility.
- FW-SLANG-0030 Chokwadi: broad meanings and native review; weak pathways none; weak criteria linguisticAccessibility.
- FW-FIN-0187 Faith Kipyegon: track-specific recognition, third generic; weak pathways none; weak criteria alternativePathwayQuality.
- FW-AFRFB-0017 Jay-Jay Okocha: given name obscure; weak pathways 1; weak criteria none.
- FW-REF-0210 Sha Sha: recording titles and birth name; weak pathways 3; weak criteria none.
- FW-ZIMMU-0004 Hosho: native terms; weak pathways none; weak criteria linguisticAccessibility.
- FW-ZIMMU-0008 Jerusarema: formal heritage routes; overlap Jerusalema spelling not same identity; weak pathways none; weak criteria linguisticAccessibility.
- FW-ZIMMU-0012 ExQ: birth name and industry knowledge; weak pathways 1; weak criteria none.
- FW-ZIMMU-0013 Freeman HKD: third circular vague; weak pathways 3; weak criteria none.
- FW-ZIMMU-0017 Tocky Vibes: birth name plus song dependence; weak pathways 1; weak criteria none.
- FW-ZIMMU-0018 Nutty O: birth name less useful; weak pathways 3; weak criteria none.
- FW-ZIMMU-0021 Tytan: ambiguous collaboration and brand; weak pathways 2, 3; weak criteria alternativePathwayQuality.
- FW-ZIMMU-0023 Holy Ten: third generic; weak pathways 3; weak criteria none.
- FW-ZIMMU-0024 Voltz JT: title and birth-name dependence; weak pathways 1; weak criteria none.
- FW-ZIMMU-0025 Saintfloew: birth name and tracks; weak pathways 1; weak criteria none.
- FW-ZIMMU-0026 Mambo Dhuterere: third generic; weak pathways 3; weak criteria none.
- FW-ZIMMU-0030 Mokoomba: group recognition uncertain; generic second and third; weak pathways 2, 3; weak criteria alternativePathwayQuality.
- FW-ZIMMU-0034 System Tazvida: older artist recognition; weak pathways 3; weak criteria none.
- FW-AFRMU-0008 Kabza De Small: given names and generic last route; weak pathways 1; weak criteria none.
- FW-FAITH-0010 Samson: Manoah reference relatively specialist; weak pathways 3; weak criteria none.
- FW-SOCIAL-0015 Kiekie: comedy and comedian redundant; birth name obscure; weak pathways 1; weak criteria alternativePathwayQuality.
- FW-SOCIAL-0016 Taffy Theman: comedy/humour overlap; all generic; weak pathways none; weak criteria alternativePathwayQuality.
- FW-SOCIAL-0019 Kuda Musasiwa: entrepreneur visibility varies; last broad; weak pathways none; weak criteria alternativePathwayQuality.
- FW-WORLD-0012 Egypt: flag route obscure; weak pathways 3; weak criteria none.

## Limitations
Native Shona/Ndebele adjudication, observed timed solvability, full independent factual verification, native linguistic morphology, independent scoring and app build remain outstanding. Automated compound checking limited to explicit examples; no blanket substring prohibition. Some regional additions score lower than familiar everyday concepts, and need further testing. Candidate not release ready.