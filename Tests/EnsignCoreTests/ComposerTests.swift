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

final class ComposerTests: XCTestCase {

    // MARK: - Frame geometry coverage

    func testEveryShapeHasGeometry() {
        for shape in FrameShape.allCases {
            if shape == .circle {
                XCTAssertNil(FrameGeometry.segments(for: shape), "circle is emitted as a circle instruction")
            } else {
                let segments = FrameGeometry.segments(for: shape)
                XCTAssertNotNil(segments)
                XCTAssertGreaterThanOrEqual(segments?.count ?? 0, 3, "\(shape) has too few segments")
                if case .move? = segments?.first {} else {
                    XCTFail("\(shape) does not start with a move")
                }
            }
            let bounds = FrameGeometry.bounds(for: shape)
            XCTAssertLessThan(bounds.x1, bounds.x2)
            XCTAssertLessThan(bounds.y1, bounds.y2)
            XCTAssertGreaterThanOrEqual(bounds.x1, 0)
            XCTAssertLessThanOrEqual(bounds.x2, 200)
            XCTAssertGreaterThanOrEqual(bounds.y1, 0)
            XCTAssertLessThanOrEqual(bounds.y2, 200)
        }
    }

    func testClosedFramesAreClosed() {
        // Land and sea frames are closed outlines; air and subsurface
        // frames are open per the standard.
        let closed: [FrameShape] = [.rectangle, .square, .diamond, .quatrefoil, .hexagon]
        for shape in closed {
            XCTAssertTrue(FrameGeometry.segments(for: shape)?.last == .close, "\(shape) should close")
        }
        let open: [FrameShape] = [
            .archOpenBottom, .tentOpenBottom, .squareOpenBottom, .cloverOpenBottom,
            .archOpenTop, .tentOpenTop, .squareOpenTop, .cloverOpenTop,
        ]
        for shape in open {
            XCTAssertTrue(FrameGeometry.segments(for: shape)?.last != .close, "\(shape) should stay open")
        }
    }

    // MARK: - Composition

    func testSolidFrameComposesToSingleInstruction() throws {
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10033000000000000000"))
        XCTAssertEqual(geometry.instructions.count, 1)
        guard case .circle(let center, let radius, let style)? = geometry.instructions.first else {
            return XCTFail("Friend sea surface should compose to a circle instruction")
        }
        XCTAssertEqual(center, SymbolPoint(100, 100))
        XCTAssertEqual(radius, 60)
        XCTAssertEqual(style.fill, .affiliationFill)
        XCTAssertEqual(style.stroke, .frameStroke)
        XCTAssertEqual(style.strokeWidth, 4)
        XCTAssertNil(style.dash)
    }

    func testDashedIdentityAddsOverlayOnTopOfSolidFrame() throws {
        // Assumed friend sea surface: solid circle frame first, white
        // dashed overlay last.
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10023000000000000000"))
        XCTAssertEqual(geometry.instructions.count, 2)
        guard case .circle(_, _, let overlay)? = geometry.instructions.last else {
            return XCTFail("Expected a circle overlay instruction")
        }
        XCTAssertEqual(overlay.fill, ColorRole.none)
        XCTAssertEqual(overlay.stroke, .contrastFill)
        XCTAssertEqual(overlay.strokeWidth, 5)
        XCTAssertEqual(overlay.dash, [4, 4])
    }

    func testAnticipatedStatusUsesLongDashPattern() throws {
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10033010000000000000"))
        guard case .circle(_, _, let overlay)? = geometry.instructions.last else {
            return XCTFail("Expected a circle overlay instruction")
        }
        XCTAssertEqual(overlay.dash, [8, 12])
    }

    func testAnticipatedStatusTakesPrecedenceOverUncertainIdentity() throws {
        // Suspect and planned: one overlay, with the status pattern.
        let symbol = try MilSymbol("10053010000000000000")
        XCTAssertEqual(symbol.frame.dash, .anticipatedStatus)
        let geometry = SymbolComposer.geometry(for: symbol)
        XCTAssertEqual(geometry.instructions.count, 2)
    }

    func testSpaceDomainAddsBarOverlay() throws {
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10030500000000000000"))
        XCTAssertEqual(geometry.instructions.count, 2)
        guard case .path(let bar)? = geometry.instructions.last else {
            return XCTFail("Expected the space bar path")
        }
        XCTAssertEqual(bar.style.fill, .frameStroke)
        XCTAssertEqual(bar.style.stroke, ColorRole.none)
    }

    func testActivityDomainAddsCornerBrackets() throws {
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10034000000000000000"))
        XCTAssertEqual(geometry.instructions.count, 2)
        guard case .path(let corners)? = geometry.instructions.last else {
            return XCTFail("Expected the corner bracket path")
        }
        // Four subpaths, one per corner.
        let moves = corners.segments.filter {
            if case .move = $0 { return true }
            return false
        }
        XCTAssertEqual(moves.count, 4)
        XCTAssertEqual(corners.style.fill, .frameStroke)
    }

