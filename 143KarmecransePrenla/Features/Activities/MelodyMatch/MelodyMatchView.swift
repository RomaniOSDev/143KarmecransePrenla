import SwiftUI
import UIKit

struct MelodyMatchView: View {
    @EnvironmentObject private var dataModel: DataModel
    @Environment(\.dismiss) private var dismiss

    private let level: Int
    private let difficulty: SessionDifficulty
    @StateObject private var viewModel: MelodyMatchViewModel

    @State private var outcome: SessionOutcome?
    @State private var hasSubmitted = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    init(level: Int, difficulty: SessionDifficulty) {
        self.level = level
        self.difficulty = difficulty
        _viewModel = StateObject(wrappedValue: MelodyMatchViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ZStack {
            AppAmbientBackgroundFill()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Melody Match")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Listen to the lane, then rebuild it. Slide across neighboring cells to chain two tones.")
                        .bodyTextStyle()

                    statusText

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<8, id: \.self) { index in
                            noteCell(index: index)
                        }
                    }
                    .padding(.vertical, 6)

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
                    canSaveMelody: outcome.stars >= 2,
                    melodyPatternSummary: viewModel.patternDescription(),
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
                    onSaveMelody: { title in
                        dataModel.saveRhythm(title: title, patternDescription: viewModel.patternDescription())
                    }
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
            let sweep = dataModel.shouldShowDailySweepBanner(afterCompleting: .melodyMatch)
            let result = viewModel.buildOutcome(activity: .melodyMatch).withDailySweep(sweep)
            dataModel.recordSessionOutcome(
                levelId: ActivityKind.melodyMatch.levelId(level),
                stars: result.stars,
                goodHits: viewModel.matchedSteps,
                attempts: viewModel.userSequence.count,
                melodyCorrect: viewModel.matchedSteps,
                melodyTotal: viewModel.targetSequence.count,
                activityKind: .melodyMatch,
                level: level,
                historySummary: "\(result.accuracyText) · \(result.replicationText)"
            )
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                outcome = result
            }
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.phase {
        case .idle:
            Text("Ready when you are")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        case .demonstrating:
            Text("Demonstrating pattern…")
                .font(.headline)
                .foregroundStyle(Color.appAccent)
        case .userTurn:
            Text("Your turn · \(viewModel.userSequence.count)/\(viewModel.targetSequence.count) steps")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        case .finished:
            Text("Wrapping up…")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private func noteCell(index: Int) -> some View {
        let active = viewModel.highlightIndex == index
        let cellMin: CGFloat = dataModel.largeTapTargetsEnabled ? 60 : 50
        return Text("Note \(index + 1)")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: cellMin)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: active
                                ? [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.55)]
                                : [Color.appSurface.opacity(0.9), Color.appBackground.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(active ? 0.4 : 0.22), radius: active ? 12 : 6, x: 0, y: active ? 6 : 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.appAccent.opacity(active ? 0.9 : 0.25), lineWidth: active ? 2 : 1)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let distance = hypot(value.translation.width, value.translation.height)
                        if distance < 12 {
                            lightImpact()
                            viewModel.registerTap(note: index)
                        } else {
                            let horizontalSteps = Int(round(value.translation.width / 70))
                            let verticalSteps = Int(round(value.translation.height / 60))
                            var target = index + horizontalSteps + verticalSteps * 4
                            target = max(0, min(7, target))
                            lightImpact()
                            viewModel.registerSlide(from: index, to: target)
                        }
                    }
            )
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
        case .demonstrating, .userTurn:
            Button(role: .cancel) {
                viewModel.stopTimers()
                dismiss()
            } label: {
                Text("Leave session")
            }
            .buttonStyle(SecondarySurfaceButton())
            .frame(minHeight: dataModel.largeTapTargetsEnabled ? 56 : 44)
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
