import SwiftUI

struct DifficultySelectionView: View {
    @EnvironmentObject private var dataModel: DataModel
    let kind: ActivityKind
    let level: Int

    private var rowMinHeight: CGFloat {
        dataModel.largeTapTargetsEnabled ? 58 : 48
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose difficulty")
                    .screenTitleStyle()
                Text("Easy widens timing windows, medium tightens sequences, hard asks for crisp focus end to end.")
                    .bodyTextStyle()

                VStack(spacing: 12) {
                    ForEach(SessionDifficulty.allCases) { difficulty in
                        NavigationLink {
                            destination(for: difficulty)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(difficulty.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text(subtitle(for: difficulty))
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(3)
                                        .minimumScaleFactor(0.7)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(16)
                            .frame(minHeight: rowMinHeight)
                            .appElevatedPlate(cornerRadius: 18)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .screenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func destination(for difficulty: SessionDifficulty) -> some View {
        switch kind {
        case .beatSync:
            BeatSyncView(level: level, difficulty: difficulty)
        case .melodyMatch:
            MelodyMatchView(level: level, difficulty: difficulty)
        case .rhythmPuzzle:
            RhythmPuzzleView(level: level, difficulty: difficulty)
        }
    }

    private func subtitle(for difficulty: SessionDifficulty) -> String {
        switch kind {
        case .beatSync:
            return "Starting tempo \(Int(difficulty.beatSyncStartingBPM)) BPM · lane length scales with level."
        case .melodyMatch:
            let length = min(12, difficulty.melodyBaseLength + level / 2)
            return "Pattern length \(length) notes · playback every \(String(format: "%.2f", difficulty.melodyPlaybackStep))s."
        case .rhythmPuzzle:
            let tiles = min(10, difficulty.puzzlePieceCount + (level + 1) / 2)
            return "\(tiles) tiles · \(Int(difficulty.puzzleTimeLimit) + level * 4)s on the clock."
        }
    }
}
