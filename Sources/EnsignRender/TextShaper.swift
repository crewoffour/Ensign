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

#if canImport(CoreGraphics) && canImport(CoreText)
import CoreGraphics
import CoreText
import Foundation
import EnsignCore

/// Shapes anchored text instructions with the bundled Liberation Sans
/// fonts, drawing into the same canvas coordinate space as paths.
///
/// The anchor and baseline rules are the ones the icon pipeline proved
/// pixel-faithful against the reference renderer: start/middle/end
/// anchors offset by the typographic width, and alignment-baseline
/// middle as a baseline shift of half the x-height. Using the same
/// font files as the reference is what makes shaped text
/// oracle-comparable.
enum TextShaper {
    // CTFont is an immutable Core Foundation object documented as
    // thread-safe; the SDK has not annotated it Sendable, so the
    // unsafe marker asserts what the documentation states. Loaded
    // once, read-only thereafter.
    nonisolated(unsafe) private static let regular: CTFont? =
        loadFont(named: "LiberationSans-Regular")
    nonisolated(unsafe) private static let bold: CTFont? =
        loadFont(named: "LiberationSans-Bold")

    private static func loadFont(named name: String) -> CTFont? {
        guard let url = Bundle.module.url(
                forResource: name, withExtension: "ttf", subdirectory: "Fonts"),
              let provider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(provider) else {
            return nil
        }
        return CTFontCreateWithGraphicsFont(cgFont, 12, nil, nil)
    }

    /// Draws a text instruction into the context, in canvas
    /// coordinates. Missing fonts degrade to drawing nothing, matching
    /// the placeholder-glyph philosophy elsewhere.
    static func draw(
        _ instruction: TextInstruction,
        palette: SymbolPalette,
        fillClass: FillClass,
        in context: CGContext
    ) {
        guard let base = instruction.isBold ? bold : regular else { return }
        let font = CTFontCreateCopyWithAttributes(
            base, CGFloat(instruction.fontSize), nil, nil)
        let color = palette.color(for: instruction.fill, fillClass: fillClass)
        let cgColor = CGColor(
            srgbRed: color.red, green: color.green, blue: color.blue,
            alpha: color.alpha)
        let attributed = NSAttributedString(
            string: instruction.text,
            attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): font,
                NSAttributedString.Key(kCTForegroundColorAttributeName as String): cgColor,
            ])
        let line = CTLineCreateWithAttributedString(attributed)
        let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))

        var penX = CGFloat(instruction.x)
        switch instruction.anchor {
        case .start: break
        case .middle: penX -= width / 2
        case .end: penX -= width
        }
        var baselineY = CGFloat(instruction.y)
        if instruction.baseline == .middle {
            baselineY += CTFontGetXHeight(font) / 2
        }

        // Core Text draws glyphs upward; the canvas space is y-down.
        // Flip locally about the baseline so text lands like paths do.
        context.saveGState()
        context.translateBy(x: penX, y: baselineY)
        context.scaleBy(x: 1, y: -1)
        context.textPosition = .zero
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
#endif
