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

extension SymbolGeometry {
    /// The axis-aligned extent of everything this geometry draws, in
    /// canvas coordinates, including stroke widths, or `nil` for empty
    /// geometry.
    ///
    /// Curve extents use the control-point hull, which always contains
    /// the curve; the result is therefore never too small and at most
    /// a few canvas units generous, which is exactly right for fitting
    /// sprites into cells.
    public var extent: FrameBounds? {
        var minX = Double.infinity
        var minY = Double.infinity
        var maxX = -Double.infinity
        var maxY = -Double.infinity
        var any = false

        func cover(_ point: SymbolPoint, margin: Double) {
            any = true
            minX = min(minX, point.x - margin)
            minY = min(minY, point.y - margin)
            maxX = max(maxX, point.x + margin)
            maxY = max(maxY, point.y + margin)
        }

        for instruction in instructions {
            switch instruction {
            case .path(let path):
                let margin = path.style.stroke == ColorRole.none
                    ? 0
                    : path.style.strokeWidth / 2
                for segment in path.segments {
                    switch segment {
                    case .move(let to), .line(let to):
                        cover(to, margin: margin)
                    case .quadCurve(let to, let control):
                        cover(to, margin: margin)
                        cover(control, margin: margin)
                    case .curve(let to, let control1, let control2):
                        cover(to, margin: margin)
                        cover(control1, margin: margin)
                        cover(control2, margin: margin)
                    case .arc(let center, let radius, _, _, _):
                        cover(center, margin: radius + margin)
                    case .close:
                        break
                    }
                }
            case .circle(let center, let radius, let style):
                let margin = style.stroke == ColorRole.none
                    ? 0
                    : style.strokeWidth / 2
                cover(center, margin: radius + margin)
            }
        }

        guard any else { return nil }
        return FrameBounds(x1: minX, y1: minY, x2: maxX, y2: maxY)
    }
}
