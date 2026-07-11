// Copyright 2026 Jason Griffin
// Licensed under the Apache License, Version 2.0. See LICENSE.
//
// Renders milsymbol reference PNGs for a list of SIDCs, on the full
// 200x200 canvas so they align 1:1 with Ensign's renders.
//
// milsymbol's asSVG() crops its viewBox to the symbol bounding box
// (see src/ms/symbol/assvg.js in milsymbol 3.0.4), but the SVG body is
// authored in raw canvas coordinates. Replacing the root element's
// width, height, and viewBox with the full canvas yields an uncropped
// render without touching the body.
//
// Usage:
//   node reference-render.js [--sidcs sidcs-frames.txt] [--out out/refs]
//                            [--pixels 200] [--no-icon] [--no-frame]
//                            [--no-fill] [--standard 2525]

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { Resvg } from "@resvg/resvg-js";
import ms from "milsymbol";

const CANVAS = 200;
const FONT_FILES = [
  "fonts/LiberationSans-Regular.ttf",
  "fonts/LiberationSans-Bold.ttf",
].filter((path) => existsSync(path));

const { values: args } = parseArgs({
  options: {
    sidcs: { type: "string", default: "sidcs-frames.txt" },
    out: { type: "string", default: "out/refs" },
    pixels: { type: "string", default: "200" },
    "no-icon": { type: "boolean", default: false },
    "no-frame": { type: "boolean", default: false },
    "no-fill": { type: "boolean", default: false },
    standard: { type: "string", default: "" },
    fields: { type: "string" },
  },
});

const pixels = Number.parseInt(args.pixels, 10);
if (!Number.isFinite(pixels) || pixels <= 0) {
  console.error(`Invalid --pixels value: ${args.pixels}`);
  process.exit(2);
}

function readSidcList(path) {
  return readFileSync(path, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"));
}

function symbolOptions() {
  const options = { size: 100, infoFields: false };
  if (args["no-icon"]) options.icon = false;
  if (args["no-frame"]) options.frame = false;
  if (args["no-fill"]) options.fill = false;
  if (args.standard) options.standard = args.standard;
  return options;
}

// Recursively checks for text instructions; the reference renderer
// loads no fonts, so text would rasterize inconsistently. Frame-level
// validation sets contain no text; icon-era sets will convert text to
// outlines during extraction instead.
function containsText(instructions) {
  for (const instruction of instructions ?? []) {
    if (Array.isArray(instruction)) {
      if (containsText(instruction)) return true;
    } else if (instruction && typeof instruction === "object") {
      if (instruction.type === "text") return true;
      if (instruction.draw && containsText(instruction.draw)) return true;
    }
  }
  return false;
}

function fullCanvasSVG(symbol) {
  const svg = symbol.asSVG();
  const bodyStart = svg.indexOf(">") + 1;
  const bodyEnd = svg.lastIndexOf("</svg>");
  let body = svg.slice(bodyStart, bodyEnd);
  if (FONT_FILES.length > 0) {
    // Pin every text element to the loaded reference font rather than
    // trusting family-name fallback; milsymbol emits Arial, and
    // Liberation Sans is its metric-compatible stand-in.
    body = body.replace(/font-family="[^"]*"/g, 'font-family="Liberation Sans"');
  }
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" version="1.2" ` +
    `baseProfile="tiny" width="${CANVAS}" height="${CANVAS}" ` +
    `viewBox="0 0 ${CANVAS} ${CANVAS}">` +
    body +
    `</svg>`
  );
}

function main() {
  const sidcs = readSidcList(args.sidcs);
  mkdirSync(args.out, { recursive: true });
  console.log(
    `Rendering ${sidcs.length} references at ${pixels}px ` +
    `with milsymbol ${ms.getVersion()}`
  );

  let rendered = 0;
  let withText = 0;
  const failures = [];
  if (FONT_FILES.length > 0) {
    console.log(`Reference fonts loaded: ${FONT_FILES.join(", ")}`);
  }
  for (const sidc of sidcs) {
    try {
      const symbol = new ms.Symbol(sidc, {
        ...symbolOptions(),
        ...(args.fields ? { infoFields: true, ...JSON.parse(args.fields) } : {}),
      });
      if (containsText(symbol.drawInstructions)) {
        withText += 1;
        if (FONT_FILES.length === 0) {
          console.warn(`TEXT ${sidc}: contains text instructions but no fonts ` +
            `in fonts/; the reference will render without the text ` +
            `(see README, Fonts section)`);
        }
      }
      // Info fields grow milsymbol's viewbox beyond the square
      // canvas; render the native SVG at the same pixels-per-canvas-
      // unit scale so dimensions match Ensign's grown-canvas output.
      let svg = fullCanvasSVG(symbol);
      let fitWidth = pixels;
      if (args.fields) {
        svg = symbol.asSVG();
        const viewBox = svg.match(/viewBox="([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+)"/);
        if (viewBox) {
          fitWidth = Math.round((Number(viewBox[3]) * pixels) / 200);
        }
      }
      const resvg = new Resvg(svg, {
        fitTo: { mode: "width", value: fitWidth },
        font: FONT_FILES.length > 0
          ? {
              loadSystemFonts: false,
              fontFiles: FONT_FILES,
              defaultFontFamily: "Liberation Sans",
            }
          : { loadSystemFonts: false },
      });
      const png = resvg.render().asPng();
      writeFileSync(join(args.out, `${sidc}.png`), png);
      rendered += 1;
    } catch (error) {
      failures.push(sidc);
      console.error(`FAILED ${sidc}: ${error}`);
    }
  }

  console.log(
    `Rendered ${rendered}/${sidcs.length} to ${args.out}` +
    (withText ? `; ${withText} contained text` : "") +
    (failures.length ? `; ${failures.length} failed` : "")
  );
  if (failures.length > 0) process.exitCode = 1;
}

main();