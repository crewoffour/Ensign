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

// The snapshot suite: renders every SIDC with a committed golden image
// in Snapshots/ and compares pixels with tolerance. This is the
// regression net that runs on plain `swift test` with no Node, npm, or
// oracle in the loop.
//
// The committed snapshots ARE the test list: each Snapshots/<sidc>.png
// is rendered fresh and compared. To record or refresh them, from the
// package root:
//
//   swift run -c release ensign-catalog render \
//     tools/extract/sidcs-maritime.txt Tests/EnsignRenderTests/Snapshots 200
//
// Re-record only after an intentional rendering change that the
// milsymbol oracle (tools/extract) has verified; the oracle referees
// changes, the snapshots freeze them. `git diff --stat` on the
// snapshot directory then shows exactly which symbols changed.
//
// Comparison is tolerance-based rather than byte-exact so that
// CoreGraphics antialiasing drift across macOS versions cannot cause
// false alarms: a pixel counts as different only when some channel
// moves by more than the channel tolerance, and an image fails only
// when more than the allowed fraction of its pixels differ.

#if canImport(CoreGraphics)
import XCTest
import CoreGraphics
import ImageIO
import EnsignCore
import EnsignRender

final class SnapshotTests: XCTestCase {

    /// Per-channel delta at or below which a component is considered
    /// unchanged. Absorbs antialiasing differences between
    /// CoreGraphics versions; real geometry or color changes move
    /// whole runs of pixels far beyond it.
    private static let channelTolerance: Int = 32

    /// The fraction of differing pixels allowed per image. Same-engine
    /// re-renders are normally identical; this headroom exists solely
    /// for cross-machine antialiasing on curve and dash edges.
    private static let allowedFraction: Double = 0.005

    func testSnapshotsMatchCommittedReferences() throws {
        let snapshots = try Self.snapshotURLs()
        if snapshots.isEmpty {
            throw XCTSkip("""
                No snapshots recorded yet. From the package root:
                swift run -c release ensign-catalog render tools/extract/sidcs-maritime.txt Tests/EnsignRenderTests/Snapshots 200
                Then re-run the tests.
                """)
        }

        let renderer = SymbolRenderer(palette: .light)
        var failures: [String] = []

        for url in snapshots {
            let sidc = url.deletingPathExtension().lastPathComponent
            do {
                guard let golden = try Self.pixels(ofPNGAt: url) else {
                    failures.append("\(sidc): the committed snapshot could not be decoded")
                    continue
                }
                let symbol = try MilSymbol(sidc)
                guard let image = renderer.image(for: symbol, size: golden.width) else {
                    failures.append("\(sidc): renders nothing but has a committed snapshot; if the change is intentional, delete or re-record it")
                    continue
                }
                let current = try Self.pixels(of: image)
                guard golden.width == current.width, golden.height == current.height else {
                    failures.append("\(sidc): size mismatch \(golden.width)x\(golden.height) vs \(current.width)x\(current.height)")
                    continue
                }
                let fraction = Self.mismatchFraction(golden, current)
                if fraction > Self.allowedFraction {
                    failures.append(String(
                        format: "%@: %.3f%% of pixels differ (allowed %.3f%%)",
                        sidc, fraction * 100, Self.allowedFraction * 100
                    ))
                }
            } catch {
                failures.append("\(sidc): \(error)")
            }
        }

        if !failures.isEmpty {
            XCTFail("""
                \(failures.count) snapshot(s) differ:
                \(failures.joined(separator: "\n"))
                If these changes are intentional and oracle-verified, re-record with:
                swift run -c release ensign-catalog render tools/extract/sidcs-maritime.txt Tests/EnsignRenderTests/Snapshots 200
                """)
        }
    }

    // MARK: - Pixel plumbing

    private struct PixelBuffer {
        let width: Int
        let height: Int
        let data: [UInt8]
    }

    private static func snapshotURLs() throws -> [URL] {
        guard let directory = Bundle.module.url(forResource: "Snapshots", withExtension: nil) else {
            return []
        }
        return try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private static func pixels(ofPNGAt url: URL) throws -> PixelBuffer? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        return try pixels(of: image)
    }

    /// Normalizes any CGImage into straight rows of sRGB RGBA8 by
    /// drawing it into a fresh context, so golden PNGs and live
    /// renders compare in an identical format regardless of how they
    /// were encoded.
    private static func pixels(of image: CGImage) throws -> PixelBuffer {
        let width = image.width
        let height = image.height
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let space = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw SnapshotError.colorSpaceUnavailable
        }
        try data.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                throw SnapshotError.contextCreationFailed
            }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return PixelBuffer(width: width, height: height, data: data)
    }

    private static func mismatchFraction(_ a: PixelBuffer, _ b: PixelBuffer) -> Double {
        var mismatched = 0
        let count = min(a.data.count, b.data.count)
        var index = 0
        while index < count {
            if abs(Int(a.data[index]) - Int(b.data[index])) > channelTolerance ||
               abs(Int(a.data[index + 1]) - Int(b.data[index + 1])) > channelTolerance ||
               abs(Int(a.data[index + 2]) - Int(b.data[index + 2])) > channelTolerance ||
               abs(Int(a.data[index + 3]) - Int(b.data[index + 3])) > channelTolerance {
                mismatched += 1
            }
            index += 4
        }
        return Double(mismatched) / Double(a.width * a.height)
    }

    private enum SnapshotError: Error {
        case colorSpaceUnavailable
        case contextCreationFailed
    }
}
#endif
