// Copyright 2026 Jason Griffin
// Licensed under the Apache License, Version 2.0. See LICENSE.
//
// Extracts milsymbol's internal draw instructions for a list of SIDCs
// and writes them to JSON. This JSON is the input to the Swift code
// generator and the ground truth for what milsymbol draws.
//
// milsymbol builds symbol.drawInstructions at construction time (see
// src/ms/symbol/setoptions.js in milsymbol 3.0.4): an array of plain
// objects of type path/circle/text/svg/translate/rotate/scale/clip in
// 200x200 canvas coordinates. We serialize that array untouched, along
// with the metadata, colors, bbox, and anchors needed downstream.
//
// Usage:
//   node extract.js [--sidcs sidcs-frames.txt] [--out out/extracted.json]
//                   [--no-icon] [--no-frame] [--no-fill] [--standard 2525]

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { parseArgs } from "node:util";
import ms from "milsymbol";

const { values: args } = parseArgs({
  options: {
    sidcs: { type: "string", default: "sidcs-frames.txt" },
    out: { type: "string", default: "out/extracted.json" },
    "icon-extract": { type: "boolean", default: false },
    "no-icon": { type: "boolean", default: false },
    "no-frame": { type: "boolean", default: false },
    "no-fill": { type: "boolean", default: false },
    standard: { type: "string", default: "" },
  },
});

