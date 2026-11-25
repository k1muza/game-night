#!/usr/bin/env python3
import json,re,pathlib,unicodedata
p=pathlib.Path(__file__).parent
rows=[json.loads(s) for s in (p/'cards.jsonl').read_text().splitlines() if s.strip()]
logs=[json.loads(s) for s in (p/'revision-log.jsonl').read_text().splitlines() if s.strip()]
def norm(s): return re.sub(r'[^a-z0-9]+',' ', ''.join(c for c in unicodedata.normalize('NFKD',s.lower()) if not unicodedata.combining(c))).strip()
def stem(w): return re.sub(r'(ing|ed|es|s)$','',re.sub(r'ies$','y',w)) if len(w)>4 else w
def st(s): return ' '.join(stem(w) for w in norm(s).split())
def has(a,b): return ' '+b+' ' in ' '+a+' '
assert len(rows)==len(logs)==500
assert len({r['cardId'] for r in rows})==len({norm(r['targetWord']) for r in rows})==500
assert len({r['originalCardId'] for r in logs})==500
assert {r.get('successorId',r['originalCardId']) for r in logs}=={r['cardId'] for r in rows}
flags=[]
for r in rows:
    assert r['gameType']=='forbidden-words' and r['schemaVersion']=='1.0.0'
    assert r['difficulty'] in ('easy','medium','hard')
    assert re.fullmatch(r'(ZIM|AFR|SPT|MUS|ENT|SMC|SCI|UNI|WLD)-0[1-6]',r['category'])
    assert all(k in r for k in ('cardId','version','language','tags','regionalRelevance','acceptedTargetAliases','editorialMetadata','forbiddenClueDetails','solvabilityCheck'))
    clues=r['forbiddenClues']; assert len(clues)==len(set(map(norm,clues)))==5
    assert [a['clue'] for a in r['forbiddenClueDetails']]==clues
    paths=r['solvabilityCheck']['sampleValidClues']; assert len(paths)>=3
    assert paths==[a['exampleSentence'] for a in r['solvabilityCheck']['pathways']]
    terms=[r['targetWord'],*r['acceptedTargetAliases'],*clues,*r['editorialMetadata'].get('prohibitedTargetTranslations',[])]
    for i,s in enumerate(paths,1):
        hits=[t for t in terms if has(norm(s),norm(t)) or has(st(s),st(t))]
        hits += ['component:'+w for w in norm(r['targetWord']).split() if len(w)>2 and w not in ('the','and','for','with') and stem(w) in st(s).split()]
        if hits: flags.append((r['cardId'],i,hits))
print('500 cards: structural checks passed. Lexical flags:',len(flags))
for f in flags: print(f)
assert not flags
print('Heuristic only; independent semantic, native-language and human review pending.')
