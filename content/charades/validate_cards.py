#!/usr/bin/env python3
"""Structural candidate validator; does not prove cultural quality."""
import json, re, sys, unicodedata
from pathlib import Path
from collections import Counter
ROOT = Path(__file__).resolve().parent
def norm(s):
    return ''.join(c for c in unicodedata.normalize('NFKD', s).casefold() if c.isalnum())
def read(path):
    return [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()]
def main():
    try:
        cards = read(ROOT/'cards.jsonl')
        log = read(ROOT/'revision-log.jsonl')
        manifest = json.loads((ROOT.parent/'manifest.json').read_text(encoding='utf-8'))
    except (ValueError, OSError) as exc:
        print(exc); return 1
    errors, warnings = [], []
    allowed = set(["Movie","TV Show","Landmark","Fictional Character","Musician","Comedian","Famous Person","Historical Figure","Sports Personality","Song","Book","Sport","Sporting Activity","Sports Team","Traditional Game","Dance","Video Game","Cultural Symbol","Proverb","Internet Personality","Internet Meme","Bible Character","Idiom","Animal","Occupation","Object","Food","Music Genre"])
    bible = set(["Adam","Eve","Noah","Abraham","Sarah","Isaac","Jacob","Esau","Joseph","Moses","Aaron","Miriam","Joshua","Samson","Delilah","Gideon","Ruth","Naomi","David","Goliath","Solomon","Elijah","Elisha","Jonah","Daniel","Esther","Job","Balaam","John the Baptist","Peter","Paul","Judas Iscariot","Thomas","Zacchaeus","Lazarus","Mary Magdalene","Jesus","Mary","Cain","Abel","Pharaoh","Deborah","Rahab","Nehemiah","Stephen","Philip","Timothy"])
    required = set(["cardId","gameType","version","schemaVersion","category","productionCategory","subcategory","categoryType","playableCategory","prompt","acceptableAnswers","essentialConcepts","difficulty","wordCount","gestureability","mimeHints","minAge","ageRating","language","regionalRelevance","ageCohortRelevance","estimatedFamiliarity","accessibility","tags","stereotypeBiasFlag","editorialStatus","reviewCadence","reviewAfterDate","createdDate","contentOrigin","sourceReferences","editorialNotes","modeEligibility","estimatedSolveTimeSeconds","editorialAssessment","sourceVerificationStatus","answerAcceptanceRule"])
    ds = next(d for d in manifest['datasets'] if d['game']=='charades')
    if len(cards)!=600 or ds['cardCount']!=600: errors.append('Expected 600 cards')
    ids, prompts, aliases = set(), set(), {}
    for c in cards:
        if not isinstance(c,dict) or not required <= c.keys():
            errors.append('Missing required fields'); continue
        cid,p = c['cardId'],c['prompt']
        if cid in ids: errors.append(f'{cid}: duplicate id')
        ids.add(cid)
        if not isinstance(p,str) or not p.strip(): errors.append(f'{cid}: empty prompt'); continue
        key=norm(p)
        if key in prompts: errors.append(f'{cid}: duplicate prompt')
        prompts.add(key)
        if c['gameType']!='charades' or c['schemaVersion']!=ds['currentSchemaVersion']: errors.append(f'{cid}: schema/game mismatch')
        if c['playableCategory'] not in allowed: errors.append(f'{cid}: category')
        if c['difficulty'] not in ('easy','medium','hard'): errors.append(f'{cid}: difficulty')
        if c['wordCount']!=len(p.split()): errors.append(f'{cid}: word count')
        if not isinstance(c['acceptableAnswers'],list) or p not in c['acceptableAnswers']: errors.append(f'{cid}: canonical alias missing')
        else:
            for a in c['acceptableAnswers']:
                if not isinstance(a,str) or not norm(a): errors.append(f'{cid}: empty alias'); continue
                n=norm(a)
                if n in aliases and aliases[n]!=cid: errors.append(f'{cid}: alias collision')
                aliases[n]=cid
        if not isinstance(c['mimeHints'],list) or len(c['mimeHints'])<2 or not all(isinstance(h,str) and h.strip() for h in c['mimeHints']): errors.append(f'{cid}: missing hints')
        if c['editorialStatus']!='draft': errors.append(f'{cid}: unexpected approval')
        if c['productionCategory']=='Bible characters' and (c['playableCategory']!='Bible Character' or p not in bible): errors.append(f'{cid}: Bible restriction')
        if c['playableCategory']=='Bible Character' and p not in bible: errors.append(f'{cid}: Bible character not on allowlist')
        if re.match(r'^(Trying to|Getting caught|Pretending to|A person|Someone who)\b',p,re.I): warnings.append(f'{cid}: possible invented scenario')
        if not c['editorialAssessment'].get('minimumThresholdPassed'): warnings.append(f'{cid}: provisional rubric failure')
    if len(log)!=600 or len({r['originalCardId'] for r in log})!=600 or {r['successorCardId'] for r in log}!=ids: errors.append('Revision mapping coverage')
    print('Cards:',len(cards),'Unique prompts:',len(prompts),'Errors:',len(errors),'Warnings:',len(warnings))
    print('Categories:',dict(Counter(c['playableCategory'] for c in cards)))
    for e in errors: print('ERROR',e)
    for w in warnings: print('WARN',w)
    return int(bool(errors))
if __name__=='__main__': sys.exit(main())
