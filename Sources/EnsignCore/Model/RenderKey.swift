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
    /// identity, frame base, fill class, dash treatment, framing, and
    /// the space and activity overlays. It is deliberately versioned
    /// ("ensign1") because new rendered features (echelons, HQ staffs)
    /// will extend it; do not persist render keys across app versions
    /// before Ensign 1.0.
    public var renderKey: String {
        let descriptor = frame
        var parts = [
            "ensign1",
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
        }
        return parts.joined(separator: ":")
    }
}
