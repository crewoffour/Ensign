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

// EnsignRender: the Core Graphics drawing engine.
//
// Session 2 delivers the compose-and-emit stages here: frame geometry
// for every FrameShape, affiliation fill, dashed status frames, the
// space bar overlay, and the palette that resolves ColorRole values
// (standard 2525 light, medium, and dark fill modes plus a custom
// palette hook). The canImport guard keeps this target an empty,
// harmless compile on Linux, where only EnsignCore is meaningful.

#if canImport(CoreGraphics)
import CoreGraphics
@_exported import EnsignCore
#endif
