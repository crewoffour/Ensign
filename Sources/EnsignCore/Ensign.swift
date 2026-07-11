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

/// Library-level constants for Ensign.
public enum Ensign {
    /// The library version. Follows semantic versioning; the public API
    /// stabilizes at 1.0.0.
    public static let version = "1.0.0"

    /// The nominal square canvas that all symbol geometry is authored
    /// against, in abstract units. The symbol anchor point sits at the
    /// canvas center, (100, 100).
    ///
    /// This matches the milsymbol convention deliberately: it makes the
    /// ported symbol definitions mechanical to consume and makes oracle
    /// comparison against milsymbol output a direct overlay. Treat this
    /// value as a one-way-door constant; changing it invalidates all
    /// authored geometry.
    public static let canvasSize: Double = 200
}
