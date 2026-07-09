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

/// A thread-safe cache of rendered symbol images, keyed by render key
/// and pixel size, for runtime rendering pipelines.
///
/// The intended pattern for a map client: resolve each track to its
/// symbol, ask the cache for the image, and register it with the map
/// engine under `symbol.renderKey` the first time that key appears.
/// Symbols sharing a render key share one cached image, so the cache
/// stays small (one entry per distinct visual, not per track or per
/// SIDC) and rendering cost is paid once per visual.
///
/// ```swift
/// let cache = SymbolImageCache()          // .light palette, tight fit
/// if let image = cache.image(for: symbol, size: 80) {
///     style.setImage(UIImage(cgImage: image, scale: 2, orientation: .up),
///                    forName: symbol.renderKey)
/// }
/// ```
///
/// The palette and fit are fixed per cache instance; use separate
/// caches for separate palettes (a day and a night map style, for
/// example).
public final class SymbolImageCache: @unchecked Sendable {

    private struct Key: Hashable {
        let renderKey: String
        let size: Int
    }

    /// The palette every image in this cache renders with.
    public let palette: SymbolPalette
    /// The fit every image in this cache renders with. Tight fit is
    /// the map-sprite default; see ``SpriteFit``.
    public let fit: SpriteFit

    private let renderer: SymbolRenderer
    private let lock = NSLock()
    private var images: [Key: CGImage] = [:]

    public init(palette: SymbolPalette = .light, fit: SpriteFit = .tight) {
        self.palette = palette
        self.fit = fit
        self.renderer = SymbolRenderer(palette: palette)
    }

    /// The cached image for a symbol at a pixel size, rendering and
    /// caching it on first request. Returns `nil` when the symbol has
    /// nothing to draw (unframeable domains, or unframed symbols whose
    /// icon is not in the library), in which case nothing is cached.
    public func image(for symbol: MilSymbol, size: Int) -> CGImage? {
        let key = Key(renderKey: symbol.renderKey, size: size)

        lock.lock()
        if let cached = images[key] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        // Render outside the lock; a concurrent duplicate render is
        // harmless (identical output) and the first insert wins.
        guard let rendered = renderer.image(for: symbol, size: size, fit: fit) else {
            return nil
        }

        lock.lock()
        defer { lock.unlock() }
        if let raced = images[key] {
            return raced
        }
        images[key] = rendered
        return rendered
    }

    /// The number of distinct images currently cached.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return images.count
    }

    /// Empties the cache (for palette changes handled by swapping
    /// caches, or memory pressure).
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        images.removeAll()
    }
}
#endif
