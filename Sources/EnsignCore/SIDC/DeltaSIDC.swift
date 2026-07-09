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

/// A parsed MIL-STD-2525D/E Symbol Identification Code of 20 digits,
/// or 30 digits for full-length 2525E codes.
///
/// Layout (1-based digit positions):
///
/// | Digits | Field |
/// |---|---|
/// | 1-2 | Version |
/// | 3 | Context (reality, exercise, simulation) |
/// | 4 | Standard identity |
/// | 5-6 | Symbol set |
/// | 7 | Status |
/// | 8 | Headquarters / task force / dummy |
/// | 9-10 | Amplifier (echelon or mobility) |
/// | 11-12 | Entity |
/// | 13-14 | Entity type |
/// | 15-16 | Entity subtype |
/// | 17-18 | Sector 1 modifier |
/// | 19-20 | Sector 2 modifier |
/// | 21-30 | 2525E extension block (30-digit codes only), preserved
///           raw in ``extensionDigits``; position 23 carries the 2525E
///           frame shape modifier |
public struct DeltaSIDC: Hashable, Sendable {
    /// The 20- or 30-digit code as parsed.
    public let raw: String
    /// Digits 1-2 as an integer, preserved even when the version is
    /// newer than this library knows about.
    public let versionCode: Int
    /// Digit 3: real-world context.
    public let context: DeltaContext
    /// Digit 4: the standard identity.
    public let standardIdentity: DeltaStandardIdentity
    /// Digits 5-6: the raw symbol set code, preserved even when the set
    /// is not one this library recognizes.
    public let symbolSetCode: String
    /// Digit 7: status and operational condition.
    public let status: DeltaStatus
    /// Digit 8: headquarters / task force / dummy flags.
    public let headquartersTaskForceDummy: HQTFDummy
    /// Digits 9-10: the raw amplifier pair. A decoded echelon view is
    /// available via ``echelon``.
    public let amplifier: String
    /// Digits 11-12.
    public let entity: String
    /// Digits 13-14.
    public let entityType: String
    /// Digits 15-16.
    public let entitySubtype: String
    /// Digits 17-18.
    public let sectorOneModifier: String
    /// Digits 19-20.
    public let sectorTwoModifier: String
    /// Digits 21-30 of a 30-digit 2525E code, or the empty string for
    /// 20-digit codes. Preserved raw; the fields inside are decoded
    /// lazily as the library grows support for them.
    public let extensionDigits: String

    /// Parses a delta-family SIDC string of exactly 20 or 30 decimal
    /// digits (the 30-digit form is the full-length 2525E code).
    /// - Throws: ``SIDCParseError``.
    public init(_ string: String) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == 20 || trimmed.count == 30 else {
            throw SIDCParseError.invalidLength(
                found: trimmed.count,
                expected: "exactly 20 digits for a 2525D/E code, or 30 for a full-length 2525E code"
            )
        }
        let chars = Array(trimmed)
        for (index, char) in chars.enumerated() {
            guard char.isASCII && char.isNumber else {
                throw SIDCParseError.invalidCharacter(char, position: index + 1)
            }
        }

        guard let parsedContext = DeltaContext(character: chars[2]) else {
            throw SIDCParseError.invalidContext(chars[2])
        }
        guard let identity = DeltaStandardIdentity(character: chars[3]) else {
            throw SIDCParseError.invalidStandardIdentityDigit(chars[3])
        }
        guard let parsedStatus = DeltaStatus(character: chars[6]) else {
            throw SIDCParseError.invalidStatusDigit(chars[6])
        }
        guard let hq = Self.decodeHQTFDummy(chars[7]) else {
            throw SIDCParseError.invalidHQTFDummyDigit(chars[7])
        }

