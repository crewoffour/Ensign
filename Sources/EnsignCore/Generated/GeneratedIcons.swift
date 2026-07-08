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
// GENERATED FILE - do not edit by hand.
// Produced by tools/extract/codegen.js from milsymbol 3.0.4
// draw instructions (6 icons). Icon geometry data is ported
// from milsymbol (https://github.com/spatialillusions/milsymbol),
// Copyright (c) Mans Beckman, MIT License. See NOTICE.

extension IconLibrary {
    /// The generated icon table.
    static let generatedIcons: [IconKey: IconEntry] = {
        var table: [IconKey: IconEntry] = [:]
        table.reserveCapacity(6)
        table[IconKey(family: .delta, code: "01110104")] = .universal(icon_delta_01110104())
        table[IconKey(family: .delta, code: "10121100")] = .perBase([.friend: icon_delta_10121100_friend(), .hostile: icon_delta_10121100_hostile(), .neutral: icon_delta_10121100_neutral(), .unknown: icon_delta_10121100_unknown()])
        table[IconKey(family: .delta, code: "30120100")] = .universal(icon_delta_30120100())
        table[IconKey(family: .delta, code: "30140100")] = .universal(icon_delta_30140100())
        table[IconKey(family: .delta, code: "30140200")] = .universal(icon_delta_30140200())
        table[IconKey(family: .delta, code: "35110100")] = .universal(icon_delta_35110100())
        return table
    }()

    // 10030100001101040000, 10060100001101040000
    private static func icon_delta_01110104() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(112.095947, 88.9375)),
            .line(to: SymbolPoint(95.748291, 88.9375)),
            .line(to: SymbolPoint(95.748291, 98.517578)),
            .line(to: SymbolPoint(111.590576, 98.517578)),
            .line(to: SymbolPoint(111.590576, 103.527344)),
            .line(to: SymbolPoint(95.748291, 103.527344)),
            .line(to: SymbolPoint(95.748291, 114.887207)),
            .line(to: SymbolPoint(89.266357, 114.887207)),
            .line(to: SymbolPoint(89.266357, 83.927734)),
            .line(to: SymbolPoint(112.095947, 83.927734)),
            .line(to: SymbolPoint(112.095947, 88.9375)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 10031000001211000000
    private static func icon_delta_10121100_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(25, 50)),
            .line(to: SymbolPoint(175, 150)),
            .move(to: SymbolPoint(25, 150)),
            .line(to: SymbolPoint(175, 50)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10061000001211000000
    private static func icon_delta_10121100_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 70)),
            .line(to: SymbolPoint(140, 130)),
            .move(to: SymbolPoint(60, 130)),
            .line(to: SymbolPoint(140, 70)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10041000001211000000
    private static func icon_delta_10121100_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(45, 45)),
            .line(to: SymbolPoint(155, 155)),
            .move(to: SymbolPoint(45, 155)),
            .line(to: SymbolPoint(155, 45)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10011000001211000000
    private static func icon_delta_10121100_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(50, 65)),
            .line(to: SymbolPoint(150, 135)),
            .move(to: SymbolPoint(50, 135)),
            .line(to: SymbolPoint(150, 65)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10033000001201000000, 10043000001201000000, 10063000001201000000
    private static func icon_delta_30120100() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(80, 100)),
            .line(to: SymbolPoint(100, 120)),
            .line(to: SymbolPoint(120, 100)),
            .line(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(100, 80)),
            .line(to: SymbolPoint(80, 80)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10033000001401000000
    private static func icon_delta_30140100() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(75, 100)),
            .line(to: SymbolPoint(75, 65)),
            .line(to: SymbolPoint(125, 65)),
            .line(to: SymbolPoint(125, 100)),
            .line(to: SymbolPoint(145, 100)),
            .line(to: SymbolPoint(130, 135)),
            .line(to: SymbolPoint(70, 135)),
            .line(to: SymbolPoint(55, 100)),
            .close,
        ], style: DrawStyle(fill: .contrastFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10033000001402000000
    private static func icon_delta_30140200() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(75, 100)),
            .line(to: SymbolPoint(75, 85)),
            .line(to: SymbolPoint(95, 85)),
            .line(to: SymbolPoint(95, 100)),
            .line(to: SymbolPoint(145, 100)),
            .line(to: SymbolPoint(130, 135)),
            .line(to: SymbolPoint(70, 135)),
            .line(to: SymbolPoint(55, 100)),
            .close,
            .move(to: SymbolPoint(105, 57.4)),
            .line(to: SymbolPoint(105, 100)),
            .move(to: SymbolPoint(135, 65)),
            .line(to: SymbolPoint(105, 100)),
        ], style: DrawStyle(fill: .contrastFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10033500001101000000, 10063500001101000000
    private static func icon_delta_35110100() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(75, 85)),
            .line(to: SymbolPoint(125, 85)),
            .line(to: SymbolPoint(140, 100)),
            .line(to: SymbolPoint(125, 115)),
            .line(to: SymbolPoint(75, 115)),
            .line(to: SymbolPoint(60, 100)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }
}
