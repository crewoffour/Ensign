// bake-glyphs.js: bakes the exercise amplifier letter outlines (X, J,
// K, S) into Sources/EnsignCore/Generated/GeneratedExerciseGlyphs.swift.
//
// The conversion reproduces codegen.js's oracle-proven text handling
// exactly: Liberation Sans Bold, opentype getPath at the requested
// fontsize, with alignment-baseline "middle" as a baseline shift of
// half the x-height (from the OS/2 table, with the same fallbacks).
// Glyphs are authored relative to the text anchor (text-anchor start),
// so the composer translates them to the anchor point at compose time.
//
// Run from tools/extract:
//   node bake-glyphs.js [--out ../../Sources/EnsignCore/Generated/GeneratedExerciseGlyphs.swift]

import { writeFileSync } from "node:fs";
import { parseArgs } from "node:util";
import opentype from "opentype.js";

const { values: args } = parseArgs({
  options: {
    out: {
      type: "string",
      default: "../../Sources/EnsignCore/Generated/GeneratedExerciseGlyphs.swift",
    },
  },
});

const LETTERS = ["X", "J", "K", "S"];
const FONT_SIZE = 35;

const face = opentype.loadSync("fonts/LiberationSans-Bold.ttf");
const scale = FONT_SIZE / face.unitsPerEm;

// alignment-baseline "middle": baseline sits half the x-height below
// the alignment point (same rule and fallbacks as codegen.js).
let xHeight = face.tables?.os2?.sxHeight;
if (!Number.isFinite(xHeight) || xHeight <= 0) {
  xHeight = face.charToGlyph("x")?.getMetrics?.().yMax ?? face.ascender * 0.5;
}
const baselineShift = (xHeight / 2) * scale;

function round(value) {
  const rounded = Math.round(value * 1e6) / 1e6;
  return Object.is(rounded, -0) ? 0 : rounded;
}

function swiftPoint(x, y) {
  return `SymbolPoint(${round(x)}, ${round(y)})`;
}

function segmentsFor(letter) {
  const path = face.getPath(letter, 0, baselineShift, FONT_SIZE);
  const lines = [];
  for (const command of path.commands) {
    switch (command.type) {
      case "M":
        lines.push(`.move(to: ${swiftPoint(command.x, command.y)})`);
        break;
      case "L":
        lines.push(`.line(to: ${swiftPoint(command.x, command.y)})`);
        break;
      case "Q":
        lines.push(
          `.quadCurve(to: ${swiftPoint(command.x, command.y)}, ` +
          `control: ${swiftPoint(command.x1, command.y1)})`
        );
        break;
      case "C":
        lines.push(
          `.curve(to: ${swiftPoint(command.x, command.y)}, ` +
          `control1: ${swiftPoint(command.x1, command.y1)}, ` +
          `control2: ${swiftPoint(command.x2, command.y2)})`
        );
        break;
      case "Z":
        lines.push(".close");
        break;
      default:
        throw new Error(`unsupported path command ${command.type} in glyph ${letter}`);
    }
  }
  if (lines.length === 0) {
    throw new Error(`glyph ${letter} produced no path commands`);
  }
  return lines;
}

const glyphBlocks = LETTERS.map((letter) => {
  const body = segmentsFor(letter)
    .map((line) => `        ${line},`)
    .join("\n");
  return `    private static let glyph${letter}: [PathSegment] = [\n${body}\n    ]`;
}).join("\n\n");

const cases = LETTERS
  .map((letter) => `        case "${letter}": return glyph${letter}`)
  .join("\n");

const output = `// Copyright 2026 Jason Griffin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// GENERATED FILE, do not edit by hand. Regenerate with:
//   cd tools/extract && node bake-glyphs.js
// Exercise amplifier letter outlines from Liberation Sans Bold at
// fontsize ${FONT_SIZE}, authored relative to the text anchor
// (text-anchor start, alignment-baseline middle). Glyph outlines
// include data derived from the Liberation fonts under the SIL Open
// Font License; see NOTICE.

/// Baked outline geometry for the exercise amplifier letters.
public enum GeneratedExerciseGlyphs {
    /// Outline segments for an amplifier letter, relative to the text
    /// anchor, or \`nil\` for letters outside the amplifier set.
    public static func segments(for letter: Character) -> [PathSegment]? {
        switch letter {
${cases}
        default: return nil
        }
    }

${glyphBlocks}
}
`;

writeFileSync(args.out, output);
console.log(
  `Baked ${LETTERS.length} glyphs (${LETTERS.join(", ")}) at fontsize ` +
  `${FONT_SIZE}, baseline shift ${round(baselineShift)}, to ${args.out}`
);
