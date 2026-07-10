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
// The standard fill values in this file are ported from milsymbol
// (https://github.com/spatialillusions/milsymbol), Copyright (c)
// Mans Beckman, MIT License. See NOTICE.

/// A framework-free RGBA color with components in 0...1.
public struct SymbolColor: Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Builds a color from 0-255 components, matching how the 2525 fill
    /// values are specified.
    public static func rgb255(_ red: Double, _ green: Double, _ blue: Double) -> SymbolColor {
        SymbolColor(red: red / 255, green: green / 255, blue: blue / 255)
    }

    public static let black = SymbolColor(red: 0, green: 0, blue: 0)
    public static let white = SymbolColor(red: 1, green: 1, blue: 1)
    public static let clear = SymbolColor(red: 0, green: 0, blue: 0, alpha: 0)
}

/// The six fill classes of MIL-STD-2525D/E.
///
/// Distinct from ``Affiliation``: several affiliations share a fill
/// (assumed friend fills as friend, joker fills as suspect, faker fills
/// as hostile), and civilian is a fill class without being an
/// affiliation at all.
public enum FillClass: Hashable, Sendable, CaseIterable {
    case friend
    case hostile
    case neutral
    case unknown
    case civilian
    case suspect
}

/// Resolves semantic ``ColorRole`` values into concrete colors.
///
/// The three standard palettes carry the exact fill values of the
/// corresponding milsymbol color modes, which trace to the 2525 crayon
/// specifications. Custom palettes (high contrast, colorblind-safe,
/// dark map styles) are a value away: construct one and pass it to the
/// renderer.
public struct SymbolPalette: Hashable, Sendable {
    /// The frame outline color. Black in the standard palettes.
    public var frameStroke: SymbolColor
    /// Main icon linework. Black in the standard palettes.
    public var iconStroke: SymbolColor
    /// Filled icon areas. Black in the standard palettes.
    public var iconFill: SymbolColor
    /// The contrast color used for the dashed frame overlay and icon
    /// areas that must read against the affiliation fill. White in the
    /// standard palettes.
    public var contrastFill: SymbolColor
    /// The affiliation fill for each fill class.
    public var fills: [FillClass: SymbolColor]

    public init(
        frameStroke: SymbolColor = .black,
        iconStroke: SymbolColor = .black,
        iconFill: SymbolColor = .black,
        contrastFill: SymbolColor = .white,
        fills: [FillClass: SymbolColor]
    ) {
        self.frameStroke = frameStroke
        self.iconStroke = iconStroke
        self.iconFill = iconFill
        self.contrastFill = contrastFill
        self.fills = fills
    }

    /// Resolves one role for one fill class.
    /// The saturated affiliation colors for unfilled symbols (mine
    /// warfare): milsymbol's unfilled color set. The suspect value is
    /// the evidently intended one; milsymbol 3.0.4 ships it with an
    /// "rbg" typo that produces an invalid color (worth reporting
    /// upstream), so unfilled suspect symbols cannot be
    /// oracle-compared until that is fixed.
    public var affiliationColors: [FillClass: SymbolColor] = [
        .friend: .rgb255(0, 255, 255),
        .hostile: .rgb255(255, 0, 0),
        .neutral: .rgb255(0, 255, 0),
        .unknown: .rgb255(255, 255, 0),
        .civilian: .rgb255(255, 0, 255),
        .suspect: .rgb255(255, 188, 1),
    ]

    /// Operational condition bar colors. Defaults are milsymbol's
    /// fixed values; override in a custom palette for accessibility
    /// (the default green/yellow/red set is hostile to red-green
    /// color vision).
    public var conditionFullyCapable: SymbolColor = .rgb255(0, 255, 0)
    public var conditionDamaged: SymbolColor = .rgb255(255, 255, 0)
    public var conditionDestroyed: SymbolColor = .rgb255(255, 0, 0)
    public var conditionFullToCapacity: SymbolColor = .rgb255(0, 180, 240)

