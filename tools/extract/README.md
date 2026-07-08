# Ensign extraction and oracle tooling

Development tooling for Ensign. Nothing in this directory ships with
the library; adopters never see it. It has two jobs:

1. **Extraction**: read milsymbol's internal draw instructions for a
   list of SIDCs and serialize them to JSON. That JSON is the input to
   the Swift code generator (icon sessions) and the authoritative
   record of what milsymbol draws.
2. **Oracle**: render milsymbol references and pixel-diff them against
   Ensign's output, proving the port is faithful.

milsymbol is pinned to exactly 3.0.4. Internal details this tooling
relies on (`symbol.drawInstructions`, the asSVG viewBox layout) were
verified against that version's source; treat any milsymbol upgrade as
a change requiring re-verification.

## Setup

```
cd tools/extract
npm install
```

Node 18.17 or later. Dependencies are exact-pinned: milsymbol 3.0.4,
@resvg/resvg-js 2.6.2 (SVG rasterizer), pixelmatch 5.3.0, pngjs 7.0.0.

## The frame oracle (Session 3 workflow)

On the Mac, from `tools/extract`:

```
sh run-oracle.sh
```

That runs three steps, which can also be run individually:

```
node reference-render.js --sidcs sidcs-frames.txt --out out/refs --pixels 200
(cd ../.. && swift run -c release ensign-catalog render tools/extract/sidcs-frames.txt tools/extract/out/ensign 200)
node diff.js --refs out/refs --candidates out/ensign --out out/diffs
```

On Windows, `run-oracle.bat` performs the Node steps; produce the
Ensign renders on the Mac first (the renderer needs CoreGraphics) and
copy `out/ensign` over.

The diff ignores anti-aliased edge pixels (CoreGraphics and resvg
rasterize edges differently) and fails a symbol when more than the
allowed fraction of pixels disagree (default 0.2%, tune with
`--allow`). Failures get a diff PNG in `out/diffs` showing exactly
which pixels disagree.

`sidcs-frames.txt` is the Session 2 frame validation set: every
identity x domain combination plus the dash and fill-class specials.
Land installation and joker/faker are excluded there (milsymbol draws
the installation bar and J/K text amplifiers at frame level; Ensign
adds both in the modifier stage) - the file's comments carry the
details.

## Extraction

```
node extract.js --sidcs sidcs-frames.txt --out out/extracted.json
```

Options `--no-icon`, `--no-frame`, `--no-fill`, and `--standard` pass
through to milsymbol on both extract and reference-render.

The JSON records, per SIDC: validity, bounding box, anchors, a metadata
subset (milsymbol's own parse interpretation, useful for cross-checking
Ensign's parsers), the resolved color tables, and the raw
`drawInstructions` tree in 200x200 canvas coordinates. Instruction
semantics to keep in mind when consuming it (verified against
milsymbol's assvg.js):

- An instruction with `fill` undefined takes the SVG default, which is
  black; `fill: false` means none. Same pattern for `stroke` (default
  none).
- `strokewidth` on an instruction overrides the style default (4), and
  `non_scaling_stroke` multiplies it.
- `linecap` sets both the SVG line cap and line join.
- `translate`, `rotate`, `scale`, and `clip` instructions nest a
  `draw` array; `clipPath` can also appear inline on any instruction.
- `text` instructions carry font size/family/weight and `textanchor`
  (default `start`); converting them to outline paths happens at
  extraction time in codegen, never at runtime.

## Icon code generation

The pipeline from milsymbol icons to Swift, run from `tools/extract`:

```
node extract.js --sidcs sidcs-icons-demo.txt --icon-extract --out out/icons.json
(cd ../.. && swift run ensign-catalog keys tools/extract/sidcs-icons-demo.txt > tools/extract/out/iconkeys.tsv)
node codegen.js --icons out/icons.json --keys out/iconkeys.tsv
```

That overwrites `Sources/EnsignCore/Generated/GeneratedIcons.swift`.
Rebuild and the composer picks the icons up by IconKey; SIDCs whose
icons are not in the library keep rendering frame and fill only.

`--icon-extract` isolates icon instructions by subtraction: each SIDC
is built twice with the reference renderer's own options (full, and
icon disabled), the frame-only instructions are verified to be a
strict prefix of the full instructions, and the remainder is the icon.
Because the full build uses default frame and fill options, the
concrete colors in the extraction are exactly what a reference render
uses; rendering options can never distort them. SIDCs with modifiers
drawn after the icon fail the prefix check loudly (a future extension
when the modifier sessions land).

Codegen refuses to run on extraction output that was not produced
icon-only (`--no-frame --no-fill`), skips codes milsymbol has no icon
for (`validIcon` false), flattens transform containers, converts arcs
to cubics, maps concrete colors back to Ensign color roles using each
symbol's own color tables, and reports every problem in one pass
without writing anything.

Icons that extract identically under every frame base in the list are
stored once as universal entries. Full-frame icons (those that span
the frame outline, like the infantry saltire) legitimately differ per
frame base; codegen detects the difference and emits per-base
variants. Cover all four bases in the SIDC list for such icons, or the
uncovered bases degrade to frame-and-fill and codegen prints a NOTE.

Text with `alignment-baseline: middle` or `central` is vertically
positioned from the font's own metrics (x-height and em box per the
SVG definitions); the oracle diff is the referee on whether that
matches resvg's interpretation, so watch text-bearing icons on their
first pass.

### Fonts (only when icons contain text)

Some icons draw text. Codegen converts text to outline paths at
generation time using Liberation Sans (metric-compatible with the
Arial that milsymbol assumes; SIL OFL licensed). Fonts are not needed
until a text icon appears, at which point codegen stops with a clear
message. To set up:

1. Download the latest release from
   https://github.com/liberationfonts/liberation-fonts/releases
2. Place `LiberationSans-Regular.ttf` and `LiberationSans-Bold.ttf`
   in `tools/extract/fonts/`

When the first text-bearing icon ships, the OFL attribution gets added
to the project NOTICE alongside the milsymbol attribution.

## Verifying generated icons

After codegen and a rebuild, the same oracle closes the loop, now with
icons included:

```
node reference-render.js --sidcs sidcs-icons-demo.txt --out out/icon-refs --pixels 200
(cd ../.. && swift run -c release ensign-catalog render tools/extract/sidcs-icons-demo.txt tools/extract/out/icon-ensign 200)
node diff.js --refs out/icon-refs --candidates out/icon-ensign --out out/icon-diffs
```