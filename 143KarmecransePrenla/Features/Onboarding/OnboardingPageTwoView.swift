import Combine
import SwiftUI

struct OnboardingPageTwoView: View {
    let onContinue: () -> Void
    @State private var pulse: CGFloat = 0
    @State private var flowEnergy: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Spacer(minLength: max(52, proxy.safeAreaInsets.top + 36))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Practice")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                            .tracking(1.2)

                        Text("Shape your lane")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        Text("Ideas start as small sparks. Notes drift, connect, and find a groove without forcing perfection on the first pass.")
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
                            .strokeBorder(Color.appPrimary.opacity(0.18), lineWidth: 1)
                    )

                    TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        Canvas { context, size in
                            let centerY = size.height * 0.55
                            for index in 0..<18 {
                                let progress = CGFloat(index) / 17
                                let x = progress * size.width
                                let sway = sin(t * 2 + Double(index) * 0.4) * 18
                                let y = centerY + CGFloat(sway) + sin(progress * .pi * 2 + CGFloat(pulse) + flowEnergy) * 10
                                let note = Path(roundedRect: CGRect(x: x - 10, y: y - 14, width: 36, height: 22), cornerRadius: 8)
                                context.fill(
                                    note,
                                    with: .linearGradient(
                                        Gradient(colors: [
                                            Color.appPrimary.opacity(0.92),
                                            Color.appPrimary.opacity(0.55)
                                        ]),
                                        startPoint: CGPoint(x: x - 10, y: y - 14),
                                        endPoint: CGPoint(x: x + 26, y: y + 8)
                                    )
                                )
                                let stem = Path(CGRect(x: x + 18, y: y - 6, width: 3, height: 46))
                                context.fill(
                                    stem,
                                    with: .linearGradient(
                                        Gradient(colors: [
                                            Color.appAccent.opacity(0.95),
                                            Color.appAccent.opacity(0.45)
                                        ]),
                                        startPoint: CGPoint(x: x + 18, y: y - 6),
                                        endPoint: CGPoint(x: x + 18, y: y + 40)
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
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.appAccent.opacity(0.35), Color.appSurface.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )

                    Text("Beat Sync, Melody Match, and Rhythm Puzzle all live in one calm shell.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.95))
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appSoftInsetPlate(cornerRadius: 16)

                    Spacer(minLength: 8)

                    Spacer()

                    Button(action: onContinue) {
                        Text("Keep exploring")
                    }
                    .buttonStyle(PrimaryProminentButton())

                    Spacer(minLength: max(20, proxy.safeAreaInsets.bottom + 24))
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = 1
            }
        }
        .onReceive(Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                flowEnergy += 0.35
            }
        }
    }
}
