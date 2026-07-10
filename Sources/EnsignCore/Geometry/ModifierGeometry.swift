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
// The amplifier geometry in this file (headquarters staff, task force
// bracket, installation bar, feint/dummy caret, echelon marks, and
// mobility indicators) is ported coordinate-for-coordinate from
// milsymbol's symbolfunctions/modifier.js
// (https://github.com/spatialillusions/milsymbol), Copyright (c)
// Mans Beckman, MIT License, for oracle pixel parity. See NOTICE.

/// The authored geometry for frame amplifiers, positioned off the
/// frame bounds exactly as milsymbol positions them: every part
/// references the original frame bbox, never an accumulated one.
public enum ModifierGeometry {

    /// Amplifier linework: frame color stroke, no fill.
    static let stroke = DrawStyle(stroke: .frameStroke, strokeWidth: 4)
    /// Filled amplifier marks (installation bar, filled echelon dots,
    /// towed array symbols): frame color fill and stroke.
    static let filled = DrawStyle(fill: .frameStroke, stroke: .frameStroke, strokeWidth: 4)
    /// The feint/dummy caret stroke, dashed with milsymbol's
    /// feintDummy array.
    static let feintDummyStroke = DrawStyle(stroke: .frameStroke, strokeWidth: 4, dash: [8, 8])

    // MARK: - Headquarters staff

    /// The HQ staff: a line from the frame's left edge down to
    /// `bounds.y2 + 100` canvas units. The attachment point is the
    /// frame's bottom corner where one exists (per milsymbol's
    /// dimension+affiliation table), the top corner for the friend
    /// subsurface arch, and the canvas midline otherwise.
    public static func headquartersStaff(shape: FrameShape, bounds: FrameBounds) -> DrawInstruction {
        // milsymbol keys this on dimension+affiliation strings; the
        // dismounted hexagon's dimension is "LandDismountedIndividual",
        // not "Ground", so it deliberately takes the default midline.
        let y: Double
        switch shape {
        case .rectangle, .square,
             .archOpenBottom, .squareOpenBottom, .squareOpenTop:
            y = bounds.y2
        case .archOpenTop:
            y = bounds.y1
        default:
            y = 100
        }
        return .path(SymbolPath(segments: [
            .move(to: SymbolPoint(bounds.x1, y)),
            .line(to: SymbolPoint(bounds.x1, bounds.y2 + 100)),
        ], style: stroke))
    }

    // MARK: - Task force bracket

