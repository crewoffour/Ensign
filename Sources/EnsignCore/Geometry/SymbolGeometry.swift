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

/// A point on the 200x200 symbol canvas.
///
/// Named `SymbolPoint` rather than `Point` so adopters never collide
/// with their own geometry types. The origin is top-left; the symbol
/// anchor is the canvas center at (100, 100), matching the milsymbol
/// convention so ported definitions transfer without transformation.
public struct SymbolPoint: Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

/// A semantic color slot, resolved to an actual color at render time.
///
/// Geometry never carries literal colors. This keeps the Foundation-only
/// core free of any graphics framework, lets the 2525 light, medium, and
/// dark fill modes remain a render-time choice, and makes custom palettes
/// (including accessibility palettes) a single substitution point rather
/// than a geometry rewrite.
public enum ColorRole: Hashable, Sendable {
    /// The frame outline. Standard rendering uses black.
    case frameStroke
    /// The frame interior, resolved per affiliation and fill mode.
    case affiliationFill
    /// Main icon linework drawn over the fill.
    case iconStroke
    /// Icon areas filled with the icon color.
    case iconFill
    /// Icon areas that must contrast against the affiliation fill
    /// (typically white in standard rendering).
    case contrastFill
    /// The saturated affiliation color used by unfilled symbols (mine
    /// warfare), where the frame outline and icons carry the
    /// affiliation instead of a fill: pure red, cyan, green, yellow,
    /// per milsymbol's unfilled color set.
    case affiliationColor
    /// Operational condition bar fills. Defaults match milsymbol's
    /// fixed condition colors; custom palettes can override them,
    /// which is the substitution point for accessibility palettes
    /// (fully capable green vs destroyed red is a classic red-green
    /// confusion pair).
    case conditionFullyCapable
    case conditionDamaged
    case conditionDestroyed
    case conditionFullToCapacity
    /// A fixed, palette-independent color. Some icons (mine warfare's
    /// red, per the standard's MEDAL coloring) carry literal colors
    /// that never vary with affiliation or fill mode; the generator
    /// emits these as literals and notes them in its output.
    case literal(SymbolColor)
    /// No paint; used for construction paths.
    case none
}

/// Stroke and fill parameters for one instruction.
public struct DrawStyle: Hashable, Sendable {
    public var fill: ColorRole
    public var stroke: ColorRole
    public var strokeWidth: Double
    /// A dash pattern in canvas units, or `nil` for a solid stroke.
    public var dash: [Double]?

    public init(
        fill: ColorRole = .none,
        stroke: ColorRole = .none,
        strokeWidth: Double = 0,
        dash: [Double]? = nil
    ) {
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.dash = dash
    }

    /// The standard frame style: affiliation fill under a solid stroked
    /// outline. Dashing is never applied to the frame stroke itself; per
    /// milsymbol (and for oracle pixel parity), uncertain and anticipated
    /// frames draw a white dashed overlay on top of the solid frame. See
    /// ``frameDashOverlay(pattern:)``.
    public static let frame = DrawStyle(
        fill: .affiliationFill,
        stroke: .frameStroke,
        strokeWidth: 4
    )

    /// The dashed overlay stroked over a solid frame for uncertain
    /// identities and anticipated status: contrast color (white in the
    /// standard palettes), one unit wider than the frame stroke so it
    /// fully covers it, dashed with the given pattern.
    public static func frameDashOverlay(pattern: [Double]) -> DrawStyle {
        DrawStyle(
            stroke: .contrastFill,
            strokeWidth: 5,
            dash: pattern
        )
    }

    /// The standard icon linework style.
    public static let iconLine = DrawStyle(stroke: .iconStroke, strokeWidth: 4)
}

/// One segment of a path. Curves use cubic and quadratic Bezier control
/// points; arcs are circular, with angles in radians measured from the
/// positive x axis.
public enum PathSegment: Hashable, Sendable {
    case move(to: SymbolPoint)
    case line(to: SymbolPoint)
    case quadCurve(to: SymbolPoint, control: SymbolPoint)
    case curve(to: SymbolPoint, control1: SymbolPoint, control2: SymbolPoint)
    case arc(center: SymbolPoint, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool)
    case close
}

/// A styled path.
public struct SymbolPath: Hashable, Sendable {
    public var segments: [PathSegment]
    public var style: DrawStyle

    public init(segments: [PathSegment], style: DrawStyle) {
        self.segments = segments
        self.style = style
    }
}

/// One drawing operation. Text does not appear here by design: main-icon
/// lettering arrives as outline paths from the extraction pipeline so
/// that rendering is deterministic and font-free on every platform.
/// Dynamic text (the amplifier fields around the symbol) is laid out
/// here in Core, in canvas coordinates with anchors, and shaped into
/// glyphs by EnsignRender with Core Text and the bundled fonts.
public enum DrawInstruction: Hashable, Sendable {
    case path(SymbolPath)
    case circle(center: SymbolPoint, radius: Double, style: DrawStyle)
    case text(TextInstruction)
}

/// Anchored text in canvas coordinates: the info field layout's
/// output. The renderer shapes it with the bundled Liberation fonts;
/// the reference renderer shapes the same coordinates with the same
/// fonts, which is what keeps text oracle-comparable.
public struct TextInstruction: Hashable, Sendable {
    public enum Anchor: Hashable, Sendable {
        case start, middle, end
    }
    public enum Baseline: Hashable, Sendable {
        /// The y coordinate is the alphabetic baseline (SVG default).
        case alphabetic
        /// The y coordinate is the glyph vertical center
        /// (alignment-baseline middle).
        case middle
    }
    public var text: String
    public var x: Double
    public var y: Double
    public var anchor: Anchor
    public var baseline: Baseline
    public var fontSize: Double
    public var isBold: Bool
    public var fill: ColorRole

    public init(text: String, x: Double, y: Double,
                anchor: Anchor = .start, baseline: Baseline = .alphabetic,
                fontSize: Double, isBold: Bool = false, fill: ColorRole) {
        self.text = text
        self.x = x
        self.y = y
        self.anchor = anchor
        self.baseline = baseline
        self.fontSize = fontSize
        self.isBold = isBold
        self.fill = fill
    }
}

/// A complete symbol drawing: an ordered list of instructions against
/// the 200x200 canvas. This is what the compose stage produces and what
/// EnsignRender turns into Core Graphics paths, images, and SwiftUI
/// shapes.
public struct SymbolGeometry: Hashable, Sendable {
    /// The canvas side length. Always ``Ensign/canvasSize`` today; carried
    /// on the value so geometry is self-describing.
    public var canvasSize: Double

    /// The grown canvas for symbols with info fields, in canvas
    /// coordinates, or nil for the standard square canvas. Renderers
    /// honoring it produce non-square output sized to these bounds,
    /// matching milsymbol's grown SVG viewbox.
    public var canvasBounds: FrameBounds? = nil
    /// Instructions in back-to-front paint order.
    public var instructions: [DrawInstruction]

    public init(canvasSize: Double = Ensign.canvasSize, instructions: [DrawInstruction] = []) {
        self.canvasSize = canvasSize
        self.instructions = instructions
    }
}
