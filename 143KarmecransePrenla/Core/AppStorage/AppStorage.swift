import Combine
import Foundation

@MainActor
final class DataModel: ObservableObject {
    static let resetNotification = Notification.Name("DataModelResetNotification")
    private static let historyLimit = 100

    private enum Keys {
        static let hasSeenOnboarding = "rhythm_hasSeenOnboarding"
        static let completedChallenges = "rhythm_completedChallenges"
        static let starRatings = "rhythm_starRatings"
        static let savedRhythms = "rhythm_savedRhythms"
        static let totalSessions = "rhythm_totalSessions"
        static let totalGoodHits = "rhythm_totalGoodHits"
        static let totalAttempts = "rhythm_totalAttempts"
        static let melodyCorrectSteps = "rhythm_melodyCorrectSteps"
        static let melodyTotalSteps = "rhythm_melodyTotalSteps"
        static let lastDailyDate = "rhythm_lastDailyDate"
        static let todayActivityBits = "rhythm_todayActivityBits"
        static let sessionHistory = "rhythm_sessionHistory"
        static let weekKey = "rhythm_weekKey"
        static let weekBeatSync = "rhythm_weekBeatSync"
        static let weekMelody = "rhythm_weekMelody"
        static let weekPuzzle = "rhythm_weekPuzzle"
        static let visualMetronome = "rhythm_visualMetronome"
        static let largeTapTargets = "rhythm_largeTapTargets"
    }

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var completedChallenges: Set<String>
    @Published private(set) var starRatings: [String: Int]
    @Published private(set) var savedRhythms: [SavedRhythm]
    @Published private(set) var totalSessionsCompleted: Int
    @Published private(set) var totalGoodHits: Int
    @Published private(set) var totalTapAttempts: Int
    @Published private(set) var melodyCorrectSteps: Int
    @Published private(set) var melodyTotalSteps: Int
    @Published private(set) var sessionHistory: [SessionHistoryEntry]
    @Published private(set) var visualMetronomeEnabled: Bool
    @Published private(set) var largeTapTargetsEnabled: Bool

    private var lastDailyDateString: String
    private var todayActivityMask: Int
    private var currentWeekKey: String
    private var weeklyBeatSync: Int
    private var weeklyMelody: Int
    private var weeklyPuzzle: Int

