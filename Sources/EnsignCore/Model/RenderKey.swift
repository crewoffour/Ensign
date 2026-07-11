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

/// The render key format namespace.
public enum RenderKey {
    /// The current render key format version. Bumped whenever a
    /// rendering change makes previously cached images stale for the
    /// same key; equal keys under equal versions render identically.
    /// Stability policy: patch releases never bump this; minor
    /// releases may, and the CHANGELOG says so when they do.
    public static let version = "ensign5"
}

extension MilSymbol {
    /// A canonical string identifying what this symbol renders as.
    ///
    /// Two symbols with the same render key produce identical geometry
    /// under any given palette, even when their SIDCs differ (a
    /// 20-digit code and its 30-digit equivalent, or two entity
    /// subtypes sharing an icon). This makes the key the right cache
    /// and image-registry name for runtime rendering: map clients can
    /// register one image per key with their rendering engine and
    /// share it across every track that resolves to it.
    ///
    /// The key covers everything the composer currently draws: icon
    /// identity, frame base, fill class, dash treatment, framing, the
    /// space and activity overlays, and the frame amplifiers (HQ/task
    /// force/feint-dummy flags, echelon, mobility). It is deliberately versioned
    /// (RenderKey.version, "ensign5" since sector modifier icons
    /// joined the rendering)
    /// because new rendered features will extend it; do not persist render keys across app versions
    /// before Ensign 1.0.
    public var renderKey: String {
        let descriptor = frame
        var parts = [
            RenderKey.version,
            iconKey.family.rawValue,
            iconKey.code,
            String(describing: affiliation.frameBase),
            String(describing: fillClass),
        ]
        if !descriptor.isFramed {
            parts.append("unframed")
        } else {
            switch descriptor.dash {
            case .uncertainIdentity: parts.append("dash-identity")
            case .anticipatedStatus: parts.append("dash-status")
            case nil: break
            }
            if descriptor.hasSpaceModifier { parts.append("space") }
            if descriptor.hasActivityModifier { parts.append("activity") }
            let hqtfd = headquartersTaskForceDummy
            if hqtfd.contains(.headquarters) { parts.append("hq") }
            if hqtfd.contains(.taskForce) { parts.append("tf") }
            if hqtfd.contains(.feintDummy) { parts.append("fd") }
            if let echelon { parts.append("e-\(String(describing: echelon))") }
            if let mobility { parts.append("m-\(String(describing: mobility))") }
            if isSimulation {
                parts.append("sim")
            } else if isExercise {
                parts.append("ex")
            }
            if leadership != nil { parts.append("lead") }
        }
        switch status {
        case .presentFullyCapable: parts.append("c-fc")
        case .presentDamaged: parts.append("c-dmg")
        case .presentDestroyed: parts.append("c-dst")
        case .presentFullToCapacity: parts.append("c-ftc")
        case .present, .anticipated: break
        }
        if !isFilled { parts.append("nofill") }
        if case .delta(let value) = sidc {
            if value.sectorOneModifier != "00" { parts.append("m1-\(value.sectorOneModifier)") }
            if value.sectorTwoModifier != "00" { parts.append("m2-\(value.sectorTwoModifier)") }
        }
        return parts.joined(separator: ":")
    }
}
