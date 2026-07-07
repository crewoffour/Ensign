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

import XCTest
@testable import EnsignCore

final class CharlieParsingTests: XCTestCase {

    // MARK: - Field extraction

    func testFullFieldExtraction() throws {
        let sidc = try CharlieSIDC("SFSPCLDD--AAUSX")
        XCTAssertEqual(sidc.codingScheme, .warfighting)
        XCTAssertEqual(sidc.standardIdentity, .friend)
        XCTAssertEqual(sidc.battleDimension, .seaSurface)
        XCTAssertEqual(sidc.status, .present)
        XCTAssertEqual(sidc.functionID, "CLDD--")
        XCTAssertEqual(sidc.symbolModifier, "AA")
        XCTAssertEqual(sidc.countryCode, "US")
        XCTAssertEqual(sidc.orderOfBattle, "X")
        XCTAssertNil(sidc.graphicCategory)
    }

    func testUnfilledOptionalFields() throws {
        let sidc = try CharlieSIDC("SFSPCLDD-------")
        XCTAssertNil(sidc.countryCode)
        XCTAssertNil(sidc.orderOfBattle)
        XCTAssertEqual(sidc.symbolModifier, "--")
    }

    func testEveryStandardIdentityParses() throws {
        for identity in CharlieStandardIdentity.allCases {
            let code = "S\(identity.rawValue)GP-----------"
            let sidc = try CharlieSIDC(code)
            XCTAssertEqual(sidc.standardIdentity, identity)
        }
    }

    func testEveryBattleDimensionParses() throws {
        for dimension in CharlieBattleDimension.allCases {
            let code = "SF\(dimension.rawValue)P-----------"
            let sidc = try CharlieSIDC(code)
            XCTAssertEqual(sidc.battleDimension, dimension)
        }
    }

    func testEveryStatusParses() throws {
        for status in CharlieStatus.allCases {
            let code = "SFG\(status.rawValue)-----------"
            let sidc = try CharlieSIDC(code)
            XCTAssertEqual(sidc.status, status)
        }
    }

    // MARK: - Normalization

    func testLowercaseIsRaised() throws {
        let sidc = try CharlieSIDC("sfspcldd-------")
        XCTAssertEqual(sidc.raw, "SFSPCLDD-------")
    }

    func testAsteriskFillIsNormalized() throws {
        let sidc = try CharlieSIDC("SFSPCLDD--*****")
        XCTAssertEqual(sidc.raw, "SFSPCLDD-------")
    }

    func testShortCodeIsPadded() throws {
        let sidc = try CharlieSIDC("SFSPCLDD--")
        XCTAssertEqual(sidc.raw, "SFSPCLDD-------")
        XCTAssertEqual(sidc.functionID, "CLDD--")
    }

    func testWhitespaceIsTrimmed() throws {
        let sidc = try CharlieSIDC("  SFSPCLDD-------\n")
        XCTAssertEqual(sidc.raw, "SFSPCLDD-------")
    }

    // MARK: - Tactical graphics scheme

    func testTacticalGraphicsStoresCategoryNotDimension() throws {
        let sidc = try CharlieSIDC("GFGPGPP--------")
        XCTAssertEqual(sidc.codingScheme, .tacticalGraphics)
        XCTAssertNil(sidc.battleDimension)
        XCTAssertEqual(sidc.graphicCategory, "G")
    }

    // MARK: - Symbol modifier decoding

    func testHQTFDummyDecoding() throws {
        XCTAssertEqual(try CharlieSIDC("SFGPUCI---A----").headquartersTaskForceDummy, .headquarters)
        XCTAssertEqual(try CharlieSIDC("SFGPUCI---B----").headquartersTaskForceDummy, [.taskForce, .headquarters])
        XCTAssertEqual(try CharlieSIDC("SFGPUCI---D----").headquartersTaskForceDummy, [.feintDummy, .taskForce, .headquarters])
        XCTAssertEqual(try CharlieSIDC("SFGPUCI---E----").headquartersTaskForceDummy, .taskForce)
        XCTAssertNil(try CharlieSIDC("SFGPUCI--------").headquartersTaskForceDummy)
    }

    func testEchelonDecoding() throws {
        XCTAssertEqual(try CharlieSIDC("SFGPUCI----F---").echelon, .battalionSquadron)
        XCTAssertEqual(try CharlieSIDC("SFGPUCI---AI---").echelon, .division)
        XCTAssertNil(try CharlieSIDC("SFGPUCI--------").echelon)
    }

    func testMobilityPairDoesNotDecodeAsEchelon() throws {
        // MO = wheeled mobility; the O must not decode as an echelon.
        let sidc = try CharlieSIDC("SFGPUCI---MO---")
        XCTAssertNil(sidc.echelon)
        XCTAssertNil(sidc.headquartersTaskForceDummy)
        XCTAssertEqual(sidc.symbolModifier, "MO")
    }

    func testInstallationModifier() throws {
        XCTAssertTrue(try CharlieSIDC("SFGPI-----H----").isInstallationModifier)
        XCTAssertFalse(try CharlieSIDC("SFGPUCI--------").isInstallationModifier)
    }

    // MARK: - Failures

    func testEmptyInputThrows() {
        XCTAssertThrowsError(try SIDC("")) { error in
            XCTAssertEqual(error as? SIDCParseError, .emptyInput)
        }
    }

    func testTooShortThrows() {
        XCTAssertThrowsError(try CharlieSIDC("SFG")) { error in
            guard case .invalidLength(let found, _)? = error as? SIDCParseError else {
                return XCTFail("Expected invalidLength, got \(error)")
            }
            XCTAssertEqual(found, 3)
        }
    }

    func testTooLongThrows() {
        XCTAssertThrowsError(try CharlieSIDC("SFSPCLDD--------")) // 16 chars
    }

    func testInvalidCharacterThrows() {
        XCTAssertThrowsError(try CharlieSIDC("S!SPCLDD-------")) { error in
            guard case .invalidCharacter(let char, let position)? = error as? SIDCParseError else {
                return XCTFail("Expected invalidCharacter, got \(error)")
            }
            XCTAssertEqual(char, "!")
            XCTAssertEqual(position, 2)
        }
    }

    func testUnrecognizedCodingSchemeThrows() {
        XCTAssertThrowsError(try CharlieSIDC("XFSPCLDD-------")) { error in
            XCTAssertEqual(error as? SIDCParseError, .unrecognizedCodingScheme("X"))
        }
    }

    func testWeatherSchemeIsUnsupportedForNow() {
        XCTAssertThrowsError(try CharlieSIDC("WAS-WSTSSP-----")) { error in
            guard case .unsupportedCodingScheme(let char, _)? = error as? SIDCParseError else {
                return XCTFail("Expected unsupportedCodingScheme, got \(error)")
            }
            XCTAssertEqual(char, "W")
        }
    }

    func testUnrecognizedIdentityThrows() {
        XCTAssertThrowsError(try CharlieSIDC("SXGP-----------")) { error in
            XCTAssertEqual(error as? SIDCParseError, .unrecognizedStandardIdentity("X"))
        }
    }
}
