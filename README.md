# Ensign

A native Swift library for MIL-STD-2525 military symbology.

Ensign parses Symbol Identification Codes in both modern dialects - the
15-character alphanumeric SIDC of MIL-STD-2525C and the 20-digit numeric
SIDC of MIL-STD-2525D - and resolves them into a single normalized symbol
model, with vector rendering, rasterization, sprite-atlas generation, and
SwiftUI views built on top.

There is no other native Swift implementation of MIL-STD-2525. Ensign
aims to be the definitive one.

## Status

Early development. The SIDC parsers and normalized symbol model
(EnsignCore) are functional and tested; rendering (EnsignRender) and
SwiftUI support (EnsignUI) are under active development. The public API
is not yet stable and will change before 1.0.

## Quick start

```swift
import EnsignCore

// Both SIDC dialects parse through one entry point.
let legacy = try SIDC("SFSPCLDD-------")      // 2525C, 15 characters
let modern = try SIDC("10033000001201000000") // 2525D, 20 digits

// Both resolve into the same normalized model.
let symbol = MilSymbol(sidc: modern)
symbol.affiliation    // .friend
symbol.domain         // .seaSurface
symbol.status         // .present
symbol.frame.shape    // .circle
symbol.frame.isDashed // false
```

Parse failures are descriptive:

```swift
do {
    _ = try SIDC("10933000001201000000")
} catch {
    print(error)
    // Invalid context digit '9' at position 3.
    // Expected 0 (reality), 1 (exercise), or 2 (simulation).
}
```

## Packages

| Target | Contents | Platforms |
|---|---|---|
| EnsignCore | SIDC parsing, normalized symbol model, neutral geometry model | iOS 16+, macOS 13+, visionOS 1+, Linux |
| EnsignRender | Core Graphics drawing, rasterization, sprite atlas generation | iOS 16+, macOS 13+, visionOS 1+ |
| EnsignUI | SwiftUI views | iOS 16+, macOS 13+, visionOS 1+ |
| ensign-catalog | Demonstration and visual-regression catalog | development tool |

## Installation

Swift Package Manager only:

```swift
dependencies: [
    .package(url: "https://github.com/OWNER/Ensign.git", from: "0.1.0")
]
```

## Design principles

- **Two dialects, one model.** The charlie (2525A/B/C) and delta
  (2525D/E) SIDC families parse separately and resolve into one
  normalized `MilSymbol`. Ensign does not convert codes between
  families, because the crosswalk is not one-to-one; it renders both
  natively instead.
- **Graceful on live traffic.** Codes that parse but reference unknown
  icons render as frame and fill rather than failing. A symbology
  library facing a live CoT feed must degrade, not crash.
- **Semantic color, resolved late.** Geometry carries color roles, not
  colors. Standard light, medium, and dark fill modes and fully custom
  palettes (including accessibility palettes) are a render-time choice.
- **Deterministic, font-free rendering.** Icon lettering ships as
  outline paths, so output is identical on every platform and OS
  version.

## Roadmap

1. SIDC parsing for both dialects and the normalized model (done)
2. Frame rendering: all affiliation and domain outlines, fills, status
3. Symbol data pipeline: milsymbol port as proving ground and oracle
4. Maritime-first icon subset (roughly 50-100 symbols)
5. Rasterization, sprite atlas generation, SwiftUI views
6. Amplifiers and modifiers; expanded coverage
7. Migration to the authoritative JMSML symbol data

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

Symbol definition data in future releases will be ported from
[milsymbol](https://github.com/spatialillusions/milsymbol) (MIT), with
attribution maintained in NOTICE.
