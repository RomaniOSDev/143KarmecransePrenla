import SwiftUI

struct LibraryTabView: View {
    @EnvironmentObject private var dataModel: DataModel
    @State private var editTarget: SavedRhythm?
    @State private var showEditor = false

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.45),
                    Color.appBackground.opacity(0.98),
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxHeight: 280)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LibraryHeroHeader(savedCount: dataModel.savedRhythms.count)

                    if dataModel.savedRhythms.isEmpty {
                        LibraryEmptyStateCard()
                    } else {
                        HStack {
                            Text("Saved lanes")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Text("\(dataModel.savedRhythms.count)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.appPrimary.opacity(0.35))
                                )
                        }

                        LazyVStack(spacing: 14) {
                            ForEach(Array(dataModel.savedRhythmsSortedForLibrary.enumerated()), id: \.element.id) { index, item in
                                LibrarySavedRhythmCard(
                                    item: item,
                                    index: index + 1,
                                    onFavorite: { dataModel.toggleFavoriteRhythm(id: item.id) },
                                    onDuplicate: { dataModel.duplicateRhythm(id: item.id) },
                                    onEdit: {
                                        editTarget = item
                                        showEditor = true
                                    },
                                    onDelete: { dataModel.deleteRhythm(id: item.id) }
                                )
                            }
                        }
                    }
                }
                .screenPadding()
                .padding(.bottom, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditor, onDismiss: { editTarget = nil }) {
            Group {
                if let rhythm = editTarget {
                    LibraryEditRhythmSheet(
                        rhythm: rhythm,
                        onSave: { title, note in
                            dataModel.updateRhythm(id: rhythm.id, title: title, note: note)
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Edit sheet

private struct LibraryEditRhythmSheet: View {
    let rhythm: SavedRhythm
    var onSave: (String, String) -> Void
    var onCancel: () -> Void

    @State private var title: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Lane title", text: $title)
                        .foregroundStyle(Color.appTextPrimary)
                } header: {
                    Text("Title")
                        .foregroundStyle(Color.appTextSecondary)
                }

                Section {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(Color.appTextPrimary)
                } header: {
                    Text("Note")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background {
                AppAmbientBackgroundFill(opacity: 1)
            }
            .navigationTitle("Edit lane")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalTitle = trimmedTitle.isEmpty ? rhythm.title : trimmedTitle
                        onSave(finalTitle, note)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .onAppear {
                title = rhythm.title
                note = rhythm.note
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Hero

private struct LibraryHeroHeader: View {
    let savedCount: Int

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.4), Color.appSurface.opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)

                Canvas { context, size in
                    let mid = size.height * 0.52
                    for i in 0..<14 {
                        let x = CGFloat(i) / 13 * size.width
                        let h = 6 + sin(Double(i) * 0.55) * 8
                        let rect = CGRect(x: x - 1.2, y: mid - CGFloat(h) * 0.5, width: 2.4, height: CGFloat(h))
                        context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(Color.appAccent.opacity(0.35)))
                    }
                }
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.appAccent.opacity(0.5), lineWidth: 1)

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.95))
                    .shadow(color: Color.appBackground.opacity(0.45), radius: 3, y: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Your library")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Text("Keep the patterns you love close. Everything here was saved from a strong Melody Match finish.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)

                if savedCount > 0 {
                    Label("\(savedCount) saved \(savedCount == 1 ? "lane" : "lanes")", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                        .padding(.top, 2)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 24)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.5), Color.appPrimary.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Empty

private struct LibraryEmptyStateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: false)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    let bars = 22
                    for i in 0..<bars {
                        let x = CGFloat(i) / CGFloat(bars - 1) * (size.width - 8) + 4
                        let wave = sin(t * 1.8 + Double(i) * 0.22) * 0.5 + 0.5
                        let h = CGFloat(16 + wave * (size.height - 28))
                        let rect = CGRect(x: x - 2, y: size.height - h - 8, width: 4, height: h)
                        let opacity = 0.35 + wave * 0.45
                        context.fill(
                            Path(roundedRect: rect, cornerRadius: 2),
                            with: .color(i % 3 == 0 ? Color.appPrimary.opacity(opacity) : Color.appAccent.opacity(opacity))
                        )
                    }
                }
                .frame(height: 120)
                .appSoftInsetPlate(cornerRadius: 18)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Nothing here yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                (
                    Text("Play Melody Match, land two stars or more, then tap ")
                        .foregroundStyle(Color.appTextSecondary)
                    + Text("Save to Library")
                        .foregroundStyle(Color.appAccent)
                        .fontWeight(.semibold)
                    + Text(" on the results sheet. Your lane appears here instantly.")
                        .foregroundStyle(Color.appTextSecondary)
                )
                .font(.subheadline)
                .lineLimit(8)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appPrimary)
                Text("Tip: add a note after saving so future-you knows why it mattered.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.75)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appSoftInsetPlate(cornerRadius: 14)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 24)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.appAccent.opacity(0.28), lineWidth: 1)
        )
    }
}

// MARK: - Saved card

private struct LibrarySavedRhythmCard: View {
    let item: SavedRhythm
    let index: Int
    var onFavorite: () -> Void
    var onDuplicate: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 52, height: 52)

                    Text("\(index)")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    if item.note.isEmpty == false {
                        Text(item.note)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appAccent)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                    }
                }
                Spacer(minLength: 0)

                Button(action: onFavorite) {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(item.isFavorite ? Color.appAccent : Color.appTextSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(item.isFavorite ? "Remove from favorites" : "Add to favorites"))
            }

            Text(item.patternDescription)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(4)
                .minimumScaleFactor(0.75)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appSoftInsetPlate(cornerRadius: 14)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.68)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(.plain)

                Button(action: onDuplicate) {
                    Label("Copy", systemImage: "square.on.square")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.68)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(.plain)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 48, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appPrimary.opacity(0.95), Color.appPrimary.opacity(0.75)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.appPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Delete saved lane"))
            }
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(item.isFavorite ? 0.55 : 0.35), Color.appPrimary.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
