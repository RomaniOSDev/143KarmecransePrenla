import SwiftUI

struct SessionResultView: View {
    let outcome: SessionOutcome
    var canSaveMelody: Bool
    var melodyPatternSummary: String
    var onNext: () -> Void
    var onRetry: () -> Void
    var onProgress: () -> Void
    var onSaveMelody: ((String) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.mainTabSelection) private var tabSelection: Binding<MainTab>

    @State private var revealedStars: [Bool] = [false, false, false]
    @State private var bannerOffset: CGFloat = -120
    @State private var showSaveAlert = false
    @State private var saveTitle: String = "New lane"

    var body: some View {
        ZStack {
            AppAmbientBackgroundFill(opacity: 0.97)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if outcome.showDailySweepBanner {
                        achievementBanner
                            .offset(y: bannerOffset)
                    }

                    Text("Session complete")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { index in
                            let active = index < outcome.stars
                            Image(systemName: active ? "star.fill" : "star")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(active ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
                                .scaleEffect(revealedStars[index] ? 1 : 0.2)
                                .shadow(color: active && revealedStars[index] ? Color.appAccent.opacity(0.85) : .clear, radius: 14)
                                .animation(.spring(response: 0.4, dampingFraction: 0.72).delay(Double(index) * 0.12), value: revealedStars)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(outcome.accuracyText)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                        Text(outcome.replicationText)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedPlate(cornerRadius: 18)

                    VStack(spacing: 12) {
                        Button(action: onNext) {
                            Text("Next Session")
                        }
                        .buttonStyle(PrimaryProminentButton())

                        Button(action: onRetry) {
                            Text("Retry")
                        }
                        .buttonStyle(SecondarySurfaceButton())

                        Button {
                            onProgress()
                            tabSelection.wrappedValue = .discover
                            dismiss()
                        } label: {
                            Text("View Progress")
                        }
                        .buttonStyle(SecondarySurfaceButton())

                        if canSaveMelody, let onSaveMelody {
                            Button {
                                saveTitle = "New lane"
                                showSaveAlert = true
                            } label: {
                                Text("Save to Library")
                            }
                            .buttonStyle(SecondarySurfaceButton())
                            .alert("Save this pattern", isPresented: $showSaveAlert) {
                                TextField("Lane title", text: $saveTitle)
                                Button("Save") {
                                    let trimmed = saveTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let title = trimmed.isEmpty ? "Custom lane" : trimmed
                                    onSaveMelody(title)
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text(melodyPatternSummary)
                            }
                        }
                    }
                }
                .screenPadding()
            }
        }
        .onAppear {
            animateEntrance()
        }
    }

    private var achievementBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .foregroundStyle(Color.appPrimary)
            Text("You finished every focus lane for today. Come back tomorrow for a fresh trio.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(4)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 18)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.appAccent.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: Color.appAccent.opacity(0.25), radius: 20, x: 0, y: 8)
    }

    private func animateEntrance() {
        for index in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12 + Double(index) * 0.12) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                    revealedStars[index] = true
                }
            }
        }
        if outcome.showDailySweepBanner {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    bannerOffset = 0
                }
            }
        }
    }
}
