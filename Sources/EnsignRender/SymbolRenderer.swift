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
import ImageIO
import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
import EnsignCore

/// How a symbol is placed within a square render.
public enum SpriteFit: Sendable {
    /// The full 200x200 canvas maps to the square: symbols keep their
    /// authored margins and every symbol shares a common scale. The
    /// anchor is always the canvas center.
    case fullCanvas
    /// The symbol's drawn extent is scaled (aspect-preserved) to fill
    /// the square and centered: maximum visual size per cell, the
    /// right choice for map sprite sheets.
    case tight
}

/// Renders composed symbol geometry with Core Graphics.
///
/// ```swift
/// let renderer = SymbolRenderer()                 // .light palette
/// let symbol = try MilSymbol("10033000001201000000")
/// let image = renderer.image(for: symbol, size: 128)
/// ```
public struct SymbolRenderer: Sendable {
    /// The palette resolving semantic color roles. Swap in `.medium`,
    /// `.dark`, or a custom palette without touching geometry.
    public var palette: SymbolPalette

    public init(palette: SymbolPalette = .light) {
        self.palette = palette
    }

    // MARK: - Images

    /// Renders a symbol into a square bitmap of the given pixel size.
    /// Returns `nil` for unframeable symbols (empty geometry) or an
    /// invalid size.
    public func image(for symbol: MilSymbol, size: Int, fit: SpriteFit = .fullCanvas) -> CGImage? {
        let geometry = SymbolComposer.geometry(for: symbol)
        guard !geometry.instructions.isEmpty else { return nil }
        return image(geometry: geometry, fillClass: symbol.fillClass, size: size, fit: fit)
    }

    /// Renders arbitrary geometry into a square bitmap.
    public func image(
        geometry: SymbolGeometry,
        fillClass: FillClass,
        size: Int,
        fit: SpriteFit = .fullCanvas
    ) -> CGImage? {
        guard size > 0 else { return nil }
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: size,
                height: size,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }

        // Flip to the top-left origin the geometry is authored in.
        context.translateBy(x: 0, y: CGFloat(size))
        context.scaleBy(x: 1, y: -1)

        draw(geometry, fillClass: fillClass, in: context, pixelSize: CGFloat(size), fit: fit)
        return context.makeImage()
    }

    /// Draws geometry into a context whose current transform maps a
    /// top-left-origin square of `pixelSize` points, honoring the fit:
    /// full canvas keeps the authored margins; tight scales the drawn
    /// extent to fill the square, aspect-preserved and centered (the
    /// choice for tall amplified symbols that overflow the authored
    /// canvas).
    public func draw(
        _ geometry: SymbolGeometry,
        fillClass: FillClass,
        in context: CGContext,
        pixelSize: CGFloat,
        fit: SpriteFit
    ) {
        switch fit {
        case .fullCanvas:
            draw(geometry, fillClass: fillClass, in: context, pixelSize: pixelSize)
        case .tight:
            guard let extent = geometry.extent else { return }
            let width = extent.x2 - extent.x1
            let height = extent.y2 - extent.y1
            guard width > 0 || height > 0 else { return }
            let scale = pixelSize / CGFloat(max(width, height))
            let offsetX = (pixelSize - CGFloat(width) * scale) / 2
            let offsetY = (pixelSize - CGFloat(height) * scale) / 2
            context.saveGState()
            context.translateBy(
                x: offsetX - CGFloat(extent.x1) * scale,
                y: offsetY - CGFloat(extent.y1) * scale
            )
            context.scaleBy(x: scale, y: scale)
            drawInstructions(geometry, fillClass: fillClass, in: context)
            context.restoreGState()
        }
    }

    /// Encodes a rendered symbol as PNG data. Convenience for tooling,
    /// snapshot tests, and the catalog.
    public func pngData(for symbol: MilSymbol, size: Int) -> Data? {
        guard let image = image(for: symbol, size: size) else { return nil }
        return Self.pngData(from: image)
    }

    /// Encodes any CGImage as PNG data.
    public static func pngData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        #if canImport(UniformTypeIdentifiers)
        let type = UTType.png.identifier as CFString
        #else
        let type = "public.png" as CFString
        #endif
        guard let destination = CGImageDestinationCreateWithData(data, type, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    // MARK: - Context drawing

    /// Draws geometry into a context whose current transform maps the
    /// top-left-origin canvas into a square of `pixelSize` points.
    public func draw(
        _ geometry: SymbolGeometry,
        fillClass: FillClass,
        in context: CGContext,
        pixelSize: CGFloat
    ) {
        guard geometry.canvasSize > 0 else { return }
        let scale = pixelSize / CGFloat(geometry.canvasSize)

        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        drawInstructions(geometry, fillClass: fillClass, in: context)
        context.restoreGState()
    }

    /// Paints the instructions in canvas coordinates using the
    /// context's current transform.
    func drawInstructions(
        _ geometry: SymbolGeometry,
        fillClass: FillClass,
        in context: CGContext
    ) {
        context.setLineCap(.butt)
        context.setLineJoin(.miter)

        for instruction in geometry.instructions {
            switch instruction {
            case .path(let symbolPath):
                let path = CGPathBuilder.path(from: symbolPath.segments)
                paint(path, style: symbolPath.style, fillClass: fillClass, in: context)
            case .circle(let center, let radius, let style):
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                let path = CGPath(ellipseIn: rect, transform: nil)
                paint(path, style: style, fillClass: fillClass, in: context)
            }
        }
    }

    private func paint(
        _ path: CGPath,
        style: DrawStyle,
        fillClass: FillClass,
        in context: CGContext
    ) {
        if style.fill != .none {
            let fill = palette.color(for: style.fill, fillClass: fillClass)
            context.addPath(path)
            context.setFillColor(CGPathBuilder.color(from: fill))
            context.fillPath()
        }
        if style.stroke != .none && style.strokeWidth > 0 {
            let stroke = palette.color(for: style.stroke, fillClass: fillClass)
            context.addPath(path)
            context.setStrokeColor(CGPathBuilder.color(from: stroke))
            context.setLineWidth(CGFloat(style.strokeWidth))
            if let dash = style.dash {
                context.setLineDash(phase: 0, lengths: dash.map { CGFloat($0) })
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            context.strokePath()
        }
    }
}
#endif
