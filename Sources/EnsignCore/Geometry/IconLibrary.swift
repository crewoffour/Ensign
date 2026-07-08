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

/// One icon's geometry in the library.
///
/// Most icons are drawn on the symbol octagon and are identical under
/// every frame; those are `universal`. Full-frame icons (the infantry
/// saltire, for example) span the frame outline itself, so their
/// geometry differs per frame base; those carry per-base variants,
/// discovered at extraction time by comparing what milsymbol actually
/// drew for each base rather than by any a priori list.
public enum IconEntry: Sendable {
    case universal([DrawInstruction])
    case perBase([FrameBase: [DrawInstruction]])
}

/// The library of main icon geometry, keyed by ``IconKey``.
///
/// The tables behind this facade live in GeneratedIcons.swift, which is
/// produced by tools/extract/codegen.js from milsymbol's draw
/// instructions and is never edited by hand. A missing key is not an
/// error: per the standard's degradation guidance, symbols with icons
/// the library does not know render as frame and fill only. A per-base
/// entry missing the requested base degrades the same way.
public enum IconLibrary {
    /// The icon drawing instructions for a key under a frame base, in
    /// 200x200 canvas coordinates, or `nil` when the library has no
    /// matching entry.
    public static func instructions(for key: IconKey, base: FrameBase) -> [DrawInstruction]? {
        switch generatedIcons[key] {
        case .universal(let instructions):
            return instructions
        case .perBase(let variants):
            return variants[base]
        case nil:
            return nil
        }
    }

    /// The number of icons in the generated library.
    public static var iconCount: Int {
        generatedIcons.count
    }
}
