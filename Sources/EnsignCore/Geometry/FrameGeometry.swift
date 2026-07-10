// Copyright 2026 Jason Griffin
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
// The frame outlines, space bar overlays, and activity corner brackets
// in this file are ported coordinate-for-coordinate from milsymbol
// (https://github.com/spatialillusions/milsymbol), Copyright (c)
// Mans Beckman, MIT License, so that Ensign output is pixel-comparable
// against milsymbol reference renders. See NOTICE.

/// The axis-aligned bounds of a frame on the 200x200 canvas, used later
/// for amplifier and text placement.
public struct FrameBounds: Hashable, Sendable {
    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double

    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }
}

/// The authored geometry for every frame outline and frame-level
/// overlay, and the bounds that go with them.
public enum FrameGeometry {

    // MARK: - Frame outlines

    /// The outline segments for a frame shape. The circle shape has no
    /// path representation here; it is emitted as a circle instruction
    /// by the composer (center (100, 100), radius 60).
    public static func segments(for shape: FrameShape) -> [PathSegment]? {
        switch shape {
        case .circle:
            return nil

        case .rectangle:
            // milsymbol GroundFriend: M25,50 l150,0 0,100 -150,0 z
            return [
                .move(to: SymbolPoint(25, 50)),
                .line(to: SymbolPoint(175, 50)),
                .line(to: SymbolPoint(175, 150)),
                .line(to: SymbolPoint(25, 150)),
                .close,
            ]

        case .square:
            // milsymbol GroundNeutral: M45,45 l110,0 0,110 -110,0 z
            return [
                .move(to: SymbolPoint(45, 45)),
                .line(to: SymbolPoint(155, 45)),
                .line(to: SymbolPoint(155, 155)),
                .line(to: SymbolPoint(45, 155)),
                .close,
            ]

        case .diamond:
            // milsymbol GroundHostile: M 100,28 L172,100 100,172 28,100 100,28 Z
            return [
                .move(to: SymbolPoint(100, 28)),
                .line(to: SymbolPoint(172, 100)),
                .line(to: SymbolPoint(100, 172)),
                .line(to: SymbolPoint(28, 100)),
                .close,
            ]

        case .quatrefoil:
            // milsymbol GroundUnknown:
            // M63,63 C63,20 137,20 137,63 C180,63 180,137 137,137
            // C137,180 63,180 63,137 C20,137 20,63 63,63 Z
            return [
                .move(to: SymbolPoint(63, 63)),
                .curve(to: SymbolPoint(137, 63), control1: SymbolPoint(63, 20), control2: SymbolPoint(137, 20)),
                .curve(to: SymbolPoint(137, 137), control1: SymbolPoint(180, 63), control2: SymbolPoint(180, 137)),
                .curve(to: SymbolPoint(63, 137), control1: SymbolPoint(137, 180), control2: SymbolPoint(63, 180)),
                .curve(to: SymbolPoint(63, 63), control1: SymbolPoint(20, 137), control2: SymbolPoint(20, 63)),
                .close,
            ]

        case .hexagon:
            // milsymbol LandDismountedIndividualFriend:
            // m 100,45 55,25 0,60 -55,25 -55,-25 0,-60 z
            return [
                .move(to: SymbolPoint(100, 45)),
                .line(to: SymbolPoint(155, 70)),
                .line(to: SymbolPoint(155, 130)),
                .line(to: SymbolPoint(100, 155)),
                .line(to: SymbolPoint(45, 130)),
                .line(to: SymbolPoint(45, 70)),
                .close,
            ]

        case .archOpenBottom:
            // milsymbol AirFriend:
            // M 155,150 C 155,50 115,30 100,30 85,30 45,50 45,150
            return [
                .move(to: SymbolPoint(155, 150)),
                .curve(to: SymbolPoint(100, 30), control1: SymbolPoint(155, 50), control2: SymbolPoint(115, 30)),
                .curve(to: SymbolPoint(45, 150), control1: SymbolPoint(85, 30), control2: SymbolPoint(45, 50)),
            ]

        case .tentOpenBottom:
            // milsymbol AirHostile: M 45,150 L45,70 100,20 155,70 155,150
            return [
                .move(to: SymbolPoint(45, 150)),
                .line(to: SymbolPoint(45, 70)),
                .line(to: SymbolPoint(100, 20)),
                .line(to: SymbolPoint(155, 70)),
                .line(to: SymbolPoint(155, 150)),
            ]

        case .squareOpenBottom:
            // milsymbol AirNeutral: M 45,150 L 45,30 155,30 155,150
            return [
                .move(to: SymbolPoint(45, 150)),
                .line(to: SymbolPoint(45, 30)),
                .line(to: SymbolPoint(155, 30)),
                .line(to: SymbolPoint(155, 150)),
            ]

        case .cloverOpenBottom:
            // milsymbol AirUnknown (relative path made absolute):
            // M 65,150 c -55,0 -50,-90 0,-90 0,-50 70,-50 70,0 50,0 55,90 0,90
            return [
                .move(to: SymbolPoint(65, 150)),
                .curve(to: SymbolPoint(65, 60), control1: SymbolPoint(10, 150), control2: SymbolPoint(15, 60)),
                .curve(to: SymbolPoint(135, 60), control1: SymbolPoint(65, 10), control2: SymbolPoint(135, 10)),
                .curve(to: SymbolPoint(135, 150), control1: SymbolPoint(185, 60), control2: SymbolPoint(190, 150)),
            ]

        case .archOpenTop:
            // milsymbol SubsurfaceFriend (relative path made absolute):
            // m 45,50 c 0,100 40,120 55,120 15,0 55,-20 55,-120
            return [
                .move(to: SymbolPoint(45, 50)),
                .curve(to: SymbolPoint(100, 170), control1: SymbolPoint(45, 150), control2: SymbolPoint(85, 170)),
                .curve(to: SymbolPoint(155, 50), control1: SymbolPoint(115, 170), control2: SymbolPoint(155, 150)),
            ]

        case .tentOpenTop:
            // milsymbol SubsurfaceHostile: M45,50 L45,130 100,180 155,130 155,50
            return [
                .move(to: SymbolPoint(45, 50)),
                .line(to: SymbolPoint(45, 130)),
                .line(to: SymbolPoint(100, 180)),
                .line(to: SymbolPoint(155, 130)),
                .line(to: SymbolPoint(155, 50)),
            ]

        case .squareOpenTop:
            // milsymbol SubsurfaceNeutral: M45,50 L45,170 155,170 155,50
            return [
                .move(to: SymbolPoint(45, 50)),
                .line(to: SymbolPoint(45, 170)),
                .line(to: SymbolPoint(155, 170)),
                .line(to: SymbolPoint(155, 50)),
            ]

        case .cloverOpenTop:
            // milsymbol SubsurfaceUnknown (relative path made absolute):
            // m 65,50 c -55,0 -50,90 0,90 0,50 70,50 70,0 50,0 55,-90 0,-90
            return [
                .move(to: SymbolPoint(65, 50)),
                .curve(to: SymbolPoint(65, 140), control1: SymbolPoint(10, 50), control2: SymbolPoint(15, 140)),
                .curve(to: SymbolPoint(135, 140), control1: SymbolPoint(65, 190), control2: SymbolPoint(135, 190)),
                .curve(to: SymbolPoint(135, 50), control1: SymbolPoint(185, 140), control2: SymbolPoint(190, 50)),
            ]
        }
    }

