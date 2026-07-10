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

/// The mobility amplifiers (equipment movement type indicators, drawn
/// beneath the frame), decoded from amplifier digits 9-10.
///
/// The code table below is milsymbol 3.0.4's authoritative
/// echelonMobility mapping (getmetadata.js), adopted per the oracle
/// charter: 37 pack animals, 41 over snow, 42 sled, 51 barge, 52
/// amphibious, 61/62 towed arrays, and no codes 38-39. Whether this
/// matches the MIL-STD-2525D document tables verbatim is adjudicated
/// in the JMSML migration session; until then, oracle compatibility
/// defines correctness. Leadership codes 71/72 exist in the same
/// mapping and are deferred.
public enum Mobility: Hashable, Sendable, CaseIterable {
    case wheeledLimitedCrossCountry
    case wheeledCrossCountry
    case tracked
    case wheeledAndTracked
    case towed
    case rail
    case packAnimals
    case overSnow
    case sled
    case barge
    case amphibious
    case shortTowedArray
    case longTowedArray

    /// Decodes a 2525D amplifier pair (digits 9-10).
    public init?(deltaAmplifier: String) {
        switch deltaAmplifier {
        case "31": self = .wheeledLimitedCrossCountry
        case "32": self = .wheeledCrossCountry
        case "33": self = .tracked
        case "34": self = .wheeledAndTracked
        case "35": self = .towed
        case "36": self = .rail
        case "37": self = .packAnimals
        case "41": self = .overSnow
        case "42": self = .sled
        case "51": self = .barge
        case "52": self = .amphibious
        case "61": self = .shortTowedArray
        case "62": self = .longTowedArray
        default: return nil
        }
    }
}
