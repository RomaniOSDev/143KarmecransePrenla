import SwiftUI

struct OnboardingPageOneView: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Spacer(minLength: max(52, proxy.safeAreaInsets.top + 36))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                            .tracking(1.2)

                        Text("Feel the room")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        Text("Rhythm lives in shared motion—big lights, warm air, and a crowd that breathes together.")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(5)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedPlate(cornerRadius: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.22), lineWidth: 1)
                    )

                    Canvas { context, size in
                        let stageRect = CGRect(x: 16, y: size.height * 0.4, width: size.width - 32, height: size.height * 0.24)
                        let stagePath = Path(roundedRect: stageRect, cornerRadius: 18)
                        context.fill(
                            stagePath,
                            with: .linearGradient(
                                Gradient(colors: [
                                    Color.appSurface.opacity(0.95),
                                    Color.appSurface.opacity(0.55),
                                    Color.appBackground.opacity(0.5)
                                ]),
                                startPoint: CGPoint(x: stageRect.minX, y: stageRect.minY),
                                endPoint: CGPoint(x: stageRect.maxX, y: stageRect.maxY)
                            )
                        )

                        let beamCount = 5
                        for index in 0..<beamCount {
                            let x = stageRect.minX + stageRect.width * (CGFloat(index) + 0.5) / CGFloat(beamCount)
                            var beam = Path()
                            beam.move(to: CGPoint(x: x, y: stageRect.minY))
                            beam.addLine(to: CGPoint(x: x - 18, y: stageRect.maxY + 40))
                            beam.addLine(to: CGPoint(x: x + 18, y: stageRect.maxY + 40))
                            beam.closeSubpath()
                            context.fill(
                                beam,
                                with: .linearGradient(
                                    Gradient(colors: [
                                        Color.appPrimary.opacity(0.28 + Double(index) * 0.05),
                                        Color.appPrimary.opacity(0.06)
                                    ]),
                                    startPoint: CGPoint(x: x, y: stageRect.minY),
                                    endPoint: CGPoint(x: x, y: stageRect.maxY + 36)
                                )
                            )
                        }

                        for row in 0..<4 {
                            for col in 0..<10 {
                                let x = 20 + CGFloat(col) * (size.width - 40) / 9
                                let y = stageRect.maxY + 24 + CGFloat(row) * 10
                                let circle = Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                                context.fill(circle, with: .color(Color.appAccent.opacity(0.32 + Double(row) * 0.04)))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: min(340, proxy.size.height * 0.34))
                    .appElevatedPlate(cornerRadius: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Live energy")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)

                        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            Canvas { context, size in
                                let baseY = size.height * 0.55
                                for index in 0..<36 {
                                    let x = CGFloat(index) / 35 * size.width
                                    let amp = sin(t * 3 + Double(index) * 0.35) * 10
                                    let rect = CGRect(x: x, y: baseY + CGFloat(amp), width: 4, height: 18)
                                    let bar = Path(roundedRect: rect, cornerRadius: 2)
                                    let hueShift = Double(index) / 35
                                    context.fill(
                                        bar,
                                        with: .linearGradient(
                                            Gradient(colors: [
                                                Color.appAccent.opacity(0.45 + hueShift * 0.35),
                                                Color.appPrimary.opacity(0.55 + hueShift * 0.2)
                                            ]),
                                            startPoint: CGPoint(x: rect.midX, y: rect.minY),
                                            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                                        )
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: min(140, proxy.size.height * 0.14))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appSoftInsetPlate(cornerRadius: 18)

                    Text("Swipe or tap below to continue.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    Spacer(minLength: 8)

                    Spacer()

                    Button(action: onContinue) {
                        Text("Tune in")
                    }
                    .buttonStyle(PrimaryProminentButton())

                    Spacer(minLength: max(20, proxy.safeAreaInsets.bottom + 24))
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                .padding(.horizontal, 16)
            }
        }
    }
}
