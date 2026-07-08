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

// The catalog. Two modes on Apple platforms:
//
//   swift run ensign-catalog
//     Renders ensign-frames.png, a contact sheet of every frame, to
//     the working directory for visual inspection.
//
//   swift run ensign-catalog render <sidc-list> <output-dir> [pixels]
//     Renders one PNG per SIDC (named <sidc>.png) for the milsymbol
//     oracle in tools/extract. The list file allows blank lines and
//     # comments. Unframeable SIDCs are skipped with a note.
//
// On Linux both modes fall back to a text-mode parser smoke test.

import Foundation
import EnsignCore

// Delta SIDC builders keep the grid definitions readable.
func deltaSIDC(context: String = "0", identity: String, symbolSet: String, status: String = "0") -> String {
    "10" + context + identity + symbolSet + status + "0" + "00" + "000000" + "0000"
}

let identityDigits: [(label: String, digit: String)] = [
    ("Unknown", "1"), ("Friend", "3"), ("Neutral", "4"), ("Hostile", "6"),
]
let domainColumns: [(label: String, symbolSet: String)] = [
    ("Air", "01"), ("Space", "05"), ("Land unit", "10"),
    ("Land equipment", "15"), ("Installation", "20"),
    ("Dismounted", "27"), ("Sea surface", "30"),
    ("Subsurface", "35"), ("Activity", "40"),
]
let specials: [(label: String, sidc: String)] = [
    ("Suspect land unit (dashed identity)", deltaSIDC(identity: "5", symbolSet: "10")),
    ("Planned friend land unit (dashed status)", deltaSIDC(identity: "3", symbolSet: "10", status: "1")),
    ("Friend land civilian (civilian fill)", deltaSIDC(identity: "3", symbolSet: "11")),
    ("Joker (suspect fill, dashed)", deltaSIDC(context: "1", identity: "5", symbolSet: "10")),
    ("Faker (hostile fill, solid)", deltaSIDC(context: "1", identity: "6", symbolSet: "10")),
    ("Assumed friend subsurface (dashed)", deltaSIDC(identity: "2", symbolSet: "35")),
    ("Pending air (dashed)", deltaSIDC(identity: "0", symbolSet: "01")),
    ("Hostile space (space bar)", deltaSIDC(identity: "6", symbolSet: "05")),
    ("Neutral activity (corner brackets)", deltaSIDC(identity: "4", symbolSet: "40")),
]

func readSIDCList(at path: String) throws -> [String] {
    try String(contentsOfFile: path, encoding: .utf8)
        .split(whereSeparator: \.isNewline)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty && !$0.hasPrefix("#") }
}

// MARK: - Icon key mode (all platforms)

/// Prints `sidc<TAB>family<TAB>code<TAB>base` per line to stdout for
/// the extraction tooling, keeping Ensign's IconKey derivation the
/// single source of truth. The frame base column lets codegen group
/// full-frame icons, whose geometry varies with the frame shape.
/// Diagnostics go to stderr so the TSV stays clean for redirection.
func runKeysMode(listPath: String) -> Never {
    func warn(_ message: String) {
        FileHandle.standardError.write(Data((message + "\n").utf8))
    }
    let sidcs: [String]
    do {
        sidcs = try readSIDCList(at: listPath)
    } catch {
        warn("Could not read the SIDC list at \(listPath).")
        warn("Check the path; it should be a text file with one SIDC per line.")
        exit(2)
    }
    var failures = 0
    for sidc in sidcs {
        do {
            let symbol = try MilSymbol(sidc)
            let key = symbol.iconKey
            let base = String(describing: symbol.affiliation.frameBase)
            print("\(sidc)\t\(key.family.rawValue)\t\(key.code)\t\(base)")
        } catch {
            warn("PARSE FAILED \(sidc): \(error)")
            failures += 1
        }
    }
    exit(failures > 0 ? 1 : 0)
}

let arguments = CommandLine.arguments
if arguments.count >= 2 && arguments[1] == "keys" {
    guard arguments.count >= 3 else {
        FileHandle.standardError.write(Data("Usage: ensign-catalog keys <sidc-list>\n".utf8))
        exit(2)
    }
    runKeysMode(listPath: arguments[2])
}

#if canImport(CoreGraphics)
import CoreGraphics
import EnsignRender

let renderer = SymbolRenderer(palette: .light)

// MARK: - Oracle render mode

