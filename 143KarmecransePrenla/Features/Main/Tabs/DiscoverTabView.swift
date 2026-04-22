import SwiftUI

struct DiscoverTabView: View {
    @State private var challengeFilter: DiscoverChallengeFilter = .all

    private let practiceThemes: [PracticeTheme] = [
        PracticeTheme(id: "neo_pulse", title: "Neo pulse", subtitle: "Tight subdivisions and driving accents—visual timing only."),
        PracticeTheme(id: "loft_groove", title: "Loft groove", subtitle: "Wide pocket and calm spacing—still no audio tracks."),
        PracticeTheme(id: "skyline_swing", title: "Skyline swing", subtitle: "Off-beat targets and crisp on-screen markers."),
        PracticeTheme(id: "night_ledger", title: "Night ledger", subtitle: "Sparse layout with lots of room between taps."),
        PracticeTheme(id: "aurora_blend", title: "Aurora blend", subtitle: "Layered goals that stack focus—no streaming music.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Discover lanes")
                    .screenTitleStyle()

                Text("No audio playback or music streaming. Everything here is interactive rhythm practice on the device.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appSurface.opacity(0.55))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.28), lineWidth: 1)
                    )

                Text("Curated sets, filters, and themed practice routes—all paths open the same visual challenges.")
                    .bodyTextStyle()

                PracticeCollectionsSection()

                DiscoverChallengeBrowserView(selectedFilter: $challengeFilter)

                Text("Practice themes")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 4)

                LazyVStack(spacing: 12) {
                    ForEach(practiceThemes) { theme in
                        NavigationLink {
                            ThemePracticeSetsView(theme: theme)
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appPrimary.opacity(0.85), Color.appAccent.opacity(0.75)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: "waveform")
                                            .foregroundStyle(Color.appTextPrimary)
                                    }
                                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(theme.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text(theme.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(3)
                                        .minimumScaleFactor(0.7)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(16)
                            .appElevatedPlate(cornerRadius: 18)
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundStyle(Color.appAccent)
                            Text("Open progress & reset")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(16)
                        .appElevatedPlate(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
            .screenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PracticeCollectionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Curated sets")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            ForEach(PracticeCollection.allCases) { collection in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: collection.symbolName)
                            .foregroundStyle(Color.appPrimary)
                            .font(.title3.weight(.semibold))
                        Text(collection.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    Text(collection.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)

                    HStack(spacing: 8) {
                        ForEach(ActivityKind.allCases) { kind in
                            let level = collection.suggestedLevel(for: kind)
                            NavigationLink {
                                DifficultySelectionView(kind: kind, level: level)
                            } label: {
                                Text(shortChip(kind: kind, level: level))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .appSoftInsetPlate(cornerRadius: 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedPlate(cornerRadius: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.appAccent.opacity(0.22), lineWidth: 1)
                )
            }
        }
    }

    private func shortChip(kind: ActivityKind, level: Int) -> String {
        let prefix: String
        switch kind {
        case .beatSync: prefix = "Pulse"
        case .melodyMatch: prefix = "Shape"
        case .rhythmPuzzle: prefix = "Lane"
        }
        return "\(prefix) L\(level)"
    }
}

struct ThemePracticeSetsView: View {
    let theme: PracticeTheme

    private var laneSets: [PracticeLaneSet] {
        [
            PracticeLaneSet(
                id: "\(theme.id)_pulse",
                title: "\(theme.title) · Beat lane",
                subtitle: "Visual Beat Sync challenges (no sound required).",
                kind: .beatSync
            ),
            PracticeLaneSet(
                id: "\(theme.id)_shape",
                title: "\(theme.title) · Shape lane",
                subtitle: "Melody Match grids—tap patterns, not songs.",
                kind: .melodyMatch
            ),
            PracticeLaneSet(
                id: "\(theme.id)_lane",
                title: "\(theme.title) · Puzzle lane",
                subtitle: "Reorder tiles in Rhythm Puzzle—still no playback.",
                kind: .rhythmPuzzle
            )
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(theme.title)
                    .screenTitleStyle()
                Text(theme.subtitle)
                    .bodyTextStyle()

                Text("These rows are practice shortcuts. They do not download or play music.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.85)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appSoftInsetPlate(cornerRadius: 14)

                LazyVStack(spacing: 12) {
                    ForEach(laneSets) { laneSet in
                        NavigationLink {
                            ActivityLevelsView(kind: laneSet.kind)
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: laneSet.kind.symbolName)
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(laneSet.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                    Text(laneSet.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(16)
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
}
