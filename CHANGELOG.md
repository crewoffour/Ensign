# Changelog

## 1.0.0

Initial release.

- SIDC parsing for MIL-STD-2525C (15-character) and 2525D/E (20- and
  30-digit) dialects, normalized into one symbol model
- Complete point-symbol icon library: 6,918 icons across both
  dialects, extracted from and pixel-verified against milsymbol 3.0.4
- All frames, affiliations, and fill classes; echelon, mobility,
  HQ/task force/feint-dummy, engagement status conditions, leadership,
  exercise and simulation amplifiers; sector one and two modifier
  icons; the unfilled (mine warfare) color model
- Info fields: the standard's text amplifier system with bundled
  Liberation Sans, grown-canvas rendering, milsymbol-compatible field
  names
- Render keys (format ensign5): stable rendered-appearance identities
  for map-engine image sharing, with a documented stability policy
- SymbolRenderer (Core Graphics), sprite atlas support, direction
  arrow, SwiftUI views; EnsignCore builds on Linux
- Symbol tables adjudicated against JMSML (DISA/Esri machine-readable
  2525D); official 2525C-to-D crosswalk extracted and committed
- Oracle tooling: enumeration, extraction, codegen, reference
  rendering, and pixel diffing under tools/extract/

Post-1.0 roadmap: METOC symbol sets; DocC catalog expansion.
