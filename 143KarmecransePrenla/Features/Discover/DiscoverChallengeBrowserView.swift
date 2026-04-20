import SwiftUI

struct DiscoverChallengeBrowserView: View {
    @EnvironmentObject private var dataModel: DataModel
    @Binding var selectedFilter: DiscoverChallengeFilter

    private var discoverLevelLinks: [DiscoverLevelLink] {
        var out: [DiscoverLevelLink] = []
        for activity in ActivityKind.allCases {
            for level in 1...ActivityProgress.levelCount {
                guard dataModel.isLevelUnlocked(activity: activity, level: level) else { continue }
                if dataModel.levelPassesDiscoverFilter(activity: activity, level: level, filter: selectedFilter) {
                    out.append(DiscoverLevelLink(activity: activity, level: level))
                }
            }
        }
        return out
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse levels")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DiscoverChallengeFilter.allCases) { filter in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                selectedFilter = filter
                            }
                        } label: {
                            Text(filter.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(selectedFilter == filter ? Color.appTextPrimary : Color.appTextSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: selectedFilter == filter
                                                    ? [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.55)]
                                                    : [Color.appSurface.opacity(0.9), Color.appBackground.opacity(0.55)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(
                                            color: Color.black.opacity(selectedFilter == filter ? 0.38 : 0.28),
                                            radius: selectedFilter == filter ? 10 : 6,
                                            x: 0,
                                            y: 4
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if discoverLevelLinks.isEmpty {
                Text("Nothing matches this filter yet. Try another chip or clear a few levels first.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(5)
                    .minimumScaleFactor(0.75)
                    .padding(.vertical, 8)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(discoverLevelLinks) { link in
                        NavigationLink {
                            DifficultySelectionView(kind: link.activity, level: link.level)
                        } label: {
                            HStack {
                                Image(systemName: link.activity.symbolName)
                                    .foregroundStyle(Color.appAccent)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(link.activity.title) · Level \(link.level)")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text(starSubtitle(activity: link.activity, level: link.level))
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(14)
                            .appElevatedPlate(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func starSubtitle(activity: ActivityKind, level: Int) -> String {
        let s = dataModel.bestStars(for: activity, level: level)
        return s >= 3 ? "Top rating on this lane" : "Best: \(s) star\(s == 1 ? "" : "s")"
    }
}

private struct DiscoverLevelLink: Identifiable {
    let activity: ActivityKind
    let level: Int

    var id: String { "\(activity.rawValue)-\(level)" }
}
