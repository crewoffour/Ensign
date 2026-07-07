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

final class NormalizationTests: XCTestCase {

    // MARK: - Family detection

    func testFifteenCharacterCodeDetectsAsCharlie() throws {
        let sidc = try SIDC("SFSPCLDD-------")
        XCTAssertEqual(sidc.family, .charlie)
        XCTAssertNotNil(sidc.charlieValue)
        XCTAssertNil(sidc.deltaValue)
    }

    func testTwentyDigitCodeDetectsAsDelta() throws {
        let sidc = try SIDC("10033000001201000000")
        XCTAssertEqual(sidc.family, .delta)
        XCTAssertNotNil(sidc.deltaValue)
        XCTAssertNil(sidc.charlieValue)
    }

    func testAllDigitsWrongLengthGetsDeltaLengthError() {
        XCTAssertThrowsError(try SIDC("123456789012")) { error in
            guard case .invalidLength? = error as? SIDCParseError else {
                return XCTFail("Expected invalidLength, got \(error)")
            }
        }
    }

    // MARK: - Affiliation normalization, both families

    func testCharlieExerciseIdentitiesNormalize() throws {
        let exerciseFriend = try MilSymbol("SDGPUCI--------")
        XCTAssertEqual(exerciseFriend.affiliation, .friend)
        XCTAssertTrue(exerciseFriend.isExercise)

        let joker = try MilSymbol("SJGP-----------")
        XCTAssertEqual(joker.affiliation, .joker)
        XCTAssertTrue(joker.isExercise)
        XCTAssertEqual(joker.affiliation.frameBase, .hostile)

        let faker = try MilSymbol("SKGP-----------")
        XCTAssertEqual(faker.affiliation, .faker)
        XCTAssertEqual(faker.affiliation.frameBase, .hostile)
    }

    func testDeltaExerciseContextProducesJokerAndFaker() throws {
        // Suspect in the exercise context is a joker.
        let joker = try MilSymbol("10153000001201000000")
        XCTAssertEqual(joker.affiliation, .joker)
        XCTAssertTrue(joker.isExercise)

        // Hostile in the exercise context is a faker.
        let faker = try MilSymbol("10163000001201000000")
        XCTAssertEqual(faker.affiliation, .faker)

        // Hostile in reality stays hostile.
        let hostile = try MilSymbol("10063000001201000000")
        XCTAssertEqual(hostile.affiliation, .hostile)
        XCTAssertFalse(hostile.isExercise)
    }

    func testDeltaSimulationContext() throws {
        let simulated = try MilSymbol("10233000001201000000")
        XCTAssertTrue(simulated.isSimulation)
        XCTAssertFalse(simulated.isExercise)
    }

    func testEquivalentCodesInBothFamiliesNormalizeIdentically() throws {
        // Friend sea-surface present, expressed in each dialect, must
        // agree on every normalized property. This is the dual-format
        // promise in one test.
        let charlie = try MilSymbol("SFSP-----------")
        let delta = try MilSymbol("10033000000000000000")

        XCTAssertEqual(charlie.affiliation, delta.affiliation)
        XCTAssertEqual(charlie.domain, delta.domain)
        XCTAssertEqual(charlie.status, delta.status)
        XCTAssertEqual(charlie.frame, delta.frame)
    }

    // MARK: - Domain normalization

    func testCharlieGroundSplitsByFunctionIDFirstCharacter() throws {
        XCTAssertEqual(try MilSymbol("SFGPUCI--------").domain, .landUnit)
        XCTAssertEqual(try MilSymbol("SFGPE----------").domain, .landEquipment)
        XCTAssertEqual(try MilSymbol("SFGPI----------").domain, .landInstallation)
    }

    func testCharlieDimensionsNormalize() throws {
        XCTAssertEqual(try MilSymbol("SFAP-----------").domain, .air)
        XCTAssertEqual(try MilSymbol("SFPP-----------").domain, .space)
        XCTAssertEqual(try MilSymbol("SFSP-----------").domain, .seaSurface)
        XCTAssertEqual(try MilSymbol("SFUP-----------").domain, .subsurface)
        // SOF uses the land-unit frame family.
        XCTAssertEqual(try MilSymbol("SFFP-----------").domain, .landUnit)
    }

    func testDeltaSymbolSetsNormalize() throws {
        XCTAssertEqual(try MilSymbol("10031000001101000000").domain, .landUnit)
        XCTAssertEqual(try MilSymbol("10031500001101000000").domain, .landEquipment)
        XCTAssertEqual(try MilSymbol("10032000001101000000").domain, .landInstallation)
        XCTAssertEqual(try MilSymbol("10030100001101000000").domain, .air)
        XCTAssertEqual(try MilSymbol("10030500001101000000").domain, .space)
        XCTAssertEqual(try MilSymbol("10033500001101000000").domain, .subsurface)
        XCTAssertEqual(try MilSymbol("10034000001101000000").domain, .activity)
    }