        self.raw = trimmed
        self.versionCode = Int(String(chars[0...1])) ?? 0
        self.context = parsedContext
        self.standardIdentity = identity
        self.symbolSetCode = String(chars[4...5])
        self.status = parsedStatus
        self.headquartersTaskForceDummy = hq
        self.amplifier = String(chars[8...9])
        self.entity = String(chars[10...11])
        self.entityType = String(chars[12...13])
        self.entitySubtype = String(chars[14...15])
        self.sectorOneModifier = String(chars[16...17])
        self.sectorTwoModifier = String(chars[18...19])
        self.extensionDigits = chars.count == 30 ? String(chars[20...29]) : ""
    }

    /// The 2525E frame shape modifier (position 23 of a 30-digit code),
    /// or `nil` when absent or not overriding ("0"). Parsed and
    /// preserved; frame-shape override rendering is a future extension
    /// tracked in the plan.
    public var frameShapeModifier: Character? {
        guard extensionDigits.count == 10 else { return nil }
        let char = Array(extensionDigits)[2]
        return char == "0" ? nil : char
    }

    /// The known specification version, or `nil` for version codes this
    /// library does not recognize (which still parse; forward
    /// compatibility is deliberate).
    public var knownVersion: DeltaVersion? {
        DeltaVersion(code: versionCode)
    }

    /// The recognized symbol set, or `nil` for codes this library does
    /// not know. The raw code is always preserved in ``symbolSetCode``.
    public var symbolSet: DeltaSymbolSet? {
        DeltaSymbolSet(code: symbolSetCode)
    }

    /// The six-digit entity code (entity, type, subtype concatenated),
    /// the delta analog of the charlie function ID.
    public var entityCode: String {
        entity + entityType + entitySubtype
    }

    /// The decoded echelon from the amplifier pair, when it encodes one.
    public var echelon: Echelon? {
        Echelon(deltaAmplifier: amplifier)
    }

    private static func decodeHQTFDummy(_ digit: Character) -> HQTFDummy? {
        switch digit {
        case "0": return []
        case "1": return .feintDummy
        case "2": return .headquarters
        case "3": return [.feintDummy, .headquarters]
        case "4": return .taskForce
        case "5": return [.feintDummy, .taskForce]
        case "6": return [.taskForce, .headquarters]
        case "7": return [.feintDummy, .taskForce, .headquarters]
        default: return nil
        }
    }
}

extension DeltaSIDC: CustomStringConvertible {
    public var description: String { raw }
}

/// Known 2525D-family specification versions (digits 1-2).
///
/// Unrecognized version codes do not fail parsing; they surface as a
/// `nil` ``DeltaSIDC/knownVersion`` with the raw value preserved in
/// ``DeltaSIDC/versionCode``.
public enum DeltaVersion: Hashable, Sendable {
    case milStd2525D
    case milStd2525DChange1

    public init?(code: Int) {
        switch code {
        case 10: self = .milStd2525D
        case 11: self = .milStd2525DChange1
        default: return nil
        }
    }
}

/// Digit 3 of a delta SIDC: real-world context.
public enum DeltaContext: Character, Hashable, Sendable, CaseIterable {
    case reality = "0"
    case exercise = "1"
    case simulation = "2"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Digit 4 of a delta SIDC: the standard identity.
///
/// In the delta family, joker and faker are not distinct identity codes;
/// they arise from combining suspect or hostile with the exercise
/// context. The normalized ``Affiliation`` handles that combination.
public enum DeltaStandardIdentity: Character, Hashable, Sendable, CaseIterable {
    case pending = "0"
    case unknown = "1"
    case assumedFriend = "2"
    case friend = "3"
    case neutral = "4"
    case suspect = "5"
    case hostile = "6"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Digit 7 of a delta SIDC: status and operational condition.
public enum DeltaStatus: Character, Hashable, Sendable, CaseIterable {
    case present = "0"
    case planned = "1"
    case presentFullyCapable = "2"
    case presentDamaged = "3"
    case presentDestroyed = "4"
    case presentFullToCapacity = "5"

    public init?(character: Character) {
        self.init(rawValue: character)
    }
}

/// Digits 5-6 of a delta SIDC: the symbol set.
///
/// Unrecognized codes do not fail parsing; they surface as a `nil`
/// ``DeltaSIDC/symbolSet`` with the raw pair preserved in
/// ``DeltaSIDC/symbolSetCode``.
public enum DeltaSymbolSet: String, Hashable, Sendable, CaseIterable {
    case air = "01"
    case airMissile = "02"
    case space = "05"
    case spaceMissile = "06"
    case landUnit = "10"
    case landCivilian = "11"
    case landEquipment = "15"
    case landInstallation = "20"
    case controlMeasure = "25"
    case dismountedIndividual = "27"
    case seaSurface = "30"
    case seaSubsurface = "35"
    case mineWarfare = "36"
    case activities = "40"
    case meteorologicalAtmospheric = "45"
    case meteorologicalOceanographic = "46"
    case signalsIntelligenceSpace = "50"
    case signalsIntelligenceAir = "51"
    case signalsIntelligenceLand = "52"
    case signalsIntelligenceSeaSurface = "53"
    case signalsIntelligenceSubsurface = "54"
    case cyberspace = "60"

    public init?(code: String) {
        self.init(rawValue: code)
    }
}
