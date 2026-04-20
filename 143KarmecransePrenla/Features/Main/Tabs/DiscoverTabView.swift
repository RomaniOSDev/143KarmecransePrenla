import SwiftUI

struct DiscoverTabView: View {
    @State private var challengeFilter: DiscoverChallengeFilter = .all

    private let genres: [MusicGenre] = [
        MusicGenre(id: "neo_pulse", title: "Neo pulse", subtitle: "Bright, driving electronic patterns"),
        MusicGenre(id: "loft_groove", title: "Loft groove", subtitle: "Warm bass-led pocket playing"),
        MusicGenre(id: "skyline_swing", title: "Skyline swing", subtitle: "Off-beat accents and crisp hi-hats"),
        MusicGenre(id: "night_ledger", title: "Night ledger", subtitle: "Sparse hits with wide space"),
        MusicGenre(id: "aurora_blend", title: "Aurora blend", subtitle: "Layered textures and floating fills")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Discover lanes")
                    .screenTitleStyle()

                Text("Curated sets, filters, and genre playlists—all paths lead into the same focused challenges.")
                    .bodyTextStyle()

                PracticeCollectionsSection()

                DiscoverChallengeBrowserView(selectedFilter: $challengeFilter)

                Text("Genres")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 4)

                LazyVStack(spacing: 12) {
                    ForEach(genres) { genre in
                        NavigationLink {
                            GenrePlaylistsView(genre: genre)
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
                                    Text(genre.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text(genre.subtitle)
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

struct GenrePlaylistsView: View {
    let genre: MusicGenre

    private var playlists: [PlaylistItem] {
        [
            PlaylistItem(id: "\(genre.id)_pulse", title: "\(genre.title) · Pulse set", subtitle: "Beat Sync focus", kind: .beatSync),
            PlaylistItem(id: "\(genre.id)_shape", title: "\(genre.title) · Shape set", subtitle: "Melody Match focus", kind: .melodyMatch),
            PlaylistItem(id: "\(genre.id)_lane", title: "\(genre.title) · Lane set", subtitle: "Rhythm Puzzle focus", kind: .rhythmPuzzle)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(genre.title)
                    .screenTitleStyle()
                Text(genre.subtitle)
                    .bodyTextStyle()

                LazyVStack(spacing: 12) {
                    ForEach(playlists) { playlist in
                        NavigationLink {
                            ActivityLevelsView(kind: playlist.kind)
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
                                        Image(systemName: playlist.kind.symbolName)
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(playlist.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                    Text(playlist.subtitle)
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
