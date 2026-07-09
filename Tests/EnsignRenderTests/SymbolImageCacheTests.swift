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

final class SymbolImageCacheTests: XCTestCase {

    func testCacheReturnsSameInstanceAndSharesRenderKeys() throws {
        let cache = SymbolImageCache()
        let short = try MilSymbol("13033000001201000000")
        let long = try MilSymbol("130330000012010000000000000000")

        let first = try XCTUnwrap(cache.image(for: short, size: 80))
        let second = try XCTUnwrap(cache.image(for: short, size: 80))
        XCTAssertTrue(first === second, "repeat requests return the cached instance")

        // The 30-digit equivalent shares the render key and the image.
        let equivalent = try XCTUnwrap(cache.image(for: long, size: 80))
        XCTAssertTrue(first === equivalent)
        XCTAssertEqual(cache.count, 1)

        // A different size is a distinct entry.
        _ = cache.image(for: short, size: 40)
        XCTAssertEqual(cache.count, 2)

        // A different affiliation is a distinct entry.
        _ = cache.image(for: try MilSymbol("13063000001201000000"), size: 80)
        XCTAssertEqual(cache.count, 3)
    }

    func testUnrenderableSymbolsCacheNothing() throws {
        let cache = SymbolImageCache()
        XCTAssertNil(cache.image(for: try MilSymbol("10032500000000000000"), size: 80))
        XCTAssertEqual(cache.count, 0)
    }

    func testRemoveAllEmptiesTheCache() throws {
        let cache = SymbolImageCache()
        _ = cache.image(for: try MilSymbol("13033000001201000000"), size: 80)
        XCTAssertEqual(cache.count, 1)
        cache.removeAll()
        XCTAssertEqual(cache.count, 0)
    }
}
#endif
