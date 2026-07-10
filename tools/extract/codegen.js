// Copyright 2026 Jason Griffin
// Licensed under the Apache License, Version 2.0. See LICENSE.
//
// Generates Sources/EnsignCore/Generated/GeneratedIcons.swift from
// icon-only milsymbol extraction output.
//
// Inputs:
//   1. icons.json produced by:
//        node extract.js --sidcs <list> --icon-extract --out out/icons.json
//      (icon instructions isolated by prefix subtraction against a
//      frame-only build, so concrete colors match a reference render
//      by construction)
//   2. iconkeys.tsv produced by:
//        swift run ensign-catalog keys <list> > out/iconkeys.tsv
//      (sidc TAB family TAB code TAB base; Ensign's own IconKey and
//      frame base derivation)
//
// What it does per icon:
//   - flattens translate/rotate/scale containers into absolute
//     coordinates (uniform scale also scales stroke widths)
//   - converts text instructions to outline paths with opentype.js
//     and the pinned fonts in fonts/ (only needed when text appears)
//   - parses SVG path data (M L H V C S Q T A Z, absolute and
//     relative); arcs become cubic Bezier approximations
//   - maps concrete milsymbol colors back to Ensign ColorRole values
//     using the per-symbol color tables, failing loudly on anything
//     unrecognized
//   - deduplicates by icon key, verifying that SIDCs sharing a key
//     extracted identical geometry
//
// Usage:
//   node codegen.js [--icons out/icons.json] [--keys out/iconkeys.tsv]
//                   [--out ../../Sources/EnsignCore/Generated/GeneratedIcons.swift]
//                   [--font-regular fonts/LiberationSans-Regular.ttf]
//                   [--font-bold fonts/LiberationSans-Bold.ttf]

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, unlinkSync } from "node:fs";
import { dirname, join } from "node:path";
import { parseArgs } from "node:util";
import opentype from "opentype.js";

const { values: args } = parseArgs({
  options: {
    icons: { type: "string", default: "out/icons.json" },
    keys: { type: "string", default: "out/iconkeys.tsv" },
    out: { type: "string", default: "../../Sources/EnsignCore/Generated/GeneratedIcons.swift" },
    "font-regular": { type: "string", default: "fonts/LiberationSans-Regular.ttf" },
    "font-bold": { type: "string", default: "fonts/LiberationSans-Bold.ttf" },
  },
});

// ---------------------------------------------------------------------------
// Problem collection: gather everything, then fail once with the full list.

const problems = [];
function problem(sidc, message) {
  problems.push(`${sidc}: ${message}`);
}

// ---------------------------------------------------------------------------
// Fonts, loaded lazily on the first text instruction.

const fonts = {};
function font(weight) {
  const key = weight === "bold" ? "bold" : "regular";
  if (!fonts[key]) {
    const path = key === "bold" ? args["font-bold"] : args["font-regular"];
    if (!existsSync(path)) {
      throw new Error(
        `Text instruction encountered but no ${key} font at ${path}.\n` +
        `Download Liberation Sans (SIL OFL) from ` +
        `https://github.com/liberationfonts/liberation-fonts/releases ` +
        `and place the TTFs in fonts/, or pass --font-${key}.`
      );
    }
    fonts[key] = opentype.loadSync(path);
  }
  return fonts[key];
}

// ---------------------------------------------------------------------------
// Affine transforms. Matrix is [a, b, c, d, e, f] as in SVG:
//   x' = a*x + c*y + e
//   y' = b*x + d*y + f

const IDENTITY = [1, 0, 0, 1, 0, 0];

function multiply(m, n) {
  return [
    m[0] * n[0] + m[2] * n[1],
    m[1] * n[0] + m[3] * n[1],
    m[0] * n[2] + m[2] * n[3],
    m[1] * n[2] + m[3] * n[3],
    m[0] * n[4] + m[2] * n[5] + m[4],
    m[1] * n[4] + m[3] * n[5] + m[5],
  ];
}

function translated(m, x, y) {
  return multiply(m, [1, 0, 0, 1, x, y]);
}

function scaled(m, factor) {
  return multiply(m, [factor, 0, 0, factor, 0, 0]);
}

