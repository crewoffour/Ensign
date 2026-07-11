// enumerate-corpus.js: discovers every icon-bearing SIDC in milsymbol's
// tables, both dialects, by hierarchical probing.
//
// The entity space (delta) and function ID space (charlie) are trees,
// BUT milsymbol's tables omit category-header parents (all of set 25
// lives under entries whose parents have no icon rows), so tree
// pruning silently amputates subtrees. Delta therefore sweeps the
// full entity space unpruned: ~19.4M probes, about a minute and a
// half at measured probe rates, once per milsymbol version. Charlie
// cannot brute-force 36^6, so its breadth-first walk tolerates gaps:
// the frontier descends through invalid nodes for up to GAP_GRACE
// levels, catching leaves beneath missing headers.
//
// Validity criterion: milsymbol's own validIcon flag on a friend-
// identity build (icon existence is identity-independent).
//
// Usage, from tools/extract:
//   node enumerate-corpus.js                 # writes corpus lists + summary
//   node enumerate-corpus.js --stats         # counts only, no files
//
// Outputs: out/corpus-delta.txt, out/corpus-charlie.txt (one SIDC per
// line, grouped by set/dimension with comment headers).

import { writeFileSync, mkdirSync } from "node:fs";
import { parseArgs } from "node:util";
import ms from "milsymbol";

const { values: args } = parseArgs({
  options: {
    stats: { type: "boolean", default: false },
    out: { type: "string", default: "out" },
  },
});

// How many consecutive invalid levels the charlie walk descends
// through before giving up on a branch.
const GAP_GRACE = 2;

console.log(`Enumerating milsymbol ${ms.version} icon tables`);

