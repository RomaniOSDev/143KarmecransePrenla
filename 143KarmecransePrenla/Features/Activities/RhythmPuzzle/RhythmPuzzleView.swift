import SwiftUI
import UIKit

struct RhythmPuzzleView: View {
    @EnvironmentObject private var dataModel: DataModel
    @Environment(\.dismiss) private var dismiss

    private let level: Int
    private let difficulty: SessionDifficulty
    @StateObject private var viewModel: RhythmPuzzleViewModel

    @State private var outcome: SessionOutcome?
    @State private var hasSubmitted = false

    init(level: Int, difficulty: SessionDifficulty) {
        self.level = level
        self.difficulty = difficulty
        _viewModel = StateObject(wrappedValue: RhythmPuzzleViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ZStack {
            AppAmbientBackgroundFill()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Rhythm Puzzle")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Reorder the tiles until the kit reads naturally from top to bottom. The lane locks when every piece is in place.")
                        .bodyTextStyle()

                    statusText

                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appSurface.opacity(0.72),
                                        Color.appSurface.opacity(0.42),
                                        Color.appBackground.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 10)

                        Canvas { context, size in
                            let stepY = size.height / CGFloat(max(2, viewModel.pieces.count))
                            for index in 0..<viewModel.pieces.count {
                                let y = CGFloat(index) * stepY + stepY * 0.5
                                var path = Path()
                                path.move(to: CGPoint(x: 16, y: y))
                                path.addLine(to: CGPoint(x: size.width - 16, y: y))
                                context.stroke(path, with: .color(Color.appAccent.opacity(0.25)), lineWidth: 1)
                            }
                        }
                        .allowsHitTesting(false)

                        puzzleList
                    }
                    .frame(minHeight: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                    )

                    Text(viewModel.message)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)

                    controls
                }
                .screenPadding()
            }

            if let outcome {
                SessionResultView(
                    outcome: outcome,
                    canSaveMelody: false,
                    melodyPatternSummary: "",
                    onNext: {
                        self.outcome = nil
                        dismiss()
                    },
                    onRetry: {
                        self.outcome = nil
                        hasSubmitted = false
                        viewModel.start()
                    },
                    onProgress: {},
                    onSaveMelody: nil
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopTimers()
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            guard newPhase == .finished else { return }
            guard hasSubmitted == false else { return }
            hasSubmitted = true
            let sweep = dataModel.shouldShowDailySweepBanner(afterCompleting: .rhythmPuzzle)
            let result = viewModel.buildOutcome(activity: .rhythmPuzzle).withDailySweep(sweep)
            let goodHits = viewModel.isCorrectOrder ? viewModel.pieces.count : Int(viewModel.orderAccuracy * 100)
            dataModel.recordSessionOutcome(
                levelId: ActivityKind.rhythmPuzzle.levelId(level),
                stars: result.stars,
                goodHits: goodHits,
                attempts: viewModel.moves,
                melodyCorrect: 0,
                melodyTotal: 0,
                activityKind: .rhythmPuzzle,
                level: level,
                historySummary: "\(result.accuracyText) · \(result.replicationText)"
            )
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                outcome = result
            }
        }
    }

    private var puzzleList: some View {
        List {
            ForEach(viewModel.pieces) { piece in
                HStack {
                    Text(piece.label)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(minHeight: dataModel.largeTapTargetsEnabled ? 56 : 44)
                .listRowBackground(Color.appSurface.opacity(0.35))
            }
            .onMove { indices, newOffset in
                lightImpact()
                viewModel.movePiece(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.phase {
        case .idle:
            Text("Ready when you are")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        case .playing:
            HStack {
                Text("Time left: \(Int(viewModel.secondsRemaining))s")
                Spacer()
                Text("Moves: \(viewModel.moves)")
            }
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        case .finished:
            Text("Lane evaluated")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch viewModel.phase {
        case .idle:
            Button {
                lightImpact()
                viewModel.start()
            } label: {
                Text("Begin session")
            }
            .buttonStyle(PrimaryProminentButton())
            .frame(minHeight: dataModel.largeTapTargetsEnabled ? 56 : 44)
        case .playing:
            VStack(spacing: 12) {
                Button {
                    lightImpact()
                    viewModel.finish()
                } label: {
                    Text("Lock lane early")
                }
                .buttonStyle(PrimaryProminentButton())
                .frame(minHeight: dataModel.largeTapTargetsEnabled ? 56 : 44)

                Button(role: .cancel) {
                    viewModel.stopTimers()
                    dismiss()
                } label: {
                    Text("Leave session")
                }
                .buttonStyle(SecondarySurfaceButton())
                .frame(minHeight: dataModel.largeTapTargetsEnabled ? 56 : 44)
            }
        case .finished:
            EmptyView()
        }
    }

    private func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