    private let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        self.hasSeenOnboarding = userDefaults.bool(forKey: Keys.hasSeenOnboarding)
        if let data = userDefaults.data(forKey: Keys.completedChallenges),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            self.completedChallenges = Set(decoded)
        } else {
            self.completedChallenges = []
        }
        if let data = userDefaults.data(forKey: Keys.starRatings),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.starRatings = decoded
        } else {
            self.starRatings = [:]
        }
        if let data = userDefaults.data(forKey: Keys.savedRhythms),
           let decoded = try? JSONDecoder().decode([SavedRhythm].self, from: data) {
            self.savedRhythms = decoded
        } else {
            self.savedRhythms = []
        }
        if let data = userDefaults.data(forKey: Keys.sessionHistory),
           let decoded = try? JSONDecoder().decode([SessionHistoryEntry].self, from: data) {
            self.sessionHistory = decoded
        } else {
            self.sessionHistory = []
        }
        self.totalSessionsCompleted = userDefaults.integer(forKey: Keys.totalSessions)
        self.totalGoodHits = userDefaults.integer(forKey: Keys.totalGoodHits)
        self.totalTapAttempts = userDefaults.integer(forKey: Keys.totalAttempts)
        self.melodyCorrectSteps = userDefaults.integer(forKey: Keys.melodyCorrectSteps)
        self.melodyTotalSteps = userDefaults.integer(forKey: Keys.melodyTotalSteps)
        self.lastDailyDateString = userDefaults.string(forKey: Keys.lastDailyDate) ?? ""
        self.todayActivityMask = userDefaults.integer(forKey: Keys.todayActivityBits)
        self.visualMetronomeEnabled = userDefaults.bool(forKey: Keys.visualMetronome)
        self.largeTapTargetsEnabled = userDefaults.bool(forKey: Keys.largeTapTargets)

        let liveWeek = Self.isoWeekKey(for: Date())
        let storedWeek = userDefaults.string(forKey: Keys.weekKey) ?? liveWeek
        if storedWeek != liveWeek {
            self.currentWeekKey = liveWeek
            self.weeklyBeatSync = 0
            self.weeklyMelody = 0
            self.weeklyPuzzle = 0
            userDefaults.set(liveWeek, forKey: Keys.weekKey)
            userDefaults.set(0, forKey: Keys.weekBeatSync)
            userDefaults.set(0, forKey: Keys.weekMelody)
            userDefaults.set(0, forKey: Keys.weekPuzzle)
        } else {
            self.currentWeekKey = liveWeek
            self.weeklyBeatSync = userDefaults.integer(forKey: Keys.weekBeatSync)
            self.weeklyMelody = userDefaults.integer(forKey: Keys.weekMelody)
            self.weeklyPuzzle = userDefaults.integer(forKey: Keys.weekPuzzle)
        }
        normalizeDailyWindowIfNeeded()
    }

    var dailyAchievementsSummary: String {
        let count = todayCompletedActivityCount()
        return "Today: \(count)/\(ActivityKind.allCases.count) focus sessions"
    }

    var overallAccuracyDescription: String {
        guard totalTapAttempts > 0 else { return "No tap data yet" }
        let ratio = Double(totalGoodHits) / Double(totalTapAttempts)
        return String(format: "Tap precision: %.0f%%", ratio * 100)
    }

    var melodyReplicationDescription: String {
        guard melodyTotalSteps > 0 else { return "No sequence data yet" }
        let ratio = Double(melodyCorrectSteps) / Double(melodyTotalSteps)
        return String(format: "Sequence match: %.0f%%", ratio * 100)
    }

    var milestoneAllDailyComplete: Bool {
        todayCompletedActivityCount() >= ActivityKind.allCases.count
    }

    var savedRhythmsSortedForLibrary: [SavedRhythm] {
        savedRhythms.sorted { a, b in
            if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
            return a.createdAt > b.createdAt
        }
    }

    var weeklyTargetsTotal: Int { ActivityProgress.weeklySessionsPerActivityGoal * 3 }

    var weeklyProgressSum: Int {
        weeklyBeatSync + weeklyMelody + weeklyPuzzle
    }

    func weeklyCount(for activity: ActivityKind) -> Int {
        switch activity {
        case .beatSync: return weeklyBeatSync
        case .melodyMatch: return weeklyMelody
        case .rhythmPuzzle: return weeklyPuzzle
        }
    }

    func setVisualMetronomeEnabled(_ value: Bool) {
        visualMetronomeEnabled = value
        defaults.set(value, forKey: Keys.visualMetronome)
        objectWillChange.send()
    }

    func setLargeTapTargetsEnabled(_ value: Bool) {
        largeTapTargetsEnabled = value
        defaults.set(value, forKey: Keys.largeTapTargets)
        objectWillChange.send()
    }

    func isActivityDoneToday(_ activity: ActivityKind) -> Bool {
        normalizeDailyWindowIfNeeded()
        guard let index = ActivityKind.allCases.firstIndex(of: activity) else { return false }
        return (todayActivityMask >> index) & 1 == 1
    }

    func suggestedPracticeLevel(for activity: ActivityKind) -> Int {
        for level in 1...ActivityProgress.levelCount {
            guard isLevelUnlocked(activity: activity, level: level) else { continue }
            let id = activity.levelId(level)
            let stars = stars(for: id)
            let done = completedChallenges.contains(id)
            if done == false || stars < 3 {
                return level
            }
        }
        return ActivityProgress.levelCount
    }

    func stars(for levelId: String) -> Int {
        starRatings[levelId] ?? 0
    }

    func isLevelUnlocked(activity: ActivityKind, level: Int) -> Bool {
        if level <= 1 { return true }
        let previous = activity.levelId(level - 1)
        return completedChallenges.contains(previous)
    }

    func bestStars(for activity: ActivityKind, level: Int) -> Int {
        stars(for: activity.levelId(level))
    }

    func levelPassesDiscoverFilter(
        activity: ActivityKind,
        level: Int,
        filter: DiscoverChallengeFilter
    ) -> Bool {
        let id = activity.levelId(level)
        let stars = stars(for: id)
        let completed = completedChallenges.contains(id)
        switch filter {
        case .all:
            return true
        case .incomplete:
            return stars < 3 || completed == false
        case .threeStars:
            return stars >= 3
        case .beatSync:
            return activity == .beatSync
        case .melodyMatch:
            return activity == .melodyMatch
        case .rhythmPuzzle:
            return activity == .rhythmPuzzle
        }
    }

    func markOnboardingFinished() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        objectWillChange.send()
    }

    func recordSessionOutcome(
        levelId: String,
        stars: Int,
        goodHits: Int,
        attempts: Int,
        melodyCorrect: Int,
        melodyTotal: Int,
        activityKind: ActivityKind,
        level: Int,
        historySummary: String
    ) {
        if stars >= 1 {
            completedChallenges.insert(levelId)
        }
        let previous = starRatings[levelId] ?? 0
        if stars > 0 {
            starRatings[levelId] = max(previous, stars)
        }

        totalSessionsCompleted += 1
        totalGoodHits += goodHits
        totalTapAttempts += attempts
        melodyCorrectSteps += melodyCorrect
        melodyTotalSteps += melodyTotal

        normalizeDailyWindowIfNeeded()
        updateTodayMask(for: activityKind)
        rollWeeklyIfNeeded()
        incrementWeekly(for: activityKind)
        appendHistory(activity: activityKind, level: level, stars: stars, summary: historySummary)

        persistChallenges()
        persistStars()
        persistHistory()
        persistWeekly()
        defaults.set(totalSessionsCompleted, forKey: Keys.totalSessions)
        defaults.set(totalGoodHits, forKey: Keys.totalGoodHits)
        defaults.set(totalTapAttempts, forKey: Keys.totalAttempts)
        defaults.set(melodyCorrectSteps, forKey: Keys.melodyCorrectSteps)
        defaults.set(melodyTotalSteps, forKey: Keys.melodyTotalSteps)
        defaults.set(lastDailyDateString, forKey: Keys.lastDailyDate)
        defaults.set(todayActivityMask, forKey: Keys.todayActivityBits)
        objectWillChange.send()
    }

    func saveRhythm(title: String, patternDescription: String, note: String = "") {
        let item = SavedRhythm(
            id: UUID().uuidString,
            title: title,
            patternDescription: patternDescription,
            createdAt: Date(),
            isFavorite: false,
            note: note
        )
        savedRhythms.insert(item, at: 0)
        persistSavedRhythms()
        objectWillChange.send()
    }

    func deleteRhythm(id: String) {
        savedRhythms.removeAll { $0.id == id }
        persistSavedRhythms()
        objectWillChange.send()
    }

    func toggleFavoriteRhythm(id: String) {
        guard let index = savedRhythms.firstIndex(where: { $0.id == id }) else { return }
        savedRhythms[index].isFavorite.toggle()
        persistSavedRhythms()
        objectWillChange.send()
    }

    func updateRhythm(id: String, title: String, note: String) {
        guard let index = savedRhythms.firstIndex(where: { $0.id == id }) else { return }
        savedRhythms[index].title = title
        savedRhythms[index].note = note
        persistSavedRhythms()
        objectWillChange.send()
    }

    func duplicateRhythm(id: String) {
        guard let item = savedRhythms.first(where: { $0.id == id }) else { return }
        let copy = SavedRhythm(
            id: UUID().uuidString,
            title: item.title + " (copy)",
            patternDescription: item.patternDescription,
            createdAt: Date(),
            isFavorite: false,
            note: item.note
        )
        savedRhythms.insert(copy, at: 0)
        persistSavedRhythms()
        objectWillChange.send()
    }

    func resetAllProgress() {
        hasSeenOnboarding = false
        completedChallenges = []
        starRatings = [:]
        savedRhythms = []
        totalSessionsCompleted = 0
        totalGoodHits = 0
        totalTapAttempts = 0
        melodyCorrectSteps = 0
        melodyTotalSteps = 0
        lastDailyDateString = ""
        todayActivityMask = 0
        sessionHistory = []
        weeklyBeatSync = 0
        weeklyMelody = 0
        weeklyPuzzle = 0
        visualMetronomeEnabled = false
        largeTapTargetsEnabled = false

        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.completedChallenges)
        defaults.removeObject(forKey: Keys.starRatings)
        defaults.removeObject(forKey: Keys.savedRhythms)
        defaults.removeObject(forKey: Keys.totalSessions)
        defaults.removeObject(forKey: Keys.totalGoodHits)
        defaults.removeObject(forKey: Keys.totalAttempts)
        defaults.removeObject(forKey: Keys.melodyCorrectSteps)
        defaults.removeObject(forKey: Keys.melodyTotalSteps)
        defaults.removeObject(forKey: Keys.lastDailyDate)
        defaults.removeObject(forKey: Keys.todayActivityBits)
        defaults.removeObject(forKey: Keys.sessionHistory)
        defaults.removeObject(forKey: Keys.weekKey)
        defaults.removeObject(forKey: Keys.weekBeatSync)
        defaults.removeObject(forKey: Keys.weekMelody)
        defaults.removeObject(forKey: Keys.weekPuzzle)
        defaults.removeObject(forKey: Keys.visualMetronome)
        defaults.removeObject(forKey: Keys.largeTapTargets)

        NotificationCenter.default.post(name: Self.resetNotification, object: nil)
        objectWillChange.send()
    }

    func shouldShowDailySweepBanner(afterCompleting activity: ActivityKind) -> Bool {
        normalizeDailyWindowIfNeeded()
        updateTodayMask(for: activity)
        return todayCompletedActivityCount() >= ActivityKind.allCases.count
    }

    private func appendHistory(activity: ActivityKind, level: Int, stars: Int, summary: String) {
        let entry = SessionHistoryEntry(
            id: UUID().uuidString,
            finishedAt: Date(),
            activity: activity,
            level: level,
            stars: stars,
            summary: summary
        )
        var next = [entry] + sessionHistory
        if next.count > Self.historyLimit {
            next = Array(next.prefix(Self.historyLimit))
        }
        sessionHistory = next
    }

    private func rollWeeklyIfNeeded() {
        let live = Self.isoWeekKey(for: Date())
        if live != currentWeekKey {
            currentWeekKey = live
            weeklyBeatSync = 0
            weeklyMelody = 0
            weeklyPuzzle = 0
            defaults.set(live, forKey: Keys.weekKey)
            defaults.set(0, forKey: Keys.weekBeatSync)
            defaults.set(0, forKey: Keys.weekMelody)
            defaults.set(0, forKey: Keys.weekPuzzle)
        }
    }

    private func incrementWeekly(for activity: ActivityKind) {
        rollWeeklyIfNeeded()
        switch activity {
        case .beatSync:
            weeklyBeatSync += 1
        case .melodyMatch:
            weeklyMelody += 1
        case .rhythmPuzzle:
            weeklyPuzzle += 1
        }
    }

    private func todayCompletedActivityCount() -> Int {
        var count = 0
        for (index, _) in ActivityKind.allCases.enumerated() {
            if (todayActivityMask >> index) & 1 == 1 {
                count += 1
            }
        }
        return count
    }

    private func normalizeDailyWindowIfNeeded() {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        if lastDailyDateString != today {
            lastDailyDateString = today
            todayActivityMask = 0
            defaults.set(lastDailyDateString, forKey: Keys.lastDailyDate)
            defaults.set(todayActivityMask, forKey: Keys.todayActivityBits)
        }
    }

    private func updateTodayMask(for activity: ActivityKind) {
        normalizeDailyWindowIfNeeded()
        guard let index = ActivityKind.allCases.firstIndex(of: activity) else { return }
        todayActivityMask |= (1 << index)
        defaults.set(todayActivityMask, forKey: Keys.todayActivityBits)
    }

    private func persistChallenges() {
        let array = Array(completedChallenges)
        if let data = try? JSONEncoder().encode(array) {
            defaults.set(data, forKey: Keys.completedChallenges)
        }
    }

    private func persistStars() {
        if let data = try? JSONEncoder().encode(starRatings) {
            defaults.set(data, forKey: Keys.starRatings)
        }
    }

    private func persistSavedRhythms() {
        if let data = try? JSONEncoder().encode(savedRhythms) {
            defaults.set(data, forKey: Keys.savedRhythms)
        }
    }

    private func persistHistory() {
        if let data = try? JSONEncoder().encode(sessionHistory) {
            defaults.set(data, forKey: Keys.sessionHistory)
        }
    }

    private func persistWeekly() {
        defaults.set(currentWeekKey, forKey: Keys.weekKey)
        defaults.set(weeklyBeatSync, forKey: Keys.weekBeatSync)
        defaults.set(weeklyMelody, forKey: Keys.weekMelody)
        defaults.set(weeklyPuzzle, forKey: Keys.weekPuzzle)
    }

    private static func isoWeekKey(for date: Date) -> String {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone.current
        let y = cal.component(.yearForWeekOfYear, from: date)
        let w = cal.component(.weekOfYear, from: date)
        return "\(y)-W\(w)"
    }
}
