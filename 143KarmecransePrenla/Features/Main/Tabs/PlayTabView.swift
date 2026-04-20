import SwiftUI

struct PlayTabView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

// MARK: - Practice hub (full scroll from earlier Play root)

struct PracticeHubView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Rhythm challenges")
                    .screenTitleStyle()

                Text("Pick a lane, choose a level, then dial the difficulty that matches your focus today.")
                    .bodyTextStyle()

                PracticeTodaySection()
                PracticeWeekPulseSection()

                VStack(spacing: 12) {
                    ForEach(ActivityKind.allCases) { kind in
                        NavigationLink {
                            ActivityLevelsView(kind: kind)
                        } label: {
                            ActivitySummaryCard(kind: kind)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .screenPadding()
        }
        .navigationTitle("Practice hub")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { PlayTabTrailingToolbar() }
    }
}

// MARK: - Today

private struct PracticeTodaySection: View {
    @EnvironmentObject private var dataModel: DataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's practice set")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("One suggested lane per focus type. Finishing all three completes the daily trio.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(4)
                .minimumScaleFactor(0.75)

            VStack(spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    let level = dataModel.suggestedPracticeLevel(for: kind)
                    let done = dataModel.isActivityDoneToday(kind)
                    NavigationLink {
                        DifficultySelectionView(kind: kind, level: level)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: kind.symbolName)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 40, alignment: .center)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(kind.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Text("Start around level \(level)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                if done {
                                    Label("Touched today", systemImage: "checkmark.seal.fill")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.appPrimary)
                                }
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(14)
                        .appElevatedPlate(cornerRadius: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.appAccent.opacity(done ? 0.45 : 0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 22)
    }
}

// MARK: - Week

private struct PracticeWeekPulseSection: View {
    @EnvironmentObject private var dataModel: DataModel

    private let goal = ActivityProgress.weeklySessionsPerActivityGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly rhythm clock")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Light counters reset every ISO week. Aim for \(goal) sessions per lane type.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(4)
                .minimumScaleFactor(0.75)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    let count = dataModel.weeklyCount(for: kind)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(kind.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Text("\(count) / \(goal)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }
                        GeometryReader { geo in
                            let ratio = min(1, CGFloat(count) / CGFloat(max(1, goal)))
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.appBackground.opacity(0.75))
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appAccent, Color.appPrimary.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(6, geo.size.width * ratio))
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 22)
    }
}

private struct ActivitySummaryCard: View {
    @EnvironmentObject private var dataModel: DataModel
    let kind: ActivityKind

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurface)
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: kind.symbolName)
                        .foregroundStyle(Color.appAccent)
                        .font(.system(size: 22, weight: .semibold))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(kind.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(kind.detail)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                Text("Best stars: \(bestStarSummary)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 18)
    }

    private var bestStarSummary: String {
        let values = (1...ActivityProgress.levelCount).map { dataModel.bestStars(for: kind, level: $0) }
        let total = values.reduce(0, +)
        return "\(total) / \(ActivityProgress.maxStarsPerActivity)"
    }
}