    /// The bounds of a frame shape, from the milsymbol geometry table.
    public static func bounds(for shape: FrameShape) -> FrameBounds {
        switch shape {
        case .rectangle: return FrameBounds(x1: 25, y1: 50, x2: 175, y2: 150)
        case .circle: return FrameBounds(x1: 40, y1: 40, x2: 160, y2: 160)
        case .square: return FrameBounds(x1: 45, y1: 45, x2: 155, y2: 155)
        case .diamond: return FrameBounds(x1: 28, y1: 28, x2: 172, y2: 172)
        case .quatrefoil: return FrameBounds(x1: 30.75, y1: 30.75, x2: 169.25, y2: 169.25)
        case .hexagon: return FrameBounds(x1: 45, y1: 45, x2: 155, y2: 155)
        case .archOpenBottom: return FrameBounds(x1: 45, y1: 30, x2: 155, y2: 150)
        case .tentOpenBottom: return FrameBounds(x1: 45, y1: 20, x2: 155, y2: 150)
        case .squareOpenBottom: return FrameBounds(x1: 45, y1: 30, x2: 155, y2: 150)
        case .cloverOpenBottom: return FrameBounds(x1: 25, y1: 20, x2: 175, y2: 150)
        case .archOpenTop: return FrameBounds(x1: 45, y1: 50, x2: 155, y2: 170)
        case .tentOpenTop: return FrameBounds(x1: 45, y1: 50, x2: 155, y2: 180)
        case .squareOpenTop: return FrameBounds(x1: 45, y1: 50, x2: 155, y2: 170)
        case .cloverOpenTop: return FrameBounds(x1: 25, y1: 50, x2: 175, y2: 180)
        }
    }

