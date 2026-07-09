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
import CoreGraphics
import Foundation
import EnsignCore

/// One sprite's placement in an atlas, in pixel coordinates of the
/// atlas image with the origin at the top left, matching the MapLibre
/// sprite JSON convention.
public struct SpriteAtlasEntry: Hashable, Sendable {
    public let name: String
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
    public let pixelRatio: Int
}

/// A rendered sprite sheet and its placement table.
public struct SpriteAtlas {
    /// The packed sheet.
    public let image: CGImage
    /// Placements, in the order the symbols were supplied.
    public let entries: [SpriteAtlasEntry]

    /// The sheet encoded as PNG.
    public func pngData() -> Data? {
        SymbolRenderer.pngData(from: image)
    }

    /// The MapLibre sprite index: a JSON object mapping each sprite
    /// name to `{x, y, width, height, pixelRatio}`. Keys are sorted
    /// and the output is pretty-printed so regenerated atlases diff
    /// cleanly.
    public func spriteJSONData() throws -> Data {
        struct Rect: Encodable {
            let x: Int
            let y: Int
            let width: Int
            let height: Int
            let pixelRatio: Int
        }
        var index: [String: Rect] = [:]
        for entry in entries {
            index[entry.name] = Rect(
                x: entry.x, y: entry.y,
                width: entry.width, height: entry.height,
                pixelRatio: entry.pixelRatio
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return try encoder.encode(index)
    }
}

/// Renders named symbols into a packed sprite sheet for MapLibre (or
/// any consumer of the standard sprite format).
///
/// ```swift
/// let builder = SpriteAtlasBuilder(pointSize: 32, pixelRatio: 2)
/// let result = builder.build(symbols)   // [(name, MilSymbol)]
/// try result?.atlas.pngData()?.write(to: pngURL)
/// try result?.atlas.spriteJSONData().write(to: jsonURL)
/// ```
public struct SpriteAtlasBuilder: Sendable {
    /// The palette symbols render with.
    public var palette: SymbolPalette
    /// The logical sprite size in points. The rendered pixel size is
    /// `pointSize * pixelRatio`.
    public var pointSize: Int
    /// The display scale this sheet targets (1 for the base sheet, 2
    /// for the @2x sheet). Recorded on every entry per the sprite spec.
    public var pixelRatio: Int
    /// Transparent spacing between sprites in points (scaled by the
    /// pixel ratio, so 1x and 2x sheets have identical layouts),
    /// preventing sample bleed when the map engine scales icons.
    public var padding: Int
    /// How symbols are placed in their cells. `.tight` (the default)
    /// scales each symbol's drawn extent to fill the cell
    /// aspect-preserved, matching the visual weight map sprites need;
    /// `.fullCanvas` keeps the authored 200-canvas margins and a
    /// common scale across all symbols.
    public var fit: SpriteFit

    public init(
        palette: SymbolPalette = .light,
        pointSize: Int = 40,
        pixelRatio: Int = 1,
        padding: Int = 4,
        fit: SpriteFit = .tight
    ) {
        self.palette = palette
        self.pointSize = pointSize
        self.pixelRatio = pixelRatio
        self.padding = padding
        self.fit = fit
    }

    /// Builds the atlas. Symbols that render nothing (unframeable
    /// domains, or unframed symbols whose icon is not in the library)
    /// and duplicate names are skipped and reported by name with a
    /// reason, so a manifest problem is never silent.
    /// Returns `nil` when no symbol rendered at all.
    public func build(
        _ symbols: [(name: String, symbol: MilSymbol)]
    ) -> (atlas: SpriteAtlas, skipped: [(name: String, reason: String)])? {
        let renderer = SymbolRenderer(palette: palette)
        let cell = pointSize * pixelRatio
        let gap = padding * pixelRatio

        var rendered: [(name: String, image: CGImage)] = []
        var skipped: [(name: String, reason: String)] = []
        var seen = Set<String>()
        for (name, symbol) in symbols {
            guard seen.insert(name).inserted else {
                skipped.append((name, "duplicate sprite name; first occurrence kept"))
                continue
            }
            guard let image = renderer.image(for: symbol, size: cell, fit: fit) else {
                if symbol.frame.shape == nil {
                    skipped.append((name, "no frame rendering defined for this domain yet"))
                } else if !symbol.frame.isFramed {
                    skipped.append((name, "unframed symbol whose icon is not in the library yet"))
                } else {
                    skipped.append((name, "renders nothing"))
                }
                continue
            }
            rendered.append((name, image))
        }

        guard !rendered.isEmpty else { return nil }

        let columns = Int(Double(rendered.count).squareRoot().rounded(.up))
        let rows = (rendered.count + columns - 1) / columns
        let sheetWidth = gap + columns * (cell + gap)
        let sheetHeight = gap + rows * (cell + gap)

        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: sheetWidth,
                height: sheetHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }

        var entries: [SpriteAtlasEntry] = []
        entries.reserveCapacity(rendered.count)
        for (index, sprite) in rendered.enumerated() {
            let column = index % columns
            let row = index / columns
            // Top-origin placement for the JSON; flip for CoreGraphics.
            let x = gap + column * (cell + gap)
            let y = gap + row * (cell + gap)
            let cgY = sheetHeight - y - cell
            context.draw(
                sprite.image,
                in: CGRect(x: x, y: cgY, width: cell, height: cell)
            )
            entries.append(SpriteAtlasEntry(
                name: sprite.name,
                x: x, y: y,
                width: cell, height: cell,
                pixelRatio: pixelRatio
            ))
        }

        guard let image = context.makeImage() else { return nil }
        return (SpriteAtlas(image: image, entries: entries), skipped)
    }
}
#endif
