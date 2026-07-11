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
// The info field layout is ported row for row from milsymbol's
// symbolfunctions/textfields.js (MIT, Måns Beckman; see NOTICE): five
// end-anchored rows left of the frame, five start-anchored rows right,
// at y = 100 +/- {0.5, 1.5, 2.5} font sizes, plus the three specials
// (quantity top center, headquarters element bottom center, special
// headquarters inside the frame). Field-to-row assignment varies by
// dimension family; joined fields use "/" separators. Canvas growth
// uses the exact string width estimator, which is what keeps the grown
// canvas identical to the reference renderer's.

/// Lays out MIL-STD-2525 info fields around a symbol's frame.
enum InfoFieldLayout {
    static let fontSize: Double = 40
    static let spaceTextIcon: Double = 20

    struct Output {
        var instructions: [DrawInstruction]
        var bounds: FrameBounds
    }

    /// The dimension families with distinct field-to-row assignments.
    private enum Family {
        case air, groundUnit, groundEquipment, sea, subsurface, dismounted
    }

    private static func family(for symbol: MilSymbol) -> Family {
        if case .charlie = symbol.sidc {
            // Letter SIDCs take the ground layout; the unit/equipment
            // split follows the normalized domain.
            return symbol.domain == .landEquipment ? .groundEquipment : .groundUnit
        }
        switch symbol.domain {
        case .air, .space: return .air
        case .seaSurface: return .sea
        case .subsurface: return .subsurface
        case .dismountedIndividual: return .dismounted
        case .landEquipment, .landInstallation: return .groundEquipment
        default: return .groundUnit
        }
    }

