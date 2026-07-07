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

// The catalog is text-mode until rendering lands in Session 2, at which
// point it grows into the SwiftUI gallery and visual-regression harness
// described in the charter. For now it is a cross-platform smoke test:
// run `swift run ensign-catalog` to see both parsers and the frame
// resolution table exercised end to end.

import EnsignCore

print("Ensign \(Ensign.version) - MIL-STD-2525 symbology for Swift")
print(String(repeating: "=", count: 60))

let samples: [(label: String, code: String)] = [
    ("Friend sea surface, 2525C", "SFSPCLDD-------"),
    ("Hostile subsurface, 2525C", "SHUP-----------"),
    ("Suspect air (dashed), 2525C", "SSAP-----------"),
    ("Exercise friend ground unit, 2525C", "SDGPUCI--------"),
    ("Anticipated neutral ground equipment, 2525C", "SNGAE----------"),
    ("Friend sea surface combatant, 2525D", "10033000001201000000"),
    ("Exercise hostile subsurface (faker), 2525D", "10163500001100000000"),
    ("Planned unknown air, 2525D", "10010110001101000000"),
]

print("\nParsed samples")
print(String(repeating: "-", count: 60))
for sample in samples {
    do {
        let symbol = try MilSymbol(sample.code)
        let shape = symbol.frame.shape.map { "\($0)" } ?? "(no frame defined)"
        let dashed = symbol.frame.isDashed ? ", dashed" : ""
        let exercise = symbol.isExercise ? ", exercise" : ""
        print("\(sample.label)")
        print("  \(sample.code)")
        print("  affiliation=\(symbol.affiliation) domain=\(symbol.domain)")
        print("  frame=\(shape)\(dashed)\(exercise) icon=\(symbol.iconKey)")
    } catch {
        print("\(sample.label): PARSE FAILED - \(error)")
    }
}

print("\nFrame resolution matrix (base x domain)")
print(String(repeating: "-", count: 60))
let domains: [(String, SymbolDomain)] = [
    ("air", .air), ("space", .space),
    ("land unit", .landUnit), ("land equip", .landEquipment),
    ("installation", .landInstallation),
    ("sea surface", .seaSurface), ("subsurface", .subsurface),
    ("activity", .activity),
]
for base in FrameBase.allCases {
    print("\(base):")
    for (name, domain) in domains {
        let shape = FrameShape.resolve(base: base, domain: domain)
        print("  \(name): \(shape.map { "\($0)" } ?? "-")")
    }
}

print("\nDone.")
