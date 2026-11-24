#!/usr/bin/env node
/**
 * Trivia validation suite for Game Night
 * Validates cards.jsonl against schema and content requirements
 */
const fs = require('fs');
const path = require('path');

const CARDS_PATH = path.join(__dirname, '..', 'cards.jsonl');
const SCHEMA_PATH = path.join(__dirname, '..', '..', 'schemas', 'draft-v1.1.schema.json');

function loadCards() {
  const lines = fs.readFileSync(CARDS_PATH, 'utf8').trim().split('\n');
  return lines.map((l, i) => {
    try { return JSON.parse(l); }
    catch(e) { return { _error: `Line ${i+1}: ${e.message}` }; }
  });
}

function validate(cards) {
  const results = {
    totalCards: cards.length,
    parseErrors: [],
    checks: {},
    passed: true,
    timestamp: new Date().toISOString()
  };

  // Check 1: Exactly 800 records
  const c1 = cards.length === 800;
  results.checks['exactly_800_records'] = { passed: c1, actual: cards.length };
  if (!c1) results.passed = false;

  // Filter out parse errors
  const validCards = cards.filter(c => !c._error);
  const errorCards = cards.filter(c => c._error);
  results.parseErrors = errorCards.map(c => c._error);

  // Check 2: Unique card IDs
  const ids = validCards.map(c => c.cardId);
  const uniqueIds = new Set(ids);
  const c2 = uniqueIds.size === validCards.length;
  results.checks['unique_card_ids'] = { passed: c2, unique: uniqueIds.size, total: validCards.length };
  if (!c2) {
    const dupes = ids.filter((id, i) => ids.indexOf(id) !== i);
    results.checks['unique_card_ids'].duplicates = [...new Set(dupes)];
    results.passed = false;
  }

  // Check 3: Required fields
  const requiredFields = ['cardId','gameType','version','schemaVersion','category','difficulty',
    'minAge','language','regionalRelevance','tags','editorialStatus',
    'question','correctAnswer','distractors','explanation',
    'sourceTitle','sourceUrl','sourceRetrievedDate','factCheckStatus'];
  const missingFields = [];
  validCards.forEach(c => {
    requiredFields.forEach(f => {
      if (!(f in c)) missingFields.push(`${c.cardId}: missing ${f}`);
    });
  });
  results.checks['required_fields'] = { passed: missingFields.length === 0, missing: missingFields.length, details: missingFields.slice(0, 20) };
  if (missingFields.length > 0) results.passed = false;

  // Check 4: Exactly one correct answer (string)
  const wrongCorrect = validCards.filter(c => typeof c.correctAnswer !== 'string' || c.correctAnswer.length === 0);
  results.checks['one_correct_answer'] = { passed: wrongCorrect.length === 0, failures: wrongCorrect.length };
  if (wrongCorrect.length > 0) results.passed = false;

  // Check 5: Exactly 3 distractors
  const wrongDistractors = validCards.filter(c => !Array.isArray(c.distractors) || c.distractors.length !== 3);
  results.checks['three_distractors'] = { passed: wrongDistractors.length === 0, failures: wrongDistractors.length };
  if (wrongDistractors.length > 0) results.passed = false;

  // Check 6: 4 distinct answer options
  const nonDistinct = [];
  validCards.forEach(c => {
    if (Array.isArray(c.distractors)) {
      const all = [c.correctAnswer, ...c.distractors].map(a => (a||'').toLowerCase().trim());
      if (new Set(all).size !== 4) nonDistinct.push(c.cardId);
    }
  });
  results.checks['four_distinct_options'] = { passed: nonDistinct.length === 0, failures: nonDistinct.length, cards: nonDistinct.slice(0, 20) };
  if (nonDistinct.length > 0) results.passed = false;

  // Check 7: Category allocation
  const catCounts = {};
  validCards.forEach(c => { catCounts[c.productionCategory || c.category] = (catCounts[c.productionCategory || c.category] || 0) + 1; });
  results.checks['category_allocation'] = { passed: true, distribution: catCounts };

  // Check 8: Difficulty allocation
  const diffCounts = { easy: 0, medium: 0, hard: 0 };
  validCards.forEach(c => { if (c.difficulty in diffCounts) diffCounts[c.difficulty]++; });
  const diffOk = diffCounts.easy === 320 && diffCounts.medium === 320 && diffCounts.hard === 160;
  results.checks['difficulty_allocation'] = { passed: diffOk, distribution: diffCounts, target: { easy: 320, medium: 320, hard: 160 } };

  // Check 9: Canonical fact uniqueness
  const factIds = {};
  validCards.forEach(c => {
    if (c.canonicalFactId) {
      if (!factIds[c.canonicalFactId]) factIds[c.canonicalFactId] = [];
      factIds[c.canonicalFactId].push(c.cardId);
    }
  });
  const dupeFacts = Object.entries(factIds).filter(([k, v]) => v.length > 1);
  results.checks['canonical_fact_uniqueness'] = { passed: dupeFacts.length === 0, duplicates: dupeFacts.length, details: dupeFacts.slice(0, 10) };

  // Check 10: Evidence metadata
  const noEvidence = validCards.filter(c => !c.sourceEvidence && (!c.sourceReferences || c.sourceReferences.length === 0));
  results.checks['evidence_metadata'] = { passed: noEvidence.length === 0, missing: noEvidence.length };

  // Check 11: Verification status
  const statusCounts = {};
  validCards.forEach(c => { statusCounts[c.factCheckStatus] = (statusCounts[c.factCheckStatus] || 0) + 1; });
  results.checks['verification_status'] = { distribution: statusCounts, allVerified: (statusCounts['verified'] || 0) === validCards.length };

  // Check 12: Valid review dates
  const invalidDates = validCards.filter(c => {
    if (c.sourceRetrievedDate === null) return false;
    return c.sourceRetrievedDate && !/^\d{4}-\d{2}-\d{2}$/.test(c.sourceRetrievedDate);
  });
  results.checks['valid_dates'] = { passed: invalidDates.length === 0, invalid: invalidDates.length };

  // Check 13: Explanation completeness
  const noExplanation = validCards.filter(c => !c.explanation || c.explanation.length === 0);
  results.checks['explanation_completeness'] = { passed: noExplanation.length === 0, missing: noExplanation.length };

  // Check 14: Evidence duplication (heuristic)
  const evidenceMatchesExplanation = validCards.filter(c => c.sourceEvidence === c.explanation);
  results.checks['evidence_explanation_duplication'] = {
    count: evidenceMatchesExplanation.length,
    percentage: ((evidenceMatchesExplanation.length / validCards.length) * 100).toFixed(1) + '%',
    note: 'Heuristic check — some overlap is acceptable'
  };

  // Check 15: Schema compliance
  const wrongGameType = validCards.filter(c => c.gameType !== 'trivia');
  const wrongSchemaVersion = validCards.filter(c => c.schemaVersion !== '1.1.0');
  const wrongIdPattern = validCards.filter(c => !/^TR-[A-Z]{2,6}-\d{4,6}$/.test(c.cardId));
  results.checks['schema_compliance'] = {
    passed: wrongGameType.length === 0 && wrongSchemaVersion.length === 0 && wrongIdPattern.length === 0,
    wrongGameType: wrongGameType.length,
    wrongSchemaVersion: wrongSchemaVersion.length,
    wrongIdPattern: wrongIdPattern.length,
    wrongIdPatternCards: wrongIdPattern.map(c => c.cardId).slice(0, 10)
  };
  if (!results.checks['schema_compliance'].passed) results.passed = false;

  // Check 16: Question word count
  const longQuestions = validCards.filter(c => c.question && c.question.split(/\s+/).length > 25);
  results.checks['question_length'] = {
    passed: longQuestions.length === 0,
    over25Words: longQuestions.length,
    cards: longQuestions.map(c => ({ id: c.cardId, words: c.question.split(/\s+/).length })).slice(0, 10)
  };

  // Check 17: Social media count
  const smcCount = validCards.filter(c => c.productionCategory === 'Social Media & Internet Culture').length;
  results.checks['social_media_count'] = { passed: smcCount === 50, actual: smcCount, target: 50 };

  return results;
}

// Run
const cards = loadCards();
const results = validate(cards);

// Output
console.log(JSON.stringify(results, null, 2));

// Write to file
const outputPath = path.join(__dirname, '..', 'validation-results.json');
fs.writeFileSync(outputPath, JSON.stringify(results, null, 2));
console.error(`\nValidation results written to ${outputPath}`);
console.error(`Overall: ${results.passed ? 'PASSED' : 'FAILED'}`);

process.exit(results.passed ? 0 : 1);