    // MARK: - Space bar overlay

    /// The filled bar drawn over the air frame for the space domain,
    /// ported from milsymbol basegeometry.js space modifiers.
    public static func spaceModifierSegments(base: FrameBase) -> [PathSegment] {
        switch base {
        case .friend:
            // M 100,30 C 90,30 80,35 68.65625,50 l 62.6875,0 C 120,35 110,30 100,30
            return [
                .move(to: SymbolPoint(100, 30)),
                .curve(to: SymbolPoint(68.65625, 50), control1: SymbolPoint(90, 30), control2: SymbolPoint(80, 35)),
                .line(to: SymbolPoint(131.34375, 50)),
                .curve(to: SymbolPoint(100, 30), control1: SymbolPoint(120, 35), control2: SymbolPoint(110, 30)),
                .close,
            ]
        case .hostile:
            // M67,50 L100,20 133,50 z
            return [
                .move(to: SymbolPoint(67, 50)),
                .line(to: SymbolPoint(100, 20)),
                .line(to: SymbolPoint(133, 50)),
                .close,
            ]
        case .neutral:
            // M45,50 l0,-20 110,0 0,20 z
            return [
                .move(to: SymbolPoint(45, 50)),
                .line(to: SymbolPoint(45, 30)),
                .line(to: SymbolPoint(155, 30)),
                .line(to: SymbolPoint(155, 50)),
                .close,
            ]
        case .unknown:
            // M 100 22.5 C 85 22.5 70 31.669211 66 50 L 134 50
            // C 130 31.669204 115 22.5 100 22.5 z
            return [
                .move(to: SymbolPoint(100, 22.5)),
                .curve(to: SymbolPoint(66, 50), control1: SymbolPoint(85, 22.5), control2: SymbolPoint(70, 31.669211)),
                .line(to: SymbolPoint(134, 50)),
                .curve(to: SymbolPoint(100, 22.5), control1: SymbolPoint(130, 31.669204), control2: SymbolPoint(115, 22.5)),
                .close,
            ]
        }
    }

    // MARK: - Activity corner brackets