    func testUnrenderableDomainsSurfaceAsOtherWithNilFrame() throws {
        // Control measures parse fine but have no frame defined yet.
        let controlMeasure = try MilSymbol("10032500001101000000")
        guard case .other(let code) = controlMeasure.domain else {
            return XCTFail("Expected .other, got \(controlMeasure.domain)")
        }
        XCTAssertEqual(code, "25")
        XCTAssertNil(controlMeasure.frame.shape)

        // Charlie tactical graphics likewise.
        let graphic = try MilSymbol("GFGPGPP--------")
        XCTAssertNil(graphic.frame.shape)
    }

    // MARK: - Frame resolution

    func testFrameShapes() throws {
        XCTAssertEqual(try MilSymbol("SFSP-----------").frame.shape, .circle)
        XCTAssertEqual(try MilSymbol("SFGPUCI--------").frame.shape, .rectangle)
        XCTAssertEqual(try MilSymbol("SHAP-----------").frame.shape, .tentOpenBottom)
        XCTAssertEqual(try MilSymbol("SHUP-----------").frame.shape, .tentOpenTop)
        XCTAssertEqual(try MilSymbol("SNUP-----------").frame.shape, .squareOpenTop)
        XCTAssertEqual(try MilSymbol("SUGPUCI--------").frame.shape, .quatrefoil)
        XCTAssertEqual(try MilSymbol("SUAP-----------").frame.shape, .cloverOpenBottom)
        XCTAssertEqual(try MilSymbol("SFUP-----------").frame.shape, .archOpenTop)
    }

    func testEveryBaseAndFramedDomainResolves() {
        let framedDomains: [SymbolDomain] = [
            .air, .space, .landUnit, .landEquipment, .landInstallation,
            .seaSurface, .subsurface, .activity,
        ]
        for base in FrameBase.allCases {
            for domain in framedDomains {
                XCTAssertNotNil(
                    FrameShape.resolve(base: base, domain: domain),
                    "No frame for \(base) x \(domain)"
                )
            }
        }
    }

    func testDashedFrames() throws {
        // Uncertain identities dash the frame.
        XCTAssertTrue(try MilSymbol("SSAP-----------").frame.isDashed)  // suspect
        XCTAssertTrue(try MilSymbol("SAGPUCI--------").frame.isDashed)  // assumed friend
        XCTAssertTrue(try MilSymbol("SPGP-----------").frame.isDashed)  // pending
        // Anticipated status dashes the frame.
        XCTAssertTrue(try MilSymbol("SFSA-----------").frame.isDashed)
        XCTAssertTrue(try MilSymbol("10033010001201000000").frame.isDashed) // planned
        // Present, certain identities do not.
        XCTAssertFalse(try MilSymbol("SFSP-----------").frame.isDashed)
        XCTAssertFalse(try MilSymbol("10033000001201000000").frame.isDashed)
    }

    func testSpaceModifierFlag() throws {
        XCTAssertTrue(try MilSymbol("SFPP-----------").frame.hasSpaceModifier)
        XCTAssertFalse(try MilSymbol("SFAP-----------").frame.hasSpaceModifier)
    }

    // MARK: - Status normalization

    func testStatusNormalization() throws {
        XCTAssertEqual(try MilSymbol("SFSC-----------").status, .presentFullyCapable)
        XCTAssertEqual(try MilSymbol("SFSD-----------").status, .presentDamaged)
        XCTAssertEqual(try MilSymbol("SFSX-----------").status, .presentDestroyed)
        XCTAssertEqual(try MilSymbol("10033030001201000000").status, .presentDamaged)
        XCTAssertEqual(try MilSymbol("10033040001201000000").status, .presentDestroyed)
    }

    // MARK: - Icon keys

    func testCharlieIconKey() throws {
        let symbol = try MilSymbol("SFSPCLDD-------")
        XCTAssertEqual(symbol.iconKey, IconKey(family: .charlie, code: "SSCLDD--"))
    }

    func testDeltaIconKey() throws {
        let symbol = try MilSymbol("10033000001201040000")
        XCTAssertEqual(symbol.iconKey, IconKey(family: .delta, code: "30120104"))
    }

    func testIconKeyIgnoresAffiliationAndStatus() throws {
        // The same platform seen as friend or hostile, present or
        // anticipated, must share one icon key: the icon identifies the
        // entity, not the assessment of it.
        let friend = try MilSymbol("SFSPCLDD-------")
        let hostileAnticipated = try MilSymbol("SHSACLDD-------")
        XCTAssertEqual(friend.iconKey, hostileAnticipated.iconKey)
    }

    // MARK: - Equality and hashing

    func testValueSemantics() throws {
        let a = try MilSymbol("SFSPCLDD-------")
        let b = try MilSymbol("sfspcldd--*****")
        XCTAssertEqual(a, b, "Normalization must make differently written but identical codes equal")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }
}
