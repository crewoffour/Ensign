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

/// The normalized symbol domain, version-independent.
///
/// Bridges the charlie battle dimension (plus the ground unit /
/// equipment / installation split encoded in the function ID) and the
/// delta symbol set into the single concept that drives frame selection.
public enum SymbolDomain: Hashable, Sendable {
    case space
    case air
    case landUnit
    case landEquipment
    case landInstallation
    case seaSurface
    case subsurface
    case activity
    /// Dismounted individual (2525D symbol set 27). Distinct from land
    /// unit because 2525D/E gives it its own friend frame, a hexagon.
    case dismountedIndividual
    /// A domain that parses cleanly but has no frame rendering defined
    /// yet (control measures, METOC, cyberspace, tactical graphics, and
    /// unrecognized codes). The associated value preserves the raw
    /// dimension character or symbol set code for diagnostics.
    case other(String)

    /// Resolves the domain for a charlie code. The ground dimension
    /// splits into unit, equipment, and installation using the first
    /// function ID character (U, E, I), per 2525C.
    public init(charlie sidc: CharlieSIDC) {
        guard sidc.codingScheme != .tacticalGraphics else {
            self = .other("G:\(sidc.graphicCategory.map(String.init) ?? "?")")
            return
        }
        guard let dimension = sidc.battleDimension else {
            self = .other("?")
            return
        }
        switch dimension {
        case .space:
            self = .space
        case .air:
            self = .air
        case .ground:
            switch sidc.functionID.first {
            case "E": self = .landEquipment
            case "I": self = .landInstallation
            default: self = .landUnit
            }
        case .seaSurface:
            self = .seaSurface
        case .subsurface:
            self = .subsurface
        case .specialOperations:
            // 2525C SOF symbols use the land-unit frame family.
            self = .landUnit
        case .other, .unknown:
            self = .other(String(dimension.rawValue))
        }
    }

    /// Resolves the domain for a delta code from its symbol set.
    public init(delta sidc: DeltaSIDC) {
        guard let set = sidc.symbolSet else {
            self = .other(sidc.symbolSetCode)
            return
        }
        switch set {
        case .air, .airMissile, .signalsIntelligenceAir:
            self = .air
        case .space, .spaceMissile, .signalsIntelligenceSpace:
            self = .space
        case .landUnit, .landCivilian:
            self = .landUnit
        case .dismountedIndividual:
            self = .dismountedIndividual
        case .landEquipment, .signalsIntelligenceLand:
            self = .landEquipment
        case .landInstallation:
            self = .landInstallation
        case .seaSurface, .signalsIntelligenceSeaSurface:
            self = .seaSurface
        case .seaSubsurface, .mineWarfare, .signalsIntelligenceSubsurface:
            self = .subsurface
        case .activities:
            self = .activity
        case .controlMeasure, .meteorologicalAtmospheric,
             .meteorologicalOceanographic, .cyberspace:
            self = .other(set.rawValue)
        }
    }
}

/// The normalized status and operational condition, version-independent.
public enum OperationalStatus: Hashable, Sendable, CaseIterable {
    case present
    /// Anticipated (charlie) / planned (delta). Renders as a dashed frame.
    case anticipated
    case presentFullyCapable
    case presentDamaged
    case presentDestroyed
    case presentFullToCapacity

    public init(charlie status: CharlieStatus) {
        switch status {
        case .present: self = .present
        case .anticipated: self = .anticipated
        case .presentFullyCapable: self = .presentFullyCapable
        case .presentDamaged: self = .presentDamaged
        case .presentDestroyed: self = .presentDestroyed
        case .presentFullToCapacity: self = .presentFullToCapacity
        }
    }

    public init(delta status: DeltaStatus) {
        switch status {
        case .present: self = .present
        case .planned: self = .anticipated
        case .presentFullyCapable: self = .presentFullyCapable
        case .presentDamaged: self = .presentDamaged
        case .presentDestroyed: self = .presentDestroyed
        case .presentFullToCapacity: self = .presentFullToCapacity
        }
    }
}

/// The distinct frame outlines of MIL-STD-2525, prior to any geometry.
///
/// Geometry for each shape is authored in ``FrameGeometry`` against the
/// 200x200 canvas. The space domain reuses the air outlines and adds a
/// filled bar overlay at composition time, so it introduces no shapes of
/// its own here.
public enum FrameShape: Hashable, Sendable, CaseIterable {
    /// Friend land unit, installation, and activity.
    case rectangle
    /// Friend land equipment and sea surface.
    case circle
    /// Neutral land and sea surface.
    case square
    /// Hostile land and sea surface.
    case diamond
    /// Unknown land and sea surface (four-lobed clover).
    case quatrefoil
    /// Friend dismounted individual (2525D/E only).
    case hexagon
    /// Friend air and space (dome, open at the bottom).
    case archOpenBottom
    /// Friend subsurface (bowl, open at the top).
    case archOpenTop
    /// Neutral air and space.
    case squareOpenBottom
    /// Neutral subsurface.
    case squareOpenTop
    /// Hostile air and space (peaked tent, open at the bottom).
    case tentOpenBottom
    /// Hostile subsurface (chevron, open at the top).
    case tentOpenTop
    /// Unknown air and space (two lobes over an open bottom).
    case cloverOpenBottom
    /// Unknown subsurface (two lobes under an open top).
    case cloverOpenTop

    /// Resolves the frame outline for an affiliation base and domain, or
    /// `nil` when the domain has no frame rendering defined.
    public static func resolve(base: FrameBase, domain: SymbolDomain) -> FrameShape? {
        switch domain {
        case .air, .space:
            switch base {
            case .unknown: return .cloverOpenBottom
            case .friend: return .archOpenBottom
            case .neutral: return .squareOpenBottom
            case .hostile: return .tentOpenBottom
            }
        case .landUnit, .landInstallation, .activity:
            switch base {
            case .unknown: return .quatrefoil
            case .friend: return .rectangle
            case .neutral: return .square
            case .hostile: return .diamond
            }
        case .landEquipment, .seaSurface:
            switch base {
            case .unknown: return .quatrefoil
            case .friend: return .circle
            case .neutral: return .square
            case .hostile: return .diamond
            }
        case .dismountedIndividual:
            switch base {
            case .unknown: return .quatrefoil
            case .friend: return .hexagon
            case .neutral: return .square
            case .hostile: return .diamond
            }
        case .subsurface:
            switch base {
            case .unknown: return .cloverOpenTop
            case .friend: return .archOpenTop
            case .neutral: return .squareOpenTop
            case .hostile: return .tentOpenTop
            }
        case .other:
            return nil
        }
    }
}