let builds = 0;
function hasIcon(sidc) {
  builds += 1;
  try {
    const symbol = new ms.Symbol(sidc, { size: 20, infoFields: false });
    return symbol.validIcon === true;
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Delta: version 10, reality, friend, present; probe symbol sets 00-99
// and the entity tree XX -> XXYY -> XXYYZZ within each.

function deltaSIDC(set, entity) {
  // version 10, reality, friend, set, present, no hqtfd, no
  // amplifier, entity, no modifiers: exactly 20 digits.
  return `1003${set}0000${entity}0000`;
}

function pad2(n) {
  return String(n).padStart(2, "0");
}

function enumerateDelta() {
  const bySet = new Map();
  for (let s = 0; s < 100; s++) {
    const set = pad2(s);
    const found = [];
    // Full unpruned sweep: milsymbol omits category-header parents,
    // so validity of a child implies nothing about its parent row.
    // Entity roots start at 01: 000000 is the frame-only generic.
    for (let a = 1; a < 100; a++) {
      const root = `${pad2(a)}0000`;
      if (hasIcon(deltaSIDC(set, root))) found.push(root);
      for (let b = 1; b < 100; b++) {
        const mid = `${pad2(a)}${pad2(b)}00`;
        if (hasIcon(deltaSIDC(set, mid))) found.push(mid);
        for (let c = 1; c < 100; c++) {
          const leaf = `${pad2(a)}${pad2(b)}${pad2(c)}`;
          if (hasIcon(deltaSIDC(set, leaf))) found.push(leaf);
        }
      }
    }
    if (found.length > 0) bySet.set(set, found);
    if (found.length > 0) console.log(`  delta set ${set}: ${found.length}`);
  }
  return bySet;
}

// ---------------------------------------------------------------------------
// Charlie: scheme S (and I for intelligence), dimensions across the
// battle space; probe the function ID tree one character at a time.

const CHARLIE_DIMENSIONS = ["P", "A", "G", "S", "U", "F"];
const CHARLIE_SCHEMES = ["S", "I"];
const FUNCTION_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split("");

function charlieSIDC(scheme, dimension, functionID) {
  return `${scheme}F${dimension}P${functionID}-----`.slice(0, 15);
}

function enumerateCharlie() {
  const byDimension = new Map();
  for (const scheme of CHARLIE_SCHEMES) {
    for (const dimension of CHARLIE_DIMENSIONS) {
      const found = [];
      // Breadth-first over the function tree, descending through up
      // to GAP_GRACE consecutive invalid levels so leaves beneath
      // missing category headers are still reached.
      let frontier = [{ id: "", gaps: 0 }];
      for (let depth = 0; depth < 6 && frontier.length > 0; depth++) {
        const next = [];
        for (const parent of frontier) {
          for (const char of FUNCTION_CHARS) {
            const id = parent.id + char;
            const candidate = id.padEnd(6, "-");
            if (hasIcon(charlieSIDC(scheme, dimension, candidate))) {
              found.push(candidate);
              next.push({ id, gaps: 0 });
            } else if (parent.gaps < GAP_GRACE) {
              next.push({ id, gaps: parent.gaps + 1 });
            }
          }
        }
        frontier = next;
      }
      if (found.length > 0) byDimension.set(`${scheme}:${dimension}`, found);
    }
  }
  return byDimension;
}

// ---------------------------------------------------------------------------
// Main.

mkdirSync(args.out, { recursive: true });
const startedAt = Date.now();

// ---------------------------------------------------------------------------
// Delta sector modifiers: probe entity 000000 plus each modifier code,
// discriminating by draw-instruction count against the bare-frame
// baseline. validIcon is unreliable here (bare generics report true),
// but a real modifier icon adds instructions and a nonexistent code
// adds none.

function instructionCount(sidc) {
  builds += 1;
  try {
    return new ms.Symbol(sidc, { size: 20, infoFields: false })
      .drawInstructions.length;
  } catch {
    return -1;
  }
}

function enumerateDeltaModifiers(sets) {
  const found = new Map();
  for (const set of sets) {
    const baseline = instructionCount(`1003${set}0000000000` + "0000");
    if (baseline < 0) continue;
    for (const sector of [1, 2]) {
      const codes = [];
      for (let n = 1; n < 100; n++) {
        const code = pad2(n);
        const mods = sector === 1 ? `${code}00` : `00${code}`;
        const count = instructionCount(`1003${set}0000000000${mods}`);
        if (count > baseline) codes.push(code);
      }
      if (codes.length > 0) found.set(`${set}:${sector}`, codes);
    }
  }
  return found;
}

const delta = enumerateDelta();
let deltaTotal = 0;
const deltaLines = [
  "# Full delta icon corpus, enumerated from milsymbol " + ms.version,
  "# by enumerate-corpus.js. Friend identity; icon existence is",
  "# identity-independent.",
];
for (const [set, entities] of [...delta.entries()].sort()) {
  deltaLines.push("", `# Symbol set ${set}: ${entities.length} icons`);
  for (const entity of entities) {
    deltaLines.push(deltaSIDC(set, entity));
  }
  deltaTotal += entities.length;
}

const modifiers = enumerateDeltaModifiers([...delta.keys()]);
let modifierTotal = 0;
const modifierLines = [
  "# Delta sector modifier icon corpus, enumerated from milsymbol " + ms.version,
  "# by enumerate-corpus.js: entity 000000 with a single sector",
  "# modifier set. Extraction isolates the modifier icon; the keys",
  "# tool assigns it the set+sector+code icon key.",
];
for (const [key, codes] of [...modifiers.entries()].sort()) {
  const [set, sector] = key.split(":");
  modifierLines.push("", `# set ${set} sector ${sector}: ${codes.length} modifier icons`);
  for (const code of codes) {
    const mods = sector === "1" ? `${code}00` : `00${code}`;
    modifierLines.push(`1003${set}0000000000${mods}`);
  }
  modifierTotal += codes.length;
  console.log(`  modifiers ${key}: ${codes.length}`);
}

const charlie = enumerateCharlie();
let charlieTotal = 0;
const charlieLines = [
  "# Full charlie icon corpus, enumerated from milsymbol " + ms.version,
  "# by enumerate-corpus.js.",
];
for (const [key, functions] of [...charlie.entries()].sort()) {
  charlieLines.push("", `# ${key}: ${functions.length} icons`);
  for (const functionID of functions) {
    const [scheme, dimension] = key.split(":");
    charlieLines.push(charlieSIDC(scheme, dimension, functionID));
  }
  charlieTotal += functions.length;
  console.log(`  charlie ${key}: ${functions.length}`);
}

const seconds = ((Date.now() - startedAt) / 1000).toFixed(1);
console.log(
  `\nTotal: ${deltaTotal} delta + ${charlieTotal} charlie icons + ` +
  `${modifierTotal} sector modifier icons (${builds} probe builds, ${seconds}s)`
);

if (!args.stats) {
  writeFileSync(`${args.out}/corpus-delta.txt`, deltaLines.join("\n") + "\n");
  writeFileSync(`${args.out}/corpus-charlie.txt`, charlieLines.join("\n") + "\n");
  writeFileSync(`${args.out}/corpus-modifiers.txt`, modifierLines.join("\n") + "\n");
  console.log(
    `Wrote ${args.out}/corpus-delta.txt, ${args.out}/corpus-charlie.txt, ` +
    `and ${args.out}/corpus-modifiers.txt`);
}