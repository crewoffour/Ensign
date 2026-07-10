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
| 2 | Frame engine: exact milsymbol-ported geometry for all 14 frame outlines (incl. dismounted hexagon), space bar and activity corner overlays, dashed-frame overlay mechanism, fill classes and light/medium/dark palettes with custom palette hook, SymbolComposer, Core Graphics SymbolRenderer, PNG contact-sheet catalog | Complete |
| 3 | Extraction tool (tools/extract, Node.js, all deps exact-pinned): milsymbol draw-instruction extraction by prefix subtraction, icon text to outline paths via opentype.js with Liberation Sans, Swift code generation (universal and per-base full-frame icon entries), IconLibrary and composer integration, catalog keys and render modes, milsymbol reference-render oracle. Frame oracle 38/38 and icon oracle 13/13 at 0.000% mismatch. Found and fixed: edition-aware suspect fill, dash precedence, civilian entity-prefix rule, iconFillColor contrast role. | Complete |
| 4 | Maritime icon subset from Beacon's real atlas (54 SIDCs, 30-digit 2525E, oracle 54/54): 19 icons incl. 3 full-frame per-base, own-track and fused-track maritime frame rules, 30-digit SIDC parsing, unframed-symbol extraction; SnapshotTests suite (hand-rolled tolerance pixel diff against committed goldens, no shipped dependencies, no Node in CI). Charlie-dialect icons deferred to first real charlie consumer; set 20/25/36 and HQ entries deferred to Session 7 per the worklist notes. | Complete |
| 5 | SpriteAtlasBuilder (grid packing, MapLibre sprite JSON, per-name skip reasons); tight-fit rendering via geometry extent (aspect-preserving, replacing the aspect distortion in Beacon's Node generator); catalog atlas mode reading Beacon's symbols.json and writing Beacon-parity sprites*.png/json at 40pt/4pt padding; MilSymbolView (SwiftUI Canvas, resolution-independent, palette-aware). Verified against Beacon's real manifest and sheet. | Complete |
| 6 | Beacon integration via runtime rendering: MilSymbol.renderKey and SymbolImageCache in Ensign; Beacon tracks resolve to render keys, rendered once per distinct visual and registered on demand with MapLibre (re-registered on style reloads); SymbologyMapper entity tables corrected (verified against extraction); legacy atlas retained for markers, FunctionMarkers, and not-yet-drawable fallbacks; Node generator retired in favor of the catalog atlas mode. Verified live against tak-cot-simulator. | Complete |
| 7 | Amplifiers and modifiers, complete. 7a: HQ staff, task force, installation bar, feint/dummy, all echelons, all mobility indicators (oracle 61/61). 7b: joker/faker friend-frame remap and exercise amplifier letters X/J/K/S via baked Liberation glyphs (oracle 18/18). 7c: control measure points render icon-only through the frameless composer path (oracle-verified via the merged worklist); direction of movement arrow asset (DirectionArrow, milsymbol's centered variant) with Beacon's track layer de-rotated and a course-bound arrow layer added; self-marker chevron keeps rotating by design. Render key at v3. | Complete |
| 8 | Close the rendering gaps: status/condition modifiers (statusmodifier.js port, oracle-verified), leadership amplifier (codes 71/72), mine warfare MEDAL fill rules (un-defers nav-hazard), charlie mobility and installation amplifier decoding (deferred in 7a), C-L and M-F subtype verification via extraction, MilSymbolView tight-fit option for tall amplified symbols | Planned |
| 9 | Coverage at scale, both dialects as peers: enumerate the full valid delta set/entity corpus and the charlie function ID corpus (the ATAK ecosystem is charlie-first and government timelines favor long 2525C relevance), batch extraction, GeneratedIcons sharding per symbol set/scheme, compile-time and binary-size measurement, snapshot strategy for the large corpus | Planned |
| 10 | JMSML adjudication: official DISA/Esri symbology data as the authority; comparison tooling against Ensign's tables; every divergence adjudicated and documented (mobility 38/39 included); provenance becomes standard-first with milsymbol as the rendering oracle | Planned |
| 11 | Beacon completion: FunctionMarkers and user markers migrate to render keys; bundled legacy atlas and the SymbolSprites name table deleted; importers updated; 50k-track performance confirmation | Planned |
| 12 | Info fields (2525 text amplifier fields): the standard's ~30 lettered fields (unique designation, higher formation, speed, DTG, altitude/depth, staff comments, and the rest) laid out per the standard's positions, ported from milsymbol's infofields. Arbitrary text cannot be baked, so EnsignRender bundles the Liberation fonts as SPM resources (SIL OFL) and lays out with CoreText, keeping oracle verifiability with shared fonts. Opt-in API: map clients that label via map-engine text layers pay nothing | Planned |
| 13 | 1.0 release: API and access-control audit, render key stability policy, DocC documentation, CHANGELOG, CI polish, public GitHub publication under the to-be-created organization and Swift Package Index listing, CONTRIBUTING; METOC recorded as an explicit post-1.0 roadmap item | Planned |

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
| Frame geometry ported coordinate-exact from milsymbol 3.0.4 | Session 3's oracle pixel-diffs Ensign output against milsymbol reference renders; approximated coordinates would flag every symbol. milsymbol 3.x renders per 2525E, which also matches Beacon's existing atlas. MIT attribution recorded in NOTICE. |
| Dashed frames are a white overlay, not a dashed stroke | milsymbol draws the solid frame, then strokes a white dashed outline (width 5 over the width-4 frame) on top. Ported as-is for pixel parity. Dash arrays: 4,4 for uncertain identity, 8,12 for anticipated status; uncertain identity takes precedence when both apply (milsymbol assigns the status dash first and lets the identity dash overwrite it; corrected by the Session 3 oracle). |
| Suspect and joker fill is edition-aware | The distinct suspect amber applies only to 2525E-coded SIDCs (delta version 13/14); charlie and 2525D-coded suspects fill hostile red with the dashed identity frame. Matches milsymbol (numbersidc/metadata.js sets the suspect flag only for version 13) and fielded TAK rendering. Found by the Session 3 frame oracle. |
| Joker/faker frame treatment deferred to Session 7 | milsymbol 3.x remaps joker and faker onto a different frame base at frame level (source comment: "shape of friendly") and draws J/K text amplifiers. Ensign currently uses suspect/hostile bases. Excluded from the oracle; resolve with the amplifier work. |
| Icon extraction is by prefix subtraction | Each SIDC is built twice with the reference renderer's own options (full, and icon:false); the frame-only instructions must be a strict prefix of the full instructions and the remainder is the icon. Concrete colors therefore match reference renders by construction; option-dependent color distortion is impossible. Post-icon modifiers fail the prefix check loudly until the modifier sessions extend it. |
| iconFillColor maps to the contrast role | milsymbol's iconFillColor is the hollow-interior fill that makes icons read against the affiliation fill (the civilian vessel interiors); it is Ensign's contrastFill, not affiliationFill. When it coincides with the affiliation fill, first-wins ordering resolves identically. Found by the icon oracle. |
| Full-frame icons carry per-base variants | Icons spanning the frame outline (infantry saltire) legitimately differ per frame base. Codegen detects this by comparing extracted geometry across bases: identical everywhere collapses to a universal entry, differing emits per-base variants, uncovered bases degrade to frame-and-fill with a NOTE. |
| Icon text becomes outlines at generation time via Liberation Sans | Text instructions convert to paths with opentype.js using Liberation Sans (metric-compatible with milsymbol's Arial, SIL OFL); alignment-baseline middle/central positioned from font metrics (x-height and em box). Verified pixel-identical against resvg. No fonts at runtime, ever. OFL attribution in NOTICE. |
| Snapshots freeze what the oracle verified | The snapshot suite compares fresh renders against committed golden PNGs (filename = SIDC, the directory is the test list) with per-channel tolerance and an allowed pixel fraction, so plain swift test guards regressions in CI with no Node. The milsymbol oracle referees intentional changes; snapshots are re-recorded only after oracle verification. Recording reuses the catalog render mode. |
| Beacon integrates by runtime rendering, not atlas swap | Tracks resolve to MilSymbol.renderKey; one image per distinct visual is rendered through SymbolImageCache and registered with style.setImage on demand, re-registered on style reloads. Every valid SIDC renders correctly; unknown entities degrade to correct frames instead of borrowed icons. The legacy atlas remains only for name-referencing paths (user markers, FunctionMarkers) and for symbols Ensign cannot draw yet; both migrate in Session 7. |
| Frames stay upright; course rides the arrow | Per 2525, track symbol frames do not rotate: Beacon's track and aggregate layers de-rotated, with Ensign's DirectionArrow (milsymbol's centered variant, rotation anchor at image center) on a dedicated layer bound to course and gated on a hasCourse feed flag. The ground offset-line arrow variant cannot ride a rotating sprite and is the documented simplification. The self-marker chevron is itself a heading indicator and keeps rotating. |
| The oracle's mapping tables are authoritative, not just its geometry | The mobility amplifier failures were a perfect geometry port attached to the wrong code table: milsymbol assigns 37 pack animals, 41 over snow, 42 sled, 51 barge, 52 amphibious, 61/62 towed arrays, with no 38-39 (and 71/72 leadership, deferred). Ensign adopts milsymbol's tables per the oracle charter; divergence from the raw 2525D document tables is adjudicated at the JMSML migration. |
| Amplifiers position off the original frame bounds | Every modifier part in milsymbol references the frame bbox as cloned before any part draws; nothing positions off accumulated bounds. Ensign mirrors this: ModifierGeometry functions take FrameGeometry.bounds directly, and emission order is HQ staff, task force, installation, feint/dummy, echelon, mobility, after the icon. |
| Sprites render tight-fit, aspect-preserved | Beacon's Node generator stretched milsymbol's bbox-cropped (non-square) SVGs into square cells, distorting every non-square frame. Ensign's tight fit scales the geometry extent (control-point hull plus stroke margins) to fill the cell aspect-preserved and centered: Beacon's visual weight without the distortion. Full-canvas fit remains the renderer default so snapshots and the oracle are unaffected. |
| Atlas output is Beacon-parity by default | sprites.png/sprites@2x.png (plural) plus JSON, 40pt sprites, 4pt padding scaled by pixel ratio, MapLibre manifest format. Sheet dimensions match Beacon's generator for the same manifest. Set 25 control measures skip with reasons; Beacon keeps its old sprites for those names until Session 7. |
| Dismounted individual is its own domain with a hexagon friend frame | 2525D/E symbol set 27 has distinct frames (hexagon/diamond/square/quatrefoil), not the land unit rectangle. Corrected from the Session 1 mapping. |
| Fill classes are distinct from affiliations | Six 2525D fill classes (friend, hostile, neutral, unknown, civilian, suspect); joker fills as suspect, faker as hostile, civilian purple applies only to non-threat civilians. Civilian is flagged by entity prefix per set, matching milsymbol exactly: set 11 always, air/space/subsurface/set-12 entities 12xxxx, land equipment 16xxxx, sea surface 14xxxx (found by the Session 3 icon oracle). Charlie civilian function IDs deferred. |
| 30-digit 2525E codes parse alongside 20-digit | Beacon's atlas and runtime speak full-length 2525E SIDCs (version 13, 30 digits). DeltaSIDC accepts both lengths; the extension block (positions 21-30) is preserved raw with the frame shape modifier (position 23) parsed. Frame-shape override rendering semantics deferred until real traffic carries a non-zero value. |
| Maritime frame rules (Session 4) | Sea own track (30/150000) renders unframed: icon only, no frame, fill, or overlays. Fused tracks (30/160000, 35/140000, 35/150000) force the pending dash regardless of identity. Exact entity matches, per milsymbol's numbersidc metadata. |
| Installation bar and HQ staff deferred to Session 7 | Both are modifier-stage drawing (milsymbol handles them outside base geometry; HQ staff length is 100 canvas units). Frames render correctly without them. |

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
