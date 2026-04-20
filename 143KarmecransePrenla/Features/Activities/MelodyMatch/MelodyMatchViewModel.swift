import Combine
import Foundation

@MainActor
final class MelodyMatchViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case demonstrating
        case userTurn
        case finished
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var highlightIndex: Int?
    @Published private(set) var targetSequence: [Int] = []
    @Published private(set) var userSequence: [Int] = []
    @Published private(set) var wrongSteps: Int = 0
    @Published private(set) var elapsedUserPhase: TimeInterval = 0
    @Published private(set) var message: String = "Watch the lane, then repeat the pattern."

    private let difficulty: SessionDifficulty
    private let level: Int
    private var demoTimer: AnyCancellable?
    private var userTimer: AnyCancellable?
    private var demoStep: Int = 0
    private var userPhaseStart: Date?

    init(difficulty: SessionDifficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
    }

    func start() {
        cancelTimers()
        userSequence = []
        wrongSteps = 0
        elapsedUserPhase = 0
        let base = difficulty.melodyBaseLength
        let length = min(12, base + level / 2)
        targetSequence = (0..<length).map { _ in Int.random(in: 0..<8) }
        phase = .demonstrating
        demoStep = 0
        runDemonstration()
    }

    func stopTimers() {
        cancelTimers()
    }

    private func cancelTimers() {
        demoTimer?.cancel()
        demoTimer = nil
        userTimer?.cancel()
        userTimer = nil
    }

    private func runDemonstration() {
        let step = difficulty.melodyPlaybackStep
        demoTimer = Timer.publish(every: step, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard phase == .demonstrating else { return }
                if demoStep < targetSequence.count {
                    highlightIndex = targetSequence[demoStep]
                    demoStep += 1
                } else {
                    highlightIndex = nil
                    beginUserPhase()
                }
            }
    }

    private func beginUserPhase() {
        cancelTimers()
        phase = .userTurn
        userPhaseStart = Date()
        userTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self, let start = userPhaseStart else { return }
                elapsedUserPhase = now.timeIntervalSince(start)
            }
    }

    func registerTap(note: Int) {
        guard phase == .userTurn else { return }
        let nextIndex = userSequence.count
        guard nextIndex < targetSequence.count else { return }
        userSequence.append(note)
        if note == targetSequence[nextIndex] {
            message = "Nice—stay ahead of the next tone."
        } else {
            wrongSteps += 1
            message = "Almost—listen for the contour again."
        }
        if userSequence.count == targetSequence.count {
            finish()
        }
    }

    func registerSlide(from: Int, to: Int) {
        guard phase == .userTurn else { return }
        if from == to {
            registerTap(note: from)
            return
        }
        registerTap(note: to)
    }

    private func finish() {
        cancelTimers()
        phase = .finished
    }

    var matchedSteps: Int {
        zip(userSequence, targetSequence).filter { $0 == $1 }.count
    }

    var sequenceAccuracy: Double {
        let total = max(1, targetSequence.count)
        return Double(matchedSteps) / Double(total)
    }

    var speedScore: Double {
        let baseline: TimeInterval
        switch difficulty {
        case .easy: baseline = 18
        case .medium: baseline = 14
        case .hard: baseline = 11
        }
        let bonus = max(0, baseline - elapsedUserPhase) / baseline
        return min(1, 0.55 + bonus * 0.45)
    }

    static func stars(sequenceAccuracy: Double, speedFactor: Double) -> Int {
        let blended = sequenceAccuracy * 0.72 + speedFactor * 0.28
        if blended >= 0.9 { return 3 }
        if blended >= 0.74 { return 2 }
        if blended >= 0.5 { return 1 }
        return 0
    }

    func patternDescription() -> String {
        targetSequence.map { String($0 + 1) }.joined(separator: " → ")
    }

    func buildOutcome(activity: ActivityKind) -> SessionOutcome {
        let stars = Self.stars(sequenceAccuracy: sequenceAccuracy, speedFactor: speedScore)
        let accuracyText = String(format: "Pattern accuracy: %.0f%%", sequenceAccuracy * 100)
        let replicationText = String(format: "Replay pace: %.1fs", elapsedUserPhase)
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
