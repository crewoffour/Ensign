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

#if canImport(CoreGraphics)
import XCTest
import CoreGraphics
import EnsignCore
import EnsignRender

final class SpriteAtlasTests: XCTestCase {

    private func symbols(_ sidcs: [String]) throws -> [(name: String, symbol: MilSymbol)] {
        try sidcs.enumerated().map { ("sprite-\($0.offset)", try MilSymbol($0.element)) }
    }

    func testAtlasPacksEntriesWithinBoundsWithoutOverlap() throws {
        let builder = SpriteAtlasBuilder(pointSize: 32, pixelRatio: 2, padding: 2)
        let input = try symbols([
            "10033000001201000000",
            "10063000001201000000",
            "10043000001401000000",
            "10013500001101000000",
            "10031000001211000000",
        ])
        let result = try XCTUnwrap(builder.build(input))
        XCTAssertTrue(result.skipped.isEmpty)
        XCTAssertEqual(result.atlas.entries.count, input.count)

        let cell = 32 * 2
        for entry in result.atlas.entries {
            XCTAssertEqual(entry.width, cell)
            XCTAssertEqual(entry.height, cell)
            XCTAssertEqual(entry.pixelRatio, 2)
            XCTAssertGreaterThanOrEqual(entry.x, 0)
            XCTAssertGreaterThanOrEqual(entry.y, 0)
            XCTAssertLessThanOrEqual(entry.x + entry.width, result.atlas.image.width)
            XCTAssertLessThanOrEqual(entry.y + entry.height, result.atlas.image.height)
        }

        // No two placements intersect.
        let rects = result.atlas.entries.map {
            CGRect(x: $0.x, y: $0.y, width: $0.width, height: $0.height)
        }
        for i in rects.indices {
            for j in rects.indices where j > i {
                XCTAssertFalse(rects[i].intersects(rects[j]),
                    "entries \(i) and \(j) overlap")
            }
        }
    }

    func testSpriteJSONRoundTrips() throws {
        let builder = SpriteAtlasBuilder(pointSize: 24, pixelRatio: 1)
        let input = try symbols(["10033000001201000000", "10063500001101000000"])
        let result = try XCTUnwrap(builder.build(input))
        let data = try result.atlas.spriteJSONData()

        struct Rect: Decodable {
            let x: Int
            let y: Int
            let width: Int
            let height: Int
            let pixelRatio: Int
        }
        let decoded = try JSONDecoder().decode([String: Rect].self, from: data)
        XCTAssertEqual(Set(decoded.keys), Set(input.map(\.name)))
        for entry in result.atlas.entries {
            let rect = try XCTUnwrap(decoded[entry.name])
            XCTAssertEqual(rect.x, entry.x)
            XCTAssertEqual(rect.y, entry.y)
            XCTAssertEqual(rect.width, entry.width)
            XCTAssertEqual(rect.height, entry.height)
            XCTAssertEqual(rect.pixelRatio, 1)
        }
    }

    func testUnrenderableAndDuplicateNamesAreSkippedWithReasons() throws {
        let builder = SpriteAtlasBuilder()
        var input = try symbols(["10033000001201000000"])
        // A control measure has no frame rendering yet.
        input.append(("control-measure", try MilSymbol("10032500000000000000")))
        // A duplicate of the first name.
        input.append(("sprite-0", try MilSymbol("10063000001201000000")))
        let result = try XCTUnwrap(builder.build(input))
        XCTAssertEqual(result.atlas.entries.count, 1)
        XCTAssertEqual(result.skipped.count, 2)
        let skippedNames = Set(result.skipped.map(\.name))
        XCTAssertTrue(skippedNames.contains("control-measure"))
        XCTAssertTrue(skippedNames.contains("sprite-0"))
        for entry in result.skipped {
            XCTAssertFalse(entry.reason.isEmpty)
        }
    }

    func testNothingRenderableReturnsNil() throws {
        let builder = SpriteAtlasBuilder()
        let input = [("cm", try MilSymbol("10032500000000000000"))]
        XCTAssertNil(builder.build(input))
    }
}
#endif
