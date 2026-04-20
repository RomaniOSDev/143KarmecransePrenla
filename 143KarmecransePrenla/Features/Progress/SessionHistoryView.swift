import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject private var dataModel: DataModel

    var body: some View {
        Group {
            if dataModel.sessionHistory.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("No sessions yet")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Finish any lane to build a local timeline. Entries never leave this device.")
                            .bodyTextStyle()
                    }
                    .screenPadding()
                }
            } else {
                List {
                    ForEach(dataModel.sessionHistory) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(entry.activity.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Spacer()
                                starLine(stars: entry.stars)
                            }
                            Text("Level \(entry.level)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.appTextSecondary)
                            Text(entry.summary)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.75)
                            Text(entry.finishedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary.opacity(0.85))
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appSurface.opacity(0.82),
                                            Color.appSurface.opacity(0.48),
                                            Color.appBackground.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)
                                .padding(.vertical, 4)
                        )
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Session history")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func starLine(stars: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(i < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
            }
        }
    }
}
