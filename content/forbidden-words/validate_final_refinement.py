#!/usr/bin/env python3
import json,re,pathlib,unicodedata
p=pathlib.Path(__file__).parent
def read(n): return [json.loads(x) for x in (p/n).read_text(encoding='utf-8').splitlines() if x.strip()]
def norm(s): return re.sub(r'[^a-z0-9]+',' ',''.join(c for c in unicodedata.normalize('NFKD',s.lower()) if not unicodedata.combining(c))).strip()
def stem(w): return re.sub(r'(ing|ed|es|s)$','',re.sub(r'ies$','y',w)) if len(w)>4 else w
def st(s): return ' '.join(stem(w) for w in norm(s).split())
def has(a,b): return ' '+b+' ' in ' '+a+' '
rows=read('cards.jsonl'); first=read('revision-log.jsonl'); final=read('final-refinement-log.jsonl'); audit=read('final-description-pathway-audit.jsonl')
assert len(rows)==len(first)==len(audit)==500
ids={r['cardId'] for r in rows}
assert len(ids)==len({norm(r['targetWord']) for r in rows})==500
assert {r['cardId'] for r in audit}==ids
successors={x['previous']['cardId']:x['revised']['cardId'] for x in final}
firstids={x.get('successorId',x['originalCardId']) for x in first}
assert {successors.get(x,x) for x in firstids}==ids
flags=[]; aliases={}
for r in rows:
    assert r['schemaVersion']=='1.0.0' and r['gameType']=='forbidden-words'
    assert r['difficulty'] in ('easy','medium','hard')
    assert re.fullmatch(r'(ZIM|AFR|SPT|MUS|ENT|SMC|SCI|UNI|WLD)-0[1-6]',r['category'])
    assert all(k in r for k in ('version','language','tags','regionalRelevance','acceptedTargetAliases','editorialMetadata','forbiddenClueDetails','solvabilityCheck'))
    c=r['forbiddenClues']; assert len(c)==len(set(map(norm,c)))==5
    assert [d['clue'] for d in r['forbiddenClueDetails']]==c
    paths=r['solvabilityCheck']['sampleValidClues']; assert len(paths)==3 and paths==[a['exampleSentence'] for a in r['solvabilityCheck']['pathways']]
    terms=[r['targetWord'],*r['acceptedTargetAliases'],*c,*r['editorialMetadata'].get('prohibitedTargetTranslations',[])]
    for name in [r['targetWord'],*r['acceptedTargetAliases']]: aliases.setdefault(norm(name),set()).add(r['cardId'])
    for d in r['forbiddenClueDetails']: terms.extend(x for k in ('variants','prohibitedDerivatives') for x in d.get(k,[]) if isinstance(x,str))
    for i,s in enumerate(paths,1):
        hits=[t for t in terms if has(norm(s),norm(t)) or has(st(s),st(t))]
        hits += ['component:'+w for w in norm(r['targetWord']).split() if len(w)>2 and w not in ('the','and','for','with') and stem(w) in st(s).split()]
        if hits: flags.append((r['cardId'],i,hits))
print('500 cards and chained traceability passed. Heuristic flags:',flags)
print('Alias collisions:',{k:v for k,v in aliases.items() if len(v)>1})
assert not flags, 'Review flagged lexical paths'
print('Semantic and multilingual review are separate gates.')
