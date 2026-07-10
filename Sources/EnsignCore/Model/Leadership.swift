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

/// The dismounted leadership amplifier, decoded from amplifier digits
/// 9-10 codes 71-72 per milsymbol's echelonMobility mapping.
///
/// milsymbol renders both as the same chevron, for friendly
/// affiliations only (its neutral/hostile/unknown variants and the
/// deputy's dash treatment are commented out in the source), and this
/// port matches that.
public enum Leadership: Hashable, Sendable, CaseIterable {
    case individual
    case deputyIndividual

    /// Decodes a 2525D amplifier pair (digits 9-10).
    public init?(deltaAmplifier: String) {
        switch deltaAmplifier {
        case "71": self = .individual
        case "72": self = .deputyIndividual
        default: return nil
        }
    }
}
