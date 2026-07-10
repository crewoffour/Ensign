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
// draw instructions (23 icons). Icon geometry data is ported
// from milsymbol (https://github.com/spatialillusions/milsymbol),
// Copyright (c) Mans Beckman, MIT License. See NOTICE.

extension IconLibrary {
    /// The generated icon table.
    static let generatedIcons: [IconKey: IconEntry] = {
        var table: [IconKey: IconEntry] = [:]
        table.reserveCapacity(23)
        table[IconKey(family: .delta, code: "01110100")] = .universal(icon_delta_01110100())
        table[IconKey(family: .delta, code: "01110200")] = .universal(icon_delta_01110200())
        table[IconKey(family: .delta, code: "01110300")] = .universal(icon_delta_01110300())
        table[IconKey(family: .delta, code: "10120500")] = .universal(icon_delta_10120500())
        table[IconKey(family: .delta, code: "10121100")] = .perBase([.friend: icon_delta_10121100_friend(), .hostile: icon_delta_10121100_hostile(), .neutral: icon_delta_10121100_neutral(), .unknown: icon_delta_10121100_unknown()])
        table[IconKey(family: .delta, code: "10121300")] = .perBase([.friend: icon_delta_10121300_friend(), .hostile: icon_delta_10121300_hostile(), .neutral: icon_delta_10121300_neutral(), .unknown: icon_delta_10121300_unknown()])
        table[IconKey(family: .delta, code: "10140700")] = .universal(icon_delta_10140700())
        table[IconKey(family: .delta, code: "10141800")] = .universal(icon_delta_10141800())
        table[IconKey(family: .delta, code: "10141801")] = .universal(icon_delta_10141801())
        table[IconKey(family: .delta, code: "10160000")] = .universal(icon_delta_10160000())
        table[IconKey(family: .delta, code: "10161300")] = .perBase([.friend: icon_delta_10161300_friend(), .hostile: icon_delta_10161300_hostile(), .neutral: icon_delta_10161300_neutral(), .unknown: icon_delta_10161300_unknown()])
        table[IconKey(family: .delta, code: "20110600")] = .universal(icon_delta_20110600())
        table[IconKey(family: .delta, code: "25130300")] = .universal(icon_delta_25130300())
        table[IconKey(family: .delta, code: "25160100")] = .universal(icon_delta_25160100())
        table[IconKey(family: .delta, code: "30120000")] = .universal(icon_delta_30120000())
        table[IconKey(family: .delta, code: "30140100")] = .universal(icon_delta_30140100())
        table[IconKey(family: .delta, code: "30140200")] = .universal(icon_delta_30140200())
        table[IconKey(family: .delta, code: "30150000")] = .universal(icon_delta_30150000())
        table[IconKey(family: .delta, code: "30160000")] = .universal(icon_delta_30160000())
        table[IconKey(family: .delta, code: "35110100")] = .universal(icon_delta_35110100())
        table[IconKey(family: .delta, code: "35140000")] = .universal(icon_delta_35140000())
        table[IconKey(family: .delta, code: "35150000")] = .universal(icon_delta_35150000())
        table[IconKey(family: .delta, code: "36110100")] = .perBase([.friend: icon_delta_36110100_friend(), .hostile: icon_delta_36110100_hostile(), .neutral: icon_delta_36110100_neutral(), .unknown: icon_delta_36110100_unknown()])
        return table
    }()