    public func color(for role: ColorRole, fillClass: FillClass) -> SymbolColor {
        switch role {
        case .frameStroke:
            return frameStroke
        case .affiliationFill:
            return fills[fillClass] ?? .clear
        case .iconStroke:
            return iconStroke
        case .iconFill:
            return iconFill
        case .contrastFill:
            return contrastFill
        case .affiliationColor:
            return affiliationColors[fillClass] ?? .clear
        case .conditionFullyCapable:
            return conditionFullyCapable
        case .conditionDamaged:
            return conditionDamaged
        case .conditionDestroyed:
            return conditionDestroyed
        case .conditionFullToCapacity:
            return conditionFullToCapacity
        case .literal(let color):
            return color
        case .none:
            return .clear
        }
    }

    /// The 2525 light fill mode (the common default).
    public static let light = SymbolPalette(fills: [
        .friend: .rgb255(128, 224, 255),
        .hostile: .rgb255(255, 128, 128),
        .neutral: .rgb255(170, 255, 170),
        .unknown: .rgb255(255, 255, 128),
        .civilian: .rgb255(255, 161, 255),
        .suspect: .rgb255(255, 229, 153),
    ])

    /// The 2525 medium fill mode.
    public static let medium = SymbolPalette(fills: [
        .friend: .rgb255(0, 168, 220),
        .hostile: .rgb255(255, 48, 49),
        .neutral: .rgb255(0, 226, 110),
        .unknown: .rgb255(255, 255, 0),
        .civilian: .rgb255(128, 0, 128),
        .suspect: .rgb255(255, 217, 107),
    ])

    /// The 2525 dark fill mode.
    public static let dark = SymbolPalette(fills: [
        .friend: .rgb255(0, 107, 140),
        .hostile: .rgb255(200, 0, 0),
        .neutral: .rgb255(0, 160, 0),
        .unknown: .rgb255(225, 220, 0),
        .civilian: .rgb255(80, 0, 80),
        .suspect: .rgb255(255, 188, 1),
    ])
}

extension MilSymbol {
    /// Whether this symbol is a civilian track.
    ///
    /// Beyond the land civilian symbol set (11), 2525D flags civilians
    /// by entity prefix within several sets; this table matches
    /// milsymbol's numbersidc/metadata.js exactly: air and space
    /// entities 12xxxx, subsurface 12xxxx, land equipment 16xxxx, and
    /// sea surface 14xxxx. Charlie civilian function IDs remain a
    /// future refinement.
    public var isCivilian: Bool {
        guard case .delta(let value) = sidc else { return false }
        let entityPrefix = value.entityCode.prefix(2)
        switch value.symbolSetCode {
        case "11":
            return true
        case "01", "05", "12", "35":
            return entityPrefix == "12"
        case "15":
            return entityPrefix == "16"
        case "30":
            return entityPrefix == "14"
        default:
            return false
        }
    }

    /// Whether the SIDC's edition uses the distinct suspect fill.
    ///
    /// The suspect amber is a 2525E treatment, applied to delta SIDCs
    /// coded with version 13 or 14. Charlie and 2525D-coded suspects
    /// render with the hostile fill and a dashed frame, which is also
    /// exactly what milsymbol does (see numbersidc/metadata.js: the
    /// suspect flag is set only for version 13).
    var usesSuspectFill: Bool {
        if case .delta(let value) = sidc {
            return value.versionCode == 13 || value.versionCode == 14
        }
        return false
    }

    /// The fill class driving the affiliation fill color.
    ///
    /// Suspect and joker take the distinct suspect fill only for
    /// 2525E-coded SIDCs; earlier editions fill them hostile. Civilian
    /// tracks take the civilian fill only when they would otherwise
    /// fill as friend, neutral, or unknown; suspect and hostile
    /// civilians keep the threat fill, per 2525.
    public var fillClass: FillClass {
        let base: FillClass
        switch affiliation {
        case .pending, .unknown:
            base = .unknown
        case .assumedFriend, .friend:
            base = .friend
        case .neutral:
            base = .neutral
        case .suspect, .joker:
            base = usesSuspectFill ? .suspect : .hostile
        case .hostile, .faker:
            base = .hostile
        }
        if isCivilian, base == .friend || base == .neutral || base == .unknown {
            return .civilian
        }
        return base
    }
}