function rotated(m, degrees, cx, cy) {
  const r = (degrees * Math.PI) / 180;
  const cos = Math.cos(r);
  const sin = Math.sin(r);
  let out = translated(m, cx, cy);
  out = multiply(out, [cos, sin, -sin, cos, 0, 0]);
  return translated(out, -cx, -cy);
}

function apply(m, x, y) {
  return [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]];
}

function uniformScaleOf(m) {
  // milsymbol only composes translate/rotate/uniform-scale, so the
  // linear part should be a rotation times a scalar. Verify.
  const sx = Math.hypot(m[0], m[1]);
  const sy = Math.hypot(m[2], m[3]);
  if (Math.abs(sx - sy) > 1e-6) return null;
  return sx;
}

// ---------------------------------------------------------------------------
// SVG path data parsing to absolute segment lists.
// Segments: {t:"M"|"L"|"C"|"Q", pts:[...]} and {t:"Z"}.

function tokenizePath(d) {
  const tokens = d.match(/[a-df-zA-DF-Z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?/g);
  return tokens ?? [];
}

function parsePath(d, sidc) {
  const tokens = tokenizePath(d);
  const segments = [];
  let i = 0;
  let command = null;
  let cx = 0, cy = 0;          // current point
  let sx = 0, sy = 0;          // subpath start
  let pcx = null, pcy = null;  // previous cubic control (for S)
  let pqx = null, pqy = null;  // previous quad control (for T)

  const isCommand = (token) => /^[a-zA-Z]$/.test(token);
  function num() {
    const value = Number.parseFloat(tokens[i]);
    i += 1;
    if (!Number.isFinite(value)) {
      throw new Error(`bad number in path data near index ${i}`);
    }
    return value;
  }

  while (i < tokens.length) {
    if (isCommand(tokens[i])) {
      command = tokens[i];
      i += 1;
      if (command === "Z" || command === "z") {
        segments.push({ t: "Z" });
        cx = sx; cy = sy;
        pcx = pcy = pqx = pqy = null;
        continue;
      }
    }
    if (command === null) throw new Error("path data does not start with a command");
    const relative = command === command.toLowerCase();
    const op = command.toUpperCase();

    switch (op) {
      case "M": {
        let x = num(), y = num();
        if (relative) { x += cx; y += cy; }
        segments.push({ t: "M", pts: [x, y] });
        cx = x; cy = y; sx = x; sy = y;
        // Subsequent coordinate pairs are implicit linetos.
        command = relative ? "l" : "L";
        pcx = pcy = pqx = pqy = null;
        break;
      }
      case "L": {
        let x = num(), y = num();
        if (relative) { x += cx; y += cy; }
        segments.push({ t: "L", pts: [x, y] });
        cx = x; cy = y;
        pcx = pcy = pqx = pqy = null;
        break;
      }
      case "H": {
        let x = num();
        if (relative) x += cx;
        segments.push({ t: "L", pts: [x, cy] });
        cx = x;
        pcx = pcy = pqx = pqy = null;
        break;
      }
      case "V": {
        let y = num();
        if (relative) y += cy;
        segments.push({ t: "L", pts: [cx, y] });
        cy = y;
        pcx = pcy = pqx = pqy = null;
        break;
      }
      case "C": {
        let x1 = num(), y1 = num(), x2 = num(), y2 = num(), x = num(), y = num();
        if (relative) { x1 += cx; y1 += cy; x2 += cx; y2 += cy; x += cx; y += cy; }
        segments.push({ t: "C", pts: [x1, y1, x2, y2, x, y] });
        pcx = x2; pcy = y2; pqx = pqy = null;
        cx = x; cy = y;
        break;
      }
      case "S": {
        let x2 = num(), y2 = num(), x = num(), y = num();
        if (relative) { x2 += cx; y2 += cy; x += cx; y += cy; }
        const x1 = pcx !== null ? 2 * cx - pcx : cx;
        const y1 = pcy !== null ? 2 * cy - pcy : cy;
        segments.push({ t: "C", pts: [x1, y1, x2, y2, x, y] });
        pcx = x2; pcy = y2; pqx = pqy = null;
        cx = x; cy = y;
        break;
      }
      case "Q": {
        let x1 = num(), y1 = num(), x = num(), y = num();
        if (relative) { x1 += cx; y1 += cy; x += cx; y += cy; }
        segments.push({ t: "Q", pts: [x1, y1, x, y] });
        pqx = x1; pqy = y1; pcx = pcy = null;
        cx = x; cy = y;
        break;
      }
      case "T": {
        let x = num(), y = num();
        if (relative) { x += cx; y += cy; }
        const x1 = pqx !== null ? 2 * cx - pqx : cx;
        const y1 = pqy !== null ? 2 * cy - pqy : cy;
        segments.push({ t: "Q", pts: [x1, y1, x, y] });
        pqx = x1; pqy = y1; pcx = pcy = null;
        cx = x; cy = y;
        break;
      }
      case "A": {
        const rx = num(), ry = num(), rotation = num();
        const largeArc = num(), sweep = num();
        let x = num(), y = num();
        if (relative) { x += cx; y += cy; }
        for (const cubic of arcToCubics(cx, cy, rx, ry, rotation, largeArc, sweep, x, y)) {
          segments.push({ t: "C", pts: cubic });
        }
        pcx = pcy = pqx = pqy = null;
        cx = x; cy = y;
        break;
      }
      default:
        throw new Error(`unsupported path command ${command}`);
    }
  }
  return segments;
}

// SVG endpoint arc to center parameterization (SVG spec F.6.5), then
// cubic approximation per <= 90 degree slice.
function arcToCubics(x1, y1, rx, ry, rotationDeg, largeArc, sweep, x2, y2) {
  if (rx === 0 || ry === 0 || (x1 === x2 && y1 === y2)) {
    return [[x1, y1, x2, y2, x2, y2]];
  }
  rx = Math.abs(rx); ry = Math.abs(ry);
  const phi = (rotationDeg * Math.PI) / 180;
  const cosPhi = Math.cos(phi), sinPhi = Math.sin(phi);

  const dx = (x1 - x2) / 2, dy = (y1 - y2) / 2;
  const x1p = cosPhi * dx + sinPhi * dy;
  const y1p = -sinPhi * dx + cosPhi * dy;

  const lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
  if (lambda > 1) {
    const s = Math.sqrt(lambda);
    rx *= s; ry *= s;
  }

  const sign = largeArc !== sweep ? 1 : -1;
  const numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p;
  const denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p;
  const coefficient = sign * Math.sqrt(Math.max(0, numerator / denominator));
  const cxp = coefficient * (rx * y1p) / ry;
  const cyp = coefficient * (-ry * x1p) / rx;

  const cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2;
  const cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2;

  function angle(ux, uy, vx, vy) {
    const dot = ux * vx + uy * vy;
    const len = Math.hypot(ux, uy) * Math.hypot(vx, vy);
    let a = Math.acos(Math.min(1, Math.max(-1, dot / len)));
    if (ux * vy - uy * vx < 0) a = -a;
    return a;
  }

  const theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
  let deltaTheta = angle(
    (x1p - cxp) / rx, (y1p - cyp) / ry,
    (-x1p - cxp) / rx, (-y1p - cyp) / ry
  );
  if (!sweep && deltaTheta > 0) deltaTheta -= 2 * Math.PI;
  if (sweep && deltaTheta < 0) deltaTheta += 2 * Math.PI;

  const slices = Math.max(1, Math.ceil(Math.abs(deltaTheta) / (Math.PI / 2)));
  const delta = deltaTheta / slices;
  const k = (4 / 3) * Math.tan(delta / 4);

  function pointAt(theta) {
    const px = rx * Math.cos(theta), py = ry * Math.sin(theta);
    return [
      cosPhi * px - sinPhi * py + cx,
      sinPhi * px + cosPhi * py + cy,
    ];
  }
  function derivativeAt(theta) {
    const px = -rx * Math.sin(theta), py = ry * Math.cos(theta);
    return [cosPhi * px - sinPhi * py, sinPhi * px + cosPhi * py];
  }

  const cubics = [];
  let theta = theta1;
  let [px, py] = pointAt(theta);
  for (let slice = 0; slice < slices; slice += 1) {
    const thetaNext = theta + delta;
    const [nx, ny] = pointAt(thetaNext);
    const [d1x, d1y] = derivativeAt(theta);
    const [d2x, d2y] = derivativeAt(thetaNext);
    cubics.push([
      px + k * d1x, py + k * d1y,
      nx - k * d2x, ny - k * d2y,
      nx, ny,
    ]);
    theta = thetaNext;
    px = nx; py = ny;
  }
  return cubics;
}

function transformSegments(segments, m) {
  return segments.map((segment) => {
    if (segment.t === "Z") return segment;
    const pts = [];
    for (let i = 0; i < segment.pts.length; i += 2) {
      const [x, y] = apply(m, segment.pts[i], segment.pts[i + 1]);
      pts.push(x, y);
    }
    return { t: segment.t, pts };
  });
}

// ---------------------------------------------------------------------------
// Color to role mapping.

function normalizeColor(value) {
  if (value === false || value === undefined || value === null) return null;
  let v = String(value).toLowerCase().replace(/\s+/g, "");
  if (v === "none") return null;
  const hex = v.match(/^#([0-9a-f]{6})$/);
  if (hex) {
    const n = Number.parseInt(hex[1], 16);
    v = `rgb(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255})`;
  }
  const hex3 = v.match(/^#([0-9a-f]{3})$/);
  if (hex3) {
    const [r, g, b] = hex3[1].split("").map((c) => Number.parseInt(c + c, 16));
    v = `rgb(${r},${g},${b})`;
  }
  if (v === "black") v = "rgb(0,0,0)";
  // Named CSS colors appearing in milsymbol's tables.
  const named = {
    red: "rgb(255,0,0)", green: "rgb(0,128,0)", blue: "rgb(0,0,255)",
    yellow: "rgb(255,255,0)", orange: "rgb(255,165,0)",
    magenta: "rgb(255,0,255)", cyan: "rgb(0,255,255)",
  };
  if (named[v]) v = named[v];
  if (v === "white") v = "rgb(255,255,255)";
  return v;
}

// Builds the concrete-color to role table for one symbol using its own
// extracted color tables and affiliation.
function roleTable(symbol) {
  const affiliation = symbol.metadata.affiliation;
  const colors = symbol.colors ?? {};
  const table = new Map();
  const put = (value, role) => {
    const normalized = normalizeColor(value);
    if (normalized && !table.has(normalized)) table.set(normalized, role);
  };
  // Order matters: first entry wins for identical concrete colors.
  // iconColor is the icon linework (black). fillColor is the
  // affiliation fill. iconFillColor is context-dependent in milsymbol:
  // on framed symbols its concrete value is the light hollow-interior
  // color that reads against the affiliation fill (Ensign's contrast
  // role); on unframed symbols (sea own track) there is no colored
  // frame, so iconFillColor carries the affiliation color itself and
  // the icon wears the affiliation (Ensign's affiliationFill role,
  // which also keeps unframed icons palette-aware). When iconFillColor
  // happens to equal fillColor, the earlier affiliationFill entry
  // wins, which renders identically.
  // Unfilled symbols (metadata.fill false: mine warfare) color their
  // linework with the saturated affiliation set instead of black and
  // the pastels; those concrete colors map to the affiliationColor
  // role so palettes stay in charge.
  const filled = symbol.metadata?.fill !== false;
  put(colors.iconColor?.[affiliation], filled ? "icon" : "affiliationColor");
  put(colors.fillColor?.[affiliation], "affiliationFill");
  put(colors.iconFillColor?.[affiliation],
    symbol.unframed ? "affiliationFill" : "contrastFill");
  put(colors.white?.[affiliation], "contrastFill");
  put(colors.frameColor?.[affiliation], filled ? "frameStroke" : "affiliationColor");
  put("black", "icon");
  put("white", "contrastFill");
  return table;
}

function fillRole(value, table, sidc, context) {
  if (value === false) return ".none";
  const normalized = normalizeColor(value === undefined ? "black" : value);
  if (normalized === null) return ".none";
  const role = table.get(normalized);
  if (!role) {
    return literalRole(normalized, value, sidc, context);
  }
  return role === "icon" ? ".iconFill" : `.${role}`;
}

function strokeRole(value, table, sidc, context) {
  if (value === undefined || value === false) return ".none";
  const normalized = normalizeColor(value);
  if (normalized === null) return ".none";
  const role = table.get(normalized);
  if (!role) {
    return literalRole(normalized, value, sidc, context);
  }
  return role === "icon" ? ".iconStroke" : `.${role}`;
}

// Colors outside the role tables are fixed, palette-independent icon
// colors (mine warfare red, per MEDAL coloring). They emit as
// literals, noted so eyes stay on them: an affiliation-dependent
// color wrongly landing here would break per-base deduplication and
// surface there and in the oracle.
function literalRole(normalized, value, sidc, context) {
  const rgb = normalized.match(/^rgb\((\d+),(\d+),(\d+)\)$/);
  if (!rgb) {
    problem(sidc, `unmapped, unparseable color "${value}" on ${context}`);
    return ".none";
  }
  console.warn(`NOTE ${sidc}: literal color ${normalized} on ${context}`);
  return `.literal(.rgb255(${rgb[1]}, ${rgb[2]}, ${rgb[3]}))`;
}

// ---------------------------------------------------------------------------
// Instruction flattening: containers to a flat list of primitive
// drawables with accumulated transforms.

function flatten(instructions, m, out, sidc, strokeScale) {
  for (const instruction of instructions ?? []) {
    if (Array.isArray(instruction)) {
      flatten(instruction, m, out, sidc, strokeScale);
      continue;
    }
    if (!instruction || typeof instruction !== "object") continue;
    switch (instruction.type) {
      case "translate":
        flatten(instruction.draw, translated(m, instruction.x ?? 0, instruction.y ?? 0), out, sidc, strokeScale);
        break;
      case "scale": {
        const factor = instruction.factor ?? 1;
        flatten(instruction.draw, scaled(m, factor), out, sidc, strokeScale * factor);
        break;
      }
      case "rotate":
        flatten(
          instruction.draw,
          rotated(m, instruction.degree ?? 0, instruction.x ?? 100, instruction.y ?? 100),
          out, sidc, strokeScale
        );
        break;
      case "path":
      case "circle":
      case "text":
        out.push({ instruction, m, strokeScale });
        break;
      case "svg":
        problem(sidc, "raw svg instruction is not supported by codegen");
        break;
      case "clip":
        problem(sidc, "clip instruction is not supported by codegen yet");
        break;
      default:
        problem(sidc, `unknown instruction type "${instruction.type}"`);
    }
    if (instruction.clipPath) {
      problem(sidc, `inline clipPath on ${instruction.type} is not supported yet`);
    }
  }
}

// ---------------------------------------------------------------------------
// Swift emission.

function num(value) {
  const rounded = Math.round(value * 1e6) / 1e6;
  let s = String(rounded);
  if (s.includes("e") || s.includes("E")) s = rounded.toFixed(6);
  if (Object.is(rounded, -0)) s = "0";
  return s;
}

function emitSegments(segments) {
  const parts = [];
  for (const segment of segments) {
    switch (segment.t) {
      case "M":
        parts.push(`.move(to: SymbolPoint(${num(segment.pts[0])}, ${num(segment.pts[1])}))`);
        break;
      case "L":
        parts.push(`.line(to: SymbolPoint(${num(segment.pts[0])}, ${num(segment.pts[1])}))`);
        break;
      case "C":
        parts.push(
          `.curve(to: SymbolPoint(${num(segment.pts[4])}, ${num(segment.pts[5])}), ` +
          `control1: SymbolPoint(${num(segment.pts[0])}, ${num(segment.pts[1])}), ` +
          `control2: SymbolPoint(${num(segment.pts[2])}, ${num(segment.pts[3])}))`
        );
        break;
      case "Q":
        parts.push(
          `.quadCurve(to: SymbolPoint(${num(segment.pts[2])}, ${num(segment.pts[3])}), ` +
          `control: SymbolPoint(${num(segment.pts[0])}, ${num(segment.pts[1])}))`
        );
        break;
      case "Z":
        parts.push(".close");
        break;
    }
  }
  return parts;
}

function emitStyle(fill, stroke, strokeWidth, dash) {
  const dashText = dash
    ? `[${dash.map((n) => num(n)).join(", ")}]`
    : "nil";
  return `DrawStyle(fill: ${fill}, stroke: ${stroke}, ` +
    `strokeWidth: ${num(strokeWidth)}, dash: ${dashText})`;
}

function parseDash(value) {
  if (value === undefined || value === false || value === null) return null;
  const parts = String(value).split(/[\s,]+/).map(Number.parseFloat);
  return parts.every(Number.isFinite) && parts.length > 0 ? parts : null;
}

// Converts one flattened drawable to Swift DrawInstruction source.
function emitDrawable(drawable, table, sidc, defaultStrokeWidth) {
  const { instruction, m, strokeScale } = drawable;
  const context = instruction.type;
  const dash = parseDash(instruction.strokedasharray);
  const width = (instruction.strokewidth ?? defaultStrokeWidth) * strokeScale;
  const fill = fillRole(instruction.fill, table, sidc, context);
  const stroke = strokeRole(instruction.stroke, table, sidc, context);
  const effectiveWidth = stroke === ".none" ? 0 : width;

  if (instruction.type === "circle") {
    const scale = uniformScaleOf(m);
    if (scale === null) {
      problem(sidc, "circle under non-uniform transform");
      return null;
    }
    const [cx, cy] = apply(m, instruction.cx, instruction.cy);
    const r = instruction.r * scale;
    return `.circle(center: SymbolPoint(${num(cx)}, ${num(cy)}), ` +
      `radius: ${num(r)}, style: ${emitStyle(fill, stroke, effectiveWidth, dash)})`;
  }

  let d;
  if (instruction.type === "text") {
    d = textToPathData(instruction, sidc);
    if (d === null) return null;
  } else {
    d = instruction.d;
  }

  // Instructions with no path data draw nothing in milsymbol either:
  // skip them with a note. Non-empty data that parses to zero
  // segments would be a silent drop and is a problem instead.
  if (d === undefined || d === null || String(d).trim() === "") {
    console.warn(`NOTE ${sidc}: instruction with empty path data skipped`);
    return null;
  }

  let segments;
  try {
    segments = parsePath(d, sidc);
  } catch (error) {
    problem(sidc, `path parse failed: ${error.message}`);
    return null;
  }
  segments = transformSegments(segments, m);
  if (segments.length === 0) {
    problem(sidc, `non-empty path data parsed to zero segments: "${d}"`);
    return null;
  }
  const swiftSegments = emitSegments(segments);
  return `.path(SymbolPath(segments: [\n            ` +
    swiftSegments.join(",\n            ") +
    `,\n        ], style: ${emitStyle(fill, stroke, effectiveWidth, dash)}))`;
}

// Vertical adjustment for alignment-baseline values, in text-space
// units (positive moves the baseline down, SVG y-down). Per SVG,
// "middle" sits the baseline half the x-height below the alignment
// point; "central" uses the center of the em box.
function baselineShift(instruction, face, size, sidc) {
  const value = instruction.alignmentBaseline;
  if (!value || value === "alphabetic" || value === "baseline") return 0;
  const scale = size / face.unitsPerEm;
  if (value === "middle") {
    let xHeight = face.tables?.os2?.sxHeight;
    if (!Number.isFinite(xHeight) || xHeight <= 0) {
      xHeight = face.charToGlyph("x")?.getMetrics?.().yMax ?? face.ascender * 0.5;
    }
    return (xHeight / 2) * scale;
  }
  if (value === "central") {
    return ((face.ascender + face.descender) / 2) * scale;
  }
  problem(sidc, `text with alignmentBaseline "${value}" not supported yet`);
  return null;
}

function textToPathData(instruction, sidc) {
  const face = font(instruction.fontweight === "bold" ? "bold" : "regular");
  const text = String(instruction.text ?? "");
  // Fontsize occasionally arrives as a numeric string in milsymbol's
  // hand-written tables; coerce leniently. Genuinely unparseable text
  // skips with a note (flowing into the empty-icon guard when it was
  // the icon's only drawable) rather than aborting the whole corpus;
  // the oracle stage surfaces what such icons lose.
  const size = Number.parseFloat(instruction.fontsize);
  if (!Number.isFinite(size) || size <= 0) {
    console.warn(
      `NOTE ${sidc}: text instruction with unparseable fontsize ` +
      `"${instruction.fontsize}" skipped`);
    return null;
  }
  const shift = baselineShift(instruction, face, size, sidc);
  if (shift === null) return null;
  let x = instruction.x;
  const anchor = instruction.textanchor ?? "start";
  if (anchor === "middle" || anchor === "end") {
    const advance = face.getAdvanceWidth(text, size);
    x -= anchor === "middle" ? advance / 2 : advance;
  }
  return face.getPath(text, x, instruction.y + shift, size).toPathData(6);
}

// ---------------------------------------------------------------------------
// Main.

function main() {
  const extracted = JSON.parse(readFileSync(args.icons, "utf8"));
  if (extracted.options?.iconExtraction !== true) {
    console.error(
      "The extraction JSON was not produced with icon subtraction, so " +
      "its concrete colors may not match a reference render. Re-run:\n" +
      "  node extract.js --sidcs <list> --icon-extract --out out/icons.json"
    );
    process.exit(2);
  }

  const keyRows = readFileSync(args.keys, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((line) => line.split("\t"));
  const keyBySidc = new Map();
  for (const [sidc, family, code, base] of keyRows) {
    if (sidc && family && code && base) keyBySidc.set(sidc, { family, code, base });
  }
  if (keyRows.length > 0 && keyBySidc.size === 0) {
    console.error(
      "The keys TSV has no 4-column rows (sidc, family, code, base).\n" +
      "Regenerate it with the current catalog:\n" +
      "  swift run ensign-catalog keys <list> > out/iconkeys.tsv"
    );
    process.exit(2);
  }

  const BASES = ["friend", "hostile", "neutral", "unknown"];
  const icons = new Map(); // "family:code" -> {family, code, variants: Map<base, {body, sidcs}>}
  let skippedInvalid = 0;

  for (const symbol of extracted.symbols) {
    const sidc = symbol.sidc;
    if (!symbol.validIcon) {
      skippedInvalid += 1;
      console.warn(`SKIP ${sidc}: milsymbol has no icon for this code (validIcon false)`);
      continue;
    }
    const key = keyBySidc.get(sidc);
    if (!key) {
      problem(sidc, "no icon key in the keys TSV (did the catalog keys run cover this list?)");
      continue;
    }
    if (!BASES.includes(key.base)) {
      problem(sidc, `unknown frame base "${key.base}" in the keys TSV`);
      continue;
    }

    const flat = [];
    flatten(symbol.drawInstructions, IDENTITY, flat, sidc, 1);
    if (flat.length === 0) {
      console.warn(`SKIP ${sidc}: icon-only extraction produced no drawables`);
      continue;
    }

    const table = roleTable(symbol);
    const emitted = [];
    for (const drawable of flat) {
      const swift = emitDrawable(drawable, table, sidc, 4);
      if (swift !== null) emitted.push(swift);
    }
    // An icon whose every instruction was skipped (empty path data in
    // milsymbol's table) draws nothing there and does not belong in
    // the library: lookup misses render frame-only, the same result.
    if (emitted.length === 0) {
      console.warn(`NOTE ${sidc}: no drawable instructions after conversion; icon skipped`);
      continue;
    }
    const body = emitted.join(",\n        ");

    const mapKey = `${key.family}:${key.code}`;
    let icon = icons.get(mapKey);
    if (!icon) {
      icon = { family: key.family, code: key.code, variants: new Map() };
      icons.set(mapKey, icon);
    }
    const variant = icon.variants.get(key.base);
    if (variant) {
      variant.sidcs.push(sidc);
      if (variant.body !== body) {
        problem(sidc,
          `icon key ${mapKey} extracted different geometry than ` +
          `${variant.sidcs[0]} under the same frame base (${key.base})`);
      }
    } else {
      icon.variants.set(key.base, { body, sidcs: [sidc] });
    }
  }

  if (problems.length > 0) {
    console.error(`\n${problems.length} problem(s); no Swift written:`);
    for (const entry of problems) console.error(`  ${entry}`);
    process.exit(1);
  }

  const sorted = [...icons.values()].sort((a, b) =>
    a.family === b.family ? a.code.localeCompare(b.code) : a.family.localeCompare(b.family)
  );

  // Icons shard by family plus the code's first two characters (the
  // delta symbol set; the charlie scheme and dimension): one generated
  // file per shard compiles in parallel and keeps incremental builds
  // incremental, plus a root file that assembles the registry.
  const shards = new Map();
  function shard(icon) {
    const key = `${icon.family}_${icon.code.slice(0, 2).replace(/[^A-Za-z0-9]/g, "_")}`;
    let bucket = shards.get(key);
    if (!bucket) {
      bucket = { key, functions: [], tableLines: [], count: 0 };
      shards.set(key, bucket);
    }
    return bucket;
  }

  let fullFrameCount = 0;
  for (const icon of sorted) {
    const bucket = shard(icon);
    bucket.count += 1;
    const baseName = `icon_${icon.family}_${icon.code.replace(/[^A-Za-z0-9]/g, "_")}`;
    const variants = [...icon.variants.entries()];
    const bodies = new Set(variants.map(([, variant]) => variant.body));
    const allSidcs = variants.flatMap(([, variant]) => variant.sidcs);

    if (bodies.size === 1) {
      // Identical under every extracted base: universal.
      bucket.tableLines.push(
        `        table[IconKey(family: .${icon.family}, code: "${icon.code}")] = ` +
        `.universal(${baseName}())`
      );
      bucket.functions.push(
        `    // ${allSidcs.join(", ")}\n` +
        `    private static func ${baseName}() -> [DrawInstruction] { [\n` +
        `        ${variants[0][1].body},\n` +
        `    ] }`
      );
    } else {
      // Full-frame icon: geometry differs per frame base.
      fullFrameCount += 1;
      const covered = BASES.filter((base) => icon.variants.has(base));
      const missing = BASES.filter((base) => !icon.variants.has(base));
      if (missing.length > 0) {
        console.warn(
          `NOTE ${icon.family}:${icon.code} is full-frame but the list only ` +
          `covered ${covered.join("/")}; ${missing.join("/")} will degrade to ` +
          `frame-and-fill until extracted`);
      }
      const entries = [];
      for (const base of covered) {
        const variant = icon.variants.get(base);
        const name = `${baseName}_${base}`;
        entries.push(`.${base}: ${name}()`);
        bucket.functions.push(
          `    // ${variant.sidcs.join(", ")}\n` +
          `    private static func ${name}() -> [DrawInstruction] { [\n` +
          `        ${variant.body},\n` +
          `    ] }`
        );
      }
      bucket.tableLines.push(
        `        table[IconKey(family: .${icon.family}, code: "${icon.code}")] = ` +
        `.perBase([${entries.join(", ")}])`
      );
    }
  }

  const license = `// Copyright 2026 Jason Griffin
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
// GENERATED FILE - do not edit by hand.
// Produced by tools/extract/codegen.js from milsymbol ${extracted.milsymbolVersion}
// draw instructions. Icon geometry data is ported from milsymbol
// (https://github.com/spatialillusions/milsymbol),
// Copyright (c) Mans Beckman, MIT License. See NOTICE.
`;

  const outDir = dirname(args.out);
  const iconsDir = join(outDir, "Icons");
  mkdirSync(iconsDir, { recursive: true });
  // Remove stale shards (and only shards) from prior runs.
  for (const name of readdirSync(iconsDir)) {
    if (/^GeneratedIcons\+.*\.swift$/.test(name)) unlinkSync(join(iconsDir, name));
  }

  const sortedShards = [...shards.values()].sort((a, b) => a.key.localeCompare(b.key));
  for (const bucket of sortedShards) {
    const swift = license +
      `\nextension IconLibrary {\n` +
      `    /// ${bucket.count} icons.\n` +
      `    static func registerGenerated_${bucket.key}(into table: inout [IconKey: IconEntry]) {\n` +
      `${bucket.tableLines.join("\n")}\n` +
      `    }\n\n` +
      `${bucket.functions.join("\n\n")}\n` +
      `}\n`;
    writeFileSync(join(iconsDir, `GeneratedIcons+${bucket.key}.swift`), swift);
  }

  const rootSwift = license +
    `\nextension IconLibrary {\n` +
    `    /// The generated icon table: ${sorted.length} icons across ` +
    `${sortedShards.length} shards.\n` +
    `    static let generatedIcons: [IconKey: IconEntry] = {\n` +
    `        var table: [IconKey: IconEntry] = [:]\n` +
    `        table.reserveCapacity(${sorted.length})\n` +
    sortedShards.map((bucket) =>
      `        registerGenerated_${bucket.key}(into: &table)`).join("\n") + `\n` +
    `        return table\n` +
    `    }()\n` +
    `}\n`;
  writeFileSync(args.out, rootSwift);

  console.log(
    `Wrote ${sorted.length} icons to ${args.out} + ${sortedShards.length} ` +
    `shard files in ${iconsDir}` +
    (fullFrameCount ? ` (${fullFrameCount} full-frame with per-base variants)` : "") +
    (skippedInvalid ? ` (${skippedInvalid} skipped as validIcon false)` : "")
  );
}

main();