    // 130301000011010000000000000000, 130601000011010000000000000000, 130401000011010000000000000000, 130101000011010000000000000000
    private static func icon_delta_01110100() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(99.4, 80.8)),
            .curve(to: SymbolPoint(98.1, 83.4), control1: SymbolPoint(97.9, 81.1), control2: SymbolPoint(98.1, 83.4)),
            .line(to: SymbolPoint(98, 90.7)),
            .line(to: SymbolPoint(78.6, 107.4)),
            .line(to: SymbolPoint(79.3, 109.4)),
            .line(to: SymbolPoint(98.1, 98.3)),
            .line(to: SymbolPoint(98.3, 112.9)),
            .line(to: SymbolPoint(93.9, 116.6)),
            .line(to: SymbolPoint(93.9, 118.7)),
            .line(to: SymbolPoint(98.8, 116.8)),
            .curve(to: SymbolPoint(99.7, 117.5), control1: SymbolPoint(99.1, 117), control2: SymbolPoint(99.7, 117.5)),
            .curve(to: SymbolPoint(100.7, 116.8), control1: SymbolPoint(99.7, 117.5), control2: SymbolPoint(100.4, 117)),
            .line(to: SymbolPoint(105.6, 118.7)),
            .line(to: SymbolPoint(105.6, 116.6)),
            .line(to: SymbolPoint(101.1, 112.9)),
            .line(to: SymbolPoint(101.3, 98.3)),
            .line(to: SymbolPoint(120.2, 109.4)),
            .line(to: SymbolPoint(120.9, 107.4)),
            .line(to: SymbolPoint(101.5, 90.7)),
            .line(to: SymbolPoint(101.3, 83.4)),
            .curve(to: SymbolPoint(100, 80.8), control1: SymbolPoint(101.3, 83.4), control2: SymbolPoint(101.6, 81.1)),
            .curve(to: SymbolPoint(99.4, 80.8), control1: SymbolPoint(99.8, 80.8), control2: SymbolPoint(99.6, 80.8)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130301000011020000000000000000, 130601000011020000000000000000
    private static func icon_delta_01110200() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 85)),
            .line(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(140, 85)),
            .line(to: SymbolPoint(140, 115)),
            .line(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(60, 115)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130301000011030000000000000000, 130601000011030000000000000000
    private static func icon_delta_01110300() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 84)),
            .line(to: SymbolPoint(100, 104)),
            .line(to: SymbolPoint(140, 84)),
            .line(to: SymbolPoint(140, 92)),
            .line(to: SymbolPoint(100, 117)),
            .line(to: SymbolPoint(60, 92)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130310000012050000000000000000, 130610000012050000000000000000, 130410000012050000000000000000, 130110000012050000000000000000
    private static func icon_delta_10120500() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(125, 80)),
            .curve(to: SymbolPoint(125, 120), control1: SymbolPoint(150, 80), control2: SymbolPoint(150, 120)),
            .line(to: SymbolPoint(75, 120)),
            .curve(to: SymbolPoint(75, 80), control1: SymbolPoint(50, 120), control2: SymbolPoint(50, 80)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130310000012110000000000000000
    private static func icon_delta_10121100_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(25, 50)),
            .line(to: SymbolPoint(175, 150)),
            .move(to: SymbolPoint(25, 150)),
            .line(to: SymbolPoint(175, 50)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130610000012110000000000000000
    private static func icon_delta_10121100_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 70)),
            .line(to: SymbolPoint(140, 130)),
            .move(to: SymbolPoint(60, 130)),
            .line(to: SymbolPoint(140, 70)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130410000012110000000000000000
    private static func icon_delta_10121100_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(45, 45)),
            .line(to: SymbolPoint(155, 155)),
            .move(to: SymbolPoint(45, 155)),
            .line(to: SymbolPoint(155, 45)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130110000012110000000000000000
    private static func icon_delta_10121100_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(50, 65)),
            .line(to: SymbolPoint(150, 135)),
            .move(to: SymbolPoint(50, 135)),
            .line(to: SymbolPoint(150, 65)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130310000012130000000000000000
    private static func icon_delta_10121300_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(25, 150)),
            .line(to: SymbolPoint(175, 50)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130610000012130000000000000000
    private static func icon_delta_10121300_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 130)),
            .line(to: SymbolPoint(140, 70)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130410000012130000000000000000
    private static func icon_delta_10121300_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(45, 155)),
            .line(to: SymbolPoint(155, 45)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130110000012130000000000000000
    private static func icon_delta_10121300_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(50, 135)),
            .line(to: SymbolPoint(150, 65)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130310000014070000000000000000, 130610000014070000000000000000
    private static func icon_delta_10140700() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 118)),
            .line(to: SymbolPoint(60, 83)),
            .line(to: SymbolPoint(140, 83)),
            .line(to: SymbolPoint(140, 118)),
            .move(to: SymbolPoint(100, 83)),
            .line(to: SymbolPoint(100, 110)),
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130410000014180000000000000000
    private static func icon_delta_10141800() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(83.318359, 105.570801)),
            .line(to: SymbolPoint(83.318359, 105.570801)),
            .quadCurve(to: SymbolPoint(80.395264, 111.5979), control: SymbolPoint(83.318359, 109.512695)),
            .quadCurve(to: SymbolPoint(71.816406, 113.683105), control: SymbolPoint(77.472168, 113.683105)),
            .line(to: SymbolPoint(71.816406, 113.683105)),
            .quadCurve(to: SymbolPoint(63.723145, 111.85498), control: SymbolPoint(66.655762, 113.683105)),
            .quadCurve(to: SymbolPoint(59.952637, 106.313477), control: SymbolPoint(60.790527, 110.026855)),
            .line(to: SymbolPoint(59.952637, 106.313477)),
            .line(to: SymbolPoint(65.379883, 105.418457)),
            .quadCurve(to: SymbolPoint(67.531738, 108.512939), control: SymbolPoint(65.932129, 107.55127)),
            .quadCurve(to: SymbolPoint(71.96875, 109.474609), control: SymbolPoint(69.131348, 109.474609)),
            .line(to: SymbolPoint(71.96875, 109.474609)),
            .quadCurve(to: SymbolPoint(77.853027, 105.894531), control: SymbolPoint(77.853027, 109.474609)),
            .line(to: SymbolPoint(77.853027, 105.894531)),
            .quadCurve(to: SymbolPoint(77.177002, 104.009277), control: SymbolPoint(77.853027, 104.751953)),
            .quadCurve(to: SymbolPoint(75.272705, 102.771484), control: SymbolPoint(76.500977, 103.266602)),
            .quadCurve(to: SymbolPoint(70.55957, 101.571777), control: SymbolPoint(74.044434, 102.276367)),
            .line(to: SymbolPoint(70.55957, 101.571777)),
            .quadCurve(to: SymbolPoint(66.370117, 100.438721), control: SymbolPoint(67.550781, 100.867188)),
            .quadCurve(to: SymbolPoint(64.237305, 99.429443), control: SymbolPoint(65.189453, 100.010254)),
            .quadCurve(to: SymbolPoint(62.618652, 98.029785), control: SymbolPoint(63.285156, 98.848633)),
            .quadCurve(to: SymbolPoint(61.580811, 96.106445), control: SymbolPoint(61.952148, 97.210938)),
            .quadCurve(to: SymbolPoint(61.209473, 93.57373), control: SymbolPoint(61.209473, 95.001953)),
            .line(to: SymbolPoint(61.209473, 93.57373)),
            .quadCurve(to: SymbolPoint(63.942139, 88.003662), control: SymbolPoint(61.209473, 89.936523)),
            .quadCurve(to: SymbolPoint(71.892578, 86.070801), control: SymbolPoint(66.674805, 86.070801)),
            .line(to: SymbolPoint(71.892578, 86.070801)),
            .quadCurve(to: SymbolPoint(79.385986, 87.632324), control: SymbolPoint(76.881836, 86.070801)),
            .quadCurve(to: SymbolPoint(82.61377, 92.792969), control: SymbolPoint(81.890137, 89.193848)),
            .line(to: SymbolPoint(82.61377, 92.792969)),
            .line(to: SymbolPoint(77.16748, 93.535645)),
            .quadCurve(to: SymbolPoint(75.463135, 90.926758), control: SymbolPoint(76.748535, 91.802734)),
            .quadCurve(to: SymbolPoint(71.77832, 90.050781), control: SymbolPoint(74.177734, 90.050781)),
            .line(to: SymbolPoint(71.77832, 90.050781)),
            .quadCurve(to: SymbolPoint(66.674805, 93.25), control: SymbolPoint(66.674805, 90.050781)),
            .line(to: SymbolPoint(66.674805, 93.25)),
            .quadCurve(to: SymbolPoint(67.217529, 94.963867), control: SymbolPoint(66.674805, 94.297363)),
            .quadCurve(to: SymbolPoint(68.82666, 96.096924), control: SymbolPoint(67.760254, 95.630371)),
            .quadCurve(to: SymbolPoint(73.149414, 97.268066), control: SymbolPoint(69.893066, 96.563477)),
            .line(to: SymbolPoint(73.149414, 97.268066)),
            .quadCurve(to: SymbolPoint(78.681396, 98.781982), control: SymbolPoint(77.015137, 98.086914)),
            .quadCurve(to: SymbolPoint(81.318848, 100.400635), control: SymbolPoint(80.347656, 99.477051)),
            .quadCurve(to: SymbolPoint(82.804199, 102.609619), control: SymbolPoint(82.290039, 101.324219)),
            .quadCurve(to: SymbolPoint(83.318359, 105.570801), control: SymbolPoint(83.318359, 103.89502)),
            .close,
            .move(to: SymbolPoint(111.978027, 113.302246)),
            .line(to: SymbolPoint(106.41748, 113.302246)),
            .line(to: SymbolPoint(104.037109, 106.446777)),
            .line(to: SymbolPoint(93.811035, 106.446777)),
            .line(to: SymbolPoint(91.430664, 113.302246)),
            .line(to: SymbolPoint(85.812988, 113.302246)),
            .line(to: SymbolPoint(95.601074, 86.470703)),
            .line(to: SymbolPoint(102.228027, 86.470703)),
            .line(to: SymbolPoint(111.978027, 113.302246)),
            .close,
            .move(to: SymbolPoint(99.314453, 91.916992)),
            .line(to: SymbolPoint(98.914551, 90.603027)),
            .line(to: SymbolPoint(98.800293, 91.021973)),
            .quadCurve(to: SymbolPoint(98.343262, 92.583496), control: SymbolPoint(98.609863, 91.70752)),
            .quadCurve(to: SymbolPoint(95.067871, 102.219238), control: SymbolPoint(98.07666, 93.459473)),
            .line(to: SymbolPoint(95.067871, 102.219238)),
            .line(to: SymbolPoint(102.780273, 102.219238)),
            .line(to: SymbolPoint(100.133301, 94.506836)),
            .line(to: SymbolPoint(99.314453, 91.916992)),
            .close,
            .move(to: SymbolPoint(140.371094, 113.302246)),
            .line(to: SymbolPoint(134.048828, 113.302246)),
            .line(to: SymbolPoint(127.821777, 103.114258)),
            .line(to: SymbolPoint(121.23291, 103.114258)),
            .line(to: SymbolPoint(121.23291, 113.302246)),
            .line(to: SymbolPoint(115.615234, 113.302246)),
            .line(to: SymbolPoint(115.615234, 86.470703)),
            .line(to: SymbolPoint(129.021484, 86.470703)),
            .quadCurve(to: SymbolPoint(136.429199, 88.536865), control: SymbolPoint(133.820313, 86.470703)),
            .quadCurve(to: SymbolPoint(139.038086, 94.46875), control: SymbolPoint(139.038086, 90.603027)),
            .line(to: SymbolPoint(139.038086, 94.46875)),
            .quadCurve(to: SymbolPoint(137.438477, 99.334229), control: SymbolPoint(139.038086, 97.287109)),
            .quadCurve(to: SymbolPoint(133.115723, 102.028809), control: SymbolPoint(135.838867, 101.381348)),
            .line(to: SymbolPoint(133.115723, 102.028809)),
            .line(to: SymbolPoint(140.371094, 113.302246)),
            .close,
            .move(to: SymbolPoint(133.382324, 94.697266)),
            .line(to: SymbolPoint(133.382324, 94.697266)),
            .quadCurve(to: SymbolPoint(128.431152, 90.831543), control: SymbolPoint(133.382324, 90.831543)),
            .line(to: SymbolPoint(128.431152, 90.831543)),
            .line(to: SymbolPoint(121.23291, 90.831543)),
            .line(to: SymbolPoint(121.23291, 98.753418)),
            .line(to: SymbolPoint(128.583496, 98.753418)),
            .quadCurve(to: SymbolPoint(132.163574, 97.687012), control: SymbolPoint(130.944824, 98.753418)),
            .quadCurve(to: SymbolPoint(133.382324, 94.697266), control: SymbolPoint(133.382324, 96.620605)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130410000014180100000000000000
    private static func icon_delta_10141801() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(88, 88)),
            .move(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(112, 88)),
            .move(to: SymbolPoint(100, 118)),
            .line(to: SymbolPoint(100, 100)),
            .move(to: SymbolPoint(90.5, 118)),
            .line(to: SymbolPoint(110, 118)),
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(106, 87.2)),
            .curve(to: SymbolPoint(104.23078, 91.401641), control1: SymbolPoint(105.994805, 88.780571), control2: SymbolPoint(105.357771, 90.293434)),
            .curve(to: SymbolPoint(100, 93.1), control1: SymbolPoint(103.10379, 92.509849), control2: SymbolPoint(101.580435, 93.121368)),
            .curve(to: SymbolPoint(94.1, 87.2), control1: SymbolPoint(96.746077, 93.089025), control2: SymbolPoint(94.110975, 90.453923)),
            .curve(to: SymbolPoint(95.798359, 82.96922), control1: SymbolPoint(94.078632, 85.619565), control2: SymbolPoint(94.690151, 84.09621)),
            .curve(to: SymbolPoint(100, 81.2), control1: SymbolPoint(96.906566, 81.842229), control2: SymbolPoint(98.419429, 81.205195)),
            .curve(to: SymbolPoint(104.26662, 82.93338), control1: SymbolPoint(101.597865, 81.178257), control2: SymbolPoint(103.136654, 81.803414)),
            .curve(to: SymbolPoint(106, 87.2), control1: SymbolPoint(105.396586, 84.063346), control2: SymbolPoint(106.021743, 85.602135)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130310000016000000000000000000, 130610000016000000000000000000
    private static func icon_delta_10160000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(76.716309, 105.175293)),
            .line(to: SymbolPoint(76.716309, 105.175293)),
            .quadCurve(to: SymbolPoint(74.24292, 110.275146), control: SymbolPoint(76.716309, 108.510742)),
            .quadCurve(to: SymbolPoint(66.983887, 112.039551), control: SymbolPoint(71.769531, 112.039551)),
            .line(to: SymbolPoint(66.983887, 112.039551)),
            .quadCurve(to: SymbolPoint(60.135742, 110.492676), control: SymbolPoint(62.617188, 112.039551)),
            .quadCurve(to: SymbolPoint(56.945313, 105.803711), control: SymbolPoint(57.654297, 108.945801)),
            .line(to: SymbolPoint(56.945313, 105.803711)),
            .line(to: SymbolPoint(61.537598, 105.046387)),
            .quadCurve(to: SymbolPoint(63.358398, 107.664795), control: SymbolPoint(62.004883, 106.851074)),
            .quadCurve(to: SymbolPoint(67.112793, 108.478516), control: SymbolPoint(64.711914, 108.478516)),
            .line(to: SymbolPoint(67.112793, 108.478516)),
            .quadCurve(to: SymbolPoint(72.091797, 105.449219), control: SymbolPoint(72.091797, 108.478516)),
            .line(to: SymbolPoint(72.091797, 105.449219)),
            .quadCurve(to: SymbolPoint(71.519775, 103.854004), control: SymbolPoint(72.091797, 104.482422)),
            .quadCurve(to: SymbolPoint(69.908447, 102.806641), control: SymbolPoint(70.947754, 103.225586)),
            .quadCurve(to: SymbolPoint(65.92041, 101.791504), control: SymbolPoint(68.869141, 102.387695)),
            .line(to: SymbolPoint(65.92041, 101.791504)),
            .quadCurve(to: SymbolPoint(62.375488, 100.832764), control: SymbolPoint(63.374512, 101.195313)),
            .quadCurve(to: SymbolPoint(60.570801, 99.97876), control: SymbolPoint(61.376465, 100.470215)),
            .quadCurve(to: SymbolPoint(59.201172, 98.794434), control: SymbolPoint(59.765137, 99.487305)),
            .quadCurve(to: SymbolPoint(58.322998, 97.166992), control: SymbolPoint(58.637207, 98.101563)),
            .quadCurve(to: SymbolPoint(58.008789, 95.023926), control: SymbolPoint(58.008789, 96.232422)),
            .line(to: SymbolPoint(58.008789, 95.023926)),
            .quadCurve(to: SymbolPoint(60.321045, 90.310791), control: SymbolPoint(58.008789, 91.946289)),
            .quadCurve(to: SymbolPoint(67.04834, 88.675293), control: SymbolPoint(62.633301, 88.675293)),
            .line(to: SymbolPoint(67.04834, 88.675293)),
            .quadCurve(to: SymbolPoint(73.388916, 89.996582), control: SymbolPoint(71.27002, 88.675293)),
            .quadCurve(to: SymbolPoint(76.120117, 94.363281), control: SymbolPoint(75.507813, 91.317871)),
            .line(to: SymbolPoint(76.120117, 94.363281)),
            .line(to: SymbolPoint(71.511719, 94.991699)),
            .quadCurve(to: SymbolPoint(70.06958, 92.78418), control: SymbolPoint(71.157227, 93.525391)),
            .quadCurve(to: SymbolPoint(66.95166, 92.042969), control: SymbolPoint(68.981934, 92.042969)),
            .line(to: SymbolPoint(66.95166, 92.042969)),
            .quadCurve(to: SymbolPoint(62.633301, 94.75), control: SymbolPoint(62.633301, 92.042969)),
            .line(to: SymbolPoint(62.633301, 94.75)),
            .quadCurve(to: SymbolPoint(63.092529, 96.200195), control: SymbolPoint(62.633301, 95.63623)),
            .quadCurve(to: SymbolPoint(64.454102, 97.158936), control: SymbolPoint(63.551758, 96.76416)),
            .quadCurve(to: SymbolPoint(68.111816, 98.149902), control: SymbolPoint(65.356445, 97.553711)),
            .line(to: SymbolPoint(68.111816, 98.149902)),
            .quadCurve(to: SymbolPoint(72.792725, 99.430908), control: SymbolPoint(71.382813, 98.842773)),
            .quadCurve(to: SymbolPoint(75.024414, 100.800537), control: SymbolPoint(74.202637, 100.019043)),
            .quadCurve(to: SymbolPoint(76.28125, 102.669678), control: SymbolPoint(75.846191, 101.582031)),
            .quadCurve(to: SymbolPoint(76.716309, 105.175293), control: SymbolPoint(76.716309, 103.757324)),
            .close,
            .move(to: SymbolPoint(89.655273, 112.039551)),
            .line(to: SymbolPoint(89.655273, 112.039551)),
            .quadCurve(to: SymbolPoint(82.476807, 109.751465), control: SymbolPoint(84.966309, 112.039551)),
            .quadCurve(to: SymbolPoint(79.987305, 103.209473), control: SymbolPoint(79.987305, 107.463379)),
            .line(to: SymbolPoint(79.987305, 103.209473)),
            .line(to: SymbolPoint(79.987305, 89.013672)),
            .line(to: SymbolPoint(84.740723, 89.013672)),
            .line(to: SymbolPoint(84.740723, 102.838867)),
            .quadCurve(to: SymbolPoint(86.021729, 106.923584), control: SymbolPoint(84.740723, 105.529785)),
            .quadCurve(to: SymbolPoint(89.78418, 108.317383), control: SymbolPoint(87.302734, 108.317383)),
            .line(to: SymbolPoint(89.78418, 108.317383)),
            .quadCurve(to: SymbolPoint(93.699707, 106.859131), control: SymbolPoint(92.330078, 108.317383)),
            .quadCurve(to: SymbolPoint(95.069336, 102.677734), control: SymbolPoint(95.069336, 105.400879)),
            .line(to: SymbolPoint(95.069336, 102.677734)),
            .line(to: SymbolPoint(95.069336, 89.013672)),
            .line(to: SymbolPoint(99.822754, 89.013672)),
            .line(to: SymbolPoint(99.822754, 102.967773)),
            .quadCurve(to: SymbolPoint(97.156006, 109.662842), control: SymbolPoint(99.822754, 107.286133)),
            .quadCurve(to: SymbolPoint(89.655273, 112.039551), control: SymbolPoint(94.489258, 112.039551)),
            .close,
            .move(to: SymbolPoint(122.558594, 105.175293)),
            .line(to: SymbolPoint(122.558594, 105.175293)),
            .quadCurve(to: SymbolPoint(120.085205, 110.275146), control: SymbolPoint(122.558594, 108.510742)),
            .quadCurve(to: SymbolPoint(112.826172, 112.039551), control: SymbolPoint(117.611816, 112.039551)),
            .line(to: SymbolPoint(112.826172, 112.039551)),
            .quadCurve(to: SymbolPoint(105.978027, 110.492676), control: SymbolPoint(108.459473, 112.039551)),
            .quadCurve(to: SymbolPoint(102.787598, 105.803711), control: SymbolPoint(103.496582, 108.945801)),
            .line(to: SymbolPoint(102.787598, 105.803711)),
            .line(to: SymbolPoint(107.379883, 105.046387)),
            .quadCurve(to: SymbolPoint(109.200684, 107.664795), control: SymbolPoint(107.847168, 106.851074)),
            .quadCurve(to: SymbolPoint(112.955078, 108.478516), control: SymbolPoint(110.554199, 108.478516)),
            .line(to: SymbolPoint(112.955078, 108.478516)),
            .quadCurve(to: SymbolPoint(117.934082, 105.449219), control: SymbolPoint(117.934082, 108.478516)),
            .line(to: SymbolPoint(117.934082, 105.449219)),
            .quadCurve(to: SymbolPoint(117.362061, 103.854004), control: SymbolPoint(117.934082, 104.482422)),
            .quadCurve(to: SymbolPoint(115.750732, 102.806641), control: SymbolPoint(116.790039, 103.225586)),
            .quadCurve(to: SymbolPoint(111.762695, 101.791504), control: SymbolPoint(114.711426, 102.387695)),
            .line(to: SymbolPoint(111.762695, 101.791504)),
            .quadCurve(to: SymbolPoint(108.217773, 100.832764), control: SymbolPoint(109.216797, 101.195313)),
            .quadCurve(to: SymbolPoint(106.413086, 99.97876), control: SymbolPoint(107.21875, 100.470215)),
            .quadCurve(to: SymbolPoint(105.043457, 98.794434), control: SymbolPoint(105.607422, 99.487305)),
            .quadCurve(to: SymbolPoint(104.165283, 97.166992), control: SymbolPoint(104.479492, 98.101563)),
            .quadCurve(to: SymbolPoint(103.851074, 95.023926), control: SymbolPoint(103.851074, 96.232422)),
            .line(to: SymbolPoint(103.851074, 95.023926)),
            .quadCurve(to: SymbolPoint(106.16333, 90.310791), control: SymbolPoint(103.851074, 91.946289)),
            .quadCurve(to: SymbolPoint(112.890625, 88.675293), control: SymbolPoint(108.475586, 88.675293)),
            .line(to: SymbolPoint(112.890625, 88.675293)),
            .quadCurve(to: SymbolPoint(119.231201, 89.996582), control: SymbolPoint(117.112305, 88.675293)),
            .quadCurve(to: SymbolPoint(121.962402, 94.363281), control: SymbolPoint(121.350098, 91.317871)),
            .line(to: SymbolPoint(121.962402, 94.363281)),
            .line(to: SymbolPoint(117.354004, 94.991699)),
            .quadCurve(to: SymbolPoint(115.911865, 92.78418), control: SymbolPoint(116.999512, 93.525391)),
            .quadCurve(to: SymbolPoint(112.793945, 92.042969), control: SymbolPoint(114.824219, 92.042969)),
            .line(to: SymbolPoint(112.793945, 92.042969)),
            .quadCurve(to: SymbolPoint(108.475586, 94.75), control: SymbolPoint(108.475586, 92.042969)),
            .line(to: SymbolPoint(108.475586, 94.75)),
            .quadCurve(to: SymbolPoint(108.934814, 96.200195), control: SymbolPoint(108.475586, 95.63623)),
            .quadCurve(to: SymbolPoint(110.296387, 97.158936), control: SymbolPoint(109.394043, 96.76416)),
            .quadCurve(to: SymbolPoint(113.954102, 98.149902), control: SymbolPoint(111.19873, 97.553711)),
            .line(to: SymbolPoint(113.954102, 98.149902)),
            .quadCurve(to: SymbolPoint(118.63501, 99.430908), control: SymbolPoint(117.225098, 98.842773)),
            .quadCurve(to: SymbolPoint(120.866699, 100.800537), control: SymbolPoint(120.044922, 100.019043)),
            .quadCurve(to: SymbolPoint(122.123535, 102.669678), control: SymbolPoint(121.688477, 101.582031)),
            .quadCurve(to: SymbolPoint(122.558594, 105.175293), control: SymbolPoint(122.558594, 103.757324)),
            .close,
            .move(to: SymbolPoint(143.650879, 92.6875)),
            .line(to: SymbolPoint(136.303223, 92.6875)),
            .line(to: SymbolPoint(136.303223, 111.717285)),
            .line(to: SymbolPoint(131.549805, 111.717285)),
            .line(to: SymbolPoint(131.549805, 92.6875)),
            .line(to: SymbolPoint(124.218262, 92.6875)),
            .line(to: SymbolPoint(124.218262, 89.013672)),
            .line(to: SymbolPoint(143.650879, 89.013672)),
            .line(to: SymbolPoint(143.650879, 92.6875)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130310000016130000000000000000
    private static func icon_delta_10161300_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 50)),
            .line(to: SymbolPoint(100, 150)),
            .move(to: SymbolPoint(25, 100)),
            .line(to: SymbolPoint(175, 100)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130610000016130000000000000000
    private static func icon_delta_10161300_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 28)),
            .line(to: SymbolPoint(100, 172)),
            .move(to: SymbolPoint(28, 100)),
            .line(to: SymbolPoint(172, 100)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130410000016130000000000000000
    private static func icon_delta_10161300_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 45)),
            .line(to: SymbolPoint(100, 155)),
            .move(to: SymbolPoint(45, 100)),
            .line(to: SymbolPoint(155, 100)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130110000016130000000000000000
    private static func icon_delta_10161300_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 30.75)),
            .line(to: SymbolPoint(100, 169.25)),
            .move(to: SymbolPoint(30.75, 100)),
            .line(to: SymbolPoint(169.25, 100)),
        ], style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130420000011060000000000000000, 130320000011060000000000000000
    private static func icon_delta_20110600() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(74, 120)),
            .curve(to: SymbolPoint(139, 84), control1: SymbolPoint(74, 105), control2: SymbolPoint(87.2, 87.1)),
            .move(to: SymbolPoint(126, 120)),
            .curve(to: SymbolPoint(61.5, 84), control1: SymbolPoint(126, 105), control2: SymbolPoint(113, 87.1)),
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .circle(center: SymbolPoint(65, 90), radius: 6, style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil)),
        .circle(center: SymbolPoint(135, 90), radius: 6, style: DrawStyle(fill: .iconFill, stroke: .iconStroke, strokeWidth: 3, dash: nil)),
    ] }

    // 130425000013030000000000000000, 130325000013030000000000000000
    private static func icon_delta_25130300() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(60, 45)),
            .line(to: SymbolPoint(140, 45)),
            .move(to: SymbolPoint(100, 100)),
            .line(to: SymbolPoint(60, 45)),
            .line(to: SymbolPoint(60, -60)),
            .line(to: SymbolPoint(140, -60)),
            .line(to: SymbolPoint(140, 45)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(76.638184, -24.377441)),
            .line(to: SymbolPoint(76.638184, -24.377441)),
            .quadCurve(to: SymbolPoint(82.978516, -28.95752), control: SymbolPoint(81.201172, -24.377441)),
            .line(to: SymbolPoint(82.978516, -28.95752)),
            .line(to: SymbolPoint(87.370605, -27.299805)),
            .quadCurve(to: SymbolPoint(83.209229, -22.113037), control: SymbolPoint(85.952148, -23.813477)),
            .quadCurve(to: SymbolPoint(76.638184, -20.412598), control: SymbolPoint(80.466309, -20.412598)),
            .line(to: SymbolPoint(76.638184, -20.412598)),
            .quadCurve(to: SymbolPoint(67.657471, -23.702393), control: SymbolPoint(70.827637, -20.412598)),
            .quadCurve(to: SymbolPoint(64.487305, -32.905273), control: SymbolPoint(64.487305, -26.992188)),
            .line(to: SymbolPoint(64.487305, -32.905273)),
            .quadCurve(to: SymbolPoint(67.546387, -42.01416), control: SymbolPoint(64.487305, -38.835449)),
            .quadCurve(to: SymbolPoint(76.416016, -45.192871), control: SymbolPoint(70.605469, -45.192871)),
            .line(to: SymbolPoint(76.416016, -45.192871)),
            .quadCurve(to: SymbolPoint(83.320313, -43.492432), control: SymbolPoint(80.654297, -45.192871)),
            .quadCurve(to: SymbolPoint(87.062988, -38.493652), control: SymbolPoint(85.986328, -41.791992)),
            .line(to: SymbolPoint(87.062988, -38.493652)),
            .line(to: SymbolPoint(82.619629, -37.280273)),
            .quadCurve(to: SymbolPoint(80.406494, -40.159912), control: SymbolPoint(82.055664, -39.091797)),
            .quadCurve(to: SymbolPoint(76.518555, -41.228027), control: SymbolPoint(78.757324, -41.228027)),
            .line(to: SymbolPoint(76.518555, -41.228027)),
            .quadCurve(to: SymbolPoint(71.331787, -39.108887), control: SymbolPoint(73.100586, -41.228027)),
            .quadCurve(to: SymbolPoint(69.562988, -32.905273), control: SymbolPoint(69.562988, -36.989746)),
            .line(to: SymbolPoint(69.562988, -32.905273)),
            .quadCurve(to: SymbolPoint(71.383057, -26.564941), control: SymbolPoint(69.562988, -28.752441)),
            .quadCurve(to: SymbolPoint(76.638184, -24.377441), control: SymbolPoint(73.203125, -24.377441)),
            .close,
            .move(to: SymbolPoint(113.278809, -20.754395)),
            .line(to: SymbolPoint(107.331543, -20.754395)),
            .line(to: SymbolPoint(98.684082, -31.811523)),
            .line(to: SymbolPoint(95.710449, -29.538574)),
            .line(to: SymbolPoint(95.710449, -20.754395)),
            .line(to: SymbolPoint(90.668945, -20.754395)),
            .line(to: SymbolPoint(90.668945, -44.833984)),
            .line(to: SymbolPoint(95.710449, -44.833984)),
            .line(to: SymbolPoint(95.710449, -33.913574)),
            .line(to: SymbolPoint(106.5625, -44.833984)),
            .line(to: SymbolPoint(112.441406, -44.833984)),
            .line(to: SymbolPoint(102.15332, -34.648438)),
            .line(to: SymbolPoint(113.278809, -20.754395)),
            .close,
            .move(to: SymbolPoint(135.751953, -37.211914)),
            .line(to: SymbolPoint(135.751953, -37.211914)),
            .quadCurve(to: SymbolPoint(134.692383, -33.059082), control: SymbolPoint(135.751953, -34.887695)),
            .quadCurve(to: SymbolPoint(131.658936, -30.230713), control: SymbolPoint(133.632813, -31.230469)),
            .quadCurve(to: SymbolPoint(126.967773, -29.230957), control: SymbolPoint(129.685059, -29.230957)),
            .line(to: SymbolPoint(126.967773, -29.230957)),
            .line(to: SymbolPoint(120.986328, -29.230957)),
            .line(to: SymbolPoint(120.986328, -20.754395)),
            .line(to: SymbolPoint(115.944824, -20.754395)),
            .line(to: SymbolPoint(115.944824, -44.833984)),
            .line(to: SymbolPoint(126.762695, -44.833984)),
            .quadCurve(to: SymbolPoint(133.419189, -42.843018), control: SymbolPoint(131.086426, -44.833984)),
            .quadCurve(to: SymbolPoint(135.751953, -37.211914), control: SymbolPoint(135.751953, -40.852051)),
            .close,
            .move(to: SymbolPoint(130.67627, -37.126465)),
            .line(to: SymbolPoint(130.67627, -37.126465)),
            .quadCurve(to: SymbolPoint(126.19873, -40.92041), control: SymbolPoint(130.67627, -40.92041)),
            .line(to: SymbolPoint(126.19873, -40.92041)),
            .line(to: SymbolPoint(120.986328, -40.92041)),
            .line(to: SymbolPoint(120.986328, -33.110352)),
            .line(to: SymbolPoint(126.335449, -33.110352)),
            .quadCurve(to: SymbolPoint(129.54834, -34.144287), control: SymbolPoint(128.42041, -33.110352)),
            .quadCurve(to: SymbolPoint(130.67627, -37.126465), control: SymbolPoint(130.67627, -35.178223)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130425000016010000000000000000, 130325000016010000000000000000
    private static func icon_delta_25160100() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(100, 45)),
            .line(to: SymbolPoint(147.6, 127.5)),
            .line(to: SymbolPoint(52.4, 127.5)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130330000012000000000000000000, 130230000012000000000000000000, 130630000012000000000000000000
    private static func icon_delta_30120000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(86.9, 110)),
            .curve(to: SymbolPoint(76.1, 115.9), control1: SymbolPoint(83.3, 112), control2: SymbolPoint(79.7, 113.9)),
            .curve(to: SymbolPoint(86.1, 118), control1: SymbolPoint(78.2, 118.8), control2: SymbolPoint(82.8, 119.8)),
            .curve(to: SymbolPoint(89.2, 111.9), control1: SymbolPoint(88.7, 117.1), control2: SymbolPoint(90.8, 114.2)),
            .curve(to: SymbolPoint(86.9, 110), control1: SymbolPoint(88.4, 111.3), control2: SymbolPoint(87.7, 110.6)),
            .close,
            .move(to: SymbolPoint(113.2, 110.1)),
            .curve(to: SymbolPoint(124, 116), control1: SymbolPoint(116.8, 112.1), control2: SymbolPoint(120.4, 114)),
            .curve(to: SymbolPoint(114, 118.1), control1: SymbolPoint(121.9, 118.9), control2: SymbolPoint(117.3, 119.9)),
            .curve(to: SymbolPoint(110.9, 112), control1: SymbolPoint(111.4, 117.2), control2: SymbolPoint(109.3, 114.3)),
            .curve(to: SymbolPoint(113.2, 110.1), control1: SymbolPoint(111.7, 111.4), control2: SymbolPoint(112.4, 110.7)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(112.9, 110)),
            .curve(to: SymbolPoint(96.8, 97.5), control1: SymbolPoint(107.3, 106), control2: SymbolPoint(101.6, 102.1)),
            .curve(to: SymbolPoint(87.6, 82.4), control1: SymbolPoint(92.6, 93), control2: SymbolPoint(89.8, 87.7)),
            .curve(to: SymbolPoint(90, 95.6), control1: SymbolPoint(86.8, 86.8), control2: SymbolPoint(86.7, 91.7)),
            .curve(to: SymbolPoint(103.5, 107.4), control1: SymbolPoint(93.6, 100.1), control2: SymbolPoint(98.6, 103.7)),
            .curve(to: SymbolPoint(110.6, 112.2), control1: SymbolPoint(105.8, 109.1), control2: SymbolPoint(108.2, 110.7)),
            .curve(to: SymbolPoint(112.9, 110), control1: SymbolPoint(111.4, 111.5), control2: SymbolPoint(112.1, 110.7)),
            .move(to: SymbolPoint(87.2, 110)),
            .curve(to: SymbolPoint(103.3, 97.5), control1: SymbolPoint(92.8, 106), control2: SymbolPoint(98.5, 102.1)),
            .curve(to: SymbolPoint(112.5, 82.4), control1: SymbolPoint(107.5, 93), control2: SymbolPoint(110.3, 87.7)),
            .curve(to: SymbolPoint(110.1, 95.6), control1: SymbolPoint(113.3, 86.8), control2: SymbolPoint(113.4, 91.7)),
            .curve(to: SymbolPoint(96.6, 107.4), control1: SymbolPoint(106.5, 100.1), control2: SymbolPoint(101.5, 103.7)),
            .curve(to: SymbolPoint(89.5, 112.2), control1: SymbolPoint(94.3, 109.1), control2: SymbolPoint(91.9, 110.7)),
            .curve(to: SymbolPoint(87.2, 110), control1: SymbolPoint(88.7, 111.5), control2: SymbolPoint(88, 110.7)),
        ], style: DrawStyle(fill: .contrastFill, stroke: .iconStroke, strokeWidth: 2, dash: nil))),
    ] }

    // 130330000014010000000000000000, 130630000014010000000000000000, 130530000014010000000000000000, 130430000014010000000000000000
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

    // 130330000014020000000000000000, 130430000014020000000000000000
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

    // 130330000015000000000000000000
    private static func icon_delta_30150000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(50, 100)),
            .line(to: SymbolPoint(150, 100)),
            .move(to: SymbolPoint(100, 50)),
            .line(to: SymbolPoint(100, 150)),
            .move(to: SymbolPoint(150, 100)),
            .curve(to: SymbolPoint(100, 150), control1: SymbolPoint(150, 127.6), control2: SymbolPoint(127.6, 150)),
            .curve(to: SymbolPoint(50, 100), control1: SymbolPoint(72.4, 150), control2: SymbolPoint(50, 127.6)),
            .curve(to: SymbolPoint(100, 50), control1: SymbolPoint(50, 72.4), control2: SymbolPoint(72.4, 50)),
            .curve(to: SymbolPoint(150, 100), control1: SymbolPoint(127.6, 50), control2: SymbolPoint(150, 72.4)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .affiliationFill, strokeWidth: 3, dash: nil))),
    ] }

    // 130130000016000000000000000000
    private static func icon_delta_30160000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(111.151123, 92.343262)),
            .line(to: SymbolPoint(111.151123, 92.343262)),
            .quadCurve(to: SymbolPoint(110.195313, 96.166504), control: SymbolPoint(111.151123, 94.474609)),
            .quadCurve(to: SymbolPoint(106.624756, 99.726074), control: SymbolPoint(109.239502, 97.858398)),
            .line(to: SymbolPoint(106.624756, 99.726074)),
            .line(to: SymbolPoint(104.954834, 100.93457)),
            .quadCurve(to: SymbolPoint(102.724609, 103.109863), control: SymbolPoint(103.460693, 102.01123)),
            .quadCurve(to: SymbolPoint(101.922607, 105.526855), control: SymbolPoint(101.988525, 104.208496)),
            .line(to: SymbolPoint(101.922607, 105.526855)),
            .line(to: SymbolPoint(96.055908, 105.526855)),
            .quadCurve(to: SymbolPoint(97.319336, 101.527832), control: SymbolPoint(96.187744, 103.285645)),
            .quadCurve(to: SymbolPoint(100.648193, 98.231934), control: SymbolPoint(98.450928, 99.77002)),
            .line(to: SymbolPoint(100.648193, 98.231934)),
            .quadCurve(to: SymbolPoint(103.966064, 95.364502), control: SymbolPoint(102.999268, 96.605957)),
            .quadCurve(to: SymbolPoint(104.932861, 92.606934), control: SymbolPoint(104.932861, 94.123047)),
            .line(to: SymbolPoint(104.932861, 92.606934)),
            .quadCurve(to: SymbolPoint(103.669434, 89.552734), control: SymbolPoint(104.932861, 90.67334)),
            .quadCurve(to: SymbolPoint(100.076904, 88.432129), control: SymbolPoint(102.406006, 88.432129)),
            .line(to: SymbolPoint(100.076904, 88.432129)),
            .quadCurve(to: SymbolPoint(96.352539, 89.728516), control: SymbolPoint(97.857666, 88.432129)),
            .quadCurve(to: SymbolPoint(94.58374, 93.15625), control: SymbolPoint(94.847412, 91.024902)),
            .line(to: SymbolPoint(94.58374, 93.15625)),
            .line(to: SymbolPoint(88.321533, 92.892578)),
            .quadCurve(to: SymbolPoint(91.990967, 85.949219), control: SymbolPoint(88.914795, 88.432129)),
            .quadCurve(to: SymbolPoint(99.989014, 83.466309), control: SymbolPoint(95.067139, 83.466309)),
            .line(to: SymbolPoint(99.989014, 83.466309)),
            .quadCurve(to: SymbolPoint(108.173828, 85.828369), control: SymbolPoint(105.196533, 83.466309)),
            .quadCurve(to: SymbolPoint(111.151123, 92.343262), control: SymbolPoint(111.151123, 88.19043)),
            .close,
            .move(to: SymbolPoint(102.230225, 114.887207)),
            .line(to: SymbolPoint(95.880127, 114.887207)),
            .line(to: SymbolPoint(95.880127, 108.95459)),
            .line(to: SymbolPoint(102.230225, 108.95459)),
            .line(to: SymbolPoint(102.230225, 114.887207)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(70, 65)),
            .line(to: SymbolPoint(80, 100)),
            .line(to: SymbolPoint(70, 135)),
            .line(to: SymbolPoint(130, 135)),
            .line(to: SymbolPoint(120, 100)),
            .line(to: SymbolPoint(130, 65)),
            .close,
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130335000011010000000000000000, 130635000011010000000000000000
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

    // 130135000014000000000000000000
    private static func icon_delta_35140000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(114.868164, 105.791016)),
            .line(to: SymbolPoint(114.868164, 105.791016)),
            .quadCurve(to: SymbolPoint(113.59375, 110.888672), control: SymbolPoint(114.868164, 108.632813)),
            .quadCurve(to: SymbolPoint(108.833008, 115.634766), control: SymbolPoint(112.319336, 113.144531)),
            .line(to: SymbolPoint(108.833008, 115.634766)),
            .line(to: SymbolPoint(106.606445, 117.246094)),
            .quadCurve(to: SymbolPoint(103.632813, 120.146484), control: SymbolPoint(104.614258, 118.681641)),
            .quadCurve(to: SymbolPoint(102.563477, 123.369141), control: SymbolPoint(102.651367, 121.611328)),
            .line(to: SymbolPoint(102.563477, 123.369141)),
            .line(to: SymbolPoint(94.741211, 123.369141)),
            .quadCurve(to: SymbolPoint(96.425781, 118.037109), control: SymbolPoint(94.916992, 120.380859)),
            .quadCurve(to: SymbolPoint(100.864258, 113.642578), control: SymbolPoint(97.93457, 115.693359)),
            .line(to: SymbolPoint(100.864258, 113.642578)),
            .quadCurve(to: SymbolPoint(105.288086, 109.819336), control: SymbolPoint(103.999023, 111.474609)),
            .quadCurve(to: SymbolPoint(106.577148, 106.142578), control: SymbolPoint(106.577148, 108.164063)),
            .line(to: SymbolPoint(106.577148, 106.142578)),
            .quadCurve(to: SymbolPoint(104.892578, 102.070313), control: SymbolPoint(106.577148, 103.564453)),
            .quadCurve(to: SymbolPoint(100.102539, 100.576172), control: SymbolPoint(103.208008, 100.576172)),
            .line(to: SymbolPoint(100.102539, 100.576172)),
            .quadCurve(to: SymbolPoint(95.136719, 102.304688), control: SymbolPoint(97.143555, 100.576172)),
            .quadCurve(to: SymbolPoint(92.77832, 106.875), control: SymbolPoint(93.129883, 104.033203)),
            .line(to: SymbolPoint(92.77832, 106.875)),
            .line(to: SymbolPoint(84.428711, 106.523438)),
            .quadCurve(to: SymbolPoint(89.321289, 97.265625), control: SymbolPoint(85.219727, 100.576172)),
            .quadCurve(to: SymbolPoint(99.985352, 93.955078), control: SymbolPoint(93.422852, 93.955078)),
            .line(to: SymbolPoint(99.985352, 93.955078)),
            .quadCurve(to: SymbolPoint(110.898438, 97.104492), control: SymbolPoint(106.928711, 93.955078)),
            .quadCurve(to: SymbolPoint(114.868164, 105.791016), control: SymbolPoint(114.868164, 100.253906)),
            .close,
            .move(to: SymbolPoint(102.973633, 135.849609)),
            .line(to: SymbolPoint(94.506836, 135.849609)),
            .line(to: SymbolPoint(94.506836, 127.939453)),
            .line(to: SymbolPoint(102.973633, 127.939453)),
            .line(to: SymbolPoint(102.973633, 135.849609)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
    ] }

    // 130135000015000000000000000000
    private static func icon_delta_35150000() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(111.151123, 92.343262)),
            .line(to: SymbolPoint(111.151123, 92.343262)),
            .quadCurve(to: SymbolPoint(110.195313, 96.166504), control: SymbolPoint(111.151123, 94.474609)),
            .quadCurve(to: SymbolPoint(106.624756, 99.726074), control: SymbolPoint(109.239502, 97.858398)),
            .line(to: SymbolPoint(106.624756, 99.726074)),
            .line(to: SymbolPoint(104.954834, 100.93457)),
            .quadCurve(to: SymbolPoint(102.724609, 103.109863), control: SymbolPoint(103.460693, 102.01123)),
            .quadCurve(to: SymbolPoint(101.922607, 105.526855), control: SymbolPoint(101.988525, 104.208496)),
            .line(to: SymbolPoint(101.922607, 105.526855)),
            .line(to: SymbolPoint(96.055908, 105.526855)),
            .quadCurve(to: SymbolPoint(97.319336, 101.527832), control: SymbolPoint(96.187744, 103.285645)),
            .quadCurve(to: SymbolPoint(100.648193, 98.231934), control: SymbolPoint(98.450928, 99.77002)),
            .line(to: SymbolPoint(100.648193, 98.231934)),
            .quadCurve(to: SymbolPoint(103.966064, 95.364502), control: SymbolPoint(102.999268, 96.605957)),
            .quadCurve(to: SymbolPoint(104.932861, 92.606934), control: SymbolPoint(104.932861, 94.123047)),
            .line(to: SymbolPoint(104.932861, 92.606934)),
            .quadCurve(to: SymbolPoint(103.669434, 89.552734), control: SymbolPoint(104.932861, 90.67334)),
            .quadCurve(to: SymbolPoint(100.076904, 88.432129), control: SymbolPoint(102.406006, 88.432129)),
            .line(to: SymbolPoint(100.076904, 88.432129)),
            .quadCurve(to: SymbolPoint(96.352539, 89.728516), control: SymbolPoint(97.857666, 88.432129)),
            .quadCurve(to: SymbolPoint(94.58374, 93.15625), control: SymbolPoint(94.847412, 91.024902)),
            .line(to: SymbolPoint(94.58374, 93.15625)),
            .line(to: SymbolPoint(88.321533, 92.892578)),
            .quadCurve(to: SymbolPoint(91.990967, 85.949219), control: SymbolPoint(88.914795, 88.432129)),
            .quadCurve(to: SymbolPoint(99.989014, 83.466309), control: SymbolPoint(95.067139, 83.466309)),
            .line(to: SymbolPoint(99.989014, 83.466309)),
            .quadCurve(to: SymbolPoint(108.173828, 85.828369), control: SymbolPoint(105.196533, 83.466309)),
            .quadCurve(to: SymbolPoint(111.151123, 92.343262), control: SymbolPoint(111.151123, 88.19043)),
            .close,
            .move(to: SymbolPoint(102.230225, 114.887207)),
            .line(to: SymbolPoint(95.880127, 114.887207)),
            .line(to: SymbolPoint(95.880127, 108.95459)),
            .line(to: SymbolPoint(102.230225, 108.95459)),
            .line(to: SymbolPoint(102.230225, 114.887207)),
            .close,
        ], style: DrawStyle(fill: .iconFill, stroke: .none, strokeWidth: 0, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(70, 65)),
            .line(to: SymbolPoint(80, 100)),
            .line(to: SymbolPoint(70, 135)),
            .line(to: SymbolPoint(130, 135)),
            .line(to: SymbolPoint(120, 100)),
            .line(to: SymbolPoint(130, 65)),
        ], style: DrawStyle(fill: .none, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130336000011010000000000000000
    private static func icon_delta_36110100_friend() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(115.9, 73)),
            .line(to: SymbolPoint(126.5, 62.4)),
            .line(to: SymbolPoint(137.1, 73)),
            .line(to: SymbolPoint(126.5, 83.6)),
            .move(to: SymbolPoint(73.5, 83.6)),
            .line(to: SymbolPoint(62.9, 73)),
            .line(to: SymbolPoint(73.5, 62.4)),
            .line(to: SymbolPoint(84.1, 73)),
            .move(to: SymbolPoint(92.5, 70)),
            .line(to: SymbolPoint(92.5, 55)),
            .line(to: SymbolPoint(107.5, 55)),
            .line(to: SymbolPoint(107.5, 70)),
            .move(to: SymbolPoint(130, 100)),
            .curve(to: SymbolPoint(100, 130), control1: SymbolPoint(130, 116.6), control2: SymbolPoint(116.6, 130)),
            .curve(to: SymbolPoint(70, 100), control1: SymbolPoint(83.4, 130), control2: SymbolPoint(70, 116.6)),
            .curve(to: SymbolPoint(100, 70), control1: SymbolPoint(70, 83.4), control2: SymbolPoint(83.4, 70)),
            .curve(to: SymbolPoint(130, 100), control1: SymbolPoint(116.6, 70), control2: SymbolPoint(130, 83.4)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(74.8, 125.2)),
            .line(to: SymbolPoint(125.2, 125.2)),
            .line(to: SymbolPoint(125.2, 137.8)),
            .line(to: SymbolPoint(74.8, 137.8)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130636000011010000000000000000
    private static func icon_delta_36110100_hostile() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(115.9, 73)),
            .line(to: SymbolPoint(126.5, 62.4)),
            .line(to: SymbolPoint(137.1, 73)),
            .line(to: SymbolPoint(126.5, 83.6)),
            .move(to: SymbolPoint(73.5, 83.6)),
            .line(to: SymbolPoint(62.9, 73)),
            .line(to: SymbolPoint(73.5, 62.4)),
            .line(to: SymbolPoint(84.1, 73)),
            .move(to: SymbolPoint(92.5, 70)),
            .line(to: SymbolPoint(92.5, 55)),
            .line(to: SymbolPoint(107.5, 55)),
            .line(to: SymbolPoint(107.5, 70)),
            .move(to: SymbolPoint(130, 100)),
            .curve(to: SymbolPoint(100, 130), control1: SymbolPoint(130, 116.6), control2: SymbolPoint(116.6, 130)),
            .curve(to: SymbolPoint(70, 100), control1: SymbolPoint(83.4, 130), control2: SymbolPoint(70, 116.6)),
            .curve(to: SymbolPoint(100, 70), control1: SymbolPoint(70, 83.4), control2: SymbolPoint(83.4, 70)),
            .curve(to: SymbolPoint(130, 100), control1: SymbolPoint(116.6, 70), control2: SymbolPoint(130, 83.4)),
            .close,
        ], style: DrawStyle(fill: .affiliationColor, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(74.8, 125.2)),
            .line(to: SymbolPoint(125.2, 125.2)),
            .line(to: SymbolPoint(125.2, 137.8)),
            .line(to: SymbolPoint(74.8, 137.8)),
            .close,
        ], style: DrawStyle(fill: .affiliationColor, stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130436000011010000000000000000, 130436300011010000000000000000, 130436400011010000000000000000
    private static func icon_delta_36110100_neutral() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(115.9, 73)),
            .line(to: SymbolPoint(126.5, 62.4)),
            .line(to: SymbolPoint(137.1, 73)),
            .line(to: SymbolPoint(126.5, 83.6)),
            .move(to: SymbolPoint(73.5, 83.6)),
            .line(to: SymbolPoint(62.9, 73)),
            .line(to: SymbolPoint(73.5, 62.4)),
            .line(to: SymbolPoint(84.1, 73)),
            .move(to: SymbolPoint(92.5, 70)),
            .line(to: SymbolPoint(92.5, 55)),
            .line(to: SymbolPoint(107.5, 55)),
            .line(to: SymbolPoint(107.5, 70)),
            .move(to: SymbolPoint(130, 100)),
            .curve(to: SymbolPoint(100, 130), control1: SymbolPoint(130, 116.6), control2: SymbolPoint(116.6, 130)),
            .curve(to: SymbolPoint(70, 100), control1: SymbolPoint(83.4, 130), control2: SymbolPoint(70, 116.6)),
            .curve(to: SymbolPoint(100, 70), control1: SymbolPoint(70, 83.4), control2: SymbolPoint(83.4, 70)),
            .curve(to: SymbolPoint(130, 100), control1: SymbolPoint(116.6, 70), control2: SymbolPoint(130, 83.4)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(74.8, 125.2)),
            .line(to: SymbolPoint(125.2, 125.2)),
            .line(to: SymbolPoint(125.2, 137.8)),
            .line(to: SymbolPoint(74.8, 137.8)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }

    // 130036000011010000000000000000
    private static func icon_delta_36110100_unknown() -> [DrawInstruction] { [
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(115.9, 73)),
            .line(to: SymbolPoint(126.5, 62.4)),
            .line(to: SymbolPoint(137.1, 73)),
            .line(to: SymbolPoint(126.5, 83.6)),
            .move(to: SymbolPoint(73.5, 83.6)),
            .line(to: SymbolPoint(62.9, 73)),
            .line(to: SymbolPoint(73.5, 62.4)),
            .line(to: SymbolPoint(84.1, 73)),
            .move(to: SymbolPoint(92.5, 70)),
            .line(to: SymbolPoint(92.5, 55)),
            .line(to: SymbolPoint(107.5, 55)),
            .line(to: SymbolPoint(107.5, 70)),
            .move(to: SymbolPoint(130, 100)),
            .curve(to: SymbolPoint(100, 130), control1: SymbolPoint(130, 116.6), control2: SymbolPoint(116.6, 130)),
            .curve(to: SymbolPoint(70, 100), control1: SymbolPoint(83.4, 130), control2: SymbolPoint(70, 116.6)),
            .curve(to: SymbolPoint(100, 70), control1: SymbolPoint(70, 83.4), control2: SymbolPoint(83.4, 70)),
            .curve(to: SymbolPoint(130, 100), control1: SymbolPoint(116.6, 70), control2: SymbolPoint(130, 83.4)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
        .path(SymbolPath(segments: [
            .move(to: SymbolPoint(74.8, 125.2)),
            .line(to: SymbolPoint(125.2, 125.2)),
            .line(to: SymbolPoint(125.2, 137.8)),
            .line(to: SymbolPoint(74.8, 137.8)),
            .close,
        ], style: DrawStyle(fill: .literal(.rgb255(255, 0, 0)), stroke: .iconStroke, strokeWidth: 3, dash: nil))),
    ] }
}
