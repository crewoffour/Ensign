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
//
// GENERATED FILE, do not edit by hand. Regenerate with:
//   cd tools/extract && node bake-glyphs.js
// Exercise amplifier letter outlines from Liberation Sans Bold at
// fontsize 35, authored relative to the text anchor
// (text-anchor start, alignment-baseline middle). Glyph outlines
// include data derived from the Liberation fonts under the SIL Open
// Font License; see NOTICE.

/// Baked outline geometry for the exercise amplifier letters.
public enum GeneratedExerciseGlyphs {
    /// Outline segments for an amplifier letter, relative to the text
    /// anchor, or `nil` for letters outside the amplifier set.
    public static func segments(for letter: Character) -> [PathSegment]? {
        switch letter {
        case "X": return glyphX
        case "J": return glyphJ
        case "K": return glyphK
        case "S": return glyphS
        default: return nil
        }
    }

    private static let glyphX: [PathSegment] = [
        .move(to: SymbolPoint(23.037109, 9.245605)),
        .line(to: SymbolPoint(17.739258, 9.245605)),
        .line(to: SymbolPoint(11.689453, -0.341797)),
        .line(to: SymbolPoint(5.639648, 9.245605)),
        .line(to: SymbolPoint(0.307617, 9.245605)),
        .line(to: SymbolPoint(8.647461, -3.417969)),
        .line(to: SymbolPoint(1.008301, -14.833984)),
        .line(to: SymbolPoint(6.340332, -14.833984)),
        .line(to: SymbolPoint(11.689453, -6.323242)),
        .line(to: SymbolPoint(17.038574, -14.833984)),
        .line(to: SymbolPoint(22.336426, -14.833984)),
        .line(to: SymbolPoint(15.021973, -3.417969)),
        .line(to: SymbolPoint(23.037109, 9.245605)),
        .close,
    ]

    private static let glyphJ: [PathSegment] = [
        .move(to: SymbolPoint(8.955078, 9.587402)),
        .line(to: SymbolPoint(8.955078, 9.587402)),
        .quadCurve(to: SymbolPoint(3.204346, 7.963867), control: SymbolPoint(5.212402, 9.587402)),
        .quadCurve(to: SymbolPoint(0.529785, 2.717285), control: SymbolPoint(1.196289, 6.340332)),
        .line(to: SymbolPoint(0.529785, 2.717285)),
        .line(to: SymbolPoint(5.537109, 1.982422)),
        .quadCurve(to: SymbolPoint(6.682129, 4.742432), control: SymbolPoint(5.844727, 3.845215)),
        .quadCurve(to: SymbolPoint(8.989258, 5.639648), control: SymbolPoint(7.519531, 5.639648)),
        .line(to: SymbolPoint(8.989258, 5.639648)),
        .quadCurve(to: SymbolPoint(11.270752, 4.631348), control: SymbolPoint(10.493164, 5.639648)),
        .quadCurve(to: SymbolPoint(12.04834, 1.743164), control: SymbolPoint(12.04834, 3.623047)),
        .line(to: SymbolPoint(12.04834, 1.743164)),
        .line(to: SymbolPoint(12.04834, -10.88623)),
        .line(to: SymbolPoint(7.246094, -10.88623)),
        .line(to: SymbolPoint(7.246094, -14.833984)),
        .line(to: SymbolPoint(17.072754, -14.833984)),
        .line(to: SymbolPoint(17.072754, 1.623535)),
        .quadCurve(to: SymbolPoint(14.936523, 7.485352), control: SymbolPoint(17.072754, 5.383301)),
        .quadCurve(to: SymbolPoint(8.955078, 9.587402), control: SymbolPoint(12.800293, 9.587402)),
        .close,
    ]

    private static let glyphK: [PathSegment] = [
        .move(to: SymbolPoint(24.951172, 9.245605)),
        .line(to: SymbolPoint(19.003906, 9.245605)),
        .line(to: SymbolPoint(10.356445, -1.811523)),
        .line(to: SymbolPoint(7.382813, 0.461426)),
        .line(to: SymbolPoint(7.382813, 9.245605)),
        .line(to: SymbolPoint(2.341309, 9.245605)),
        .line(to: SymbolPoint(2.341309, -14.833984)),
        .line(to: SymbolPoint(7.382813, -14.833984)),
        .line(to: SymbolPoint(7.382813, -3.913574)),
        .line(to: SymbolPoint(18.234863, -14.833984)),
        .line(to: SymbolPoint(24.11377, -14.833984)),
        .line(to: SymbolPoint(13.825684, -4.648437)),
        .line(to: SymbolPoint(24.951172, 9.245605)),
        .close,
    ]

