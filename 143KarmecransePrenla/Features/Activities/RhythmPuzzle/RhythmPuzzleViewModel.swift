import Combine
import Foundation

struct RhythmPiece: Identifiable, Equatable {
    let id: UUID
    let label: String
    let slotIndex: Int
}

@MainActor
final class RhythmPuzzleViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case playing
        case finished
    }

    @Published private(set) var phase: Phase = .idle
    @Published var pieces: [RhythmPiece] = []
    @Published private(set) var secondsRemaining: TimeInterval = 0
    @Published private(set) var moves: Int = 0
    @Published private(set) var message: String = "Drag tiles until the lane reads top to bottom."

    private let difficulty: SessionDifficulty
    private let level: Int
    private var timeLimit: TimeInterval
    private var solutionOrder: [UUID] = []
    private var timerCancellable: AnyCancellable?

    init(difficulty: SessionDifficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
        self.timeLimit = difficulty.puzzleTimeLimit + Double(level) * 4
    }

    func start() {
        timerCancellable?.cancel()
        moves = 0
        let count = min(10, difficulty.puzzlePieceCount + (level + 1) / 2)
        let labels = ["Kick", "Snare", "Hi-hat", "Tom", "Ride", "Open", "Ghost", "Fill", "Break", "Lift"]
        let slice = labels.prefix(count)
        let base = slice.enumerated().map { pair in
            RhythmPiece(id: UUID(), label: String(pair.element), slotIndex: pair.offset)
        }
        pieces = base.shuffled()
        solutionOrder = base.map(\.id)
        secondsRemaining = timeLimit
        phase = .playing
        message = "You have enough time—focus on clean swaps."
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.tick()
                }
            }
    }

    func stopTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard phase == .playing else { return }
        secondsRemaining = max(0, secondsRemaining - 1)
        if secondsRemaining <= 0 {
            finish()
        }
    }

    func movePiece(fromOffsets: IndexSet, toOffset: Int) {
        guard phase == .playing else { return }
        guard let from = fromOffsets.first else { return }
        var updated = pieces
        let element = updated.remove(at: from)
        var destination = toOffset
        if from < destination {
            destination -= 1
        }
        destination = max(0, min(updated.count, destination))
        updated.insert(element, at: destination)
        pieces = updated
        moves += 1
        if updated.map(\.id) == solutionOrder {
            finish()
        }
    }

    func finish() {
        timerCancellable?.cancel()
        timerCancellable = nil
        phase = .finished
    }

    var isCorrectOrder: Bool {
        pieces.map(\.id) == solutionOrder
    }

    var orderAccuracy: Double {
        guard !solutionOrder.isEmpty else { return 0 }
        let current = pieces.map(\.id)
        var matches = 0
        for index in current.indices where index < solutionOrder.count && current[index] == solutionOrder[index] {
            matches += 1
        }
        return Double(matches) / Double(solutionOrder.count)
    }

    var timeFactor: Double {
        let used = timeLimit - secondsRemaining
        let ratio = max(0, min(1, 1 - used / max(1, timeLimit)))
        return 0.5 + 0.5 * ratio
    }

    static func stars(isCorrect: Bool, orderAccuracy: Double, timeFactor: Double) -> Int {
        guard isCorrect else {
            if orderAccuracy >= 0.85 { return 1 }
            return 0
        }
        let blended = orderAccuracy * 0.55 + timeFactor * 0.45
        if blended >= 0.92 { return 3 }
        if blended >= 0.78 { return 2 }
        return 1
    }

    func buildOutcome(activity: ActivityKind) -> SessionOutcome {
        let stars = Self.stars(isCorrect: isCorrectOrder, orderAccuracy: orderAccuracy, timeFactor: timeFactor)
        let accuracyText = String(format: "Lane order: %.0f%%", orderAccuracy * 100)
        let replicationText = "Moves used: \(moves) · Time left: \(Int(secondsRemaining))s"
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
