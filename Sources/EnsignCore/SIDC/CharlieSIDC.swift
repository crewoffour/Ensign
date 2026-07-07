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

import Foundation

/// A parsed 15-character MIL-STD-2525A/B/C Symbol Identification Code.
///
/// Layout (1-based positions):
///
/// | Position | Field |
/// |---|---|
/// | 1 | Coding scheme |
/// | 2 | Standard identity (affiliation) |
/// | 3 | Battle dimension (or graphic category for scheme G) |
/// | 4 | Status |
/// | 5-10 | Function ID |
/// | 11-12 | Symbol modifier (HQ/TF/dummy, echelon, or mobility) |
/// | 13-14 | Country code |
/// | 15 | Order of battle |
///
/// Input is normalized before parsing: whitespace trimmed, lowercase
/// raised, `*` mapped to `-`, and codes of 10 to 14 characters padded to
/// 15 with `-`, since real-world TAK traffic frequently omits trailing
/// fill. The normalized form is preserved in ``raw``.
public struct CharlieSIDC: Hashable, Sendable {
    /// The normalized 15-character code.
    public let raw: String
    /// Position 1: the coding scheme.
    public let codingScheme: CharlieCodingScheme
    /// Position 2: the standard identity.
    public let standardIdentity: CharlieStandardIdentity
    /// Position 3: the battle dimension. `nil` for the tactical graphics
    /// scheme, where position 3 is a category instead; see
    /// ``graphicCategory``.
    public let battleDimension: CharlieBattleDimension?
    /// Position 3 raw character when the coding scheme is tactical
    /// graphics (`G`). `nil` otherwise.
    public let graphicCategory: Character?
    /// Position 4: the status / operational condition.
    public let status: CharlieStatus
    /// Positions 5-10: the six-character function ID identifying the
    /// entity type. Fill characters are preserved.
    public let functionID: String
    /// Positions 11-12: the raw symbol modifier pair. Decoded views are
    /// available via ``headquartersTaskForceDummy``, ``echelon``, and
    /// ``isInstallationModifier``.
    public let symbolModifier: String
    /// Positions 13-14: the country code, or `nil` when unfilled.
    public let countryCode: String?
    /// Position 15: the order of battle character, or `nil` when unfilled.
    public let orderOfBattle: Character?

    /// Parses a charlie-family SIDC string.
    /// - Throws: ``SIDCParseError``.
    public init(_ string: String) throws {
        // Normalize: trim, uppercase, map '*' fill alias to '-'.
        var normalized = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: "*", with: "-")

        guard (10...15).contains(normalized.count) else {
            throw SIDCParseError.invalidLength(
                found: normalized.count,
                expected: "10 to 15 characters for a 2525C code (shorter codes are padded to 15)"
            )
        }
        if normalized.count < 15 {
            normalized.append(String(repeating: "-", count: 15 - normalized.count))
        }

        let chars = Array(normalized)
        for (index, char) in chars.enumerated() {
            let isValid = (char >= "A" && char <= "Z") || (char >= "0" && char <= "9") || char == "-"
            guard isValid else {
                throw SIDCParseError.invalidCharacter(char, position: index + 1)
            }
        }

        guard let scheme = CharlieCodingScheme(character: chars[0]) else {
            throw SIDCParseError.unrecognizedCodingScheme(chars[0])
        }
        if scheme == .weather {
            throw SIDCParseError.unsupportedCodingScheme(
                chars[0],
                reason: "The METOC scheme uses a different field layout and is planned for a later release."
            )
        }

        guard let identity = CharlieStandardIdentity(character: chars[1]) else {
            throw SIDCParseError.unrecognizedStandardIdentity(chars[1])
        }

        let dimension: CharlieBattleDimension?
        let category: Character?
        if scheme == .tacticalGraphics {
            dimension = nil
            category = chars[2]
        } else {
            guard let parsed = CharlieBattleDimension(character: chars[2]) else {
                throw SIDCParseError.unrecognizedBattleDimension(chars[2])
            }
            dimension = parsed
            category = nil
        }

        guard let parsedStatus = CharlieStatus(character: chars[3]) else {
            throw SIDCParseError.unrecognizedStatus(chars[3])
        }

        self.raw = normalized
        self.codingScheme = scheme
        self.standardIdentity = identity
        self.battleDimension = dimension
        self.graphicCategory = category
        self.status = parsedStatus
        self.functionID = String(chars[4...9])
        self.symbolModifier = String(chars[10...11])

