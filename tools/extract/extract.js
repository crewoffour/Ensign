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
function isInstructionPrefix(prefix, full) {
  if (prefix.length > full.length) return false;
  for (let i = 0; i < prefix.length; i += 1) {
    if (JSON.stringify(prefix[i]) !== JSON.stringify(full[i])) return false;
  }
  return true;
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
    // Symbols milsymbol itself renders unframed (sea own track:
    // metadata.frame false) have no frame instructions to subtract;
    // the full build IS the icon, and Ensign reproduces milsymbol's
    // unframed rendering by construction.
    const fullOptions = { size: 100, infoFields: false };
    if (args.standard) fullOptions.standard = args.standard;
    const full = new ms.Symbol(sidc, fullOptions);
    const metadata = full.getMetadata();

    let iconInstructions;
    let frameInstructionCount;
    if (metadata.frame === false) {
      iconInstructions = full.drawInstructions;
      frameInstructionCount = 0;
    } else {
      const frameOnly = new ms.Symbol(sidc, { ...fullOptions, icon: false });
      if (!isInstructionPrefix(frameOnly.drawInstructions, full.drawInstructions)) {
        const error = new Error(
          "frame-only instructions are not a prefix of the full " +
          "instructions; the SIDC likely carries modifiers drawn after " +
          "the icon, which icon extraction does not support yet"
        );
        error.diagnostics = {
          frameOnlyInstructions: frameOnly.drawInstructions,
          fullInstructions: full.drawInstructions,
        };
        throw error;
      }
      iconInstructions = full.drawInstructions.slice(frameOnly.drawInstructions.length);
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