    /// The four filled corner marks drawn on activity frames, ported
    /// from milsymbol basegeometry.js activity modifiers (relative
    /// paths made absolute). One path with four subpaths.
    public static func activityModifierSegments(base: FrameBase) -> [PathSegment] {
        switch base {
        case .friend:
            return [
                .move(to: SymbolPoint(160, 135)),
                .line(to: SymbolPoint(160, 150)),
                .line(to: SymbolPoint(175, 150)),
                .line(to: SymbolPoint(175, 135)),
                .close,
                .move(to: SymbolPoint(25, 135)),
                .line(to: SymbolPoint(40, 135)),
                .line(to: SymbolPoint(40, 150)),
                .line(to: SymbolPoint(25, 150)),
                .close,
                .move(to: SymbolPoint(160, 50)),
                .line(to: SymbolPoint(160, 65)),
                .line(to: SymbolPoint(175, 65)),
                .line(to: SymbolPoint(175, 50)),
                .close,
                .move(to: SymbolPoint(25, 50)),
                .line(to: SymbolPoint(40, 50)),
                .line(to: SymbolPoint(40, 65)),
                .line(to: SymbolPoint(25, 65)),
                .close,
            ]
        case .neutral:
            return [
                .move(to: SymbolPoint(140, 140)),
                .line(to: SymbolPoint(155, 140)),
                .line(to: SymbolPoint(155, 155)),
                .line(to: SymbolPoint(140, 155)),
                .close,
                .move(to: SymbolPoint(60, 140)),
                .line(to: SymbolPoint(60, 155)),
                .line(to: SymbolPoint(45, 155)),
                .line(to: SymbolPoint(45, 140)),
                .close,
                .move(to: SymbolPoint(140, 60)),
                .line(to: SymbolPoint(140, 45)),
                .line(to: SymbolPoint(155, 45)),
                .line(to: SymbolPoint(155, 60)),
                .close,
                .move(to: SymbolPoint(60, 60)),
                .line(to: SymbolPoint(45, 60)),
                .line(to: SymbolPoint(45, 45)),
                .line(to: SymbolPoint(60, 45)),
                .close,
            ]
        case .hostile:
            return [
                .move(to: SymbolPoint(100, 28)),
                .line(to: SymbolPoint(89.40625, 38.59375)),
                .line(to: SymbolPoint(100, 49.21875)),
                .line(to: SymbolPoint(110.59375, 38.59375)),
                .close,
                .move(to: SymbolPoint(38.6875, 89.3125)),
                .line(to: SymbolPoint(28.0625, 99.9375)),
                .line(to: SymbolPoint(38.6875, 110.53125)),
                .line(to: SymbolPoint(49.28125, 99.9375)),
                .close,
                .move(to: SymbolPoint(161.40625, 89.40625)),
                .line(to: SymbolPoint(150.78125, 100)),
                .line(to: SymbolPoint(161.40625, 110.59375)),
                .line(to: SymbolPoint(172, 100)),
                .close,
                .move(to: SymbolPoint(99.9375, 150.71875)),
                .line(to: SymbolPoint(89.3125, 161.3125)),
                .line(to: SymbolPoint(99.9375, 171.9375)),
                .line(to: SymbolPoint(110.53125, 161.3125)),
                .close,
            ]
        case .unknown:
            return [
                .move(to: SymbolPoint(107.96875, 31.46875)),
                .line(to: SymbolPoint(92.03125, 31.71875)),
                .line(to: SymbolPoint(92.03125, 46.4375)),
                .line(to: SymbolPoint(107.71875, 46.4375)),
                .close,
                .move(to: SymbolPoint(47.03125, 92.5)),
                .line(to: SymbolPoint(31.09375, 92.75)),
                .line(to: SymbolPoint(31.09375, 107.5)),
                .line(to: SymbolPoint(46.78125, 107.5)),
                .close,
                .move(to: SymbolPoint(168.4375, 92.5)),
                .line(to: SymbolPoint(152.5, 92.75)),
                .line(to: SymbolPoint(152.5, 107.5)),
                .line(to: SymbolPoint(168.1875, 107.5)),
                .close,
                .move(to: SymbolPoint(107.96875, 153.5625)),
                .line(to: SymbolPoint(92.03125, 153.8125)),
                .line(to: SymbolPoint(92.03125, 168.53125)),
                .line(to: SymbolPoint(107.71875, 168.53125)),
                .close,
            ]
        }
    }
}

/// Composes the drawable geometry for a symbol: frame, frame-level
/// overlays, and the main icon when the ``IconLibrary`` knows it.
public enum SymbolComposer {

    /// The style used for filled frame-level overlays (space bar,
    /// activity corners): frame color fill, no stroke.
    static let overlayFill = DrawStyle(fill: .frameStroke)

    /// Builds the geometry for a symbol. Unframeable symbols (domains
    /// with no frame defined) return empty geometry; the graceful
    /// degradation path for unknown icons keeps the frame and drops the
    /// icon, and the degradation path for unknown frames is no drawing
    /// at all rather than a wrong drawing.
    /// The horizontal gap between the frame's right edge and the
    /// exercise amplifier letter: milsymbol tucks the text 10 units
    /// closer for unknown frames and for hostile frames outside the
    /// subsurface dimension, whose right edges taper. Fakers keep the
    /// default spacing despite their hostile colors: they wear the
    /// flat-edged friend frame, and milsymbol's tuck condition does not
    /// match them (oracle-verified).
    private static func exerciseTextSpacing(for symbol: MilSymbol) -> Double {
        let affiliation = symbol.affiliation
        if affiliation == .unknown || affiliation == .pending { return -10 }
        if affiliation == .hostile, symbol.domain != .subsurface {
            return -10
        }
        return 10
    }

