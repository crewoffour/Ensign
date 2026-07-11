// sample-corpus.js: builds the curated snapshot worklist.
//
// The in-repo snapshot suite is a fast regression net for Swift-side
// rendering changes; it needs breadth across rendering features and a
// taste of every symbol set, not corpus volume (the full corpus is
// verified by the oracle, tooling-side). This script unions every
// feature worklist with the first SAMPLES_PER_GROUP icons of each
// corpus group, writing sidcs-snapshots.txt.
//
// Run from tools/extract, after enumerate-corpus.js:
//   node sample-corpus.js
// Then record:
//   cd ../.. && swift run -c release ensign-catalog render \\
//     tools/extract/sidcs-snapshots.txt Tests/EnsignRenderTests/Snapshots 200

import { readFileSync, writeFileSync, existsSync } from "node:fs";

const SAMPLES_PER_GROUP = 3;
const FEATURE_LISTS = [
  "sidcs-maritime.txt",
  "sidcs-modifiers.txt",
  "sidcs-exercise.txt",
  "sidcs-status.txt",
  "sidcs-charlie-amps.txt",
  "sidcs-controlmeasures.txt",
  "sidcs-sector-combined.txt",
];

function readList(path) {
  if (!existsSync(path)) {
    console.warn(`NOTE ${path} not found; skipped`);
    return [];
  }
  return readFileSync(path, "utf8")
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"));
}

const seen = new Set();
const out = [
  "# Curated snapshot worklist, built by sample-corpus.js: every",
  "# feature worklist plus the first icons of each corpus group.",
  "# Regenerate after corpus changes, then re-record the snapshots.",
];

function add(section, sidcs) {
  const fresh = sidcs.filter((sidc) => !seen.has(sidc));
  if (fresh.length === 0) return;
  out.push("", `# ${section}`);
  for (const sidc of fresh) {
    seen.add(sidc);
    out.push(sidc);
  }
}

for (const list of FEATURE_LISTS) {
  add(list, readList(list));
}

// Per-group samples from the enumerated corpus: group boundaries are
// the comment headers the enumerator writes.
for (const corpus of [
  "out/corpus-delta.txt",
  "out/corpus-charlie.txt",
  "out/corpus-modifiers.txt",
]) {
  if (!existsSync(corpus)) {
    console.warn(`NOTE ${corpus} not found; run enumerate-corpus.js first`);
    continue;
  }
  const lines = readFileSync(corpus, "utf8").split("\n");
  let group = null;
  let taken = 0;
  const samples = [];
  for (const raw of lines) {
    const line = raw.trim();
    if (line.startsWith("#")) {
      if (line.includes(":")) {
        group = line;
        taken = 0;
      }
      continue;
    }
    if (line.length === 0) continue;
    if (taken < SAMPLES_PER_GROUP) {
      samples.push(line);
      taken += 1;
    }
  }
  add(`samples from ${corpus}`, samples);
}

writeFileSync("sidcs-snapshots.txt", out.join("\n") + "\n");
console.log(`Wrote ${seen.size} SIDCs to sidcs-snapshots.txt`);