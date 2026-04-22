import Foundation
import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case play
    case library
    case discover

    var id: String { rawValue }

    var title: String {
        switch self {
        case .play: return "Play"
        case .library: return "Library"
        case .discover: return "Discover"
        }
    }

    var symbolName: String {
        switch self {
        case .play: return "play.circle.fill"
        case .library: return "books.vertical.fill"
        case .discover: return "sparkles"
        }
    }
}

enum ActivityKind: String, CaseIterable, Codable, Identifiable, Hashable {
    case beatSync
    case melodyMatch
    case rhythmPuzzle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beatSync: return "Beat Sync"
        case .melodyMatch: return "Melody Match"
        case .rhythmPuzzle: return "Rhythm Puzzle"
        }
    }

    var detail: String {
        switch self {
        case .beatSync:
            return "Tap in time with the moving pulse. Accuracy shapes your star rating."
        case .melodyMatch:
            return "Watch the pattern, then repeat it on the grid as quickly as you can."
        case .rhythmPuzzle:
            return "Slide pieces into the right order to rebuild the rhythm lane."
        }
    }

    var symbolName: String {
        switch self {
        case .beatSync: return "waveform.path.ecg"
        case .melodyMatch: return "square.grid.3x3.fill"
        case .rhythmPuzzle: return "rectangle.3.group.fill"
        }
    }

    func levelId(_ level: Int) -> String {
        "\(rawValue)_\(level)"
    }
}

/// Ordered levels per activity; unlocks chain from 1 to `levelCount`.
enum ActivityProgress {
    static let levelCount = 15
    static var maxStarsPerActivity: Int { levelCount * 3 }
    /// Weekly session count goal per activity kind (Beat / Melody / Puzzle).
    static let weeklySessionsPerActivityGoal = 3
}

enum SessionDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var beatSyncStartingBPM: Double {
        switch self {
        case .easy: return 84
        case .medium: return 96
        case .hard: return 108
        }
    }

    var beatSyncToleranceFactor: Double {
        switch self {
        case .easy: return 0.22
        case .medium: return 0.16
        case .hard: return 0.12
        }
    }

    var melodyBaseLength: Int {
        switch self {
        case .easy: return 4
        case .medium: return 5
        case .hard: return 6
        }
    }

    var melodyPlaybackStep: TimeInterval {
        switch self {
        case .easy: return 0.55
        case .medium: return 0.45
        case .hard: return 0.38
        }
    }

    var puzzlePieceCount: Int {
        switch self {
        case .easy: return 4
        case .medium: return 5
        case .hard: return 6
        }
    }

    var puzzleTimeLimit: TimeInterval {
        switch self {
        case .easy: return 90
        case .medium: return 70
        case .hard: return 55
        }
    }
}

/// Themed labels for Discover (visual rhythm practice — not audio genres).
struct PracticeTheme: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
}

/// One shortcut row into a lane type under a theme (not a media playlist).
struct PracticeLaneSet: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let kind: ActivityKind
}

struct SavedRhythm: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var patternDescription: String
    var createdAt: Date
    var isFavorite: Bool
    var note: String

    init(
        id: String,
        title: String,
        patternDescription: String,
        createdAt: Date,
        isFavorite: Bool = false,
        note: String = ""
    ) {
        self.id = id
        self.title = title
        self.patternDescription = patternDescription
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case id, title, patternDescription, createdAt, isFavorite, note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        patternDescription = try c.decode(String.self, forKey: .patternDescription)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(patternDescription, forKey: .patternDescription)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(note, forKey: .note)
    }
}

struct SessionHistoryEntry: Identifiable, Codable, Hashable {
    var id: String
    var finishedAt: Date
    var activity: ActivityKind
    var level: Int
    var stars: Int
    var summary: String
}

enum DiscoverChallengeFilter: String, CaseIterable, Identifiable {
    case all
    case incomplete
    case threeStars
    case beatSync
    case melodyMatch
    case rhythmPuzzle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .incomplete: return "Open"
        case .threeStars: return "3 stars"
        case .beatSync: return "Beat Sync"
        case .melodyMatch: return "Melody"
        case .rhythmPuzzle: return "Puzzle"
        }
    }
}

enum PracticeCollection: String, CaseIterable, Identifiable {
    case warmUp
    case focus
    case challenge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warmUp: return "Warm-up"
        case .focus: return "Focus"
        case .challenge: return "Challenge"
        }
    }

    var subtitle: String {
        switch self {
        case .warmUp: return "Gentle lanes, early levels, easy tempo."
        case .focus: return "Mid levels for steady improvement."
        case .challenge: return "Late levels when you want pressure."
        }
    }

    var symbolName: String {
        switch self {
        case .warmUp: return "sun.horizon.fill"
        case .focus: return "scope"
        case .challenge: return "flame.fill"
        }
    }

    /// Suggested starting level for this collection (per activity).
    func suggestedLevel(for activity: ActivityKind) -> Int {
        switch self {
        case .warmUp:
            return 1
        case .focus:
            return 7
        case .challenge:
            return max(1, ActivityProgress.levelCount - 2)
        }
    }
}

struct SessionOutcome: Hashable {
    let activity: ActivityKind
    let level: Int
    let difficulty: SessionDifficulty
    let stars: Int
    let accuracyText: String
    let replicationText: String
    let showDailySweepBanner: Bool

    func withDailySweep(_ value: Bool) -> SessionOutcome {
        SessionOutcome(
            activity: activity,
            level: level,
            difficulty: difficulty,
            stars: stars,
            accuracyText: accuracyText,
            replicationText: replicationText,
            showDailySweepBanner: value
        )
    }
}

struct MainTabSelectionKey: EnvironmentKey {
    static var defaultValue: Binding<MainTab> = .constant(.play)
}

extension EnvironmentValues {
    var mainTabSelection: Binding<MainTab> {
        get { self[MainTabSelectionKey.self] }
        set { self[MainTabSelectionKey.self] = newValue }
    }
}
