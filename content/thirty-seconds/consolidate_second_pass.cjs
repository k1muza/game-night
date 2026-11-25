#!/usr/bin/env node
"use strict";

/**
 * Apply the completed second-pass records to the production Sprint term bank.
 *
 * The input JSONL files are the editorial record. This script does not make new
 * content selections: it applies selected/approved candidates, honours explicit
 * rejections, carries human-review flags forward, and resolves the fixed
 * 800/800/400 production difficulty inventory deterministically.
 */

const fs = require("node:fs");
const path = require("node:path");

const ROOT = __dirname;
const TERMS_PATH = path.join(ROOT, "terms.jsonl");
const AUDIT_PATH = path.join(ROOT, "second-pass-refinement-log.jsonl");
const DECISIONS_PATH = path.join(ROOT, "second-pass-selected-candidates.jsonl");

const TARGET_DIFFICULTY = { easy: 800, medium: 800, hard: 400 };
const APPLY_STATUSES = new Set([
  "selected-pending-verification",
  "approved-direction-pending-integration",
]);
const REJECT_STATUS = "rejected-final-editorial";

function readJsonl(filePath) {
  return fs
    .readFileSync(filePath, "utf8")
    .trim()
    .split("\n")
    .filter((line) => line.trim())
    .map(JSON.parse);
}

function writeJsonl(filePath, rows) {
  fs.writeFileSync(filePath, `${rows.map(JSON.stringify).join("\n")}\n`, "utf8");
}

