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
// SymbolRenderer turns composed SymbolGeometry into CGContext drawing,
// CGImage bitmaps, and PNG data, resolving semantic color roles through
// a SymbolPalette. The canImport guard keeps this target an empty,
// harmless compile on Linux, where only EnsignCore is meaningful.

#if canImport(CoreGraphics)
import CoreGraphics
@_exported import EnsignCore
#endif