        let country = String(chars[12...13])
        self.countryCode = country == "--" ? nil : country
        self.orderOfBattle = chars[14] == "-" ? nil : chars[14]
    }

    /// The decoded headquarters / task force / feint-dummy flags from
    /// symbol modifier position 11, or `nil` when position 11 encodes
    /// something else (mobility, installation, or unfilled).
    public var headquartersTaskForceDummy: HQTFDummy? {
        guard let first = symbolModifier.first else { return nil }
        switch first {
        case "A": return .headquarters
        case "B": return [.taskForce, .headquarters]
        case "C": return [.feintDummy, .headquarters]
        case "D": return [.feintDummy, .taskForce, .headquarters]
        case "E": return .taskForce
        case "F": return .feintDummy
        case "G": return [.feintDummy, .taskForce]
        default: return nil
        }
    }

    /// Whether symbol modifier position 11 marks this as an installation
    /// (`H`, or `HB` for a feint/dummy installation).
    public var isInstallationModifier: Bool {
        symbolModifier.first == "H"
    }

    /// The decoded echelon from symbol modifier position 12, valid when
    /// position 11 carries an HQ/TF/dummy code, `-`, or `H`. Returns
    /// `nil` when position 12 is unfilled, unrecognized, or when the
    /// modifier pair encodes mobility (position 11 `M` or `N`), whose
    /// second character is not an echelon.
    public var echelon: Echelon? {
        guard let first = symbolModifier.first, first != "M", first != "N" else { return nil }
        guard symbolModifier.count == 2 else { return nil }
        let second = Array(symbolModifier)[1]
        return Echelon(charlieCharacter: second)
    }
}

extension CharlieSIDC: CustomStringConvertible {
    public var description: String { raw }
}

/// Position 1 of a charlie SIDC: the coding scheme.
public enum CharlieCodingScheme: Character, Hashable, Sendable, CaseIterable {
    case warfighting = "S"
    case tacticalGraphics = "G"
    case intelligence = "I"
    case stabilityOperations = "O"
    case emergencyManagement = "E"
    case weather = "W"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Position 2 of a charlie SIDC: the standard identity (affiliation).
///
/// The full 2525C identity set is parsed, not just the four base
/// affiliations, because real TAK traffic emits the exercise and
/// uncertainty variants. Rendering maps every identity onto one of the
/// four base frame shapes; see ``Affiliation``.
public enum CharlieStandardIdentity: Character, Hashable, Sendable, CaseIterable {
    case pending = "P"
    case unknown = "U"
    case assumedFriend = "A"
    case friend = "F"
    case neutral = "N"
    case suspect = "S"
    case hostile = "H"
    case exercisePending = "G"
    case exerciseUnknown = "W"
    case exerciseFriend = "D"
    case exerciseNeutral = "L"
    case exerciseAssumedFriend = "M"
    case joker = "J"
    case faker = "K"
    case noneSpecified = "O"

    public init?(character: Character) {
        self.init(rawValue: character)
    }

    /// Whether this identity is an exercise variant.
    public var isExercise: Bool {
        switch self {
        case .exercisePending, .exerciseUnknown, .exerciseFriend,
             .exerciseNeutral, .exerciseAssumedFriend, .joker, .faker:
            return true
        default:
            return false
        }
    }
}

/// Position 3 of a charlie SIDC: the battle dimension.
public enum CharlieBattleDimension: Character, Hashable, Sendable, CaseIterable {
    case space = "P"
    case air = "A"
    case ground = "G"
    case seaSurface = "S"
    case subsurface = "U"
    case specialOperations = "F"
    case other = "X"
    case unknown = "Z"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Position 4 of a charlie SIDC: status and operational condition.
public enum CharlieStatus: Character, Hashable, Sendable, CaseIterable {
    case present = "P"
    case anticipated = "A"
    case presentFullyCapable = "C"
    case presentDamaged = "D"
    case presentDestroyed = "X"
    case presentFullToCapacity = "F"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Headquarters, task force, and feint/dummy frame modifier flags.
public struct HQTFDummy: OptionSet, Hashable, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let headquarters = HQTFDummy(rawValue: 1 << 0)
    public static let taskForce = HQTFDummy(rawValue: 1 << 1)
    public static let feintDummy = HQTFDummy(rawValue: 1 << 2)
}

/// Echelon indicators, shared by both SIDC families.
public enum Echelon: Hashable, Sendable, CaseIterable {
    case teamCrew
    case squad
    case section
    case platoonDetachment
    case companyBatteryTroop
    case battalionSquadron
    case regimentGroup
    case brigade
    case division
    case corpsMEF
    case army
    case armyGroupFront
    case region
    case command

    /// Decodes a 2525C symbol modifier position 12 character.
    public init?(charlieCharacter: Character) {
        switch charlieCharacter {
        case "A": self = .teamCrew
        case "B": self = .squad
        case "C": self = .section
        case "D": self = .platoonDetachment
        case "E": self = .companyBatteryTroop
        case "F": self = .battalionSquadron
        case "G": self = .regimentGroup
        case "H": self = .brigade
        case "I": self = .division
        case "J": self = .corpsMEF
        case "K": self = .army
        case "L": self = .armyGroupFront
        case "M": self = .region
        case "N": self = .command
        default: return nil
        }
    }

    /// Decodes a 2525D amplifier pair (digits 9-10).
    public init?(deltaAmplifier: String) {
        switch deltaAmplifier {
        case "11": self = .teamCrew
        case "12": self = .squad
        case "13": self = .section
        case "14": self = .platoonDetachment
        case "15": self = .companyBatteryTroop
        case "16": self = .battalionSquadron
        case "17": self = .regimentGroup
        case "18": self = .brigade
        case "21": self = .division
        case "22": self = .corpsMEF
        case "23": self = .army
        case "24": self = .armyGroupFront
        case "25": self = .region
        case "26": self = .command
        default: return nil
        }
    }
}