    private static let glyphS: [PathSegment] = [
        .move(to: SymbolPoint(21.977539, 2.307129)),
        .line(to: SymbolPoint(21.977539, 2.307129)),
        .quadCurve(to: SymbolPoint(19.354248, 7.716064), control: SymbolPoint(21.977539, 5.844727)),
        .quadCurve(to: SymbolPoint(11.655273, 9.587402), control: SymbolPoint(16.730957, 9.587402)),
        .line(to: SymbolPoint(11.655273, 9.587402)),
        .quadCurve(to: SymbolPoint(4.39209, 7.946777), control: SymbolPoint(7.023926, 9.587402)),
        .quadCurve(to: SymbolPoint(1.008301, 2.973633), control: SymbolPoint(1.760254, 6.306152)),
        .line(to: SymbolPoint(1.008301, 2.973633)),
        .line(to: SymbolPoint(5.878906, 2.17041)),
        .quadCurve(to: SymbolPoint(7.810059, 4.94751), control: SymbolPoint(6.374512, 4.084473)),
        .quadCurve(to: SymbolPoint(11.791992, 5.810547), control: SymbolPoint(9.245605, 5.810547)),
        .line(to: SymbolPoint(11.791992, 5.810547)),
        .quadCurve(to: SymbolPoint(17.072754, 2.597656), control: SymbolPoint(17.072754, 5.810547)),
        .line(to: SymbolPoint(17.072754, 2.597656)),
        .quadCurve(to: SymbolPoint(16.466064, 0.905762), control: SymbolPoint(17.072754, 1.572266)),
        .quadCurve(to: SymbolPoint(14.75708, -0.205078), control: SymbolPoint(15.859375, 0.239258)),
        .quadCurve(to: SymbolPoint(10.527344, -1.281738), control: SymbolPoint(13.654785, -0.649414)),
        .line(to: SymbolPoint(10.527344, -1.281738)),
        .quadCurve(to: SymbolPoint(6.767578, -2.298584), control: SymbolPoint(7.827148, -1.914062)),
        .quadCurve(to: SymbolPoint(4.853516, -3.204346), control: SymbolPoint(5.708008, -2.683105)),
        .quadCurve(to: SymbolPoint(3.400879, -4.460449), control: SymbolPoint(3.999023, -3.725586)),
        .quadCurve(to: SymbolPoint(2.469482, -6.186523), control: SymbolPoint(2.802734, -5.195312)),
        .quadCurve(to: SymbolPoint(2.13623, -8.459473), control: SymbolPoint(2.13623, -7.177734)),
        .line(to: SymbolPoint(2.13623, -8.459473)),
        .quadCurve(to: SymbolPoint(4.588623, -13.458252), control: SymbolPoint(2.13623, -11.723633)),
        .quadCurve(to: SymbolPoint(11.723633, -15.192871), control: SymbolPoint(7.041016, -15.192871)),
        .line(to: SymbolPoint(11.723633, -15.192871)),
        .quadCurve(to: SymbolPoint(18.448486, -13.791504), control: SymbolPoint(16.201172, -15.192871)),
        .quadCurve(to: SymbolPoint(21.345215, -9.160156), control: SymbolPoint(20.695801, -12.390137)),
        .line(to: SymbolPoint(21.345215, -9.160156)),
        .line(to: SymbolPoint(16.45752, -8.493652)),
        .quadCurve(to: SymbolPoint(14.927979, -10.834961), control: SymbolPoint(16.081543, -10.048828)),
        .quadCurve(to: SymbolPoint(11.621094, -11.621094), control: SymbolPoint(13.774414, -11.621094)),
        .line(to: SymbolPoint(11.621094, -11.621094)),
        .quadCurve(to: SymbolPoint(7.041016, -8.75), control: SymbolPoint(7.041016, -11.621094)),
        .line(to: SymbolPoint(7.041016, -8.75)),
        .quadCurve(to: SymbolPoint(7.528076, -7.211914), control: SymbolPoint(7.041016, -7.810059)),
        .quadCurve(to: SymbolPoint(8.972168, -6.195068), control: SymbolPoint(8.015137, -6.61377)),
        .quadCurve(to: SymbolPoint(12.851563, -5.144043), control: SymbolPoint(9.929199, -5.776367)),
        .line(to: SymbolPoint(12.851563, -5.144043)),
        .quadCurve(to: SymbolPoint(17.816162, -3.7854), control: SymbolPoint(16.320801, -4.40918)),
        .quadCurve(to: SymbolPoint(20.183105, -2.332764), control: SymbolPoint(19.311523, -3.161621)),
        .quadCurve(to: SymbolPoint(21.516113, -0.350342), control: SymbolPoint(21.054688, -1.503906)),
        .quadCurve(to: SymbolPoint(21.977539, 2.307129), control: SymbolPoint(21.977539, 0.803223)),
        .close,
    ]
}
