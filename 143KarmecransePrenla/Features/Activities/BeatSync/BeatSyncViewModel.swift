import Combine
import Foundation

@MainActor
final class BeatSyncViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case countdown(Int)
        case running
        case finished
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var currentBPM: Double
    @Published private(set) var beatIndex: Int = 0
    @Published private(set) var progressAlongBeat: Double = 0
    @Published private(set) var goodHits: Int = 0
    @Published private(set) var registeredAttempts: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var message: String = "Wait for the pulse, then tap on each beat."

    private let difficulty: SessionDifficulty
    private let level: Int
    private var beatCount: Int
    private var sessionStart: Date?
    private var consumedBeats: Set<Int> = []
    private var cancellables: Set<AnyCancellable> = []

    private var beatInterval: TimeInterval {
        60.0 / currentBPM
    }

    /// Exposed for the optional on-screen pulse (no audio).
    var beatIntervalSeconds: Double {
        beatInterval
    }

    init(difficulty: SessionDifficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
        self.currentBPM = difficulty.beatSyncStartingBPM
        self.beatCount = min(28, 6 + level * 2)
    }

    func start() {
        cancelTimers()
        goodHits = 0
        registeredAttempts = 0
        streak = 0
        beatIndex = 0
        progressAlongBeat = 0
        consumedBeats = []
        sessionStart = nil
        phase = .countdown(3)
        runCountdown()
    }

    func stopTimers() {
        cancelTimers()
    }

    private func cancelTimers() {
        cancellables.removeAll()
    }

    private func runCountdown() {
        cancellables.removeAll()
        Timer.publish(every: 0.9, on: .main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                switch phase {
                case .countdown(let value):
                    if value <= 1 {
                        beginRunning()
                    } else {
                        phase = .countdown(value - 1)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func beginRunning() {
        cancellables.removeAll()
        phase = .running
        sessionStart = Date()
        startProgressTicker()
    }

    private func startProgressTicker() {
        Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self, let start = sessionStart else { return }
                guard case .running = phase else { return }
                let elapsed = now.timeIntervalSince(start)
                let interval = beatInterval
                let index = Int(floor(elapsed / interval))
                let local = (elapsed.truncatingRemainder(dividingBy: interval)) / interval
                beatIndex = index
                progressAlongBeat = min(1, max(0, local))
                if index >= beatCount {
                    finishSession()
                }
            }
            .store(in: &cancellables)
    }

    func handleTap(at date: Date = Date()) {
        guard case .running = phase, let start = sessionStart else { return }
        registeredAttempts += 1
        let elapsed = date.timeIntervalSince(start)
        let interval = beatInterval
        let nearest = Int((elapsed / interval).rounded())
        let candidates = [nearest - 1, nearest, nearest + 1].filter { $0 >= 0 && $0 < beatCount }
        let tolerance = interval * difficulty.beatSyncToleranceFactor
        var matched: Int?
        for candidate in candidates {
            if consumedBeats.contains(candidate) { continue }
            let expectedTime = Double(candidate) * interval
            if abs(elapsed - expectedTime) <= tolerance {
                matched = candidate
                break
            }
        }
        if let matched {
            consumedBeats.insert(matched)
            goodHits += 1
            streak += 1
            maybeIncreaseTempo()
            message = "Solid timing. Stay relaxed in the shoulders."
        } else {
            streak = 0
            message = "Listen for the lane—tap closer to the pulse."
        }
    }

    private func maybeIncreaseTempo() {
        guard streak > 0, streak % 3 == 0 else { return }
        let cap: Double
        switch difficulty {
        case .easy: cap = 108
        case .medium: cap = 124
        case .hard: cap = 138
        }
        if currentBPM + 2 <= cap {
            currentBPM += 2
            message = "Tempo lifts slightly—keep the pocket steady."
        }
    }

    private func finishSession() {
        cancelTimers()
        phase = .finished
    }

    var accuracyRatio: Double {
        guard beatCount > 0 else { return 0 }
        return Double(goodHits) / Double(beatCount)
    }

    var totalBeats: Int { beatCount }

    static func stars(for ratio: Double) -> Int {
        if ratio >= 0.9 { return 3 }
        if ratio >= 0.72 { return 2 }
        if ratio >= 0.45 { return 1 }
        return 0
    }

    func buildOutcome(activity: ActivityKind) -> SessionOutcome {
        let stars = Self.stars(for: accuracyRatio)
        let accuracyText = String(format: "Hit alignment: %.0f%%", accuracyRatio * 100)
        let replicationText = "Flow streak peaks at \(streak) clean taps."
        return SessionOutcome(
            activity: activity,
            level: level,
            difficulty: difficulty,
            stars: stars,
            accuracyText: accuracyText,
            replicationText: replicationText,
            showDailySweepBanner: false
        )
    }
}
