import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var dataModel: DataModel
    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .screenTitleStyle()

                Text("Progress, comfort, legal links, and App Store feedback.")
                    .bodyTextStyle()

                Text("Progress & data")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)

                Text("These numbers come straight from your sessions. Session history and weekly counters live here too.")
                    .bodyTextStyle()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sessions finished: \(dataModel.totalSessionsCompleted)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(dataModel.overallAccuracyDescription)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    Text(dataModel.melodyReplicationDescription)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    Text(dataModel.dailyAchievementsSummary)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedPlate(cornerRadius: 18)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Learning & comfort")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)

                    Toggle(isOn: Binding(
                        get: { dataModel.visualMetronomeEnabled },
                        set: { dataModel.setVisualMetronomeEnabled($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Visual metronome pulse")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Soft rings during Beat Sync only—no sound, no microphone.")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(4)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    .tint(Color.appPrimary)

                    Toggle(isOn: Binding(
                        get: { dataModel.largeTapTargetsEnabled },
                        set: { dataModel.setLargeTapTargetsEnabled($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Larger tap targets")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Bigger note pads and difficulty rows for calmer tapping.")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(4)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    .tint(Color.appPrimary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedPlate(cornerRadius: 18)

                NavigationLink {
                    SessionHistoryView()
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(Color.appAccent)
                        Text("Session history")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 18)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    HowItWorksView()
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(Color.appAccent)
                        Text("How it works")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 18)
                }
                .buttonStyle(.plain)

                Text("App & legal")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 4)

                Button {
                    rateApp()
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.appAccent)
                        Text("Rate us")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 18)
                }
                .buttonStyle(.plain)

                Button {
                    AppExternalURL.open(.privacyPolicy)
                } label: {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(Color.appAccent)
                        Text("Privacy Policy")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 18)
                }
                .buttonStyle(.plain)

                Button {
                    AppExternalURL.open(.termsOfUse)
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(Color.appAccent)
                        Text("Terms of Use")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .appElevatedPlate(cornerRadius: 18)
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Text("Reset All Progress")
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.45)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.appPrimary.opacity(0.45), radius: 14, x: 0, y: 8)
                                .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
                        )
                }
                .confirmationDialog(
                    "Reset all progress?",
                    isPresented: $confirmReset,
                    titleVisibility: .visible
                ) {
                    Button("Reset everything", role: .destructive) {
                        dataModel.resetAllProgress()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Clears stars, levels, saved lanes, history, weekly counts, and comfort toggles.")
                }
            }
            .screenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
