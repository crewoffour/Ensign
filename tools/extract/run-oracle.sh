#!/bin/sh
# Copyright 2026 Jason Griffin
# Licensed under the Apache License, Version 2.0. See LICENSE.
#
# Runs the full frame oracle on macOS: milsymbol reference renders,
# Ensign renders via the catalog executable, then the pixel diff.
# Run from tools/extract. Requires npm install to have been run once.

set -e

SIDCS="${1:-sidcs-frames.txt}"
PIXELS="${2:-200}"

echo "== milsymbol reference renders =="
node reference-render.js --sidcs "$SIDCS" --out out/refs --pixels "$PIXELS"

echo ""
echo "== Ensign renders =="
mkdir -p out/ensign
( cd ../.. && swift run -c release ensign-catalog render "tools/extract/$SIDCS" tools/extract/out/ensign "$PIXELS" )

echo ""
echo "== Pixel diff =="
node diff.js --refs out/refs --candidates out/ensign --out out/diffs