    public static func geometry(for symbol: MilSymbol) -> SymbolGeometry {
        let frame = symbol.frame
        let base = symbol.affiliation.frameBase
        var instructions: [DrawInstruction] = []

        // Domains with no frame rendering (control measure points and
        // other frameless symbol sets) still render their icon when the
        // library carries one: milsymbol treats them as icon-only, like
        // unframed sea own tracks.
        guard let shape = frame.shape else {
            if let icon = IconLibrary.instructions(for: symbol.iconKey, base: base) {
                instructions.append(contentsOf: icon)
            }
            return SymbolGeometry(instructions: instructions)
        }

        if frame.isFramed {
            // The frame itself: affiliation fill under a solid stroke.
            instructions.append(instruction(for: shape, style: .frame))

            // Filled overlays, painted in milsymbol order.
            if frame.hasSpaceModifier {
                instructions.append(.path(SymbolPath(
                    segments: FrameGeometry.spaceModifierSegments(base: base),
                    style: overlayFill
                )))
            }
            if frame.hasActivityModifier {
                instructions.append(.path(SymbolPath(
                    segments: FrameGeometry.activityModifierSegments(base: base),
                    style: overlayFill
                )))
            }

            // The dashed overlay is stroked on top of the solid frame.
            if let dash = frame.dash {
                instructions.append(instruction(
                    for: shape,
                    style: .frameDashOverlay(pattern: dash.pattern)
                ))
            }
        }
        // Unframed symbols (sea own track) skip the frame, fill, and
        // overlays entirely and render the icon alone.

        // The exercise amplifier (X/J/K/S beside the frame) draws
        // between the base geometry and the icon, matching milsymbol's
        // affliationdimension part. The glyph outlines are baked at
        // build time by tools/extract/bake-glyphs.js; absent glyphs
        // degrade to no letter.
        if frame.isFramed, let letter = symbol.exerciseAmplifierLetter,
           let glyph = GeneratedExerciseGlyphs.segments(for: letter) {
            let bounds = FrameGeometry.bounds(for: shape)
            instructions.append(ModifierGeometry.exerciseAmplifier(
                glyph: glyph,
                x: bounds.x2 + exerciseTextSpacing(for: symbol),
                y: letter == "X" ? 50 : 40
            ))
        }

        // The main icon paints last, matching milsymbol's part order
        // (its base geometry part emits the dash overlay before the
        // icon part runs). Unknown icons degrade to frame and fill.
        if let icon = IconLibrary.instructions(for: symbol.iconKey, base: base) {
            instructions.append(contentsOf: icon)
        }

        // Frame amplifiers, in milsymbol's modifier emission order:
        // headquarters staff, task force bracket, installation bar,
        // feint/dummy caret, echelon, mobility. Every part positions
        // off the original frame bounds, exactly as milsymbol does.
        // Amplifiers apply only to framed symbols.
        if frame.isFramed {
            let bounds = FrameGeometry.bounds(for: shape)
            let hqtfd = symbol.headquartersTaskForceDummy
            let isInstallation = symbol.domain == .landInstallation

            if hqtfd.contains(.headquarters) {
                instructions.append(
                    ModifierGeometry.headquartersStaff(shape: shape, bounds: bounds))
            }
            if hqtfd.contains(.taskForce) {
                instructions.append(
                    ModifierGeometry.taskForceBracket(bounds: bounds, echelon: symbol.echelon))
            }
            if isInstallation {
                instructions.append(
                    ModifierGeometry.installationBar(shape: shape, base: base, bounds: bounds))
            }
            if hqtfd.contains(.feintDummy) {
                instructions.append(
                    ModifierGeometry.feintDummyCaret(bounds: bounds))
            }
            if let echelon = symbol.echelon {
                instructions.append(contentsOf: ModifierGeometry.echelonMark(
                    echelon, bounds: bounds, installationPresent: isInstallation))
            }
            if let mobility = symbol.mobility {
                instructions.append(contentsOf: ModifierGeometry.mobilityMark(
                    mobility, base: base, bounds: bounds))
            }
        }

        return SymbolGeometry(instructions: instructions)
    }

    /// Emits the drawing instruction for one frame outline in one style.
    static func instruction(for shape: FrameShape, style: DrawStyle) -> DrawInstruction {
        if let segments = FrameGeometry.segments(for: shape) {
            return .path(SymbolPath(segments: segments, style: style))
        }
        // The circle frame (friend sea surface / land equipment).
        return .circle(center: SymbolPoint(100, 100), radius: 60, style: style)
    }
}
