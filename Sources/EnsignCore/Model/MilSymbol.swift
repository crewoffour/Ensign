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

/// The dash treatment for a non-solid frame. Per milsymbol (and for
/// oracle pixel parity), dashing is rendered as a white overlay stroked
/// on top of the solid frame; these cases carry the exact milsymbol
/// dash arrays.
public enum FrameDash: Hashable, Sendable {
    /// Pending, assumed friend, suspect, and joker identities.
    case uncertainIdentity
    /// Anticipated (charlie) / planned (delta) status.
    case anticipatedStatus

    /// The dash array in canvas units.
    public var pattern: [Double] {
        switch self {
        case .uncertainIdentity: return [4, 4]
        case .anticipatedStatus: return [8, 12]
        }
    }
}

/// Everything the composition stage needs to know about a frame.
public struct FrameDescriptor: Hashable, Sendable {
    /// The outline to draw, or `nil` when the domain has no frame
    /// rendering defined (the symbol is parsed but unframeable).
    public let shape: FrameShape?
    /// Whether the frame is drawn at all. Sea own tracks render icon
    /// only, with no frame, fill, or overlays, per the standard and
    /// milsymbol. Distinct from `shape == nil`: an unframed symbol has
    /// a resolvable shape that is deliberately not drawn.
    public let isFramed: Bool
    /// Whether the frame is drawn dashed. Equivalent to `dash != nil`.
    public let isDashed: Bool
    /// The dash treatment, or `nil` for a solid frame. Uncertain
    /// identity takes precedence over anticipated status when both
    /// apply, matching milsymbol's assignment order.
    public let dash: FrameDash?
    /// Whether the space bar overlay applies (space domain only).
    public let hasSpaceModifier: Bool
    /// Whether the activity corner brackets apply (activity domain only).
    public let hasActivityModifier: Bool
}

/// A stable, version-scoped key identifying a main icon.
///
/// For the charlie family the key is the coding scheme, battle dimension,
/// and function ID; for the delta family it is the symbol set and the
/// six-digit entity code. Icon lookup tables generated from the milsymbol
/// port (and later from the authoritative JMSML data) are keyed by this
/// type.
public struct IconKey: Hashable, Sendable, CustomStringConvertible {
    public let family: SIDCFamily
    public let code: String

    public init(family: SIDCFamily, code: String) {
        self.family = family
        self.code = code
    }

    public var description: String { "\(family.rawValue):\(code)" }
}

/// The normalized symbol model: the single representation both SIDC
/// families resolve into, and the input to the compose-and-emit stages.
///
/// `MilSymbol` is the primary entry point for rendering:
///
/// ```swift
/// let symbol = try MilSymbol("SFSPCLDD-------")
/// symbol.affiliation   // .friend
/// symbol.domain        // .seaSurface
/// symbol.frame.shape   // .circle
/// ```
public struct MilSymbol: Hashable, Sendable {
    /// The parsed, version-tagged code this symbol was built from.
    public let sidc: SIDC

    /// Builds a symbol from an already parsed code.
    public init(sidc: SIDC) {
        self.sidc = sidc
    }

    /// Parses a raw SIDC string and builds a symbol in one step.
    /// - Throws: ``SIDCParseError``.
    public init(_ string: String) throws {
        self.sidc = try SIDC(string)
    }

    /// The normalized affiliation.
    public var affiliation: Affiliation {
        switch sidc {
        case .charlie(let value):
            return Affiliation(charlie: value.standardIdentity)
        case .delta(let value):
            return Affiliation(delta: value.standardIdentity, context: value.context)
        }
    }

    /// Whether this symbol is an exercise track. Orthogonal to
    /// affiliation, matching the 2525D context model; charlie exercise
    /// identities set this flag.
    public var isExercise: Bool {
        switch sidc {
        case .charlie(let value):
            return value.standardIdentity.isExercise
        case .delta(let value):
            return value.context == .exercise
        }
    }

    /// Whether this symbol is a simulation track (delta family only;
    /// always false for charlie codes).
    public var isSimulation: Bool {
        if case .delta(let value) = sidc {
            return value.context == .simulation
        }
        return false
    }

    /// The dismounted leadership amplifier, when present. Decoded from
    /// the delta amplifier pair; the charlie encoding is deferred.
    public var leadership: Leadership? {
        if case .delta(let value) = sidc {
            return Leadership(deltaAmplifier: value.amplifier)
        }
        return nil
    }

    /// Whether the frame renders with the affiliation fill. Mine
    /// warfare (delta set 36) is framed but unfilled per milsymbol's
    /// metadata (frame true, fill false): the frame outline and icons
    /// carry the saturated affiliation colors instead of the pastel
    /// fills. The charlie mine warfare encoding is deferred.
    public var isFilled: Bool {
        if case .delta(let value) = sidc {
            return value.symbolSetCode != "36"
        }
        return true
    }

    /// Whether this symbol renders without any frame (sea own tracks).
    public var rendersUnframed: Bool {
        isOwnTrack
    }

    /// The exercise amplifier letter drawn beside the frame, when any:
    /// "J" joker, "K" faker, "S" simulation, "X" other exercise tracks.
    public var exerciseAmplifierLetter: Character? {
        if affiliation == .joker { return "J" }
        if affiliation == .faker { return "K" }
        if isSimulation { return "S" }
        if isExercise { return "X" }
        return nil
    }

    /// The normalized domain driving frame selection.
    public var domain: SymbolDomain {
        switch sidc {
        case .charlie(let value):
            return SymbolDomain(charlie: value)
        case .delta(let value):
            return SymbolDomain(delta: value)
        }
    }