function readSidcList(path) {
  return readFileSync(path, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"));
}

function symbolOptions() {
  const options = {
    size: 100, // 1 canvas unit = 1 SVG unit; keeps coordinates native
    infoFields: false,
  };
  if (args["no-icon"]) options.icon = false;
  if (args["no-frame"]) options.frame = false;
  if (args["no-fill"]) options.fill = false;
  if (args.standard) options.standard = args.standard;
  return options;
}

// Deep-equal prefix check over plain-data instruction arrays. Both
// arrays come from identical construction code paths, so JSON key
// order is stable and stringify comparison is sound.
// Splits the full build as prefix + icon + suffix, where the
// frame-only build must equal exactly prefix + suffix. Fails loudly
// with both instruction arrays and the matched lengths otherwise.
function subtractPrefixAndSuffix(frameOnly, full) {
  const key = (instruction) => JSON.stringify(instruction);
  let prefix = 0;
  while (
    prefix < frameOnly.length &&
    prefix < full.length &&
    key(frameOnly[prefix]) === key(full[prefix])
  ) {
    prefix += 1;
  }
  let suffix = 0;
  while (
    suffix < frameOnly.length - prefix &&
    suffix < full.length - prefix &&
    key(frameOnly[frameOnly.length - 1 - suffix]) === key(full[full.length - 1 - suffix])
  ) {
    suffix += 1;
  }
  if (prefix + suffix !== frameOnly.length) {
    const error = new Error(
      "frame-only instructions are not a prefix plus suffix of the " +
      "full instructions; the icon cannot be isolated by subtraction"
    );
    error.diagnostics = {
      matchedPrefix: prefix,
      matchedSuffix: suffix,
      frameOnlyInstructions: frameOnly,
      fullInstructions: full,
    };
    throw error;
  }
  return full.slice(prefix, full.length - suffix);
}

function extractOne(sidc) {
  if (args["icon-extract"]) {
    // Icon extraction by subtraction: build the symbol twice with the
    // reference renderer's own options (full, and icon:false), verify
    // the frame-only instructions are a strict prefix of the full
    // instructions, and take the remainder as the icon. Because the
    // full symbol is built with default frame and fill options, the
    // concrete colors in the icon instructions are exactly the colors
    // a reference render uses; no option-dependent color distortion
    // can creep in.
    //
    // The frame-only build equals a prefix of the full build (the
    // frame and pre-icon parts) plus a suffix (modifiers drawn after
    // the icon: installation bars, condition bars); the icon is the
    // middle. Symbols milsymbol renders unframed (sea own track)
    // simply have an empty prefix, and the same split applies.
    const fullOptions = { size: 100, infoFields: false };
    if (args.standard) fullOptions.standard = args.standard;
    const full = new ms.Symbol(sidc, fullOptions);
    const metadata = full.getMetadata();

    let iconInstructions;
    let frameInstructionCount;
    if (metadata.frame === false) {
      // Unframed symbols: the full build is the icon (established in
      // Session 4; their frame-only builds are not inspected here).
      iconInstructions = full.drawInstructions;
      frameInstructionCount = 0;
    } else {
      const frameOnly = new ms.Symbol(sidc, { ...fullOptions, icon: false });
      iconInstructions = subtractPrefixAndSuffix(
        frameOnly.drawInstructions, full.drawInstructions);
      frameInstructionCount = frameOnly.drawInstructions.length;
    }

    return {
      sidc,
      valid: full.isValid(),
      validIcon: full.validIcon,
      unframed: metadata.frame === false,
      bbox: { x1: full.bbox.x1, y1: full.bbox.y1, x2: full.bbox.x2, y2: full.bbox.y2 },
      anchor: full.getAnchor(),
      octagonAnchor: full.getOctagonAnchor(),
      metadata: metadataSubset(metadata),
      colors: full.getColors(),
      frameInstructionCount,
      drawInstructions: iconInstructions,
    };
  }

  const symbol = new ms.Symbol(sidc, symbolOptions());
  const metadata = symbol.getMetadata();
  return {
    sidc,
    valid: symbol.isValid(),
    validIcon: symbol.validIcon,
    bbox: {
      x1: symbol.bbox.x1,
      y1: symbol.bbox.y1,
      x2: symbol.bbox.x2,
      y2: symbol.bbox.y2,
    },
    anchor: symbol.getAnchor(),
    octagonAnchor: symbol.getOctagonAnchor(),
    metadata: metadataSubset(metadata),
    colors: symbol.getColors(),
    drawInstructions: symbol.drawInstructions,
  };
}

function metadataSubset(metadata) {
  return {
    affiliation: metadata.affiliation,
    baseAffilation: metadata.baseAffilation,
    baseDimension: metadata.baseDimension,
    dimension: metadata.dimension,
    context: metadata.context,
    condition: metadata.condition,
    civilian: metadata.civilian,
    activity: metadata.activity,
    installation: metadata.installation,
    space: metadata.space,
    joker: metadata.joker,
    faker: metadata.faker,
    suspect: metadata.suspect,
    notpresent: metadata.notpresent,
    functionid: metadata.functionid,
    frame: metadata.frame,
    fill: metadata.fill,
    headquarters: metadata.headquarters,
    taskForce: metadata.taskForce,
    fenintDummy: metadata.fenintDummy,
    echelon: metadata.echelon,
    mobility: metadata.mobility,
    numberSIDC: metadata.numberSIDC,
  };
}

function main() {
  const sidcs = readSidcList(args.sidcs);
  console.log(`Extracting ${sidcs.length} SIDCs with milsymbol ${ms.getVersion()}`);

  const symbols = [];
  const failures = [];
  for (const sidc of sidcs) {
    try {
      symbols.push(extractOne(sidc));
    } catch (error) {
      const failure = { sidc, error: String(error) };
      if (error.diagnostics) failure.diagnostics = error.diagnostics;
      failures.push(failure);
      console.error(`FAILED ${sidc}: ${error}`);
    }
  }

  const output = {
    generator: "ensign-extract",
    milsymbolVersion: ms.getVersion(),
    generated: new Date().toISOString(),
    options: args["icon-extract"]
      ? { size: 100, infoFields: false, iconExtraction: true,
          ...(args.standard ? { standard: args.standard } : {}) }
      : symbolOptions(),
    dashArrays: ms.getDashArrays(),
    hqStaffLength: ms.getHqStaffLength(),
    symbolCount: symbols.length,
    failureCount: failures.length,
    failures,
    symbols,
  };

  mkdirSync(dirname(args.out), { recursive: true });
  writeFileSync(args.out, JSON.stringify(output, null, 2));
  console.log(`Wrote ${symbols.length} symbols to ${args.out}` +
    (failures.length ? ` (${failures.length} failures)` : ""));
  if (failures.length > 0) process.exitCode = 1;
}

main();