    /// The task force bracket above the frame, widened for the large
    /// echelons per milsymbol's table (Corps/MEF 110, Army 145, Army
    /// Group 180, Region/Theater 215, otherwise 90).
    public static func taskForceBracket(bounds: FrameBounds, echelon: Echelon?) -> DrawInstruction {
        let width: Double
        switch echelon {
        case .corpsMEF: width = 110
        case .army: width = 145
        case .armyGroupFront: width = 180
        case .region: width = 215
        default: width = 90
        }
        return .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100 - width / 2, bounds.y1)),
            .line(to: SymbolPoint(100 - width / 2, bounds.y1 - 40)),
            .line(to: SymbolPoint(100 + width / 2, bounds.y1 - 40)),
            .line(to: SymbolPoint(100 + width / 2, bounds.y1)),
        ], style: stroke))
    }

    // MARK: - Installation bar

    /// The filled installation bar over the frame top. The gap filler
    /// closes the space between the bar and the frame outline per
    /// milsymbol's dimension+affiliation table: 14 for hostile
    /// air/ground/sea frames, 2 for unknown air/ground/sea and the
    /// friend air arch and sea circle, 0 otherwise.
    public static func installationBar(shape: FrameShape, base: FrameBase, bounds: FrameBounds) -> DrawInstruction {
        var gapFiller: Double = 0
        switch (base, shape) {
        case (.hostile, .tentOpenBottom), (.hostile, .diamond):
            gapFiller = 14
        case (.unknown, .cloverOpenBottom), (.unknown, .quatrefoil),
             (.friend, .archOpenBottom), (.friend, .circle):
            gapFiller = 2
        default:
            gapFiller = 0
        }
        let lip = bounds.y1 + gapFiller - 2   // strokeWidth / 2
        return .path(SymbolPath(segments: [
            .move(to: SymbolPoint(85, lip)),
            .line(to: SymbolPoint(85, bounds.y1 - 10)),
            .line(to: SymbolPoint(115, bounds.y1 - 10)),
            .line(to: SymbolPoint(115, lip)),
            .line(to: SymbolPoint(100, bounds.y1 - 4)), // strokeWidth
            .close,
        ], style: filled))
    }

    // MARK: - Feint / dummy caret

    /// The dashed feint/dummy caret: apex above the frame center by
    /// half the frame width, legs to the frame's top corners.
    public static func feintDummyCaret(bounds: FrameBounds) -> DrawInstruction {
        let topPoint = bounds.y1 - (bounds.x2 - bounds.x1) / 2
        return .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, topPoint)),
            .line(to: SymbolPoint(bounds.x1, bounds.y1)),
            .move(to: SymbolPoint(100, topPoint)),
            .line(to: SymbolPoint(bounds.x2, bounds.y1)),
        ], style: feintDummyStroke))
    }

    // MARK: - Echelon marks

    /// The echelon indicator above the frame. When the installation
    /// bar is present the whole mark shifts up 15 canvas units
    /// (milsymbol's installation padding).
    public static func echelonMark(
        _ echelon: Echelon,
        bounds: FrameBounds,
        installationPresent: Bool
    ) -> [DrawInstruction] {
        // milsymbol wraps the mark in translate(0, -15) for
        // installations; every coordinate below is (y1 - constant), so
        // shifting y1 is equivalent.
        let y1 = bounds.y1 - (installationPresent ? 15 : 0)

        func verticalBar(atX x: Double) -> DrawInstruction {
            .path(SymbolPath(segments: [
                .move(to: SymbolPoint(x, y1 - 10)),
                .line(to: SymbolPoint(x, y1 - 35)),
            ], style: stroke))
        }
        func filledDot(atX x: Double) -> DrawInstruction {
            .circle(center: SymbolPoint(x, y1 - 20), radius: 7.5, style: filled)
        }
        // M x,(y1-10) l25,-25 m0,25 l-25,-25
        func xMarkSegments(atX x: Double) -> [PathSegment] {
            [
                .move(to: SymbolPoint(x, y1 - 10)),
                .line(to: SymbolPoint(x + 25, y1 - 35)),
                .move(to: SymbolPoint(x + 25, y1 - 10)),
                .line(to: SymbolPoint(x, y1 - 35)),
            ]
        }
        func xMarks(atXs xs: [Double]) -> DrawInstruction {
            .path(SymbolPath(segments: xs.flatMap { xMarkSegments(atX: $0) }, style: stroke))
        }
        // M x,(y1-22.5) l25,0 m-12.5,12.5 l0,-25
        func plusSegments(atX x: Double) -> [PathSegment] {
            [
                .move(to: SymbolPoint(x, y1 - 22.5)),
                .line(to: SymbolPoint(x + 25, y1 - 22.5)),
                .move(to: SymbolPoint(x + 12.5, y1 - 10)),
                .line(to: SymbolPoint(x + 12.5, y1 - 35)),
            ]
        }

        switch echelon {
        case .teamCrew:
            return [
                .circle(center: SymbolPoint(100, y1 - 20), radius: 15, style: stroke),
                .path(SymbolPath(segments: [
                    .move(to: SymbolPoint(80, y1 - 10)),
                    .line(to: SymbolPoint(120, y1 - 30)),
                ], style: stroke)),
            ]
        case .squad:
            return [filledDot(atX: 100)]
        case .section:
            return [filledDot(atX: 115), filledDot(atX: 85)]
        case .platoonDetachment:
            return [filledDot(atX: 100), filledDot(atX: 70), filledDot(atX: 130)]
        case .companyBatteryTroop:
            return [verticalBar(atX: 100)]
        case .battalionSquadron:
            return [verticalBar(atX: 90), verticalBar(atX: 110)]
        case .regimentGroup:
            return [verticalBar(atX: 100), verticalBar(atX: 120), verticalBar(atX: 80)]
        case .brigade:
            return [xMarks(atXs: [87.5])]
        case .division:
            return [xMarks(atXs: [70, 105])]
        case .corpsMEF:
            return [xMarks(atXs: [52.5, 87.5, 122.5])]
        case .army:
            return [xMarks(atXs: [35, 70, 105, 140])]
        case .armyGroupFront:
            return [xMarks(atXs: [17.5, 52.5, 87.5, 122.5, 157.5])]
        case .region:
            return [xMarks(atXs: [0, 35, 70, 105, 140, 175])]
        case .command:
            return [.path(SymbolPath(
                segments: plusSegments(atX: 70) + plusSegments(atX: 105),
                style: stroke
            ))]
        }
    }

    // MARK: - Mobility indicators

    /// The mobility indicator beneath the frame. milsymbol authors
    /// these in local coordinates translated by the frame's bottom
    /// edge, with per-mark adjustments for the neutral square frame;
    /// this port flattens the translation into absolute coordinates.
    public static func mobilityMark(
        _ mobility: Mobility,
        base: FrameBase,
        bounds: FrameBounds
    ) -> [DrawInstruction] {
        var y = bounds.y2
        if base == .neutral {
            switch mobility {
            case .towed, .shortTowedArray, .longTowedArray:
                y += 8
            case .overSnow, .sled:
                y += 18
            case .barge:
                y += 5
            default:
                break
            }
        }

        func p(_ x: Double, _ localY: Double) -> SymbolPoint {
            SymbolPoint(x, y + localY)
        }
        func wheel(_ cx: Double, _ localCY: Double, r: Double = 8) -> DrawInstruction {
            .circle(center: p(cx, localCY), radius: r, style: stroke)
        }

        switch mobility {
        case .wheeledLimitedCrossCountry:
            return [
                .path(SymbolPath(segments: [
                    .move(to: p(53, 1)), .line(to: p(147, 1)),
                ], style: stroke)),
                wheel(58, 8), wheel(142, 8),
            ]
        case .wheeledCrossCountry:
            return [
                .path(SymbolPath(segments: [
                    .move(to: p(53, 1)), .line(to: p(147, 1)),
                ], style: stroke)),
                wheel(58, 8), wheel(142, 8), wheel(100, 8),
            ]
        case .tracked:
            // M 53,1 l 100,0 c15,0 15,15 0,15 l -100,0 c-15,0 -15,-15 0,-15
            return [.path(SymbolPath(segments: [
                .move(to: p(53, 1)),
                .line(to: p(153, 1)),
                .curve(to: p(153, 16), control1: p(168, 1), control2: p(168, 16)),
                .line(to: p(53, 16)),
                .curve(to: p(53, 1), control1: p(38, 16), control2: p(38, 1)),
            ], style: stroke))]
        case .wheeledAndTracked:
            // circle 58,8 r8; M 83,1 l 70,0 c15,0 15,15 0,15 l -70,0 c-15,0 -15,-15 0,-15
            return [
                wheel(58, 8),
                .path(SymbolPath(segments: [
                    .move(to: p(83, 1)),
                    .line(to: p(153, 1)),
                    .curve(to: p(153, 16), control1: p(168, 1), control2: p(168, 16)),
                    .line(to: p(83, 16)),
                    .curve(to: p(83, 1), control1: p(68, 16), control2: p(68, 1)),
                ], style: stroke)),
            ]
        case .towed:
            return [
                .path(SymbolPath(segments: [
                    .move(to: p(63, 1)), .line(to: p(137, 1)),
                ], style: stroke)),
                wheel(58, 3), wheel(142, 3),
            ]
        case .rail:
            return [
                .path(SymbolPath(segments: [
                    .move(to: p(53, 1)), .line(to: p(149, 1)),
                ], style: stroke)),
                wheel(58, 8), wheel(73, 8), wheel(127, 8), wheel(142, 8),
            ]
        case .overSnow:
            // M 50,-9 l10,10 90,0
            return [.path(SymbolPath(segments: [
                .move(to: p(50, -9)),
                .line(to: p(60, 1)),
                .line(to: p(150, 1)),
            ], style: stroke))]
        case .sled:
            // M 145,-12 c15,0 15,15 0,15 l -90,0 c-15,0 -15,-15 0,-15
            return [.path(SymbolPath(segments: [
                .move(to: p(145, -12)),
                .curve(to: p(145, 3), control1: p(160, -12), control2: p(160, 3)),
                .line(to: p(55, 3)),
                .curve(to: p(55, -12), control1: p(40, 3), control2: p(40, -12)),
            ], style: stroke))]
        case .packAnimals:
            // M 80,20 l 10,-20 10,20 10,-20 10,20
            return [.path(SymbolPath(segments: [
                .move(to: p(80, 20)),
                .line(to: p(90, 0)),
                .line(to: p(100, 20)),
                .line(to: p(110, 0)),
                .line(to: p(120, 20)),
            ], style: stroke))]
        case .barge:
            // M 50,1 l 100,0 c0,10 -100,10 -100,0
            return [.path(SymbolPath(segments: [
                .move(to: p(50, 1)),
                .line(to: p(150, 1)),
                .curve(to: p(50, 1), control1: p(150, 11), control2: p(50, 11)),
            ], style: stroke))]
        case .amphibious:
            // Seven alternating relative cubics starting at (65, 10).
            var segments: [PathSegment] = [.move(to: p(65, 10))]
            var x: Double = 65
            for wave in 0..<7 {
                let up = wave % 2 == 0
                let controlY: Double = up ? 0 : 20
                segments.append(.curve(
                    to: p(x + 10, 10),
                    control1: p(x, controlY),
                    control2: p(x + 10, controlY)
                ))
                x += 10
            }
            return [.path(SymbolPath(segments: segments, style: stroke))]
        case .shortTowedArray:
            // Filled: line, end squares, center diamond.
            return [.path(SymbolPath(segments: [
                .move(to: p(50, 5)), .line(to: p(150, 5)),
                .move(to: p(50, 0)), .line(to: p(60, 0)), .line(to: p(60, 10)), .line(to: p(50, 10)), .close,
                .move(to: p(150, 0)), .line(to: p(140, 0)), .line(to: p(140, 10)), .line(to: p(150, 10)), .close,
                .move(to: p(100, 0)), .line(to: p(105, 5)), .line(to: p(100, 10)), .line(to: p(95, 5)), .close,
            ], style: filled))]
        case .longTowedArray:
            // Filled: line, end squares, center square, two diamonds.
            return [.path(SymbolPath(segments: [
                .move(to: p(50, 5)), .line(to: p(150, 5)),
                .move(to: p(50, 0)), .line(to: p(60, 0)), .line(to: p(60, 10)), .line(to: p(50, 10)), .close,
                .move(to: p(150, 0)), .line(to: p(140, 0)), .line(to: p(140, 10)), .line(to: p(150, 10)), .close,
                .move(to: p(105, 0)), .line(to: p(95, 0)), .line(to: p(95, 10)), .line(to: p(105, 10)), .close,
                .move(to: p(75, 0)), .line(to: p(80, 5)), .line(to: p(75, 10)), .line(to: p(70, 5)), .close,
                .move(to: p(125, 0)), .line(to: p(130, 5)), .line(to: p(125, 10)), .line(to: p(120, 5)), .close,
            ], style: filled))]
        }
    }
}
