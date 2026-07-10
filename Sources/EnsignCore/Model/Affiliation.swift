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

/// The four base frame families every affiliation renders onto.
public enum FrameBase: Hashable, Sendable, CaseIterable {
    case unknown
    case friend
    case neutral
    case hostile
}

/// The normalized affiliation, version-independent.
///
/// Both SIDC families resolve to this single set. Exercise is modeled as
/// an orthogonal flag on ``MilSymbol`` rather than baked into the
/// affiliation, matching the 2525D structure; the charlie exercise
/// identities map onto their base affiliation with the exercise flag set.
public enum Affiliation: Hashable, Sendable, CaseIterable {
    case pending
    case unknown
    case assumedFriend
    case friend
    case neutral
    case suspect
    case hostile
    /// A friendly track acting as suspect during an exercise. Renders on
    /// the friend frame shape with suspect colors and a "J" amplifier,
    /// per milsymbol's base-affiliation rule.
    case joker
    /// A friendly track acting as hostile during an exercise. Renders on
    /// the friend frame shape with hostile colors and a "K" amplifier,
    /// per milsymbol's base-affiliation rule.
    case faker

    /// The base frame family this affiliation renders onto.
    public var frameBase: FrameBase {
        switch self {
        case .pending, .unknown:
            return .unknown
        case .assumedFriend, .friend:
            return .friend
        case .neutral:
            return .neutral
        case .suspect, .hostile:
            return .hostile
        case .joker, .faker:
            // Joker and faker are friendly tracks playing a role: the
            // frame is the friend shape; the colors carry the threat.
            return .friend
        }
    }

    /// Whether the identity itself is uncertain (pending, assumed friend,
    /// suspect, joker), which renders as a dashed frame in 2525.
    public var isUncertain: Bool {
        switch self {
        case .pending, .assumedFriend, .suspect, .joker:
            return true
        default:
            return false
        }
    }

    /// Normalizes a charlie standard identity.
    public init(charlie identity: CharlieStandardIdentity) {
        switch identity {
        case .pending, .exercisePending:
            self = .pending
        case .unknown, .exerciseUnknown, .noneSpecified:
            self = .unknown
        case .assumedFriend, .exerciseAssumedFriend:
            self = .assumedFriend
        case .friend, .exerciseFriend:
            self = .friend
        case .neutral, .exerciseNeutral:
            self = .neutral
        case .suspect:
            self = .suspect
        case .hostile:
            self = .hostile
        case .joker:
            self = .joker
        case .faker:
            self = .faker
        }
    }

    /// Normalizes a delta standard identity in its context. Suspect and
    /// hostile combined with the exercise context become joker and faker
    /// respectively, per 2525D.
    public init(delta identity: DeltaStandardIdentity, context: DeltaContext) {
        switch (identity, context) {
        case (.suspect, .exercise):
            self = .joker
        case (.hostile, .exercise):
            self = .faker
        case (.pending, _):
            self = .pending
        case (.unknown, _):
            self = .unknown
        case (.assumedFriend, _):
            self = .assumedFriend
        case (.friend, _):
            self = .friend
        case (.neutral, _):
            self = .neutral
        case (.suspect, _):
            self = .suspect
        case (.hostile, _):
            self = .hostile
        }
    }
}