    private static func join(_ parts: String?...) -> String {
        parts.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "/")
    }

    /// Lays the fields out against the symbol's frame bounds,
    /// returning the text instructions and the grown canvas bounds.
    static func layout(
        fields: InfoFields,
        symbol: MilSymbol,
        frameBounds bbox: FrameBounds
    ) -> Output {
        var instructions: [DrawInstruction] = []
        let fill: ColorRole = symbol.isFilled ? .iconStroke : .affiliationColor
        var bounds = FrameBounds(x1: bbox.x1, y1: bbox.y1, x2: bbox.x2, y2: bbox.y2)
        let family = family(for: symbol)

        // Specials.
        if let special = fields.specialHeadquarters, !special.isEmpty {
            let size: Double = special.count >= 4 ? 33 : (special.count == 3 ? 39 : 45)
            instructions.append(.text(TextInstruction(
                text: special, x: 100, y: 103, anchor: .middle, baseline: .middle,
                fontSize: size, isBold: true, fill: fill)))
        }
        if let quantity = fields.quantity, !quantity.isEmpty, family != .dismounted {
            instructions.append(.text(TextInstruction(
                text: quantity, x: 100, y: bbox.y1 - 10, anchor: .middle,
                fontSize: fontSize, fill: fill)))
            bounds.y1 = bbox.y1 - 10 - fontSize
        }
        if family == .dismounted, let quantity = fields.quantity, !quantity.isEmpty {
            instructions.append(.text(TextInstruction(
                text: quantity, x: 100, y: bbox.y2 + fontSize, anchor: .middle,
                fontSize: fontSize, fill: fill)))
            bounds.y2 = bbox.y2 + fontSize
        }
        if let hq = fields.headquartersElement, !hq.isEmpty {
            instructions.append(.text(TextInstruction(
                text: hq, x: 100, y: bbox.y2 + 35, anchor: .middle,
                fontSize: 35, isBold: true, fill: fill)))
            bounds.y2 = max(bounds.y2, bbox.y2 + 35)
        }

        // Row assembly per family, ported branch for branch.
        var left = [String](repeating: "", count: 5)
        var right = [String](repeating: "", count: 5)
        switch family {
        case .air:
            right[0] = fields.uniqueDesignation ?? ""
            right[1] = fields.iffSif ?? ""
            right[2] = fields.type ?? ""
            right[3] = join(fields.speed, fields.altitudeDepth)
            right[4] = join(fields.staffComments, fields.additionalInformation)
        case .groundUnit, .groundEquipment:
            left[0] = fields.dtg ?? ""
            left[1] = join(fields.altitudeDepth, fields.location)
            left[3] = fields.uniqueDesignation ?? ""
            left[4] = fields.speed ?? ""
            right[1] = fields.staffComments ?? ""
            right[3] = fields.higherFormation ?? ""
            right[4] = join(fields.evaluationRating, fields.combatEffectiveness,
                            fields.signatureEquipment, fields.hostile, fields.iffSif)
            if family == .groundUnit {
                left[2] = join(fields.type, fields.platformType,
                               fields.equipmentTeardownTime)
                right[0] = fields.reinforcedReduced ?? ""
                if symbol.frame.hasActivityModifier {
                    right[0] = fields.country ?? ""
                }
                right[2] = join(fields.additionalInformation, fields.commonIdentifier)
            } else {
                left[2] = join(fields.type, fields.platformType,
                               fields.commonIdentifier, fields.installationComposition)
                right[0] = fields.country ?? ""
                right[2] = join(fields.additionalInformation, fields.equipmentTeardownTime)
            }
        case .dismounted:
            left[0] = fields.dtg ?? ""
            left[1] = join(fields.altitudeDepth, fields.location)
            left[2] = join(fields.type, fields.platformType, fields.commonIdentifier)
            left[3] = fields.uniqueDesignation ?? ""
            left[4] = fields.speed ?? ""
            right[0] = fields.country ?? ""
            right[1] = fields.staffComments ?? ""
            right[2] = fields.additionalInformation ?? ""
            right[3] = fields.higherFormation ?? ""
            right[4] = join(fields.evaluationRating, fields.combatEffectiveness,
                            fields.signatureEquipment, fields.hostile, fields.iffSif)
        case .sea:
            left[0] = join(fields.guardedUnit, fields.specialDesignator)
            right[0] = fields.uniqueDesignation ?? ""
            right[1] = fields.type ?? ""
            right[2] = fields.iffSif ?? ""
            right[3] = join(fields.staffComments, fields.additionalInformation)
            right[4] = join(fields.location, fields.speed)
        case .subsurface:
            left[0] = fields.specialDesignator ?? ""
            right[0] = fields.uniqueDesignation ?? ""
            right[1] = fields.type ?? ""
            right[2] = fields.altitudeDepth ?? ""
            right[3] = fields.staffComments ?? ""
            right[4] = fields.additionalInformation ?? ""
        }

        // Canvas growth: exact width estimates, plus the centered
        // specials when they outgrow the frame.
        func centeredOverflow(_ text: String?) -> Double {
            guard let text, !text.isEmpty else { return 0 }
            return (StringWidth.estimate(text, fontSize: fontSize,
                                         spaceTextIcon: spaceTextIcon)
                    - (bbox.x2 - bbox.x1)) / 2
        }
        bounds.x1 = bbox.x1 - [
            centeredOverflow(fields.specialHeadquarters),
            centeredOverflow(fields.quantity),
            StringWidth.estimate(left[0], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(left[1], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(left[2], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(left[3], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(left[4], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
        ].max()!
        bounds.x2 = bbox.x2 + [
            centeredOverflow(fields.specialHeadquarters),
            centeredOverflow(fields.quantity),
            StringWidth.estimate(right[0], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(right[1], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(right[2], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(right[3], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
            StringWidth.estimate(right[4], fontSize: fontSize, spaceTextIcon: spaceTextIcon),
        ].max()!
        if !left[0].isEmpty || !right[0].isEmpty {
            bounds.y1 = min(bounds.y1, 100 - 2.5 * fontSize)
        }
        if !left[1].isEmpty || !right[1].isEmpty {
            bounds.y1 = min(bounds.y1, 100 - 1.5 * fontSize)
        }
        if !left[3].isEmpty || !right[3].isEmpty {
            bounds.y2 = max(bounds.y2, 100 + 1.7 * fontSize)
        }
        if !left[4].isEmpty || !right[4].isEmpty {
            bounds.y2 = max(bounds.y2, 100 + 2.7 * fontSize)
        }

        // Row emission: rows 1-5 at y = 100 + (row - 2.5) font sizes.
        for (index, text) in left.enumerated() where !text.isEmpty {
            instructions.append(.text(TextInstruction(
                text: text, x: bbox.x1 - spaceTextIcon,
                y: 100 + (Double(index) - 1.5) * fontSize,
                anchor: .end, fontSize: fontSize, fill: fill)))
        }
        for (index, text) in right.enumerated() where !text.isEmpty {
            instructions.append(.text(TextInstruction(
                text: text, x: bbox.x2 + spaceTextIcon,
                y: 100 + (Double(index) - 1.5) * fontSize,
                anchor: .start, fontSize: fontSize, fill: fill)))
        }

        return Output(instructions: instructions, bounds: bounds)
    }
}
