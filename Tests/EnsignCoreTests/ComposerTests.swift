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

    func testUncertainIdentityTakesPrecedenceOverAnticipatedStatus() throws {
        // Suspect and planned: one overlay, with the identity pattern.
        // milsymbol assigns the anticipated dash first and lets the
        // uncertain-identity dash overwrite it.
        let symbol = try MilSymbol("10053010000000000000")
        XCTAssertEqual(symbol.frame.dash, .uncertainIdentity)
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
                case .text:
                    XCTFail("frames are never text")
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

    // MARK: - 30-character 2525E codes and maritime frame rules

    func testThirtyCharacterCodesParseAndMatchTwentyCharacterEquivalents() throws {
        // Beacon's atlas codes are full-length 2525E (30 digits).
        let long = try MilSymbol("130310000012110000000000000000")
        let short = try MilSymbol("13031000001211000000")
        XCTAssertEqual(long.domain, .landUnit)
        XCTAssertEqual(long.iconKey, IconKey(family: .delta, code: "10121100"))
        XCTAssertEqual(long.frame, short.frame)
        XCTAssertEqual(long.fillClass, short.fillClass)
        XCTAssertEqual(long.iconKey, short.iconKey)
        // Version 13 keeps the edition-aware suspect fill.
        XCTAssertEqual(try MilSymbol("130530000014010000000000000000").fillClass, .suspect)
        // 21 digits is still invalid.
        XCTAssertThrowsError(try MilSymbol("130310000012110000000"))
    }

    func testFrameShapeModifierParsesFromExtensionBlock() throws {
        guard case .delta(let plain) = try MilSymbol("130310000012110000000000000000").sidc else {
            return XCTFail("expected delta")
        }
        XCTAssertEqual(plain.extensionDigits, "0000000000")
        XCTAssertNil(plain.frameShapeModifier)
        guard case .delta(let overridden) = try MilSymbol("130310000012110000000010000000").sidc else {
            return XCTFail("expected delta")
        }
        XCTAssertEqual(overridden.frameShapeModifier, "1")
        guard case .delta(let short) = try MilSymbol("13031000001211000000").sidc else {
            return XCTFail("expected delta")
        }
        XCTAssertEqual(short.extensionDigits, "")
        XCTAssertNil(short.frameShapeModifier)
    }

    func testSeaOwnTrackRendersUnframed() throws {
        let ownTrack = try MilSymbol("10033000001500000000")
        XCTAssertTrue(ownTrack.isOwnTrack)
        XCTAssertFalse(ownTrack.frame.isFramed)
        XCTAssertNotNil(ownTrack.frame.shape)
        // An unframed symbol composes to its icon alone: no frame,
        // fill, or overlay instructions ever. This holds whether or
        // not the generated library currently carries the icon.
        let geometry = SymbolComposer.geometry(for: ownTrack)
        let icon = IconLibrary.instructions(
            for: ownTrack.iconKey,
            base: ownTrack.affiliation.frameBase
        ) ?? []
        XCTAssertEqual(geometry.instructions, icon,
            "unframed symbols must compose to exactly their icon instructions")
        // Ordinary sea tracks are unaffected.
        XCTAssertFalse(try MilSymbol("10033000001201000000").isOwnTrack)
        XCTAssertTrue(try MilSymbol("10033000001201000000").frame.isFramed)
    }

    func testFusedTracksForceThePendingDash() throws {
        for sidc in ["10033000001600000000", "10033500001400000000", "10033500001500000000"] {
            let symbol = try MilSymbol(sidc)
            XCTAssertTrue(symbol.isFusedTrack, sidc)
            XCTAssertEqual(symbol.frame.dash, .uncertainIdentity, sidc)
            XCTAssertTrue(symbol.frame.isFramed, sidc)
        }
        // Fused rules are exact entity matches; neighbors are unaffected.
        XCTAssertFalse(try MilSymbol("10033000001601000000").isFusedTrack)
        XCTAssertFalse(try MilSymbol("10033500001401000000").isFusedTrack)
        // A friend fused track is dashed despite the certain identity.
        XCTAssertTrue(try MilSymbol("10033000001600000000").frame.isDashed)
    }

    func testGeometryExtentCoversFrameAndStroke() throws {
        // Friend land unit: rectangle 25,50-175,150 with a width-4
        // stroke, so the extent grows by 2 on every side.
        let rectangle = try XCTUnwrap(
            SymbolComposer.geometry(for: try MilSymbol("10031000000000000000")).extent)
        XCTAssertEqual(rectangle.x1, 23, accuracy: 0.001)
        XCTAssertEqual(rectangle.y1, 48, accuracy: 0.001)
        XCTAssertEqual(rectangle.x2, 177, accuracy: 0.001)
        XCTAssertEqual(rectangle.y2, 152, accuracy: 0.001)

        // Friend sea surface: circle center 100,100 r 60 plus stroke.
        let circle = try XCTUnwrap(
            SymbolComposer.geometry(for: try MilSymbol("10033000000000000000")).extent)
        XCTAssertEqual(circle.x1, 38, accuracy: 0.001)
        XCTAssertEqual(circle.x2, 162, accuracy: 0.001)

        // Empty geometry has no extent.
        XCTAssertNil(SymbolComposer.geometry(for: try MilSymbol("10032500000000000000")).extent)
    }

    func testRenderKeyIdentifiesRenderingNotCode() throws {
        // A 20-digit code and its 30-digit equivalent render alike.
        XCTAssertEqual(
            try MilSymbol("13031000001211000000").renderKey,
            try MilSymbol("130310000012110000000000000000").renderKey)
        // Different affiliations render differently.
        XCTAssertNotEqual(
            try MilSymbol("10033000001201000000").renderKey,
            try MilSymbol("10063000001201000000").renderKey)
        // Assumed friend differs from friend (dashed frame).
        XCTAssertNotEqual(
            try MilSymbol("10033000001201000000").renderKey,
            try MilSymbol("10023000001201000000").renderKey)
        // Fused tracks carry their dash in the key.
        XCTAssertTrue(try MilSymbol("10033000001600000000").renderKey.contains("dash-identity"))
        // Own tracks carry their unframed rendering in the key.
        XCTAssertTrue(try MilSymbol("10033000001500000000").renderKey.contains("unframed"))
        // Space and activity overlays are keyed.
        XCTAssertTrue(try MilSymbol("10030500000000000000").renderKey.contains("space"))
        XCTAssertTrue(try MilSymbol("10034000000000000000").renderKey.contains("activity"))
    }

    // MARK: - Frame amplifiers (Session 7a)

    func testAmplifierDecoding() throws {
        XCTAssertEqual(try MilSymbol("10031000331211000000").mobility, .tracked)
        XCTAssertEqual(try MilSymbol("10031500511301000000").mobility, .barge)
        XCTAssertEqual(try MilSymbol("10031500611301000000").mobility, .shortTowedArray)
        // 38 and 39 are unassigned in milsymbol's mapping: no mark.
        XCTAssertNil(try MilSymbol("10031500381301000000").mobility)
        XCTAssertNil(try MilSymbol("10031000161211000000").mobility)
        XCTAssertEqual(try MilSymbol("10031000161211000000").echelon, .battalionSquadron)
        XCTAssertEqual(
            try MilSymbol("10031007001211000000").headquartersTaskForceDummy,
            [.feintDummy, .taskForce, .headquarters])
    }

    func testAmplifiersComposeAfterFrameAndIcon() throws {
        // A plain friend land unit frame composes to one instruction;
        // each amplifier adds its marks on top, in order.
        let plain = SymbolComposer.geometry(for: try MilSymbol("10031000000000000000"))
        XCTAssertEqual(plain.instructions.count, 1)

        // HQ + TF + FD (digit 7): staff, bracket, caret.
        let hqtfd = SymbolComposer.geometry(for: try MilSymbol("10031007000000000000"))
        XCTAssertEqual(hqtfd.instructions.count, 4)
        // The caret is dashed with milsymbol's feint/dummy pattern.
        guard case .path(let caret) = hqtfd.instructions[3] else {
            return XCTFail("expected the caret last")
        }
        XCTAssertEqual(caret.style.dash, [8, 8])

        // Battalion echelon: two vertical bars.
        let battalion = SymbolComposer.geometry(for: try MilSymbol("10031000160000000000"))
        XCTAssertEqual(battalion.instructions.count, 3)

        // Tracked equipment: one capsule path below the frame.
        let tracked = SymbolComposer.geometry(for: try MilSymbol("10031500330000000000"))
        XCTAssertEqual(tracked.instructions.count, 2)

        // The installation bar appears for the installation symbol set
        // and is filled with the frame color role.
        let installation = SymbolComposer.geometry(for: try MilSymbol("10032000000000000000"))
        XCTAssertEqual(installation.instructions.count, 2)
        guard case .path(let bar) = installation.instructions[1] else {
            return XCTFail("expected the bar")
        }
        XCTAssertEqual(bar.style.fill, .frameStroke)

        // Amplifiers extend the extent (the HQ staff reaches 100 units
        // below the frame), so tight-fit rendering absorbs them.
        let staffExtent = try XCTUnwrap(
            SymbolComposer.geometry(for: try MilSymbol("10031002000000000000")).extent)
        XCTAssertGreaterThan(staffExtent.y2, 200)
    }

    func testRenderKeyCoversAmplifiers() throws {
        let plain = try MilSymbol("10031000001211000000").renderKey
        XCTAssertTrue(plain.hasPrefix("ensign5:"))
        let battalionHQ = try MilSymbol("10031002161211000000").renderKey
        XCTAssertTrue(battalionHQ.contains("hq"))
        XCTAssertTrue(battalionHQ.contains("e-battalionSquadron"))
        XCTAssertNotEqual(plain, battalionHQ)
        XCTAssertTrue(try MilSymbol("10031500331301000000").renderKey.contains("m-tracked"))
    }

    // MARK: - Exercise context, joker, and faker (Session 7b)

    func testJokerAndFakerTakeTheFriendFrameWithThreatColors() throws {
        let friend = try MilSymbol("10031000000000000000")
        let joker = try MilSymbol("13151000000000000000")
        let faker = try MilSymbol("10161000000000000000")
        // Friend frame shape, threat fills.
        XCTAssertEqual(joker.frame.shape, friend.frame.shape)
        XCTAssertEqual(faker.frame.shape, friend.frame.shape)
        XCTAssertEqual(joker.fillClass, .suspect)   // version 13
        XCTAssertEqual(faker.fillClass, .hostile)
        // Joker identity is uncertain (dashed); faker is not.
        XCTAssertTrue(joker.frame.isDashed)
        XCTAssertFalse(faker.frame.isDashed)
        // Amplifier letters.
        XCTAssertEqual(joker.exerciseAmplifierLetter, "J")
        XCTAssertEqual(faker.exerciseAmplifierLetter, "K")
        XCTAssertEqual(try MilSymbol("10131000000000000000").exerciseAmplifierLetter, "X")
        XCTAssertEqual(try MilSymbol("10231000000000000000").exerciseAmplifierLetter, "S")
        XCTAssertNil(friend.exerciseAmplifierLetter)
    }

    func testExerciseAmplifierComposesWhenGlyphsAreBaked() throws {
        // Glyph-presence-agnostic: the exercise symbol carries exactly
        // one more instruction than its reality twin when the glyph
        // exists, and the same count when it does not (placeholder).
        let reality = SymbolComposer.geometry(for: try MilSymbol("10031000000000000000"))
        let exercise = SymbolComposer.geometry(for: try MilSymbol("10131000000000000000"))
        let expected = reality.instructions.count
            + (GeneratedExerciseGlyphs.segments(for: "X") != nil ? 1 : 0)
        XCTAssertEqual(exercise.instructions.count, expected)
    }

    func testRenderKeyCoversExerciseContext() throws {
        let reality = try MilSymbol("10031000000000000000").renderKey
        let exercise = try MilSymbol("10131000000000000000").renderKey
        XCTAssertTrue(reality.hasPrefix("ensign5:"))
        XCTAssertTrue(exercise.contains(":ex"))
        XCTAssertNotEqual(reality, exercise)
        XCTAssertTrue(try MilSymbol("10231000000000000000").renderKey.contains(":sim"))
        // Joker and suspect render differently and key differently.
        XCTAssertNotEqual(
            try MilSymbol("13151000000000000000").renderKey,
            try MilSymbol("13051000000000000000").renderKey)
    }

    // MARK: - Direction arrow and frameless icons (Session 7c)

    func testDirectionArrowGeometry() throws {
        let arrow = ModifierGeometry.directionOfMovementArrow()
        XCTAssertEqual(arrow.instructions.count, 1)
        // Anchored at the canvas center, reaching to y 13 (milsymbol's
        // 95-unit arrow: 75-unit shaft plus the dart).
        let extent = try XCTUnwrap(arrow.extent)
        XCTAssertEqual(extent.y1, 11, accuracy: 0.001)   // 13 - stroke/2
        XCTAssertEqual(extent.y2, 102, accuracy: 0.001)  // 100 + stroke/2
        XCTAssertEqual((extent.x1 + extent.x2) / 2, 100, accuracy: 0.001)
    }

    func testFramelessDomainsRenderTheirIconWhenPresent() throws {
        // Control measure points have no frame; they compose to exactly
        // their icon instructions (empty until the icons are extracted),
        // never to frame geometry. Same invariant style as the own
        // track test: holds for any library state.
        let checkpoint = try MilSymbol("130425000013030000000000000000")
        XCTAssertNil(checkpoint.frame.shape)
        let icon = IconLibrary.instructions(
            for: checkpoint.iconKey,
            base: checkpoint.affiliation.frameBase
        ) ?? []
        XCTAssertEqual(
            SymbolComposer.geometry(for: checkpoint).instructions, icon,
            "frameless symbols must compose to exactly their icon instructions")
    }

    // MARK: - Status conditions and leadership (Session 8a)

    func testConditionBarComposesForFilledSymbols() throws {
        let plain = SymbolComposer.geometry(for: try MilSymbol("10031000000000000000"))
        // Damaged friend land unit: frame plus the condition bar.
        let damaged = SymbolComposer.geometry(for: try MilSymbol("10031030000000000000"))
        XCTAssertEqual(damaged.instructions.count, plain.instructions.count + 1)
        guard case .path(let bar) = damaged.instructions.last else {
            return XCTFail("expected the bar last")
        }
        XCTAssertEqual(bar.style.fill, .conditionDamaged)
        XCTAssertEqual(bar.style.stroke, .frameStroke)
        // The four condition roles resolve to milsymbol's colors in the
        // light palette.
        let palette = SymbolPalette.light
        XCTAssertEqual(palette.color(for: .conditionFullyCapable, fillClass: .friend),
                       .rgb255(0, 255, 0))
        XCTAssertEqual(palette.color(for: .conditionFullToCapacity, fillClass: .friend),
                       .rgb255(0, 180, 240))
    }

    func testMineWarfareRendersFramedUnfilled() throws {
        // Set 36 is framed but unfilled (milsymbol metadata: frame
        // true, fill false): the outline and icons carry the saturated
        // affiliation colors instead of black linework and pastel
        // fills.
        let mine = try MilSymbol("10043600000000000000")
        XCTAssertFalse(mine.isFilled)
        XCTAssertTrue(mine.frame.isFramed)
        let geometry = SymbolComposer.geometry(for: mine)
        XCTAssertEqual(geometry.instructions.count, 1)
        guard case .path(let outline) = geometry.instructions[0] else {
            return XCTFail("expected the frame outline")
        }
        XCTAssertEqual(outline.style.stroke, .affiliationColor)
        XCTAssertEqual(outline.style.fill, ColorRole.none)
        // The saturated set resolves per affiliation; the palette can
        // override it like any other role.
        XCTAssertEqual(
            SymbolPalette.light.color(for: .affiliationColor, fillClass: .hostile),
            .rgb255(255, 0, 0))
        // A pending mine takes the standard dash construction: solid
        // outline in the saturated color, white contrast dash overlay
        // on top, exactly like filled frames.
        let pending = SymbolComposer.geometry(for: try MilSymbol("10003600000000000000"))
        guard case .path(let solidOutline) = pending.instructions.first else {
            return XCTFail("expected the solid outline")
        }
        XCTAssertEqual(solidOutline.style.stroke, .affiliationColor)
        XCTAssertNil(solidOutline.style.dash)
        guard case .path(let overlay) = pending.instructions[1] else {
            return XCTFail("expected the dash overlay")
        }
        XCTAssertEqual(overlay.style.stroke, .contrastFill)
        XCTAssertNotNil(overlay.style.dash)
        // Unfilled conditions take slashes in the saturated color, not
        // the bar: one for damaged, two for destroyed, appended last.
        let damaged = SymbolComposer.geometry(for: try MilSymbol("10043630000000000000"))
        let destroyed = SymbolComposer.geometry(for: try MilSymbol("10043640000000000000"))
        XCTAssertEqual(destroyed.instructions.count, damaged.instructions.count + 1)
        guard case .path(let slash) = damaged.instructions.last else {
            return XCTFail("expected the slash")
        }
        XCTAssertEqual(slash.style.stroke, .affiliationColor)
        XCTAssertEqual(slash.style.strokeWidth, 8)
        XCTAssertTrue(mine.renderKey.contains("nofill"))
        XCTAssertFalse(mine.renderKey.contains("unframed"))
    }

    func testLeadershipChevronForFriendlyAffiliationsOnly() throws {
        XCTAssertEqual(try MilSymbol("10032700710000000000").leadership, .individual)
        XCTAssertEqual(try MilSymbol("10032700720000000000").leadership, .deputyIndividual)
        let friend = SymbolComposer.geometry(for: try MilSymbol("10032700710000000000"))
        let plain = SymbolComposer.geometry(for: try MilSymbol("10032700000000000000"))
        XCTAssertEqual(friend.instructions.count, plain.instructions.count + 1)
        // Hostile leadership renders no chevron, matching milsymbol.
        let hostile = SymbolComposer.geometry(for: try MilSymbol("10062700710000000000"))
        let hostilePlain = SymbolComposer.geometry(for: try MilSymbol("10062700000000000000"))
        XCTAssertEqual(hostile.instructions.count, hostilePlain.instructions.count)
    }

    func testRenderKeyCoversConditionsLeadershipAndFill() throws {
        XCTAssertTrue(try MilSymbol("10031030000000000000").renderKey.contains("c-dmg"))
        XCTAssertTrue(try MilSymbol("10032700710000000000").renderKey.contains("lead"))
        XCTAssertTrue(try MilSymbol("10043600000000000000").renderKey.contains("nofill"))
        XCTAssertFalse(try MilSymbol("10031000000000000000").renderKey.contains("c-"))
    }

    // MARK: - Charlie amplifiers (Session 8b)

    func testCharlieMobilityAndInstallationDecode() throws {
        XCTAssertEqual(try MilSymbol("SFGPE-----MQ---").mobility, .tracked)
        XCTAssertEqual(try MilSymbol("SFGPE-----NS---").mobility, .shortTowedArray)
        XCTAssertNil(try MilSymbol("SFGPE-----MZ---").mobility)
        XCTAssertNil(try MilSymbol("SFGPU------F---").mobility)
        XCTAssertTrue(try MilSymbol("SFGPI-----H----").isInstallation)
        XCTAssertFalse(try MilSymbol("SFGPU-----A----").isInstallation)
        // Delta installations keep the flag through the symbol set.
        XCTAssertTrue(try MilSymbol("10032000000000000000").isInstallation)
    }

    func testCharlieAmplifiersCompose() throws {
        // Tracked equipment through the charlie path: frame plus the
        // capsule, same as its delta twin.
        let charlie = SymbolComposer.geometry(for: try MilSymbol("SFGPE-----MQ---"))
        let delta = SymbolComposer.geometry(for: try MilSymbol("10031500330000000000"))
        XCTAssertEqual(charlie.instructions.count, delta.instructions.count)
        // Charlie function I is an installation by domain: the bar is
        // already there, and the H modifier is redundant on it.
        let plainI = SymbolComposer.geometry(for: try MilSymbol("SFGPI----------"))
        XCTAssertEqual(plainI.instructions.count, 2)
        let modifierI = SymbolComposer.geometry(for: try MilSymbol("SFGPI-----H----"))
        XCTAssertEqual(modifierI.instructions.count, plainI.instructions.count)
        // On a non-installation function, H alone raises the bar.
        let plainU = SymbolComposer.geometry(for: try MilSymbol("SFGPU----------"))
        let modifierU = SymbolComposer.geometry(for: try MilSymbol("SFGPU-----H----"))
        XCTAssertEqual(modifierU.instructions.count, plainU.instructions.count + 1)
    }

    // MARK: - Sector modifiers (Session 12)

    func testSectorModifierKeysAndRenderKey() throws {
        // UAV with the attack/strike sector one modifier, from the
        // JMSML crosswalk.
        let uav = try MilSymbol("10030100001103000100")
        XCTAssertEqual(uav.sectorOneModifierIconKey,
                       IconKey(family: .delta, code: "01m101"))
        XCTAssertNil(uav.sectorTwoModifierIconKey)
        // Tanker with the boom sector two modifier.
        let tanker = try MilSymbol("10030100001101090004")
        XCTAssertEqual(tanker.sectorTwoModifierIconKey,
                       IconKey(family: .delta, code: "01m204"))
        XCTAssertNil(try MilSymbol("10030100001101000000").sectorOneModifierIconKey)
        // Render keys distinguish modifier variants; version bumped.
        XCTAssertTrue(uav.renderKey.hasPrefix("ensign5:"))
        XCTAssertTrue(uav.renderKey.contains("m1-01"))
        XCTAssertNotEqual(uav.renderKey,
                          try MilSymbol("10030100001103000000").renderKey)
        // The extraction key for a modifier-probe SIDC is the modifier
        // icon key; for a combined SIDC, the entity key.
        XCTAssertEqual(try MilSymbol("10030100000000000100").extractionIconKey.code, "01m101")
        XCTAssertEqual(uav.extractionIconKey.code, "01110300")
    }

    func testSectorModifierIconsCompose() throws {
        // Library-agnostic: the combined symbol carries the entity icon
        // plus each modifier icon's instructions, whatever the library
        // holds today.
        let base = try MilSymbol("10030100001103000000")
        let combined = try MilSymbol("10030100001103000100")
        let modifierIcon = IconLibrary.instructions(
            for: IconKey(family: .delta, code: "01m101"),
            base: combined.affiliation.frameBase) ?? []
        let baseCount = SymbolComposer.geometry(for: base).instructions.count
        let combinedCount = SymbolComposer.geometry(for: combined).instructions.count
        XCTAssertEqual(combinedCount, baseCount + modifierIcon.count)
    }

    // MARK: - Info fields (Session 13)

    func testInfoFieldLayoutRowsAndGrowth() throws {
        var fields = InfoFields()
        fields.uniqueDesignation = "A21"
        fields.dtg = "30140000ZSEP97"
        fields.higherFormation = "X"
        let symbol = try MilSymbol("10031000001211000000")
        let plain = SymbolComposer.geometry(for: symbol)
        let withFields = SymbolComposer.geometry(for: symbol, infoFields: fields)
        // Three populated fields: three text instructions appended.
        XCTAssertEqual(withFields.instructions.count, plain.instructions.count + 3)
        XCTAssertNil(plain.canvasBounds)
        let bounds = try XCTUnwrap(withFields.canvasBounds)
        // Ground layout: dtg is L1 (end-anchored left, first row above
        // center), uniqueDesignation L4, higherFormation R4.
        let texts: [TextInstruction] = withFields.instructions.compactMap {
            if case .text(let t) = $0 { return t } else { return nil }
        }
        let dtg = try XCTUnwrap(texts.first { $0.text == "30140000ZSEP97" })
        XCTAssertEqual(dtg.anchor, .end)
        XCTAssertEqual(dtg.y, 100 - 1.5 * InfoFieldLayout.fontSize)
        let designation = try XCTUnwrap(texts.first { $0.text == "A21" })
        XCTAssertEqual(designation.y, 100 + 1.5 * InfoFieldLayout.fontSize)
        // The canvas grows left by the dtg width estimate and gains
        // the row-4 space below.
        let frame = FrameGeometry.bounds(for: try XCTUnwrap(symbol.frame.shape))
        let expectedLeft = frame.x1 - StringWidth.estimate(
            "30140000ZSEP97", fontSize: InfoFieldLayout.fontSize,
            spaceTextIcon: InfoFieldLayout.spaceTextIcon)
        // The final bounds carry the reference renderer's uniform
        // 4-unit viewbox margin.
        XCTAssertEqual(bounds.x1, expectedLeft - 4, accuracy: 0.001)
        XCTAssertEqual(bounds.y2, 100 + 1.7 * InfoFieldLayout.fontSize + 4, accuracy: 0.001)
        // Empty fields change nothing.
        XCTAssertEqual(
            SymbolComposer.geometry(for: symbol, infoFields: InfoFields()).instructions.count,
            plain.instructions.count)
    }

    func testStringWidthEstimatorMatchesMilsymbol() {
        // W is the widest at 32; unknown characters cost 28.5; the
        // fontSize/30 scaling and spacing addend apply.
        XCTAssertEqual(StringWidth.estimate("W", fontSize: 30, spaceTextIcon: 0), 32)
        XCTAssertEqual(StringWidth.estimate("", fontSize: 40, spaceTextIcon: 20), 0)
        XCTAssertEqual(StringWidth.estimate("A21", fontSize: 30, spaceTextIcon: 20),
                       23 + 19 + 19 + 20, accuracy: 0.001)
        XCTAssertEqual(StringWidth.estimate("素", fontSize: 30, spaceTextIcon: 0),
                       28.5, accuracy: 0.001)
    }

    // MARK: - Fill classes and palette

    func testFillClassMapping() throws {
        XCTAssertEqual(try MilSymbol("10033000000000000000").fillClass, .friend)
        XCTAssertEqual(try MilSymbol("10023000000000000000").fillClass, .friend)   // assumed friend
        XCTAssertEqual(try MilSymbol("10063000000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("10043000000000000000").fillClass, .neutral)
        XCTAssertEqual(try MilSymbol("10013000000000000000").fillClass, .unknown)
        XCTAssertEqual(try MilSymbol("10003000000000000000").fillClass, .unknown)  // pending
        XCTAssertEqual(try MilSymbol("10163000000000000000").fillClass, .hostile)  // faker
    }

    func testSuspectFillIsEditionAware() throws {
        // 2525D-coded suspects and jokers fill hostile (with the dashed
        // frame); the distinct suspect amber is a 2525E treatment,
        // applied to version 13/14 SIDCs. Matches milsymbol.
        XCTAssertEqual(try MilSymbol("10053000000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("10153000000000000000").fillClass, .hostile)  // joker
        XCTAssertEqual(try MilSymbol("13053000000000000000").fillClass, .suspect)
        XCTAssertEqual(try MilSymbol("13153000000000000000").fillClass, .suspect)  // joker
        XCTAssertEqual(try MilSymbol("14053000000000000000").fillClass, .suspect)
        // Charlie is 2525C: suspect fills hostile.
        XCTAssertEqual(try MilSymbol("SSSP-----------").fillClass, .hostile)
        // The dashed identity frame applies in every edition.
        XCTAssertTrue(try MilSymbol("10053000000000000000").frame.isDashed)
        XCTAssertTrue(try MilSymbol("13053000000000000000").frame.isDashed)
    }

    func testCivilianFillOnlyForNonThreatAffiliations() throws {
        XCTAssertTrue(try MilSymbol("10031100000000000000").isCivilian)
        XCTAssertEqual(try MilSymbol("10031100000000000000").fillClass, .civilian)
        XCTAssertEqual(try MilSymbol("10041100000000000000").fillClass, .civilian)
        XCTAssertEqual(try MilSymbol("10011100000000000000").fillClass, .civilian)
        // Hostile and suspect civilians keep the threat fill.
        XCTAssertEqual(try MilSymbol("10061100000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("10051100000000000000").fillClass, .hostile)
        XCTAssertEqual(try MilSymbol("13051100000000000000").fillClass, .suspect)
        // Charlie codes are never civilian for now.
        XCTAssertFalse(try MilSymbol("SFGPUCI--------").isCivilian)
    }

    func testCivilianEntityPrefixesMatchMilsymbol() throws {
        // Sea surface 14xxxx is civilian; 12xxxx is a military combatant.
        XCTAssertTrue(try MilSymbol("10033000001401000000").isCivilian)
        XCTAssertEqual(try MilSymbol("10033000001401000000").fillClass, .civilian)
        XCTAssertFalse(try MilSymbol("10033000001201000000").isCivilian)
        XCTAssertEqual(try MilSymbol("10033000001201000000").fillClass, .friend)
        // Air and subsurface 12xxxx are civilian.
        XCTAssertTrue(try MilSymbol("10030100001200000000").isCivilian)
        XCTAssertTrue(try MilSymbol("10033500001201000000").isCivilian)
        XCTAssertFalse(try MilSymbol("10033500001101000000").isCivilian)
        // Land equipment 16xxxx is civilian; 12xxxx is not.
        XCTAssertTrue(try MilSymbol("10031500001600000000").isCivilian)
        XCTAssertFalse(try MilSymbol("10031500001200000000").isCivilian)
        // The threat override still applies to entity-flagged civilians.
        XCTAssertEqual(try MilSymbol("10063000001401000000").fillClass, .hostile)
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
