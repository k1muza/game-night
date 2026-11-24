import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import assert from 'node:assert/strict';

const dir = fileURLToPath(new URL('../content/drafts/', import.meta.url));
const games = ['thirty-seconds','charades','trivia','forbidden-words'];
const norm = s => s.normalize('NFKC').toLowerCase().replace(/[^\p{L}\p{N}]+/gu,'');
const ids = new Set();
const seen = new Map();
const counts = {};
const release = process.argv.includes('--release');
function unique(key, value) {
  const k = key + ':' + norm(value);
  assert(!seen.has(k), 'Duplicate: ' + value + ' (' + key + ')');
  seen.set(k, true);
}
function distinct(arr, n) {
  assert.equal(arr.length,n);
  assert(arr.every(x => typeof x === 'string' && x.trim()));
  assert.equal(new Set(arr.map(norm)).size,n);
}
for (const game of games) {
  const cards = readFileSync(join(dir, game+'.jsonl'),'utf8').trim().split('\n').map(JSON.parse);
  const prefix = {'thirty-seconds':'GS',charades:'CH',trivia:'TR','forbidden-words':'FW'}[game];
  counts[game] = {total:cards.length,easy:0,medium:0,hard:0};
  for (const c of cards) {
    assert.equal(c.gameType,game);
    assert.match(c.cardId,new RegExp('^'+prefix+'-[A-Z]{2,6}-[0-9]{4,6}$'));
    assert(!ids.has(c.cardId),'Duplicate ID '+c.cardId);
    ids.add(c.cardId);
    assert.equal(c.schemaVersion,'1.1.0');
    assert(Number.isInteger(c.version)&&c.version>=1);
    assert.equal(c.minAge,16);
    assert(['easy','medium','hard'].includes(c.difficulty));
    counts[game][c.difficulty]++;
    assert.match(c.category,/^(ZIM|AFR|SPT|MUS|ENT|SMC|SCI|UNI|WLD)-0[1-6]$/);
    assert(Array.isArray(c.tags)&&c.tags.length>0);
    assert(['draft','peer-reviewed','approved','published','flagged','retired'].includes(c.editorialStatus));
    if(release) assert(['approved','published'].includes(c.editorialStatus),'Unapproved card '+c.cardId);
    if(game==='thirty-seconds'){
      distinct(c.terms.map(t=>t.term),5);
      assert(c.terms.every(t=>t.term.length<=60&&['easy','medium','hard'].includes(t.termDifficulty)));
      assert(c.terms.some(t=>t.ruralAccessible));
      assert(c.terms.filter(t=>t.termDifficulty==='hard').length<=2);
      c.terms.forEach(t=>unique('sprint-term',t.term));
    } else if(game==='charades'){
      assert(c.prompt.length>=3&&c.prompt.length<=100);
      assert(['high','medium','low'].includes(c.gestureability));
      unique('charades',c.prompt);
    } else if(game==='trivia'){
      distinct([c.correctAnswer,...c.distractors],4);
      assert(c.question.length<=200&&c.explanation.length<=300);
      assert(c.question.trim().split(/\s+/).length<=20,'Long question '+c.cardId);
      assert.equal(new URL(c.sourceUrl).protocol,'https:');
      unique('trivia',c.question);
      if(release) {
        assert.equal(c.factCheckStatus,'verified');
        assert.match(c.sourceRetrievedDate,/^\d{4}-\d{2}-\d{2}$/);
      }
    } else {
      distinct(c.forbiddenClues,5);
      assert(!c.forbiddenClues.some(x=>norm(x)===norm(c.targetWord)));
      unique('forbidden-target',c.targetWord);
      assert(c.solvabilityCheck.sampleValidClues.length>=3);
      assert(c.solvabilityCheck.validRoutesCount>=3);
      if(release) assert(c.solvabilityCheck.checkedByEditors);
    }
  }
}
console.log(JSON.stringify({total:ids.size,counts},null,2));
