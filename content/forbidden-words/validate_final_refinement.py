#!/usr/bin/env python3
"""Validate final Taboo candidate, including the targeted QA revision chain.
Lexical checks are heuristic; this does not establish human solvability.
"""
import json
import re
import pathlib
import unicodedata
from collections import Counter

p = pathlib.Path(__file__).parent

def read(n):
    return [json.loads(x) for x in (p/n).read_text(encoding="utf-8").splitlines() if x.strip()]

def norm(s):
    return re.sub(r"[^a-z0-9]+", " ", "".join(c for c in unicodedata.normalize("NFKD", s.lower()) if not unicodedata.combining(c))).strip()

def stem(w):
    return re.sub(r"(ing|ed|es|s)$", "", re.sub(r"ies$", "y", w)) if len(w) > 4 else w

def st(s):
    return " ".join(stem(w) for w in norm(s).split())

def has(a, b):
    return " " + b + " " in " " + a + " "

rows = read("cards.jsonl")
first = read("revision-log.jsonl")
final = read("final-refinement-log.jsonl")
qa = read("final-qa-refinement-log.jsonl")
audit = read("final-description-pathway-audit.jsonl")
critical = read("final-qa-critical-review.jsonl")
assert len(rows) == len(first) == len(audit) == 500
ids = {r["cardId"] for r in rows}
assert len(ids) == len({norm(r["targetWord"]) for r in rows}) == 500
chain = [x.get("successorId", x["originalCardId"]) for x in first]
for revisions in (final, qa):
    successors = {x["previous"]["cardId"]: x["revised"]["cardId"] for x in revisions}
    assert len(successors) == len(revisions)
    chain = [successors.get(x, x) for x in chain]
assert len(set(chain)) == 500 and set(chain) == ids
assert len(critical) == len({x["index"] for x in critical}) == 86
assert sum(len(x["priorWeakPathways"]) for x in critical if x["weakPathwaysRewritten"]) == 34
assert len(qa) == len({x["index"] for x in qa}) == 50
assert Counter(r["regionalRelevance"] for r in rows) == {"zimbabwe-national":225,"african":80,"global":195}
assert Counter(r["difficulty"] for r in rows) == {"easy":176,"medium":235,"hard":89}

reminders = {
    ("Chitofu","stove"), ("Mupinyi","screwdriver"), ("Matombo","stones"),
    ("Mutsago","pillow"), ("Matemba","kapenta"), ("Mupunga","rice"),
    ("Chibage","maize"), ("Munyemba","cowpeas"), ("Siyabonga","thank you"),
    ("Salibonani","hello"), ("Yebo","yes"), ("Chokwadi","truth")
}
compounds = {
    "wheelbarrow":"wheel barrow","firewood":"fire wood","sugarcane":"sugar cane",
    "smartphone":"smart phone","screenshot":"screen shot","smartwatch":"smart watch",
    "touchscreen":"touch screen","headphones":"head phones","hotspot":"hot spot",
    "fingerprint scanner":"finger print","clickbait":"click bait","rainbow":"rain bow",
    "earthquake":"earth quake","payslip":"pay slip","roommate":"room mate",
    "homesickness":"home sick","icebreaker":"ice breaker","minecraft":"craft mine",
    "hashtag":"hash tag","livestream":"live stream","payday":"pay day","unfollow":"follow"
}
flags = []
aliases = {}
overlap = set()
for r, a in zip(rows, audit):
    assert r["cardId"] == a["cardId"] and r["targetWord"] == a["target"]
    assert r["schemaVersion"] == "1.0.0" and r["gameType"] == "forbidden-words"
    assert r["difficulty"] in ("easy","medium","hard")
    assert re.fullmatch(r"(ZIM|AFR|SPT|MUS|ENT|SMC|SCI|UNI|WLD)-0[1-6]",r["category"])
    assert all(k in r for k in ("version","language","tags","regionalRelevance","acceptedTargetAliases","editorialMetadata","forbiddenClueDetails","solvabilityCheck","productionCategory"))
    c = r["forbiddenClues"]
    assert len(c) == len(set(map(norm,c))) == 5
    assert [d["clue"] for d in r["forbiddenClueDetails"]] == c == a["forbiddenClues"]
    paths = r["solvabilityCheck"]["sampleValidClues"]
    assert len(paths) == len(set(map(norm,paths))) == 3
    assert paths == [x["exampleSentence"] for x in r["solvabilityCheck"]["pathways"]]
    assert paths == [x["exampleSentence"] for x in a["reviewedDescriptionPathways"]]
    assert not a["editorialScoring"]["weakPathways"]
    terms = [r["targetWord"],*r["acceptedTargetAliases"],*c,*r["editorialMetadata"].get("prohibitedTargetTranslations",[])]
    for name in [r["targetWord"],*r["acceptedTargetAliases"]]:
        aliases.setdefault(norm(name),set()).add(r["cardId"])
    for clue in c:
        if norm(clue) in set(map(norm,r["acceptedTargetAliases"])):
            overlap.add((r["targetWord"],norm(clue)))
    for d in r["forbiddenClueDetails"]:
        terms.extend(x for k in ("variants","prohibitedDerivatives") for x in d.get(k,[]) if isinstance(x,str))
    for i,s in enumerate(paths,1):
        hits = [t for t in terms if has(norm(s),norm(t)) or has(st(s),st(t))]
        hits += ["component:"+w for w in norm(r["targetWord"]).split() if len(w)>2 and w not in ("the","and","for","with") and stem(w) in st(s).split()]
        for w in compounds.get(norm(r["targetWord"]),"").split():
            variants = [w,"paying","paid","pays","payment"] if w=="pay" else [w,"sickness"] if w=="sick" else [w]
            if any(has(norm(s),v) or has(st(s),st(v)) for v in variants):
                hits.append("compound:"+w)
        if hits:
            flags.append((r["cardId"],i,hits))
for x in qa:
    r = rows[x["index"]-1]
    assert r["cardId"] == x["revised"]["cardId"]
    assert r["targetWord"] == x["revised"]["target"]
    assert r["forbiddenClues"] == x["revised"]["forbiddenClues"]
    assert r["solvabilityCheck"]["sampleValidClues"] == x["revised"]["paths"]
assert overlap == reminders, (overlap-reminders,reminders-overlap)
assert not {k:v for k,v in aliases.items() if len(v)>1}
assert not flags, flags
print("PASS: 500 unique targets, 2500 restrictions, 1500 pathways, revision chain, balance and audit")
print("PASS: no heuristic lexical findings, no cross-card alias collisions, 12 documented visible translation reminders")
print("Native-language verification, timed play and Flutter tests remain separate gates.")
