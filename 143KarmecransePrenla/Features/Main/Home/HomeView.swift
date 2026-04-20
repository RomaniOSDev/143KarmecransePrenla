import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var dataModel: DataModel
    @Environment(\.mainTabSelection) private var tabSelection

    private var todayLanesDone: Int {
        ActivityKind.allCases.filter { dataModel.isActivityDoneToday($0) }.count
    }

    private var weeklyProgress: CGFloat {
        let maxV = max(1, dataModel.weeklyTargetsTotal)
        return min(1, CGFloat(dataModel.weeklyProgressSum) / CGFloat(maxV))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeroCard(
                    greeting: Self.timeGreeting(),
                    dateLine: Self.formattedToday(),
                    dailyLine: dataModel.dailyAchievementsSummary,
                    trioComplete: dataModel.milestoneAllDailyComplete
                )

                HomeStatsCarousel(
                    sessions: dataModel.totalSessionsCompleted,
                    weeklyRatio: weeklyProgress,
                    weeklyLabel: "\(dataModel.weeklyProgressSum)/\(dataModel.weeklyTargetsTotal)",
                    tapPct: Self.compactTapPercent(dataModel: dataModel),
                    melodyPct: Self.compactMelodyPercent(dataModel: dataModel),
                    favorites: dataModel.savedRhythms.filter(\.isFavorite).count,
                    saved: dataModel.savedRhythms.count
                )

                HomeDailyTrioWidget(todayLanesDone: todayLanesDone)

                HomeQuickLanesWidget()

                HomeCuratedCollectionsWidget()

                HomeShortcutsRow(
                    onLibrary: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                            tabSelection.wrappedValue = .library
                        }
                    },
                    onDiscover: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                            tabSelection.wrappedValue = .discover
                        }
                    }
                )

                HomeRecentSessionsWidget()

                NavigationLink {
                    PracticeHubView()
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.appPrimary.opacity(0.35))
                            .frame(width: 52, height: 52)
                            .overlay {
                                Image(systemName: "rectangle.grid.2x2.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Full practice hub")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text("Today’s set, weekly clock, and detailed lane cards.")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.28), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .screenPadding()
            .padding(.bottom, 8)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { PlayTabTrailingToolbar() }
    }

    private static func timeGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12: return "Good morning"
        case 12 ..< 17: return "Good afternoon"
        case 17 ..< 22: return "Good evening"
        default: return "Hello"
        }
    }

    private static func formattedToday() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        return f.string(from: Date())
    }

    private static func compactTapPercent(dataModel: DataModel) -> String {
        guard dataModel.totalTapAttempts > 0 else { return "—" }
        let r = Double(dataModel.totalGoodHits) / Double(dataModel.totalTapAttempts)
        return "\(Int((r * 100).rounded()))%"
    }

    private static func compactMelodyPercent(dataModel: DataModel) -> String {
        guard dataModel.melodyTotalSteps > 0 else { return "—" }
        let r = Double(dataModel.melodyCorrectSteps) / Double(dataModel.melodyTotalSteps)
        return "\(Int((r * 100).rounded()))%"
    }
}

// MARK: - Hero

private struct HomeHeroCard: View {
    let greeting: String
    let dateLine: String
    let dailyLine: String
    let trioComplete: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.55),
                            Color.appAccent.opacity(0.38),
                            Color.appSurface.opacity(0.52)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.appAccent.opacity(0.18))
                .frame(width: 120, height: 120)
                .offset(x: 200, y: -40)

            Circle()
                .fill(Color.appPrimary.opacity(0.2))
                .frame(width: 90, height: 90)
                .offset(x: -24, y: 70)

            VStack(alignment: .leading, spacing: 10) {
                Text(greeting)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Text(dateLine)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.88))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(dailyLine)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                if trioComplete {
                    Label("Daily trio complete", systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.appBackground.opacity(0.35))
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 4)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
        .appDepthShadowStrong()
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Stats carousel

private struct HomeStatsCarousel: View {
    let sessions: Int
    let weeklyRatio: CGFloat
    let weeklyLabel: String
    let tapPct: String
    let melodyPct: String
    let favorites: Int
    let saved: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("At a glance")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HomeStatTile(
                        title: "Sessions",
                        value: "\(sessions)",
                        caption: "All time",
                        icon: "bolt.horizontal.circle.fill",
                        accent: Color.appPrimary
                    )

                    HomeWeeklyRingTile(ratio: weeklyRatio, caption: weeklyLabel)

                    HomeStatTile(
                        title: "Tap aim",
                        value: tapPct,
                        caption: "Good hits",
                        icon: "scope",
                        accent: Color.appAccent
                    )

                    HomeStatTile(
                        title: "Melody",
                        value: melodyPct,
                        caption: "Steps matched",
                        icon: "square.grid.3x3.fill",
                        accent: Color.appPrimary.opacity(0.85)
                    )

                    HomeStatTile(
                        title: "Library",
                        value: "\(saved)",
                        caption: "\(favorites) favorites",
                        icon: "books.vertical.fill",
                        accent: Color.appAccent.opacity(0.9)
                    )
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct HomeStatTile: View {
    let title: String
    let value: String
    let caption: String
    let icon: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(accent)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary.opacity(0.9))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(width: 132, alignment: .leading)
        .padding(14)
        .appElevatedPlate(cornerRadius: 18)
    }
}

