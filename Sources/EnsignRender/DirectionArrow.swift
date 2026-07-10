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

/// The direction of movement indicator as a standalone, rotatable map
/// asset.
///
/// Per MIL-STD-2525, frames do not rotate: course belongs to the
/// direction of movement arrow, not the symbol. The intended map
/// pattern is one registered arrow image on its own layer, rotated by
/// the track's course about its center (which is the symbol anchor),
/// while the symbol layer stays unrotated:
///
/// ```swift
/// if let arrow = DirectionArrow.image(size: 80) {
///     style.setImage(UIImage(cgImage: arrow, scale: 2, orientation: .up),
///                    forName: DirectionArrow.imageName)
/// }
/// // arrow layer: iconImageName = DirectionArrow.imageName,
/// //              iconRotation bound to the course property,
/// //              iconRotationAlignment = .map
/// ```
public enum DirectionArrow {
    /// A suggested registry name for the arrow image, so independent
    /// components agree without coordination.
    public static let imageName = "ensign-direction-arrow"

    /// The image size multiplier for pairing this arrow with tight-fit
    /// symbol sprites at the same layer scale. The arrow renders
    /// full-canvas (its rotation anchor must be the image center), so
    /// its 87-unit reach spans 0.435 of its image; tight-fit symbols
    /// fill theirs. milsymbol's proportion puts the arrow tip 0.87
    /// frame heights beyond center, and 0.87 / 0.435 = 2: render the
    /// arrow at twice the symbol sprite size and the standard's
    /// proportions hold on screen.
    public static let sizeMultiplierForTightFitSymbols = 2

    /// The arrow rendered full-canvas into a square: the rotation
    /// anchor is the image center. Renders in the palette's icon color.
    public static func image(
        palette: SymbolPalette = .light,
        size: Int
    ) -> CGImage? {
        SymbolRenderer(palette: palette).image(
            geometry: ModifierGeometry.directionOfMovementArrow(),
            fillClass: .friend,
            size: size,
            fit: .fullCanvas
        )
    }
}
#endif