func runRenderMode(listPath: String, outputDir: String, pixels: Int) {
    print("Ensign \(Ensign.version) - oracle render mode")
    let sidcs: [String]
    do {
        sidcs = try readSIDCList(at: listPath)
    } catch {
        print("Could not read the SIDC list at \(listPath).")
        print("Check the path; it should be a text file with one SIDC per line.")
        exit(2)
    }

    do {
        try FileManager.default.createDirectory(
            atPath: outputDir, withIntermediateDirectories: true)
    } catch {
        print("Could not create the output directory \(outputDir): \(error)")
        exit(2)
    }

    var rendered = 0
    var skipped = 0
    var failed = 0
    for sidc in sidcs {
        do {
            let symbol = try MilSymbol(sidc)
            guard let data = renderer.pngData(for: symbol, size: pixels) else {
                print("SKIP \(sidc): no frame rendering defined for this domain")
                skipped += 1
                continue
            }
            let url = URL(fileURLWithPath: outputDir).appendingPathComponent("\(sidc).png")
            try data.write(to: url)
            rendered += 1
        } catch {
            print("FAIL \(sidc): \(error)")
            failed += 1
        }
    }

    print("Rendered \(rendered) of \(sidcs.count) at \(pixels)px to \(outputDir)" +
        (skipped > 0 ? " (\(skipped) skipped)" : "") +
        (failed > 0 ? " (\(failed) FAILED)" : ""))
    exit(failed > 0 ? 1 : 0)
}

// MARK: - Contact sheet mode

func runContactSheet() {
    print("Ensign \(Ensign.version) - MIL-STD-2525 symbology for Swift")
    print(String(repeating: "=", count: 60))

    let cell = 120
    let padding = 10
    let columns = domainColumns.count
    let mainRows = identityDigits.count
    let specialRows = (specials.count + columns - 1) / columns
    let rows = mainRows + specialRows
    let width = columns * cell + padding * 2
    let height = rows * cell + padding * 3

    func makeSheet() -> CGImage? {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: 0, space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }

        context.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        func place(_ image: CGImage, column: Int, row: Int) {
            // CGContext origin is bottom-left; rows count from the top.
            let x = padding + column * cell
            let y = height - padding - (row + 1) * cell
            context.draw(image, in: CGRect(x: x, y: y, width: cell, height: cell))
        }

        // Main grid: affiliation rows x domain columns.
        for (row, identity) in identityDigits.enumerated() {
            for (column, domain) in domainColumns.enumerated() {
                let sidc = deltaSIDC(identity: identity.digit, symbolSet: domain.symbolSet)
                guard let symbol = try? MilSymbol(sidc),
                      let image = renderer.image(for: symbol, size: cell)
                else {
                    print("MISSING: \(identity.label) x \(domain.label) [\(sidc)]")
                    continue
                }
                place(image, column: column, row: row)
            }
        }

        // Specials rows below the main grid.
        for (index, special) in specials.enumerated() {
            guard let symbol = try? MilSymbol(special.sidc),
                  let image = renderer.image(for: symbol, size: cell)
            else {
                print("MISSING: \(special.label) [\(special.sidc)]")
                continue
            }
            place(image, column: index % columns, row: mainRows + index / columns)
        }

        return context.makeImage()
    }

    if let sheet = makeSheet(), let data = SymbolRenderer.pngData(from: sheet) {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("ensign-frames.png")
        do {
            try data.write(to: url)
            print("\nFrame contact sheet written to \(url.path)")
            print("Rows top to bottom: \(identityDigits.map(\.label).joined(separator: ", "))")
            print("Columns left to right: \(domainColumns.map(\.label).joined(separator: ", "))")
            print("Below the grid: \(specials.map(\.label).joined(separator: "; "))")
        } catch {
            print("Failed to write contact sheet: \(error)")
        }
    } else {
        print("Failed to render the contact sheet.")
    }
}

// MARK: - Entry

if arguments.count >= 2 && arguments[1] == "render" {
    guard arguments.count >= 4 else {
        print("Usage: ensign-catalog render <sidc-list> <output-dir> [pixels]")
        print("       ensign-catalog keys <sidc-list>")
        exit(2)
    }
    let pixels = arguments.count >= 5 ? Int(arguments[4]) ?? 200 : 200
    runRenderMode(listPath: arguments[2], outputDir: arguments[3], pixels: pixels)
} else {
    runContactSheet()
}

#else

// Text-mode smoke test for platforms without CoreGraphics.
print("Ensign \(Ensign.version) - MIL-STD-2525 symbology for Swift")
print(String(repeating: "=", count: 60))
print("\nParsed samples")
print(String(repeating: "-", count: 60))
for identity in identityDigits {
    for domain in domainColumns {
        let sidc = deltaSIDC(identity: identity.digit, symbolSet: domain.symbolSet)
        do {
            let symbol = try MilSymbol(sidc)
            let shape = symbol.frame.shape.map { "\($0)" } ?? "(no frame defined)"
            let instructions = SymbolComposer.geometry(for: symbol).instructions.count
            print("\(identity.label) \(domain.label): frame=\(shape) instructions=\(instructions)")
        } catch {
            print("\(identity.label) \(domain.label): PARSE FAILED - \(error)")
        }
    }
}
for special in specials {
    do {
        let symbol = try MilSymbol(special.sidc)
        let instructions = SymbolComposer.geometry(for: symbol).instructions.count
        print("\(special.label): fill=\(symbol.fillClass) dashed=\(symbol.frame.isDashed) instructions=\(instructions)")
    } catch {
        print("\(special.label): PARSE FAILED - \(error)")
    }
}
print("\nDone.")

#endif