private struct HomeWeeklyRingTile: View {
    let ratio: CGFloat
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.appBackground.opacity(0.9), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: ratio)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text(caption)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color.appTextPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .frame(width: 52)
            }
            .frame(width: 72, height: 72)

            Text("This week")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text("ISO week goal")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary.opacity(0.85))
                .lineLimit(2)
        }
        .frame(width: 132, alignment: .leading)
        .padding(14)
        .appElevatedPlate(cornerRadius: 18)
    }
}

// MARK: - Daily trio

private struct HomeDailyTrioWidget: View {
    @EnvironmentObject private var dataModel: DataModel
    let todayLanesDone: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today’s trio")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(todayLanesDone)/\(ActivityKind.allCases.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appAccent)
            }

            Text("Tap any lane to jump into the suggested level for that focus.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.85)

            HStack(spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    HomeLaneOrb(kind: kind, done: dataModel.isActivityDoneToday(kind))
                }
            }

            VStack(spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    let level = dataModel.suggestedPracticeLevel(for: kind)
                    let done = dataModel.isActivityDoneToday(kind)
                    NavigationLink {
                        DifficultySelectionView(kind: kind, level: level)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: kind.symbolName)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(kind.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text("Level \(level)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer(minLength: 0)
                            if done {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appPrimary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .appSoftInsetPlate(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.appAccent.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct HomeLaneOrb: View {
    let kind: ActivityKind
    let done: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(done ? Color.appPrimary.opacity(0.45) : Color.appSurface.opacity(0.75))
                    .frame(width: 52, height: 52)
                if done {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                } else {
                    Image(systemName: kind.symbolName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
            Text(shortTitle(kind))
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func shortTitle(_ kind: ActivityKind) -> String {
        switch kind {
        case .beatSync: return "Pulse"
        case .melodyMatch: return "Shape"
        case .rhythmPuzzle: return "Lane"
        }
    }
}

// MARK: - Quick lanes

private struct HomeQuickLanesWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse levels")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(ActivityKind.allCases) { kind in
                    NavigationLink {
                        ActivityLevelsView(kind: kind)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: kind.symbolName)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                            Text(kind.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                            Text("All levels")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
                        .padding(14)
                        .appElevatedPlate(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Curated

private struct HomeCuratedCollectionsWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Curated sets")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Warm-up, focus, and challenge lanes—same flow as Discover.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.85)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PracticeCollection.allCases) { collection in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: collection.symbolName)
                                    .foregroundStyle(Color.appPrimary)
                                Text(collection.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            Text(collection.subtitle)
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)
                                .frame(height: 44, alignment: .topLeading)

                            VStack(spacing: 8) {
                                ForEach(ActivityKind.allCases) { kind in
                                    let level = collection.suggestedLevel(for: kind)
                                    NavigationLink {
                                        DifficultySelectionView(kind: kind, level: level)
                                    } label: {
                                        Text(homeShortChip(kind: kind, level: level))
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.appTextPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .appSoftInsetPlate(cornerRadius: 10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(14)
                        .frame(width: 200, alignment: .leading)
                        .appElevatedPlate(cornerRadius: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.appAccent.opacity(0.22), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private func homeShortChip(kind: ActivityKind, level: Int) -> String {
        let prefix: String
        switch kind {
        case .beatSync: prefix = "Pulse"
        case .melodyMatch: prefix = "Shape"
        case .rhythmPuzzle: prefix = "Lane"
        }
        return "\(prefix) L\(level)"
    }
}

// MARK: - Shortcuts

private struct HomeShortcutsRow: View {
    let onLibrary: () -> Void
    let onDiscover: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spaces")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 12) {
                Button(action: onLibrary) {
                    shortcutLabel(title: "Library", subtitle: "Saved grooves", icon: "books.vertical.fill")
                }
                .buttonStyle(.plain)

                Button(action: onDiscover) {
                    shortcutLabel(title: "Discover", subtitle: "Catalog & filters", icon: "sparkles")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func shortcutLabel(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(14)
        .appElevatedPlate(cornerRadius: 18)
    }
}

// MARK: - Recent

private struct HomeRecentSessionsWidget: View {
    @EnvironmentObject private var dataModel: DataModel

    private var recent: [SessionHistoryEntry] {
        Array(dataModel.sessionHistory.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent sessions")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                NavigationLink {
                    SessionHistoryView()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            if recent.isEmpty {
                Text("Finish a lane to see a live feed of your latest outcomes here.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.85)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(recent) { entry in
                        HStack(alignment: .top, spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.appSurface.opacity(0.9))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: entry.activity.symbolName)
                                        .foregroundStyle(Color.appAccent)
                                        .font(.body.weight(.semibold))
                                }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.activity.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                    Spacer(minLength: 4)
                                    Text(starText(entry.stars))
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.appPrimary)
                                }
                                Text("Level \(entry.level) · \(entry.finishedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption2)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text(entry.summary)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appTextSecondary.opacity(0.95))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appSoftInsetPlate(cornerRadius: 14)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 22)
    }

    private func starText(_ stars: Int) -> String {
        String(repeating: "★", count: max(0, min(3, stars)))
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(DataModel())
    .environment(\.mainTabSelection, .constant(.play))
}