    func testUnframeableSymbolComposesToEmptyGeometry() throws {
        // Control measures have no frame rendering defined yet.
        let geometry = SymbolComposer.geometry(for: try MilSymbol("10032500000000000000"))
        XCTAssertTrue(geometry.instructions.isEmpty)
    }

    func testEveryFramedBaseAndDomainComposes() {
        let framedDomains: [SymbolDomain] = [
            .air, .space, .landUnit, .landEquipment, .landInstallation,
            .seaSurface, .subsurface, .activity, .dismountedIndividual,
        ]
        for base in FrameBase.allCases {
            for domain in framedDomains {
                guard let shape = FrameShape.resolve(base: base, domain: domain) else {
                    XCTFail("No frame for \(base) x \(domain)")
                    continue
                }
                let instruction = SymbolComposer.instruction(for: shape, style: .frame)
                switch instruction {
                case .path(let path):
                    XCTAssertFalse(path.segments.isEmpty)
                case .circle(_, let radius, _):
                    XCTAssertEqual(radius, 60)
                }
            }
        }
    }

    // MARK: - Dismounted individual

    func testDismountedIndividualDomainAndHexagonFrame() throws {
        let friend = try MilSymbol("10032700000000000000")
        XCTAssertEqual(friend.domain, .dismountedIndividual)
        XCTAssertEqual(friend.frame.shape, .hexagon)

        XCTAssertEqual(try MilSymbol("10062700000000000000").frame.shape, .diamond)
        XCTAssertEqual(try MilSymbol("10042700000000000000").frame.shape, .square)
        XCTAssertEqual(try MilSymbol("10012700000000000000").frame.shape, .quatrefoil)
    }

    // MARK: - Fill classes and palette

    func testFillClassMapping() throws {
        XCTAssertEqual(try MilSymbol("10033000000000000000").fillClass, .friend)
        XCTAssertEqual(try MilSymbol("10023000000000000000").fillClass, .friend)   // assumed friend
        XCTAssertEqual(try MilSymbol("10063000000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("10043000000000000000").fillClass, .neutral)
        XCTAssertEqual(try MilSymbol("10013000000000000000").fillClass, .unknown)
        XCTAssertEqual(try MilSymbol("10003000000000000000").fillClass, .unknown)  // pending
        XCTAssertEqual(try MilSymbol("10053000000000000000").fillClass, .suspect)
        XCTAssertEqual(try MilSymbol("10153000000000000000").fillClass, .suspect)  // joker
        XCTAssertEqual(try MilSymbol("10163000000000000000").fillClass, .hostile)  // faker
    }

    func testCivilianFillOnlyForNonThreatAffiliations() throws {
        XCTAssertTrue(try MilSymbol("10031100000000000000").isCivilian)
        XCTAssertEqual(try MilSymbol("10031100000000000000").fillClass, .civilian)
        XCTAssertEqual(try MilSymbol("10041100000000000000").fillClass, .civilian)
        XCTAssertEqual(try MilSymbol("10011100000000000000").fillClass, .civilian)
        // Hostile and suspect civilians keep the threat fill.
        XCTAssertEqual(try MilSymbol("10061100000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("10051100000000000000").fillClass, .suspect)
        // Charlie codes are never civilian for now.
        XCTAssertFalse(try MilSymbol("SFGPUCI--------").isCivilian)
    }

    func testStandardPaletteValues() {
        let light = SymbolPalette.light
        XCTAssertEqual(light.color(for: .affiliationFill, fillClass: .friend), .rgb255(128, 224, 255))
        XCTAssertEqual(light.color(for: .affiliationFill, fillClass: .hostile), .rgb255(255, 128, 128))
        XCTAssertEqual(light.color(for: .affiliationFill, fillClass: .suspect), .rgb255(255, 229, 153))
        XCTAssertEqual(light.color(for: .affiliationFill, fillClass: .civilian), .rgb255(255, 161, 255))
        XCTAssertEqual(light.color(for: .frameStroke, fillClass: .friend), .black)
        XCTAssertEqual(light.color(for: .contrastFill, fillClass: .hostile), .white)
        XCTAssertEqual(light.color(for: .none, fillClass: .friend), .clear)

        XCTAssertEqual(SymbolPalette.medium.color(for: .affiliationFill, fillClass: .friend), .rgb255(0, 168, 220))
        XCTAssertEqual(SymbolPalette.dark.color(for: .affiliationFill, fillClass: .hostile), .rgb255(200, 0, 0))
    }

    func testCustomPaletteSubstitution() throws {
        // A colorblind-safe experiment: hostile fill becomes a blue-free
        // orange without touching any geometry.
        var palette = SymbolPalette.light
        palette.fills[.hostile] = .rgb255(230, 159, 0)
        XCTAssertEqual(palette.color(for: .affiliationFill, fillClass: .hostile), .rgb255(230, 159, 0))
        // The standard palette is a value type and is unaffected.
        XCTAssertEqual(SymbolPalette.light.color(for: .affiliationFill, fillClass: .hostile), .rgb255(255, 128, 128))
    }
}
