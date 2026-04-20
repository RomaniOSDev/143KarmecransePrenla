import SwiftUI

struct ActivityLevelsView: View {
    @EnvironmentObject private var dataModel: DataModel
    let kind: ActivityKind

    private let columns = [GridItem(.adaptive(minimum: 168), spacing: 14)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(kind.title)
                    .screenTitleStyle()
                Text(kind.detail)
                    .bodyTextStyle()

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(1...ActivityProgress.levelCount, id: \.self) { level in
                        let unlocked = dataModel.isLevelUnlocked(activity: kind, level: level)
                        NavigationLink {
                            DifficultySelectionView(kind: kind, level: level)
                        } label: {
                            LevelSelectionCell(
                                kind: kind,
                                level: level,
                                stars: dataModel.bestStars(for: kind, level: level),
                                locked: unlocked == false
                            )
                        }
                        .buttonStyle(LevelCellNavigationButtonStyle())
                        .disabled(unlocked == false)
                    }
                }
            }
            .screenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LevelCellNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: configuration.isPressed)
    }
}
