# Ensign

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcrewoffour%2FEnsign%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/crewoffour/Ensign)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcrewoffour%2FEnsign%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/crewoffour/Ensign)

A native Swift library for MIL-STD-2525 military symbology.

Ensign parses Symbol Identification Codes in both modern dialects - the
15-character alphanumeric SIDC of MIL-STD-2525C and the 20- or 30-digit
numeric SIDC of MIL-STD-2525D/E - and resolves them into one normalized
symbol model, with vector rendering, rasterization, sprite generation,
info field text, and SwiftUI views built on top. No fonts, images, or
network access at runtime; no dependencies.

There is no other native Swift implementation of MIL-STD-2525. Ensign
aims to be the definitive one.

## Coverage

The complete point-symbol space of the standard, in both dialects:
6,918 icons across every warfighting symbol set (air, space, land
units, civilians, equipment, installations, sea surface, subsurface,
mine warfare, activities, SIGINT, cyberspace, control measure points,
dismounted individuals), all frame shapes and affiliations, echelons,
mobility, HQ/task force/feint-dummy, engagement status conditions,
leadership, exercise and simulation amplifiers, sector one and two
modifier icons, and the full text amplifier field system.

Out of scope by charter: multipoint tactical graphics (boundaries,
phase lines, areas - map geometry, not point symbols) and, until a
post-1.0 release, the METOC sets. Known 1.0 limitations: cyberspace
(set 60) symbols render icon-only pending frame verification, and
sector modifier icons compose on framed symbols only; both are
tracked for the first post-1.0 releases.

## Provenance

Every rendered feature is verified pixel-for-pixel against
[milsymbol](https://github.com/spatialillusions/milsymbol) (the
reference JavaScript implementation, MIT) through an automated oracle
pipeline, and the symbol tables are adjudicated against
[JMSML](https://github.com/Esri/joint-military-symbology-xml), the
DISA/Esri machine-readable expression of MIL-STD-2525D, including the
official 2525C-to-2525D crosswalk. The tooling lives in
`tools/extract/`; decisions of record live in `ENSIGN_PLAN.md`.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/crewoffour/Ensign.git", from: "1.0.0")
]
```

Targets: `EnsignCore` (parsing, model, geometry; runs anywhere Swift
runs, including Linux), `EnsignRender` (Core Graphics rasterization,
Apple platforms), `EnsignUI` (SwiftUI views).

## Quick start

```swift
import EnsignCore
import EnsignRender

// Both dialects parse through one entry point.
let symbol = try MilSymbol("10031000181211020000")   // 2525D
let legacy = try MilSymbol("SFGPUCI---K----")        // 2525C

// Rasterize.
let renderer = SymbolRenderer(palette: .light)
let image = renderer.image(for: symbol, size: 128)

// SwiftUI.
MilSymbolView(symbol: symbol)
```

### Map engines and render keys

`symbol.renderKey` is a stable string identity for a symbol's
rendered appearance: two symbols with equal keys render identically,
so a map engine can register one image per key and share it across any
number of tracks. Fifty thousand tracks resolve to a few dozen images.
The key format version is `RenderKey.version`; patch releases never
change rendering under an unchanged key.

### Info fields

```swift
var fields = InfoFields()
fields.uniqueDesignation = "A21"
fields.type = "MACHINE GUN"
fields.dtg = "30140000ZSEP97"
let geometry = SymbolComposer.geometry(for: symbol, infoFields: fields)
let labeled = renderer.image(geometry: geometry,
                             fillClass: symbol.fillClass,
                             pixelsPerCanvasUnit: 1.0)
```

Field names mirror milsymbol's option names. Text shapes with bundled
Liberation Sans (SIL OFL). Info field rendering is opt-in and outside
the render key: labeled images are per-instance, not shared sprites.

## Performance notes

Debug builds of the full icon library compile in about 90 seconds and
are cached by SwiftPM thereafter; release (whole-module) builds of the
library take several minutes and happen once per configuration. Icon
lookups, composition, and rendering are allocation-light; the library
carries no runtime resources except the two info-field fonts.

## License

Apache 2.0, copyright Jason Griffin. Rendering behavior is ported
from milsymbol (MIT, Måns Beckman) with geometry extracted through an
automated pipeline; Liberation Sans is bundled under the SIL Open Font
License 1.1. See NOTICE.
