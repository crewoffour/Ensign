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

/// The SIDC family a parsed code belongs to.
///
/// MIL-STD-2525A/B/C share the 15-character alphanumeric layout and are
/// represented here as the `charlie` family. MIL-STD-2525D and E share the
/// restructured 20-digit numeric layout and are represented as the `delta`
/// family. The two families share almost no parsing logic, which is why the
/// family is a first-class concept throughout Ensign.
public enum SIDCFamily: String, Hashable, Sendable, CaseIterable {
    /// The 15-character alphanumeric SIDC of MIL-STD-2525A/B/C.
    case charlie
    /// The 20-digit numeric SIDC of MIL-STD-2525D/E.
    case delta
}

/// A parsed, version-tagged Symbol Identification Code.
///
/// `SIDC` is the entry point of the library. Construct one from a raw
/// string and the family is detected automatically:
///
/// ```swift
/// let legacy = try SIDC("SFSPCLDD-------")      // 2525C, 15 characters
/// let modern = try SIDC("10033000001201000000") // 2525D, 20 digits
/// ```
///
/// Detection rule: a string of exactly 20 decimal digits parses as the
/// delta family; everything else is attempted as the charlie family.
/// Charlie input is normalized before parsing: whitespace trimmed,
/// lowercase raised, `*` fill characters mapped to `-`, and codes of
/// 10 to 14 characters padded to 15 with `-`.
public enum SIDC: Hashable, Sendable {
    case charlie(CharlieSIDC)
    case delta(DeltaSIDC)

    /// Parses a raw SIDC string, detecting the family automatically.
    /// - Throws: ``SIDCParseError`` describing exactly what was wrong.
    public init(_ string: String) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SIDCParseError.emptyInput }

        let isAllDigits = trimmed.allSatisfy { $0.isASCII && $0.isNumber }
        if isAllDigits {
            guard trimmed.count == 20 else {
                throw SIDCParseError.invalidLength(
                    found: trimmed.count,
                    expected: "20 digits for a 2525D/E code, or a 10-15 character alphanumeric 2525C code"
                )
            }
            self = .delta(try DeltaSIDC(trimmed))
        } else {
            self = .charlie(try CharlieSIDC(trimmed))
        }
    }

    /// The family this code belongs to.
    public var family: SIDCFamily {
        switch self {
        case .charlie: return .charlie
        case .delta: return .delta
        }
    }

    /// The normalized raw code: 15 characters for charlie, 20 digits
    /// for delta.
    public var raw: String {
        switch self {
        case .charlie(let value): return value.raw
        case .delta(let value): return value.raw
        }
    }

    /// The charlie-family value, if this is a 2525A/B/C code.
    public var charlieValue: CharlieSIDC? {
        if case .charlie(let value) = self { return value }
        return nil
    }

    /// The delta-family value, if this is a 2525D/E code.
    public var deltaValue: DeltaSIDC? {
        if case .delta(let value) = self { return value }
        return nil
    }
}

extension SIDC: CustomStringConvertible {
    public var description: String { raw }
}

/// A descriptive parsing failure.
///
/// Every case carries enough context to explain what was wrong and where,
/// so callers can surface actionable messages rather than a bare failure.
public enum SIDCParseError: Error, Hashable, Sendable, CustomStringConvertible {
    /// The input was empty or whitespace.
    case emptyInput
    /// The input length matched neither family's layout.
    case invalidLength(found: Int, expected: String)
    /// A character outside the allowed set appeared at the given
    /// 1-based position.
    case invalidCharacter(Character, position: Int)
    /// Position 1 of a charlie code was not a recognized coding scheme.
    case unrecognizedCodingScheme(Character)
    /// The coding scheme is recognized but not yet supported. Currently
    /// only the weather/METOC scheme (`W`), whose field layout differs
    /// from every other scheme.
    case unsupportedCodingScheme(Character, reason: String)
    /// Position 2 of a charlie code was not a recognized standard identity.
    case unrecognizedStandardIdentity(Character)
    /// Position 3 of a charlie code was not a recognized battle dimension.
    case unrecognizedBattleDimension(Character)
    /// Position 4 of a charlie code was not a recognized status.
    case unrecognizedStatus(Character)
    /// Digit 3 of a delta code was not a valid context (0, 1, or 2).
    case invalidContext(Character)
    /// Digit 4 of a delta code was not a valid standard identity (0-6).
    case invalidStandardIdentityDigit(Character)
    /// Digit 7 of a delta code was not a valid status (0-5).
    case invalidStatusDigit(Character)
    /// Digit 8 of a delta code was not a valid HQ/TF/dummy value (0-7).
    case invalidHQTFDummyDigit(Character)

    public var description: String {
        switch self {
        case .emptyInput:
            return "The SIDC string is empty. Expected a 15-character 2525C code or a 20-digit 2525D/E code."
        case .invalidLength(let found, let expected):
            return "The SIDC has \(found) characters; expected \(expected)."
        case .invalidCharacter(let char, let position):
            return "Invalid character '\(char)' at position \(position). Charlie codes allow A-Z, 0-9, and '-' (with '*' accepted as a fill alias); delta codes allow digits only."
        case .unrecognizedCodingScheme(let char):
            return "Unrecognized coding scheme '\(char)' at position 1. Expected S, G, I, O, E, or W."
        case .unsupportedCodingScheme(let char, let reason):
            return "Coding scheme '\(char)' is recognized but not yet supported: \(reason)"
        case .unrecognizedStandardIdentity(let char):
            return "Unrecognized standard identity '\(char)' at position 2. Expected one of P, U, A, F, N, S, H, G, W, D, L, M, J, K, O."
        case .unrecognizedBattleDimension(let char):
            return "Unrecognized battle dimension '\(char)' at position 3. Expected one of P, A, G, S, U, F, X, Z."
        case .unrecognizedStatus(let char):
            return "Unrecognized status '\(char)' at position 4. Expected one of P, A, C, D, X, F."
        case .invalidContext(let char):
            return "Invalid context digit '\(char)' at position 3. Expected 0 (reality), 1 (exercise), or 2 (simulation)."
        case .invalidStandardIdentityDigit(let char):
            return "Invalid standard identity digit '\(char)' at position 4. Expected 0-6."
        case .invalidStatusDigit(let char):
            return "Invalid status digit '\(char)' at position 7. Expected 0-5."
        case .invalidHQTFDummyDigit(let char):
            return "Invalid HQ/task force/dummy digit '\(char)' at position 8. Expected 0-7."
        }
    }
}
