// swift-tools-version: 6.0
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

import PackageDescription

let package = Package(
    name: "Ensign",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        // The Foundation-only core: SIDC parsing, the normalized symbol
        // model, and the neutral geometry model. Builds on Linux.
        .library(name: "EnsignCore", targets: ["EnsignCore"]),
        // The Core Graphics drawing engine. Apple platforms.
        .library(name: "EnsignRender", targets: ["EnsignRender"]),
        // SwiftUI view wrappers. Apple platforms.
        .library(name: "EnsignUI", targets: ["EnsignUI"]),
        // Demonstration and visual-regression catalog. Not part of the
        // shipped product; a text-mode smoke test until rendering lands.
        .executable(name: "ensign-catalog", targets: ["EnsignCatalog"]),
    ],
    targets: [
        .target(
            name: "EnsignCore"
        ),
        .target(
            name: "EnsignRender",
            dependencies: ["EnsignCore"],
            resources: [
                // Liberation Sans (SIL OFL), shaping the info field
                // text; see Fonts/LICENSE and NOTICE.
                .copy("Fonts"),
            ]
        ),
        .target(
            name: "EnsignUI",
            dependencies: ["EnsignRender"]
        ),
        .executableTarget(
            name: "EnsignCatalog",
            dependencies: ["EnsignCore", "EnsignRender"]
        ),
        .testTarget(
            name: "EnsignCoreTests",
            dependencies: ["EnsignCore"]
        ),
        .testTarget(
            name: "EnsignRenderTests",
            dependencies: ["EnsignRender"],
            resources: [.copy("Snapshots")]
        ),
    ]
)
