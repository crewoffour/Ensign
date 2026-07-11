// compare-jmsml.js: adjudication tooling for Session 10.
//
// Parses the JMSML instance data (the DISA/Esri machine-readable
// MIL-STD-2525D) and compares it against Ensign's decode tables and
// the enumerated milsymbol corpus, reporting divergences by category:
//
//   - Amplifier digit table (echelon/mobility) vs Ensign's decode
//   - HQ/TF/Dummy digit table vs Ensign's decode
//   - Per-set entity codes: matches, JMSML-only (milsymbol gaps),
//     corpus-only (likely 2525E additions; JMSML is archived at D)
//   - Sector one/two modifier inventory (a surface Ensign does not
//     yet decode or render)
//
// The XML is machine-generated and regular; parsing is by regex, no
// new dependencies. Run from tools/extract:
//
//   node compare-jmsml.js --jmsml <path to jmsml repo>/instance \\
//     [--names out/jmsml-names.csv]
//
// The corpus is read from corpus/corpus-delta.txt.

import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";

const { values: args } = parseArgs({
  options: {
    jmsml: { type: "string" },
    corpus: { type: "string", default: "corpus/corpus-delta.txt" },
    names: { type: "string" },
  },
});

if (!args.jmsml) {
  console.error("usage: node compare-jmsml.js --jmsml <jmsml>/instance [--names out.csv]");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Ensign's current decode tables, mirrored from the Swift enums. If a
// Swift table changes, change it here too; the comparator exists to
// diff these against the standard.

const ENSIGN_AMPLIFIERS = {
  "11": "Team/Crew", "12": "Squad", "13": "Section",
  "14": "Platoon/Detachment", "15": "Company/Battery/Troop",
  "16": "Battalion/Squadron", "17": "Regiment/Group", "18": "Brigade",
  "21": "Division", "22": "Corps/MEF", "23": "Army",
  "24": "Army Group/Front", "25": "Region/Theater", "26": "Command",
  "31": "Wheeled limited cross country", "32": "Wheeled cross country",
  "33": "Tracked", "34": "Wheeled and tracked combination",
  "35": "Towed", "36": "Rail", "37": "Pack animals",
  "41": "Over snow (prime mover)", "42": "Sled",
  "51": "Barge", "52": "Amphibious",
  "61": "Short towed array", "62": "Long towed array",
  "71": "Leadership Individual", "72": "Deputy Individual",
};

const ENSIGN_HQTFDUMMY = {
  "0": "Not Applicable", "1": "Feint/Dummy", "2": "Headquarters",
  "3": "Feint/Dummy Headquarters", "4": "Task Force",
  "5": "Feint/Dummy Task Force", "6": "Task Force Headquarters",
  "7": "Feint/Dummy Task Force Headquarters",
};

// ---------------------------------------------------------------------------
// Parsing helpers.

function read(path) {
  return readFileSync(path, "utf8").replace(/^\uFEFF/, "");
}

function digitPair(block, element) {
  const m = block.match(new RegExp(
    `<${element}>\\s*<DigitOne>(\\d)</DigitOne>\\s*<DigitTwo>(\\d)</DigitTwo>`));
  return m ? m[1] + m[2] : null;
}

function attr(tag, name) {
  const m = tag.match(new RegExp(`${name}="([^"]*)"`));
  return m ? m[1] : null;
}

// Splits an XML body into elements of a given name (non-nested use).
function elements(body, name) {
  const out = [];
  const re = new RegExp(`<${name}[ >]`, "g");
  let match;
  while ((match = re.exec(body)) !== null) {
    const close = body.indexOf(`</${name}>`, match.index);
    const selfClose = body.indexOf("/>", match.index);
    const tagEnd = body.indexOf(">", match.index);
    if (selfClose !== -1 && selfClose < tagEnd + 1 && (close === -1 || selfClose < close)) {
      out.push(body.slice(match.index, selfClose + 2));
    } else if (close !== -1) {
      out.push(body.slice(match.index, close + name.length + 3));
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Base.xml: the amplifier and HQTFDummy digit tables.

function compareBase(basePath) {
  const s = read(basePath);
  console.log("=== Base.xml: digit tables vs Ensign decode ===\n");

  const jmsmlAmplifiers = new Map();
  for (const group of elements(s, "AmplifierGroup")) {
    const g = group.match(/<AmplifierGroupCode>(\d)<\/AmplifierGroupCode>/)?.[1];
    for (const amp of elements(group, "Amplifier")) {
      const a = amp.match(/<AmplifierCode>(\d)<\/AmplifierCode>/)?.[1];
      const label = attr(amp, "Label");
      if (g !== undefined && a !== undefined && label !== "Unknown" && label !== "Extension") {
        jmsmlAmplifiers.set(g + a, label);
      }
    }
  }
  diffTables("amplifier (digits 9-10)", jmsmlAmplifiers, ENSIGN_AMPLIFIERS,
    // Leadership 71/72 came to milsymbol from a change proposal; JMSML
    // (archived) may predate it.
    new Set(["71", "72"]));

  const jmsmlHQTFD = new Map();
  for (const hq of elements(s, "HQTFDummy")) {
    const code = hq.match(/<HQTFDummyCode>(\d)<\/HQTFDummyCode>/)?.[1];
    const label = attr(hq, "Label");
    if (code !== undefined && label !== "Extension") jmsmlHQTFD.set(code, label);
  }
  diffTables("HQ/TF/Dummy (digit 8)", jmsmlHQTFD, ENSIGN_HQTFDUMMY, new Set());
}

function diffTables(name, jmsml, ensign, expectedEnsignOnly) {
  let clean = true;
  for (const [code, label] of [...jmsml.entries()].sort()) {
    if (!(code in ensign)) {
      console.log(`  JMSML-only ${name} ${code}: ${label} (Ensign does not decode)`);
      clean = false;
    }
  }
  for (const code of Object.keys(ensign).sort()) {
    if (!jmsml.has(code)) {
      const note = expectedEnsignOnly.has(code)
        ? " (expected: post-JMSML change proposal)" : "";
      console.log(`  Ensign-only ${name} ${code}: ${ensign[code]}${note}`);
      if (!expectedEnsignOnly.has(code)) clean = false;
    }
  }
  if (clean) console.log(`  ${name}: MATCHES the standard`);
  console.log("");
}

// ---------------------------------------------------------------------------
// Per-set instance files: entities vs the enumerated corpus.

function parseSymbolSet(path) {
  const s = read(path);
  const setCode = digitPair(s, "SymbolSetCode");
  if (!setCode) return null;
  const entities = new Map(); // 6-digit code -> { label, graphic }
  for (const entity of elements(s, "Entity")) {
    const e = digitPair(entity, "EntityCode");
    if (!e || e === "00") continue;
    const eLabel = attr(entity.slice(0, entity.indexOf(">")), "Label");
    record(entities, e + "0000", eLabel, entity);
    for (const type of elements(entity, "EntityType")) {
      const t = digitPair(type, "EntityTypeCode");
      if (!t) continue;
      const tLabel = attr(type.slice(0, type.indexOf(">")), "Label");
      record(entities, e + t + "00", `${eLabel} / ${tLabel}`, type);
      for (const sub of elements(type, "EntitySubType")) {
        const u = digitPair(sub, "EntitySubTypeCode");
        if (!u) continue;
        const uLabel = attr(sub.slice(0, sub.indexOf(">")), "Label");
        record(entities, e + t + u, `${eLabel} / ${tLabel} / ${uLabel}`, sub);
      }
    }
  }
  const sectorOne = countModifiers(s, "SectorOneModifiers");
  const sectorTwo = countModifiers(s, "SectorTwoModifiers");
  return { setCode, entities, sectorOne, sectorTwo };
}

function record(map, code, label, block) {
  const graphic = attr(block.slice(0, block.indexOf(">")), "Graphic");
  map.set(code, { label, graphic });
}

function countModifiers(s, sectionName) {
  const i = s.indexOf(`<${sectionName}>`);
  if (i === -1) return 0;
  const section = s.slice(i, s.indexOf(`</${sectionName}>`, i));
  return elements(section, "Modifier")
    .filter((m) => digitPair(m, "ModifierCode") !== "00").length;
}

function loadCorpus(path) {
  const bySet = new Map();
  for (const line of read(path).split("\n")) {
    const sidc = line.trim();
    if (sidc.length !== 20 || !/^\d+$/.test(sidc)) continue;
    const set = sidc.slice(4, 6);
    const entity = sidc.slice(10, 16);
    if (!bySet.has(set)) bySet.set(set, new Set());
    bySet.get(set).add(entity);
  }
  return bySet;
}

// ---------------------------------------------------------------------------
// Main.

const allFiles = readdirSync(args.jmsml).filter((f) => f.toLowerCase().endsWith(".xml"));
const baseFile = allFiles.find((f) => /base\.xml$/i.test(f));
if (!baseFile) {
  console.error(`no Base.xml found in ${args.jmsml}`);
  process.exit(1);
}
compareBase(join(args.jmsml, baseFile));

const corpus = loadCorpus(args.corpus);
const namesRows = [];
let totalMatch = 0, totalJmsmlOnly = 0, totalCorpusOnly = 0;
let totalSectorModifiers = 0;

const files = allFiles.filter((f) => f !== baseFile);
console.log(`=== Symbol sets: ${files.length} instance files vs corpus ===\n`);

for (const file of files.sort()) {
  const parsed = parseSymbolSet(join(args.jmsml, file));
  if (!parsed) continue;
  const { setCode, entities, sectorOne, sectorTwo } = parsed;
  const corpusEntities = corpus.get(setCode) ?? new Set();

  const jmsmlOnly = [...entities.keys()].filter((e) => !corpusEntities.has(e));
  const corpusOnly = [...corpusEntities].filter((e) => !entities.has(e));
  const matches = entities.size - jmsmlOnly.length;
  totalMatch += matches;
  totalJmsmlOnly += jmsmlOnly.length;
  totalCorpusOnly += corpusOnly.length;
  totalSectorModifiers += sectorOne + sectorTwo;

  console.log(
    `set ${setCode} (${file}): ${matches} match, ` +
    `${jmsmlOnly.length} JMSML-only, ${corpusOnly.length} corpus-only ` +
    `(likely 2525E), ${sectorOne}+${sectorTwo} sector modifiers`);
  for (const code of jmsmlOnly) {
    const { label, graphic } = entities.get(code);
    console.log(`    JMSML-only ${setCode}:${code}  ${label}` +
      (graphic ? ` [${graphic}]` : " [no graphic]"));
  }

  if (args.names) {
    for (const [code, { label }] of entities) {
      namesRows.push(`delta,${setCode}${code},"${label.replaceAll('"', '""')}"`);
    }
  }
}

console.log(
  `\nTotals: ${totalMatch} matching entities, ${totalJmsmlOnly} JMSML-only ` +
  `(milsymbol gaps), ${totalCorpusOnly} corpus-only (likely 2525E), ` +
  `${totalSectorModifiers} sector modifiers (not yet decoded by Ensign)`);

if (args.names) {
  writeFileSync(args.names, "family,code,label\n" + namesRows.join("\n") + "\n");
  console.log(`Names written to ${args.names} (${namesRows.length} rows)`);
}
