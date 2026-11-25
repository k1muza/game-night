#!/usr/bin/env node
const fs=require('fs'),p=require('path'),a=require('assert/strict');
const read=f=>fs.readFileSync(p.join(__dirname,'..',f),'utf8').trim().split('\n').map(JSON.parse);
const cards=read('cards.jsonl'),facts=read('fact-check-report.jsonl'),log=read('contemporary-refinement-log.jsonl'),s=JSON.parse(fs.readFileSync(p.join(__dirname,'../../schemas/trivia-v2.schema.json'),'utf8'));
const norm=x=>x.trim().toLowerCase().replace(/\s+/g,' ');
a.equal(cards.length,800);
for(const k of ['cardId','canonicalFactId','question'])a.equal(new Set(cards.map(c=>norm(c[k]))).size,800,k);
const d={easy:0,medium:0,hard:0,expert:0};
for(const c of cards){a(s.required.every(k=>k in c));a.match(c.cardId,/^TR-(PROD|REV)-[0-9]{4}$/);a.equal(c.schemaVersion,'2.0.0');a.equal(c.gameType,'trivia');for(const k of ['category','difficulty','regionalRelevance'])a(s.properties[k].enum.includes(c[k]));for(const k of ['question','correctAnswer','explanation'])a(c[k].length>0&&c[k].length<=s.properties[k].maxLength);a.equal(c.distractors.length,3);a.equal(new Set([c.correctAnswer,...c.distractors].map(norm)).size,4);a(c.estimatedResponseSeconds>=5&&c.estimatedResponseSeconds<=35);d[c.difficulty]++;}
a.deepEqual(d,{easy:160,medium:320,hard:240,expert:80});a.equal(facts.length,800);a.equal(new Set(facts.map(c=>c.cardId)).size,800);const m=new Map(cards.map(c=>[c.cardId,c]));for(const f of facts)a.equal(m.get(f.cardId).canonicalFactId,f.canonicalFactId);for(const r of log){a(!m.has(r.previousCardId));const c=m.get(r.successorCardId);a.equal(c.canonicalFactId,r.successorCanonicalFactId);a(c.sourceReferences.length);for(const t of c.sourceReferences){a(t.title&&t.url&&t.retrievedDate&&t.evidence);new URL(t.url);}}console.log(JSON.stringify({cards:800,replacements:log.length,difficulty:d,structuralChecks:'passed',releaseReady:false},null,2));
