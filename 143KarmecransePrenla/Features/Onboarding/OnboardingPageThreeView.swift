import SwiftUI

struct OnboardingPageThreeView: View {
    @EnvironmentObject private var dataModel: DataModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Spacer(minLength: max(52, proxy.safeAreaInsets.top + 36))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("You're set")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                            .tracking(1.2)

                        Text("Listen in layers")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        Text("Highs shimmer, lows anchor, mids carry the story. Your practice space mirrors that spectrum—clear, calm, and ready when you are.")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(6)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedPlate(cornerRadius: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.2), lineWidth: 1)
                    )

                    TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: false)) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        Canvas { context, size in
                            let barCount = 28
                            for index in 0..<barCount {
                                let x = CGFloat(index) / CGFloat(barCount - 1) * (size.width - 24) + 12
                                let height = CGFloat(24 + abs(sin(t * 2.4 + Double(index) * 0.35)) * (size.height * 0.55))
                                let rect = CGRect(x: x - 3, y: size.height - height - 12, width: 6, height: height)
                                let path = Path(roundedRect: rect, cornerRadius: 3)
                                let color = index % 4 == 0 ? Color.appPrimary : Color.appAccent
                                context.fill(
                                    path,
                                    with: .linearGradient(
                                        Gradient(colors: [
                                            color.opacity(0.9),
                                            color.opacity(0.35)
                                        ]),
                                        startPoint: CGPoint(x: rect.midX, y: rect.minY),
                                        endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                                    )
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: min(300, proxy.size.height * 0.36))
                    }
                    .appElevatedPlate(cornerRadius: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                    )

                    HStack(spacing: 0) {
                        laneGlyph(symbol: "waveform.path.ecg", label: "Pulse")
                        laneGlyph(symbol: "square.grid.3x3.fill", label: "Shape")
                        laneGlyph(symbol: "rectangle.3.group.fill", label: "Lane")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .appSoftInsetPlate(cornerRadius: 18)

                    Text("No accounts, no microphone—progress stays on this device.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)

                    Spacer(minLength: 8)

                    Spacer()

                    Button {
                        dataModel.markOnboardingFinished()
                    } label: {
                        Text("Get started")
                    }
                    .buttonStyle(PrimaryProminentButton())

                    Spacer(minLength: max(20, proxy.safeAreaInsets.bottom + 24))
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                .padding(.horizontal, 16)
            }
        }
    }

    private func laneGlyph(symbol: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface.opacity(0.9), Color.appBackground.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
                )
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