function normalize(value) {
  return value
    .normalize("NFKD")
    .replace(/\p{M}/gu, "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

function unique(values) {
  return [...new Set(values)];
}

function stableMode(values) {
  const encoded = values.map((value) => JSON.stringify(value));
  const counts = new Map();
  for (const value of encoded) counts.set(value, (counts.get(value) || 0) + 1);
  const winner = [...counts].sort(
    ([left, leftCount], [right, rightCount]) =>
      rightCount - leftCount || left.localeCompare(right),
  )[0][0];
  return JSON.parse(winner);
}

function categoryProfiles(terms) {
  const profiles = {};
  const categories = [...new Set(terms.map((term) => term.category))].sort();
  for (const category of categories) {
    const group = terms.filter((term) => term.category === category);
    profiles[category] = {};
    for (const field of ["subcategory", "broadDomain", "tags", "reviewCadence"]) {
      profiles[category][field] = stableMode(group.map((term) => term[field]));
    }
  }
  return profiles;
}

function editorialAssessment(scores, humanReview) {
  return {
    status: humanReview
      ? "second-pass-human-review-required"
      : "second-pass-editorial-applied",
    describability: scores.describability,
    audienceFamiliarity: scores.audienceFamiliarity,
    distinctiveness: scores.answerDistinctiveness,
    entertainmentValue: scores.entertainmentPotential,
    culturalRelevance: scores.culturalRelevance,
    longevity: scores.longevity,
    linguisticAccessibility: scores.languageAccessibility,
    weightedScore: scores.weightedScore,
    rubric: "second-pass-editorial-2026-11-25",
  };
}

function inferPublicFigure(candidate, broadDomain) {
  if (!candidate.properNoun) return false;
  const clues = candidate.descriptionPathways.join(" ").toLowerCase();
  const personTerms =
    /\b(actor|actress|artist|athlete|author|chef|choreographer|dj|fighter|medallist|owner|player|runner|singer|songwriter|sprinter|winger)\b/;
  if (personTerms.test(clues)) return true;
  return broadDomain === "sport" && ["SPT-01", "SPT-02"].includes(candidate.category);
}

function candidateAliases(candidate, termsByNormalizedName) {
  const prior = termsByNormalizedName.get(normalize(candidate.term));
  return structuredClone(prior?.acceptedAliases || []);
}

function applyAudit(base, audit, profiles) {
  const row = structuredClone(base);
  Object.assign(row, structuredClone(audit.proposedMetadata || {}));
  Object.assign(row, {
    term: audit.revisedTerm,
    termDifficulty: audit.revisedDifficulty,
    category: audit.revisedCategory,
    regionalRelevance: audit.revisedRegion,
    properNoun: audit.revisedProperNoun,
    descriptionPathways: structuredClone(audit.descriptionPathways),
    disposition: audit.disposition,
    reason: audit.reason,
    normalized: normalize(audit.revisedTerm),
  });

  if (row.category !== base.category) {
    const profile = profiles[row.category];
    row.subcategory = profile.subcategory;
    row.broadDomain = profile.broadDomain;
    row.tags = structuredClone(profile.tags);
  }

  row.sourceRefs = unique([
    ...structuredClone(base.sourceRefs || []),
    ...structuredClone(audit.sourceRefs || []),
  ]);
  const flags = [];
  if (audit.disposition === "FLAG FOR HUMAN REVIEW") {
    flags.push(`editorial-review: ${audit.reason}`);
  }
  row.humanReviewFlags = flags;
  row.editorialAssessment = editorialAssessment(audit.editorialScores, flags.length > 0);
  row.pathwayStatus =
    row.descriptionPathways.length >= 3
      ? "second-pass-editorial-reviewed"
      : "human-review-required";
  row.verificationStatus =
    flags.length > 0 || row.descriptionPathways.length < 3
      ? "human-review-required"
      : row.sourceRefs.length > 0
        ? "source-linked-second-pass-editorial"
        : "second-pass-editorial-reviewed";
  return row;
}

function applyCandidate(row, decision, profiles, termsByNormalizedName) {
  const candidate = decision.candidate;
  const profile = profiles[candidate.category];
  const broadDomain = profile.broadDomain;
  const publicFigure = inferPublicFigure(candidate, broadDomain);
  const screenReference = broadDomain === "screen";
  const highlyLocal =
    candidate.regionalRelevance === "zimbabwe-national" &&
    candidate.termDifficulty === "hard" &&
    !publicFigure;
  const scores = candidate.editorialScores;
  const broadAccessible =
    candidate.termDifficulty === "easy" ||
    (scores.audienceFamiliarity >= 5 &&
      scores.languageAccessibility >= 4 &&
      !highlyLocal);

  const flags = [];
  if (decision.status === "selected-pending-verification") {
    flags.push("selected replacement pending human verification");
  }
  if (candidate.termLanguage !== "en") {
    flags.push(`native-language review required (${candidate.termLanguage})`);
  }
  const finalReason = decision.finalEditorialDecision?.reason || "";
  if (/native-speaker|remain open|required/i.test(finalReason)) {
    flags.push(`final editorial note: ${finalReason}`);
  }

  delete row.contextLabel;

  Object.assign(row, {
    term: candidate.term,
    termDifficulty: candidate.termDifficulty,
    termLanguage: candidate.termLanguage,
    category: candidate.category,
    subcategory: profile.subcategory,
    regionalRelevance: candidate.regionalRelevance,
    tags: structuredClone(profile.tags),
    acceptedAliases: candidateAliases(candidate, termsByNormalizedName),
    specialist: false,
    reviewCadence: publicFigure ? "12-months" : profile.reviewCadence,
    sourceRefs: structuredClone(candidate.sourceRefs || []),
    disposition: "REPLACE",
    reason: decision.reason,
    broadDomain,
    publicFigure,
    screenReference,
    properNoun: candidate.properNoun,
    highlyLocal,
    family: null,
    normalized: normalize(candidate.term),
    descriptionPathways: structuredClone(candidate.descriptionPathways),
    pathwayStatus:
      flags.length > 0
        ? "second-pass-human-review-required"
        : "second-pass-editorial-reviewed",
    verificationStatus:
      flags.length > 0
        ? "human-review-required"
        : candidate.sourceRefs?.length
          ? "source-linked-second-pass-editorial"
          : "second-pass-editorial-reviewed",
    broadAccessible,
    ruralAccessible: broadAccessible && !screenReference,
    humanReviewFlags: unique(flags),
    editorialAssessment: editorialAssessment(scores, flags.length > 0),
  });
  if (/context|distinguish|sense/i.test(decision.reason)) {
    row.contextLabel = candidate.descriptionPathways[0];
  }
  return row;
}

function synchronizeCandidateContextLabels(terms, decisions) {
  const byId = new Map(terms.map((row) => [row.termId, row]));
  for (const decision of decisions) {
    if (!APPLY_STATUSES.has(decision.status)) continue;
    const row = byId.get(decision.previousTermId);
    delete row.contextLabel;
    if (/context|distinguish|sense/i.test(decision.reason)) {
      row.contextLabel = decision.candidate.descriptionPathways[0];
    }
  }
}

function difficultyPressure(row) {
  const assessment = row.editorialAssessment;
  return (
    (5 - assessment.audienceFamiliarity) * 30 +
    (5 - assessment.describability) * 15 +
    (5 - assessment.linguisticAccessibility) * 10 +
    (row.specialist ? 15 : 0) +
    (row.highlyLocal ? 8 : 0) +
    (row.properNoun ? 8 : 0) +
    (row.broadAccessible ? 0 : 5)
  );
}

function difficultyCounts(terms) {
  const counts = { easy: 0, medium: 0, hard: 0 };
  for (const row of terms) counts[row.termDifficulty] += 1;
  return counts;
}

function resolveDifficultyInventory(terms, pinnedTermIds) {
  const editorialDifficulty = new Map(
    terms.map((row) => [row.termId, row.termDifficulty]),
  );

  function move(source, target, count, hardestFirst) {
    if (count <= 0) return;
    const eligible = terms
      .filter(
        (row) => row.termDifficulty === source && !pinnedTermIds.has(row.termId),
      )
      .sort((left, right) => {
        const scoreDifference = difficultyPressure(right) - difficultyPressure(left);
        return (hardestFirst ? scoreDifference : -scoreDifference) ||
          left.sourceIndex - right.sourceIndex;
      });
    if (eligible.length < count) {
      throw new Error(
        `not enough unpinned ${source} terms to move ${count} records to ${target}`,
      );
    }
    for (const row of eligible.slice(0, count)) row.termDifficulty = target;
  }

  let counts = difficultyCounts(terms);
  if (counts.easy > TARGET_DIFFICULTY.easy) {
    move("easy", "medium", counts.easy - TARGET_DIFFICULTY.easy, true);
  } else if (counts.easy < TARGET_DIFFICULTY.easy) {
    move("medium", "easy", TARGET_DIFFICULTY.easy - counts.easy, false);
  }

  counts = difficultyCounts(terms);
  if (counts.hard < TARGET_DIFFICULTY.hard) {
    move("medium", "hard", TARGET_DIFFICULTY.hard - counts.hard, true);
  } else if (counts.hard > TARGET_DIFFICULTY.hard) {
    move("hard", "medium", counts.hard - TARGET_DIFFICULTY.hard, false);
  }

  for (const row of terms) {
    const editorial = editorialDifficulty.get(row.termId);
    const production = row.termDifficulty;
    row.difficultyResolution = {
      editorialDifficulty: editorial,
      productionDifficulty: production,
      quotaAdjusted: editorial !== production,
      method:
        editorial !== production
          ? "second-pass-score-ranked-quota-adjustment"
          : "second-pass-editorial-difficulty",
    };
    row.estimatedSolveSeconds =
      { easy: 3.5, medium: 6, hard: 10 }[production] +
      (row.highlyLocal || row.specialist ? 1 : 0);
  }
}

function validateOutput(terms, decisions) {
  if (terms.length !== 2000) throw new Error(`expected 2000 terms, found ${terms.length}`);
  if (new Set(terms.map((row) => row.termId)).size !== 2000) {
    throw new Error("term IDs are not unique");
  }
  if (new Set(terms.map((row) => normalize(row.term))).size !== 2000) {
    throw new Error("canonical terms are not unique after normalization");
  }
  const counts = difficultyCounts(terms);
  if (JSON.stringify(counts) !== JSON.stringify(TARGET_DIFFICULTY)) {
    throw new Error(`difficulty inventory mismatch: ${JSON.stringify(counts)}`);
  }
  if (terms.some((row) => row.descriptionPathways.length < 3)) {
    throw new Error("one or more production terms have fewer than three pathways");
  }

  const byId = new Map(terms.map((row) => [row.termId, row]));
  for (const decision of decisions) {
    const row = byId.get(decision.previousTermId);
    if (decision.status === REJECT_STATUS) {
      if (row.term !== decision.previousTerm) {
        throw new Error(`rejected replacement was applied at ${decision.previousTermId}`);
      }
      if (row.replacementDecision.decision !== "reject-replacement") {
        throw new Error("rejected replacement decision was not preserved");
      }
    } else if (row.term !== decision.candidate.term) {
      throw new Error(`approved/selected replacement missing at ${row.termId}`);
    }
  }

  return {
    terms: terms.length,
    difficulty: counts,
    appliedReplacements: decisions.filter((decision) => APPLY_STATUSES.has(decision.status))
      .length,
    rejectedReplacements: decisions.filter((decision) => decision.status === REJECT_STATUS)
      .length,
    humanReviewTerms: terms.filter((row) => row.humanReviewFlags.length > 0).length,
    quotaAdjustedTerms: terms.filter(
      (row) => row.difficultyResolution.quotaAdjusted,
    ).length,
  };
}

function main() {
  const baseline = readJsonl(TERMS_PATH);
  const audits = readJsonl(AUDIT_PATH);
  const decisions = readJsonl(DECISIONS_PATH);

  if (baseline.length !== 2000 || audits.length !== 2000) {
    throw new Error("baseline and second-pass audit must each contain 2000 rows");
  }
  if (new Set(audits.map((row) => row.sourceIndex)).size !== 2000) {
    throw new Error("second-pass source indices are not unique");
  }
  if (new Set(decisions.map((row) => row.sourceIndex)).size !== decisions.length) {
    throw new Error("replacement decision source indices are not unique");
  }
  const unsupported = new Set(
    decisions
      .map((row) => row.status)
      .filter((status) => !APPLY_STATUSES.has(status) && status !== REJECT_STATUS),
  );
  if (unsupported.size) {
    throw new Error(`unsupported replacement decision statuses: ${[...unsupported]}`);
  }

  if (
    baseline.every(
      (row) =>
        Number.isInteger(row.sourceIndex) &&
        row.difficultyResolution &&
        Array.isArray(row.humanReviewFlags),
    )
  ) {
    synchronizeCandidateContextLabels(baseline, decisions);
    const summary = validateOutput(baseline, decisions);
    summary.alreadyConsolidated = true;
    writeJsonl(TERMS_PATH, baseline);
    process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
    return;
  }

  const auditsByIndex = new Map(audits.map((row) => [row.sourceIndex, row]));
  const decisionsByIndex = new Map(decisions.map((row) => [row.sourceIndex, row]));
  const profiles = categoryProfiles(baseline);
  const baselineByName = new Map(
    baseline.map((row) => [normalize(row.term), row]),
  );

  const output = [];
  const pinnedTermIds = new Set();
  for (const [offset, base] of baseline.entries()) {
    const sourceIndex = offset + 1;
    const audit = auditsByIndex.get(sourceIndex);
    if (audit.termId !== base.termId || audit.previousTerm !== base.term) {
      throw new Error(`audit identity mismatch at source index ${sourceIndex}`);
    }

    let row = applyAudit(base, audit, profiles);
    row.sourceIndex = sourceIndex;
    const decision = decisionsByIndex.get(sourceIndex);
    if (decision) {
      if (
        decision.previousTermId !== base.termId ||
        decision.previousTerm !== base.term
      ) {
        throw new Error(`replacement identity mismatch at source index ${sourceIndex}`);
      }
      const final = decision.finalEditorialDecision || {};
      row.replacementDecision = {
        status: decision.status,
        proposedTerm: decision.candidate.term,
        decision:
          final.decision ||
          (APPLY_STATUSES.has(decision.status)
            ? "apply-selected-replacement"
            : "reject-replacement"),
        reason: final.reason || decision.reason,
      };
      if (APPLY_STATUSES.has(decision.status)) {
        row = applyCandidate(row, decision, profiles, baselineByName);
        pinnedTermIds.add(row.termId);
      }
    }
    output.push(row);
  }

  resolveDifficultyInventory(output, pinnedTermIds);
  synchronizeCandidateContextLabels(output, decisions);
  const summary = validateOutput(output, decisions);
  writeJsonl(TERMS_PATH, output);
  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
}

main();
