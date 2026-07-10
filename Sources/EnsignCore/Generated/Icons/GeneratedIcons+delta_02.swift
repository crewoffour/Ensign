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
// draw instructions. Icon geometry data is ported from milsymbol
// (https://github.com/spatialillusions/milsymbol),
// Copyright (c) Mans Beckman, MIT License. See NOTICE.

extension IconLibrary {
    /// 1 icons.
    static func registerGenerated_delta_02(into table: inout [IconKey: IconEntry]) {
        table[IconKey(family: .delta, code: "02110000")] = .perBase([.friend: icon_delta_02110000_friend(), .hostile: icon_delta_02110000_hostile(), .neutral: icon_delta_02110000_neutral(), .unknown: icon_delta_02110000_unknown()])
    }

    // 10030200001100000000
    private static func icon_delta_02110000_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(87, 135)),
            .line(to: SymbolPoint(87, 124)),
            .line(to: SymbolPoint(93, 119)),
            .line(to: SymbolPoint(93, 65)),
            .line(to: SymbolPoint(100, 55)),
            .line(to: SymbolPoint(107, 65)),
            .line(to: SymbolPoint(107, 119)),
            .line(to: SymbolPoint(113, 124)),
            .line(to: SymbolPoint(113, 135)),
            .line(to: SymbolPoint(100, 125)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 255, 128)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10060200001100000000
    private static func icon_delta_02110000_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(87, 135)),
            .line(to: SymbolPoint(87, 124)),
            .line(to: SymbolPoint(93, 119)),
            .line(to: SymbolPoint(93, 65)),
            .line(to: SymbolPoint(100, 55)),
            .line(to: SymbolPoint(107, 65)),
            .line(to: SymbolPoint(107, 119)),
            .line(to: SymbolPoint(113, 124)),
            .line(to: SymbolPoint(113, 135)),
            .line(to: SymbolPoint(100, 125)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 255, 128)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10040200001100000000
    private static func icon_delta_02110000_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(87, 135)),
            .line(to: SymbolPoint(87, 124)),
            .line(to: SymbolPoint(93, 119)),
            .line(to: SymbolPoint(93, 65)),
            .line(to: SymbolPoint(100, 55)),
            .line(to: SymbolPoint(107, 65)),
            .line(to: SymbolPoint(107, 119)),
            .line(to: SymbolPoint(113, 124)),
            .line(to: SymbolPoint(113, 135)),
            .line(to: SymbolPoint(100, 125)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 255, 128)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 10010200001100000000
    private static func icon_delta_02110000_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(87, 135)),
            .line(to: SymbolPoint(87, 124)),
            .line(to: SymbolPoint(93, 119)),
            .line(to: SymbolPoint(93, 65)),
            .line(to: SymbolPoint(100, 55)),
            .line(to: SymbolPoint(107, 65)),
            .line(to: SymbolPoint(107, 119)),
            .line(to: SymbolPoint(113, 124)),
            .line(to: SymbolPoint(113, 135)),
            .line(to: SymbolPoint(100, 125)),
            .close,
        ], style: DrawStyle(fill: .affiliationFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }
}
