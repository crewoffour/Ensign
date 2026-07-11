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

/// The MIL-STD-2525 text amplifier fields drawn around a symbol.
///
/// Field names mirror milsymbol's option names one to one, which keeps
/// the oracle comparison direct and gives users of both libraries a
/// shared vocabulary. All fields are optional; an empty struct draws
/// nothing. Rendering is opt-in through the composer and renderer
/// overloads that accept fields: map clients that label through map
/// engine text layers never pay for any of this.
public struct InfoFields: Hashable, Sendable, Codable {
    public var quantity: String?
    public var reinforcedReduced: String?
    public var staffComments: String?
    public var additionalInformation: String?
    public var evaluationRating: String?
    public var combatEffectiveness: String?
    public var signatureEquipment: String?
    public var higherFormation: String?
    public var hostile: String?
    public var iffSif: String?
    public var uniqueDesignation: String?
    public var type: String?
    public var dtg: String?
    public var altitudeDepth: String?
    public var location: String?
    public var speed: String?
    public var specialHeadquarters: String?
    public var platformType: String?
    public var equipmentTeardownTime: String?
    public var commonIdentifier: String?
    public var headquartersElement: String?
    public var installationComposition: String?
    public var guardedUnit: String?
    public var specialDesignator: String?
    public var country: String?

    public init() {}

    /// True when no field carries text.
    public var isEmpty: Bool {
        [quantity, reinforcedReduced, staffComments, additionalInformation,
         evaluationRating, combatEffectiveness, signatureEquipment,
         higherFormation, hostile, iffSif, uniqueDesignation, type, dtg,
         altitudeDepth, location, speed, specialHeadquarters, platformType,
         equipmentTeardownTime, commonIdentifier, headquartersElement,
         installationComposition, guardedUnit, specialDesignator, country,
        ].allSatisfy { ($0 ?? "").isEmpty }
    }
}
