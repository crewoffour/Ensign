// Copyright 2026 Jason Griffin
// Licensed under the Apache License, Version 2.0. See LICENSE.
//
// Compares Ensign-rendered PNGs against milsymbol reference PNGs and
// reports per-symbol mismatch fractions. Anti-aliased edge pixels are
// ignored by pixelmatch's built-in detection, since CoreGraphics and
// resvg rasterize edges differently; what remains is real geometry or
// color disagreement.
//
// Usage:
//   node diff.js [--refs out/refs] [--candidates out/ensign]
//                [--out out/diffs] [--threshold 0.1] [--allow 0.002]
//
//   --threshold  pixelmatch per-pixel color sensitivity (0..1)
//   --allow      maximum fraction of mismatched pixels per image

import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import pngjs from "pngjs";
import pixelmatch from "pixelmatch";

const { PNG } = pngjs;

const { values: args } = parseArgs({
  options: {
    refs: { type: "string", default: "out/refs" },
    candidates: { type: "string", default: "out/ensign" },
    out: { type: "string", default: "out/diffs" },
    threshold: { type: "string", default: "0.1" },
    allow: { type: "string", default: "0.002" },
  },
});

const threshold = Number.parseFloat(args.threshold);
const allow = Number.parseFloat(args.allow);

function pngFiles(dir) {
  if (!existsSync(dir)) {
    console.error(`Directory not found: ${dir}`);
    process.exit(2);
  }
  return new Set(readdirSync(dir).filter((name) => name.endsWith(".png")));
}

function main() {
  const refNames = pngFiles(args.refs);
  const candidateNames = pngFiles(args.candidates);
  mkdirSync(args.out, { recursive: true });

  const shared = [...refNames].filter((name) => candidateNames.has(name)).sort();
  const refOnly = [...refNames].filter((name) => !candidateNames.has(name));
  const candidateOnly = [...candidateNames].filter((name) => !refNames.has(name));

  for (const name of refOnly) console.warn(`MISSING candidate for ${name}`);
  for (const name of candidateOnly) console.warn(`MISSING reference for ${name}`);

  const results = [];
  const errors = [];
  for (const name of shared) {
    try {
      const ref = PNG.sync.read(readFileSync(join(args.refs, name)));
      const candidate = PNG.sync.read(readFileSync(join(args.candidates, name)));
      if (ref.width !== candidate.width || ref.height !== candidate.height) {
        errors.push(`${name}: size mismatch ` +
          `${ref.width}x${ref.height} vs ${candidate.width}x${candidate.height}`);
        continue;
      }
      const diff = new PNG({ width: ref.width, height: ref.height });
      const mismatched = pixelmatch(
        ref.data, candidate.data, diff.data, ref.width, ref.height,
        { threshold }
      );
      const fraction = mismatched / (ref.width * ref.height);
      const pass = fraction <= allow;
      results.push({ name, mismatched, fraction, pass });
      if (!pass) {
        writeFileSync(join(args.out, name), PNG.sync.write(diff));
      }
    } catch (error) {
      errors.push(`${name}: ${error}`);
    }
  }

  results.sort((a, b) => b.fraction - a.fraction);
  const failures = results.filter((result) => !result.pass);

  console.log(`\nCompared ${results.length} images ` +
    `(threshold ${threshold}, allowed fraction ${allow})`);
  console.log(`Pass: ${results.length - failures.length}   Fail: ${failures.length}\n`);

  const worst = results.slice(0, 10);
  if (worst.length > 0) {
    console.log("Largest mismatch fractions:");
    for (const result of worst) {
      const marker = result.pass ? "  ok  " : " FAIL ";
      console.log(`${marker} ${result.name}  ` +
        `${(result.fraction * 100).toFixed(3)}% (${result.mismatched}px)`);
    }
  }

  for (const error of errors) console.error(`ERROR ${error}`);
  if (failures.length > 0) {
    console.log(`\nDiff images for failures written to ${args.out}`);
  }
  if (failures.length > 0 || errors.length > 0 ||
      refOnly.length > 0 || candidateOnly.length > 0) {
    process.exitCode = 1;
  }
}

main();
