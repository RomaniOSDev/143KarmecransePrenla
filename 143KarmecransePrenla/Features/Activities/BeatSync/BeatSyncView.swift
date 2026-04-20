import SwiftUI
import UIKit

struct BeatSyncView: View {
    @EnvironmentObject private var dataModel: DataModel
    @Environment(\.dismiss) private var dismiss

    private let level: Int
    private let difficulty: SessionDifficulty
    @StateObject private var viewModel: BeatSyncViewModel

    @State private var outcome: SessionOutcome?
    @State private var hasSubmitted = false

    init(level: Int, difficulty: SessionDifficulty) {
        self.level = level
        self.difficulty = difficulty
        _viewModel = StateObject(wrappedValue: BeatSyncViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ZStack {
            AppAmbientBackgroundFill()
            metronomePulseLayer
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Beat Sync")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Follow the bead. Tap when it kisses the bright markers along the lane.")
                        .bodyTextStyle()

                    phaseLabel

                    beatCanvas
                        .frame(height: 220)
                        .appSoftInsetPlate(cornerRadius: 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            lightImpact()
                            viewModel.handleTap()
                        }

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
            let sweep = dataModel.shouldShowDailySweepBanner(afterCompleting: .beatSync)
            let result = viewModel.buildOutcome(activity: .beatSync).withDailySweep(sweep)
            dataModel.recordSessionOutcome(
                levelId: ActivityKind.beatSync.levelId(level),
                stars: result.stars,
                goodHits: viewModel.goodHits,
                attempts: viewModel.registeredAttempts,
                melodyCorrect: 0,
                melodyTotal: 0,
                activityKind: .beatSync,
                level: level,
                historySummary: "\(result.accuracyText) · \(result.replicationText)"
            )
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                outcome = result
            }
        }
    }

    @ViewBuilder
    private var metronomePulseLayer: some View {
        if viewModel.phase == .running && dataModel.visualMetronomeEnabled {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
                let period = max(0.35, viewModel.beatIntervalSeconds)
                let t = timeline.date.timeIntervalSinceReferenceDate
                let phase = (t.truncatingRemainder(dividingBy: period)) / period
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    ZStack {
                        Circle()
                            .stroke(Color.appAccent.opacity(0.08 + 0.06 * sin(phase * .pi * 2)), lineWidth: 32)
                            .frame(width: side * 0.95, height: side * 0.95)
                            .scaleEffect(0.94 + 0.06 * sin(phase * .pi * 2))
                        Circle()
                            .stroke(Color.appPrimary.opacity(0.06 + 0.05 * sin(phase * .pi * 2 + 0.4)), lineWidth: 18)
                            .frame(width: side * 0.72, height: side * 0.72)
                            .scaleEffect(0.96 + 0.04 * sin(phase * .pi * 2 + 0.4))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var phaseLabel: some View {
        switch viewModel.phase {
        case .idle:
            Text("Ready when you are")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        case .countdown(let value):
            Text("Starting in \(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        case .running:
            Text("In motion · \(viewModel.goodHits)/\(viewModel.totalBeats) aligned taps")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        case .finished:
            Text("Hold steady…")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private var beatCanvas: some View {
        Canvas { context, size in
            let midY = size.height * 0.55
            var lane = Path()
            let samples = Int(size.width / 4)
            for index in 0...samples {
                let progress = CGFloat(index) / CGFloat(samples)
                let x = progress * size.width
                let angle = progress * .pi * 2 + CGFloat(viewModel.beatIndex) * 0.45 + CGFloat(viewModel.progressAlongBeat) * .pi
                let y = midY + sin(angle * 1.6) * 34
                if index == 0 {
                    lane.move(to: CGPoint(x: x, y: y))
                } else {
                    lane.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.stroke(lane, with: .color(Color.appAccent.opacity(0.85)), lineWidth: 3)

            for marker in 0..<5 {
                let x = CGFloat(marker + 1) / 6 * size.width
                let rect = CGRect(x: x - 3, y: midY - 46, width: 6, height: 92)
                let pulse = Path(roundedRect: rect, cornerRadius: 3)
                context.fill(pulse, with: .color(Color.appPrimary.opacity(0.35)))
            }

            let beadProgress = (CGFloat(viewModel.beatIndex) + CGFloat(viewModel.progressAlongBeat)) / CGFloat(max(1, viewModel.totalBeats))
            let beadX = min(size.width - 12, max(12, beadProgress * size.width))
            let angle = beadProgress * .pi * 2 + CGFloat(viewModel.beatIndex) * 0.45
            let beadY = midY + sin(angle * 1.6) * 34
            let beadRect = CGRect(x: beadX - 12, y: beadY - 12, width: 24, height: 24)
            let bead = Path(ellipseIn: beadRect)
            context.fill(bead, with: .color(Color.appPrimary))
            context.stroke(bead, with: .color(Color.appAccent.opacity(0.9)), lineWidth: 2)
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
        case .countdown, .running:
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
