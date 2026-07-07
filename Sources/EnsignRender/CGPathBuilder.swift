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
import EnsignCore

/// Converts the neutral geometry model into Core Graphics types.
public enum CGPathBuilder {

    /// Builds a CGPath from path segments. Multiple `.move` segments
    /// produce subpaths, which is how the activity corner brackets are
    /// expressed.
    public static func path(from segments: [PathSegment]) -> CGPath {
        let path = CGMutablePath()
        for segment in segments {
            switch segment {
            case .move(let to):
                path.move(to: cgPoint(to))
            case .line(let to):
                path.addLine(to: cgPoint(to))
            case .quadCurve(let to, let control):
                path.addQuadCurve(to: cgPoint(to), control: cgPoint(control))
            case .curve(let to, let control1, let control2):
                path.addCurve(to: cgPoint(to), control1: cgPoint(control1), control2: cgPoint(control2))
            case .arc(let center, let radius, let startAngle, let endAngle, let clockwise):
                path.addArc(
                    center: cgPoint(center),
                    radius: CGFloat(radius),
                    startAngle: CGFloat(startAngle),
                    endAngle: CGFloat(endAngle),
                    clockwise: clockwise
                )
            case .close:
                path.closeSubpath()
            }
        }
        return path
    }

    /// Converts a symbol color to a CGColor in the sRGB space.
    public static func color(from color: SymbolColor) -> CGColor {
        CGColor(
            srgbRed: CGFloat(color.red),
            green: CGFloat(color.green),
            blue: CGFloat(color.blue),
            alpha: CGFloat(color.alpha)
        )
    }

    static func cgPoint(_ point: SymbolPoint) -> CGPoint {
        CGPoint(x: point.x, y: point.y)
    }
}
#endif
