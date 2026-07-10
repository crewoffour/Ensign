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

#if canImport(SwiftUI) && canImport(CoreGraphics)
import SwiftUI
import CoreGraphics
import EnsignCore
import EnsignRender

/// Renders a MIL-STD-2525 symbol as a SwiftUI view.
///
/// Drawing goes through `Canvas`, so the symbol is rendered at the
/// view's actual size on every layout rather than scaling a fixed
/// bitmap: crisp at any size, in previews, lists, and detail views
/// alike.
///
/// ```swift
/// MilSymbolView(try MilSymbol("130330000014010000000000000000"))
///     .frame(width: 64, height: 64)
///
/// MilSymbolView(symbol, palette: .dark)
/// ```
///
/// The symbol fills the largest square that fits the proposed size,
/// centered. Symbols with no drawable geometry (unframeable domains,
/// or unframed symbols whose icon is not in the library) render as
/// empty space, mirroring the composer's degradation behavior.
public struct MilSymbolView: View {
    private let geometry: SymbolGeometry
    private let fillClass: FillClass
    private let accessibilityText: String

    /// The palette resolving color roles. Mutable so callers can apply
    /// `.light`, `.medium`, `.dark`, or a custom palette.
    public var palette: SymbolPalette

    /// How the symbol fills the view. Full canvas (the default) keeps
    /// the authored margins and a common scale across symbols; tight
    /// scales the drawn extent to fill the view, which is the right
    /// choice for amplified symbols (HQ staffs, large echelons) that
    /// overflow the authored canvas and would otherwise clip.
    public var fit: SpriteFit

    /// Creates a view for a parsed symbol.
    public init(_ symbol: MilSymbol, palette: SymbolPalette = .light, fit: SpriteFit = .fullCanvas) {
        self.geometry = SymbolComposer.geometry(for: symbol)
        self.fillClass = symbol.fillClass
        self.palette = palette
        self.fit = fit
        self.accessibilityText = String(describing: symbol)
    }

    public var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            guard side > 0, !geometry.instructions.isEmpty else { return }
            let renderer = SymbolRenderer(palette: palette)
            context.translateBy(
                x: (size.width - side) / 2,
                y: (size.height - side) / 2
            )
            context.withCGContext { cgContext in
                renderer.draw(
                    geometry,
                    fillClass: fillClass,
                    in: cgContext,
                    pixelSize: side,
                    fit: fit
                )
            }
        }
        .accessibilityLabel(accessibilityText)
    }
}

#Preview("Affiliations") {
    HStack(spacing: 12) {
        ForEach(
            ["130330000014010000000000000000",
             "130630000012000000000000000000",
             "130430000014020000000000000000",
             "130130000016000000000000000000"],
            id: \.self
        ) { sidc in
            if let symbol = try? MilSymbol(sidc) {
                MilSymbolView(symbol)
                    .frame(width: 72, height: 72)
            }
        }
    }
    .padding()
}
#endif