    /// The normalized status and operational condition.
    public var status: OperationalStatus {
        switch sidc {
        case .charlie(let value):
            return OperationalStatus(charlie: value.status)
        case .delta(let value):
            return OperationalStatus(delta: value.status)
        }
    }

    /// The headquarters / task force / feint-dummy flags, when present.
    public var headquartersTaskForceDummy: HQTFDummy {
        switch sidc {
        case .charlie(let value):
            return value.headquartersTaskForceDummy ?? []
        case .delta(let value):
            return value.headquartersTaskForceDummy
        }
    }

    /// The echelon indicator, when present.
    public var echelon: Echelon? {
        switch sidc {
        case .charlie(let value):
            return value.echelon
        case .delta(let value):
            return value.echelon
        }
    }

    /// The mobility indicator, when present, decoded from either
    /// dialect: the delta amplifier pair or the charlie M/N symbol
    /// modifier codes.
    public var mobility: Mobility? {
        switch sidc {
        case .delta(let value):
            return Mobility(deltaAmplifier: value.amplifier)
        case .charlie(let value):
            return Mobility(charlieModifier: value.symbolModifier)
        }
    }

    /// Whether the installation bar renders: the delta installation
    /// symbol set, or the charlie H symbol modifier that marks any
    /// symbol as an installation.
    public var isInstallation: Bool {
        if domain == .landInstallation { return true }
        if case .charlie(let value) = sidc {
            return value.isInstallationModifier
        }
        return false
    }

    /// Whether this is a sea surface own track (delta set 30, entity
    /// 150000), which 2525 renders unframed: icon only, no frame or
    /// fill. Matches milsymbol's numbersidc metadata rule.
    public var isOwnTrack: Bool {
        if case .delta(let value) = sidc {
            return value.symbolSetCode == "30" && value.entityCode == "150000"
        }
        return false
    }

    /// Whether this is a fused track (delta 30/160000, 35/140000, or
    /// 35/150000), which always renders with the pending dashed frame
    /// regardless of identity. Matches milsymbol's numbersidc metadata
    /// rule.
    public var isFusedTrack: Bool {
        if case .delta(let value) = sidc {
            switch (value.symbolSetCode, value.entityCode) {
            case ("30", "160000"), ("35", "140000"), ("35", "150000"):
                return true
            default:
                return false
            }
        }
        return false
    }

    /// The resolved frame descriptor.
    public var frame: FrameDescriptor {
        let base = affiliation.frameBase
        let resolvedDomain = domain
        let dash: FrameDash?
        if affiliation.isUncertain || isFusedTrack {
            dash = .uncertainIdentity
        } else if status == .anticipated {
            dash = .anticipatedStatus
        } else {
            dash = nil
        }
        return FrameDescriptor(
            shape: FrameShape.resolve(base: base, domain: resolvedDomain),
            isFramed: !rendersUnframed,
            isDashed: dash != nil,
            dash: dash,
            hasSpaceModifier: resolvedDomain == .space,
            hasActivityModifier: resolvedDomain == .activity
        )
    }

    /// The version-scoped key for main icon lookup.
    ///
    /// When the icon key has no entry in the icon tables, the defined
    /// fallback is to render frame and fill without an icon. A library
    /// facing live CoT traffic must degrade gracefully on codes it has
    /// never seen; hard failure is reserved for codes that do not parse.
    public var iconKey: IconKey {
        switch sidc {
        case .charlie(let value):
            let dimension = value.battleDimension.map { String($0.rawValue) }
                ?? value.graphicCategory.map { String($0) }
                ?? "-"
            let scheme = String(value.codingScheme.rawValue)
            return IconKey(family: .charlie, code: scheme + dimension + value.functionID)
        case .delta(let value):
            return IconKey(family: .delta, code: value.symbolSetCode + value.entityCode)
        }
    }

    /// Icon key for the sector one modifier icon (SIDC digits 17-18),
    /// or nil when no modifier is set. Modifier icon codes use the
    /// convention set + "m1" + code, disjoint from entity codes by the
    /// letters. Sector modifiers are a delta-dialect concept; charlie
    /// encodes its variants in the function ID itself.
    public var sectorOneModifierIconKey: IconKey? {
        guard case .delta(let value) = sidc, value.sectorOneModifier != "00" else {
            return nil
        }
        return IconKey(family: .delta,
                       code: value.symbolSetCode + "m1" + value.sectorOneModifier)
    }

    /// Icon key for the sector two modifier icon (SIDC digits 19-20),
    /// or nil when no modifier is set.
    public var sectorTwoModifierIconKey: IconKey? {
        guard case .delta(let value) = sidc, value.sectorTwoModifier != "00" else {
            return nil
        }
        return IconKey(family: .delta,
                       code: value.symbolSetCode + "m2" + value.sectorTwoModifier)
    }

    /// The icon key an icon extraction of this SIDC isolates: for a
    /// modifier-probe code (entity 000000 with exactly one sector
    /// modifier set), the extraction's middle IS the modifier icon, so
    /// the modifier key is the truthful assignment; for everything
    /// else, the entity icon key. This is what the keys tool emits for
    /// the extraction pipeline.
    public var extractionIconKey: IconKey {
        if case .delta(let value) = sidc, value.entityCode == "000000" {
            if let one = sectorOneModifierIconKey, sectorTwoModifierIconKey == nil {
                return one
            }
            if let two = sectorTwoModifierIconKey, sectorOneModifierIconKey == nil {
                return two
            }
        }
        return iconKey
    }
}

extension MilSymbol: CustomStringConvertible {
    public var description: String { "MilSymbol(\(sidc.raw))" }
}
