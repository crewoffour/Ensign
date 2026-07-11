// extract-crosswalk.js: pulls the official 2525C-to-2525D SIDC
// crosswalk out of the JMSML instance data.
//
// Each JMSML LegacySymbol carries the charlie SIDC pattern verbatim in
// its Label (asterisks are wildcard positions: identity, status, and
// the amplifier/country tail) and references the 2525D composition by
// ID: entity, entity type, entity subtype, and sector modifiers. This
// tool resolves those references to digit codes and emits one CSV row
// per mapping.
//
// Run from tools/extract:
//   node extract-crosswalk.js --jmsml <jmsml repo>/instance \\
//     [--out out/crosswalk-c-to-d.csv]
//
// Columns: charlie_pattern, delta_set, delta_entity, delta_mod1,
// delta_mod2, delta_sidc (a friend/present 20-digit realization,
// modifiers included), label.

import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";

const { values: args } = parseArgs({
  options: {
    jmsml: { type: "string" },
    out: { type: "string", default: "out/crosswalk-c-to-d.csv" },
  },
});

if (!args.jmsml) {
  console.error("usage: node extract-crosswalk.js --jmsml <jmsml>/instance [--out out.csv]");
  process.exit(1);
}

function read(path) {
  return readFileSync(path, "utf8").replace(/^\uFEFF/, "");
}

function attr(tag, name) {
  const m = tag.match(new RegExp(`${name}="([^"]*)"`));
  return m ? m[1] : null;
}

function digitPair(block, element) {
  const m = block.match(new RegExp(
    `<${element}>\\s*<DigitOne>(\\d)</DigitOne>\\s*<DigitTwo>(\\d)</DigitTwo>`));
  return m ? m[1] + m[2] : null;
}

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

function openTag(block) {
  return block.slice(0, block.indexOf(">"));
}

const rows = [];
let files = 0;

for (const file of readdirSync(args.jmsml).filter((f) => f.toLowerCase().endsWith(".xml")).sort()) {
  if (/base\.xml$/i.test(file)) continue;
  const s = read(join(args.jmsml, file));
  const setCode = digitPair(s, "SymbolSetCode");
  if (!setCode) continue;
  files += 1;

  // Resolve delta IDs to digit codes: entities hierarchically, sector
  // modifiers flat (IDs are unique within their sector).
  const entityCode = new Map();   // "E" / "E|T" / "E|T|S" -> 6 digits
  for (const entity of elements(s, "Entity")) {
    const eID = attr(openTag(entity), "ID");
    const e = digitPair(entity, "EntityCode");
    if (!eID || !e) continue;
    entityCode.set(eID, e + "0000");
    for (const type of elements(entity, "EntityType")) {
      const tID = attr(openTag(type), "ID");
      const t = digitPair(type, "EntityTypeCode");
      if (!tID || !t) continue;
      entityCode.set(`${eID}|${tID}`, e + t + "00");
      for (const sub of elements(type, "EntitySubType")) {
        const uID = attr(openTag(sub), "ID");
        const u = digitPair(sub, "EntitySubTypeCode");
        if (!uID || !u) continue;
        entityCode.set(`${eID}|${tID}|${uID}`, e + t + u);
      }
    }
  }
  const modifierCode = { one: new Map(), two: new Map() };
  for (const [sector, key] of [["SectorOneModifiers", "one"], ["SectorTwoModifiers", "two"]]) {
    const i = s.indexOf(`<${sector}>`);
    if (i === -1) continue;
    const section = s.slice(i, s.indexOf(`</${sector}>`, i));
    for (const modifier of elements(section, "Modifier")) {
      const id = attr(openTag(modifier), "ID");
      const code = digitPair(modifier, "ModifierCode");
      if (id && code) modifierCode[key].set(id, code);
    }
  }

  for (const legacy of elements(s, "LegacySymbol")) {
    const tag = openTag(legacy);
    const pattern = attr(tag, "Label");
    if (!pattern) continue;
    const eID = attr(tag, "EntityID");
    const tID = attr(tag, "EntityTypeID");
    const uID = attr(tag, "EntitySubTypeID");
    const lookupKey = [eID, tID, uID].filter(Boolean).join("|");
    const entity = entityCode.get(lookupKey);
    if (!entity) continue; // UNSPECIFIED and structural rows
    const mod1 = modifierCode.one.get(attr(tag, "ModifierOneID")) ?? "00";
    const mod2 = modifierCode.two.get(attr(tag, "ModifierTwoID")) ?? "00";
    const deltaSIDC = `1003${setCode}0000${entity}${mod1}${mod2}`;
    const label = (attr(tag, "ID") ?? "").replaceAll("_SYM", "").replaceAll("_", " ");
    rows.push(
      `"${pattern}",${setCode},${entity},${mod1},${mod2},${deltaSIDC},"${label}"`);
  }
}

writeFileSync(args.out,
  "charlie_pattern,delta_set,delta_entity,delta_mod1,delta_mod2,delta_sidc,label\n" +
  rows.join("\n") + "\n");
console.log(`Wrote ${rows.length} crosswalk rows from ${files} symbol sets to ${args.out}`);
