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

final class DeltaParsingTests: XCTestCase {

    // MARK: - Field extraction

    func testFullFieldExtraction() throws {
        //                        10 0 3 30 0 0 00 12 01 04 03 02
        let sidc = try DeltaSIDC("10033000001201040302")
        XCTAssertEqual(sidc.versionCode, 10)
        XCTAssertEqual(sidc.knownVersion, .milStd2525D)
        XCTAssertEqual(sidc.context, .reality)
        XCTAssertEqual(sidc.standardIdentity, .friend)
        XCTAssertEqual(sidc.symbolSetCode, "30")
        XCTAssertEqual(sidc.symbolSet, .seaSurface)
        XCTAssertEqual(sidc.status, .present)
        XCTAssertEqual(sidc.headquartersTaskForceDummy, [])
        XCTAssertEqual(sidc.amplifier, "00")
        XCTAssertEqual(sidc.entity, "12")
        XCTAssertEqual(sidc.entityType, "01")
        XCTAssertEqual(sidc.entitySubtype, "04")
        XCTAssertEqual(sidc.entityCode, "120104")
        XCTAssertEqual(sidc.sectorOneModifier, "03")
        XCTAssertEqual(sidc.sectorTwoModifier, "02")
    }

    func testEveryContextParses() throws {
        for context in DeltaContext.allCases {
            let code = "10\(context.rawValue)33000001201000000"
            XCTAssertEqual(try DeltaSIDC(code).context, context)
        }
    }

    func testEveryIdentityParses() throws {
        for identity in DeltaStandardIdentity.allCases {
            let code = "100\(identity.rawValue)3000001201000000"
            XCTAssertEqual(try DeltaSIDC(code).standardIdentity, identity)
        }
    }

    func testEveryStatusParses() throws {
        for status in DeltaStatus.allCases {
            let code = "100330\(status.rawValue)0001201000000"
            XCTAssertEqual(try DeltaSIDC(code).status, status)
        }
    }

    func testEveryKnownSymbolSetResolves() throws {
        for set in DeltaSymbolSet.allCases {
            let code = "1003\(set.rawValue)00001201000000"
            let sidc = try DeltaSIDC(code)
            XCTAssertEqual(sidc.symbolSet, set)
            XCTAssertEqual(sidc.symbolSetCode, set.rawValue)
        }
    }

    func testUnknownSymbolSetIsPreservedNotFatal() throws {
        let sidc = try DeltaSIDC("10039900001201000000")
        XCTAssertNil(sidc.symbolSet)
        XCTAssertEqual(sidc.symbolSetCode, "99")
    }

    func testUnknownVersionIsPreservedNotFatal() throws {
        let sidc = try DeltaSIDC("14033000001201000000")
        XCTAssertNil(sidc.knownVersion)
        XCTAssertEqual(sidc.versionCode, 14)
    }

    func testHQTFDummyDecoding() throws {
        let expectations: [(Character, HQTFDummy)] = [
            ("0", []),
            ("1", .feintDummy),
            ("2", .headquarters),
            ("3", [.feintDummy, .headquarters]),
            ("4", .taskForce),
            ("5", [.feintDummy, .taskForce]),
            ("6", [.taskForce, .headquarters]),
            ("7", [.feintDummy, .taskForce, .headquarters]),
        ]
        for (digit, expected) in expectations {
            let code = "1003300\(digit)001201000000"
            XCTAssertEqual(try DeltaSIDC(code).headquartersTaskForceDummy, expected)
        }
    }

    func testEchelonDecoding() throws {
        XCTAssertEqual(try DeltaSIDC("10033000161201000000").echelon, .battalionSquadron)
        XCTAssertEqual(try DeltaSIDC("10033000211201000000").echelon, .division)
        XCTAssertNil(try DeltaSIDC("10033000001201000000").echelon)
        // Mobility codes are not echelons.
        XCTAssertNil(try DeltaSIDC("10033000311201000000").echelon)
    }

    // MARK: - Failures

    func testWrongLengthThrows() {
        XCTAssertThrowsError(try DeltaSIDC("100330000012010000")) { error in
            guard case .invalidLength(let found, _)? = error as? SIDCParseError else {
                return XCTFail("Expected invalidLength, got \(error)")
            }
            XCTAssertEqual(found, 18)
        }
    }

    func testNonDigitThrows() {
        XCTAssertThrowsError(try DeltaSIDC("10A33000001201000000")) { error in
            guard case .invalidCharacter(let char, let position)? = error as? SIDCParseError else {
                return XCTFail("Expected invalidCharacter, got \(error)")
            }
            XCTAssertEqual(char, "A")
            XCTAssertEqual(position, 3)
        }
    }

    func testInvalidContextThrows() {
        XCTAssertThrowsError(try DeltaSIDC("10933000001201000000")) { error in
            XCTAssertEqual(error as? SIDCParseError, .invalidContext("9"))
        }
    }

    func testInvalidIdentityThrows() {
        XCTAssertThrowsError(try DeltaSIDC("10093000001201000000")) { error in
            XCTAssertEqual(error as? SIDCParseError, .invalidStandardIdentityDigit("9"))
        }
    }

    func testInvalidStatusThrows() {
        XCTAssertThrowsError(try DeltaSIDC("10033090001201000000")) { error in
            XCTAssertEqual(error as? SIDCParseError, .invalidStatusDigit("9"))
        }
    }

    func testInvalidHQTFDummyThrows() {
        XCTAssertThrowsError(try DeltaSIDC("10033009001201000000")) { error in
            XCTAssertEqual(error as? SIDCParseError, .invalidHQTFDummyDigit("9"))
        }
    }
}
