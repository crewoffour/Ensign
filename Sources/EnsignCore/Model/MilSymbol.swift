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

/// Everything the composition stage needs to know about a frame.
public struct FrameDescriptor: Hashable, Sendable {
    /// The outline to draw, or `nil` when the domain has no frame
    /// rendering defined (the symbol is parsed but unframeable).
    public let shape: FrameShape?
    /// Whether the frame is drawn dashed: true for uncertain identities
    /// (pending, assumed friend, suspect, joker) and for anticipated or
    /// planned status.
    public let isDashed: Bool
    /// Whether the space bar overlay applies (space domain only).
    public let hasSpaceModifier: Bool
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

    /// The resolved frame descriptor.
    public var frame: FrameDescriptor {
        let base = affiliation.frameBase
        let resolvedDomain = domain
        return FrameDescriptor(
            shape: FrameShape.resolve(base: base, domain: resolvedDomain),
            isDashed: affiliation.isUncertain || status == .anticipated,
            hasSpaceModifier: resolvedDomain == .space
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
}

extension MilSymbol: CustomStringConvertible {
    public var description: String { "MilSymbol(\(sidc.raw))" }
}
