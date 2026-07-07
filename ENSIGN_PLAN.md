# Ensign Development Plan

Working plan for Ensign development sessions. Companion to the project
charter (Ensign-Charter.docx v0.2), which records scope and ownership;
this document records the build order, per-session goals, and running
decisions. Update the status column and decision log as sessions
complete.

## Session plan

| Session | Scope | Status |
|---|---|---|
| 1 | Package scaffold; EnsignCore with dual SIDC parsers (2525C 15-char, 2525D 20-digit), normalized MilSymbol model, frame resolution, geometry model; test suite; CI | Complete |
| 2 | EnsignRender frame engine: geometry for all 13 frame outlines, affiliation fills, dashed frames, space bar overlay, palette with light/medium/dark modes and custom palette hook; catalog frame grid | Planned |
| 3 | Extraction tool (tools/, Node.js): milsymbol draw-instruction serialization, icon text to outline paths via opentype.js with pinned font, Swift code generation, milsymbol reference-render oracle harness | Planned |
| 4 | Maritime-first icon subset through the pipeline, both dialects; snapshot regression suite (hand-rolled, no shipped dependencies) | Planned |
| 5 | Rasterization to images; sprite atlas generation matching Beacon's MapLibre atlas format with incremental additions; EnsignUI SwiftUI views | Planned |
| 6 | Beacon integration: replace the milsymbol.js sprite pipeline; Beacon keeps its CoT-type-to-SIDC mapping; replace Beacon's Affiliation enum with Ensign's | Planned |
| 7+ | Amplifier and modifier rendering (echelon, HQ/TF/dummy, mobility, text amplifiers); expanded symbol coverage; JMSML migration; METOC scheme | Planned |

## Inputs needed from Jason (not blocking until noted)

- Beacon's sprite pipeline script and atlas JSON format/keying - needed
  by Session 5
- A real-world SIDC list captured from Beacon and tak-cot-simulator
  traffic, to ground the icon subset - useful from Session 4
- GitHub repository owner/name; confirm the Ensign name is free on the
  Swift Package Index - needed before first push

## Decision log

| Decision | Rationale |
|---|---|
| Dual-format from day one | Beacon already speaks 2525D; parsing is the cheap half of D support, and milsymbol carries D icon data so the extraction pipeline covers both dialects in one pass. Recorded as a change against the charter's original "C first, D later" sequencing. |
| No C-to-D conversion | The crosswalk between families is not one-to-one. Parse both, render both, convert never - or later as an explicit utility with documented gaps. |
| 200x200 canvas, anchor (100,100) | Matches milsymbol so ported definitions transfer without transformation and oracle comparison is a direct overlay. One-way door. |
| Semantic ColorRole in geometry, resolved at render time | Keeps EnsignCore free of graphics frameworks; makes 2525 fill modes and custom/accessibility palettes a substitution point, not a geometry rewrite. |
| Icon text ships as outline paths | Deterministic, font-free rendering on every platform. The extraction tool converts glyphs with opentype.js against a pinned font. Dynamic amplifier text is composed in EnsignRender with Core Text and never enters the geometry model. |
| Generated Swift data, not bundled JSON | Symbol definitions compile into the binary (GeneratedIcons.swift). No runtime parsing, no bundle-loading failure modes, full type safety. |
| Weather/METOC scheme deferred | The W scheme's field layout differs from every other charlie scheme. It throws a descriptive unsupportedCodingScheme error rather than mis-parsing. |
| Unknown icons degrade to frame and fill | Live CoT traffic contains codes no library has seen. Hard failure is reserved for codes that do not parse at all. |
| Unknown delta versions and symbol sets parse | Forward compatibility: versionCode and symbolSetCode preserve raw values; knownVersion and symbolSet are nil for unrecognized codes. |
| Hand-rolled snapshot testing | Roughly 80 lines; avoids shipping a third-party test dependency to adopters. |
| Full 2525C identity set parsed | Real TAK traffic emits exercise and uncertainty variants (all 15 identities including joker and faker), not just the four base affiliations. |
| Charlie codes of 10-14 characters pad to 15 | Real-world traffic frequently omits trailing fill. '*' accepted as a fill alias; input uppercased. |

## Session 1 deliverables (this session)

- SPM package: swift-tools 6.0, Swift 6 strict concurrency, iOS 16 /
  macOS 13 / visionOS 1.0, EnsignCore also on Linux
- Four targets per the charter: EnsignCore, EnsignRender (placeholder),
  EnsignUI (placeholder), ensign-catalog (text-mode smoke test)
- EnsignCore: SIDC family detection; CharlieSIDC and DeltaSIDC parsers
  with descriptive errors; normalized Affiliation, SymbolDomain,
  OperationalStatus, HQTFDummy, Echelon; FrameShape resolution matrix;
  MilSymbol; IconKey; neutral geometry model (SymbolPoint, ColorRole,
  DrawStyle, PathSegment, SymbolPath, DrawInstruction, SymbolGeometry)
- Tests: charlie parsing, delta parsing, normalization and dual-dialect
  equivalence
- CI: macOS build and test, Linux build and test, license-header check
- LICENSE (Apache 2.0), NOTICE, .spi.yml, README
