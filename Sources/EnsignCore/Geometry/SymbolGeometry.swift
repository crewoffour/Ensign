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
public enum ColorRole: Hashable, Sendable, CaseIterable {
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

    /// The standard frame style: affiliation fill under a stroked outline.
    public static func frame(dashed: Bool) -> DrawStyle {
        DrawStyle(
            fill: .affiliationFill,
            stroke: .frameStroke,
            strokeWidth: 4,
            dash: dashed ? [12, 12] : nil
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
/// Dynamic text (the amplifier fields around the symbol) is composed in
/// EnsignRender with Core Text and never passes through this model.
public enum DrawInstruction: Hashable, Sendable {
    case path(SymbolPath)
    case circle(center: SymbolPoint, radius: Double, style: DrawStyle)
}

/// A complete symbol drawing: an ordered list of instructions against
/// the 200x200 canvas. This is what the compose stage produces and what
/// EnsignRender turns into Core Graphics paths, images, and SwiftUI
/// shapes.
public struct SymbolGeometry: Hashable, Sendable {
    /// The canvas side length. Always ``Ensign/canvasSize`` today; carried
    /// on the value so geometry is self-describing.
    public var canvasSize: Double
    /// Instructions in back-to-front paint order.
    public var instructions: [DrawInstruction]

    public init(canvasSize: Double = Ensign.canvasSize, instructions: [DrawInstruction] = []) {
        self.canvasSize = canvasSize
        self.instructions = instructions
    }
}
