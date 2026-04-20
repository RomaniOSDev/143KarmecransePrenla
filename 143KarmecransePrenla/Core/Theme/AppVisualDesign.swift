import SwiftUI

// MARK: - Ambient screen

/// Full-screen depth behind scroll content (replaces flat `Color.appBackground`).
struct AppAmbientBackgroundFill: View {
    var opacity: CGFloat = 1

    var body: some View {
        ZStack {
            Color.appBackground.opacity(opacity)

            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.16 * opacity),
                    Color.appBackground.opacity(0.35 * opacity),
                    Color.appAccent.opacity(0.1 * opacity)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.14 * opacity),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color.appPrimary.opacity(0.12 * opacity),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - View extensions

extension View {
    /// Layered gradient “room” behind a screen.
    func appStandardScreenBackground(opacity: CGFloat = 1) -> some View {
        background {
            AppAmbientBackgroundFill(opacity: opacity)
        }
    }

    /// Raised card: gradient fill, rim light, dual shadow (depth + brand glow).
    func appElevatedPlate(cornerRadius: CGFloat = 18) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.96),
                                Color.appSurface.opacity(0.62),
                                Color.appBackground.opacity(0.48)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.appTextPrimary.opacity(0.16),
                                Color.appTextPrimary.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.48), radius: 18, x: 0, y: 12)
            .shadow(color: Color.appPrimary.opacity(0.12), radius: 26, x: 0, y: 8)
        }
    }

    /// Softer lift for nested panels and diagrams.
    func appSoftInsetPlate(cornerRadius: CGFloat = 14) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.78),
                                Color.appBackground.opacity(0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.28), radius: 10, x: 0, y: 6)
        }
    }

    /// Stronger drop shadow for hero-sized cards (use with own fill or after `appElevatedPlate`).
    func appDepthShadowStrong() -> some View {
        shadow(color: Color.black.opacity(0.55), radius: 28, x: 0, y: 18)
            .shadow(color: Color.appAccent.opacity(0.14), radius: 32, x: 0, y: 10)
    }

    func appDepthShadowMedium() -> some View {
        shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 10)
            .shadow(color: Color.appPrimary.opacity(0.1), radius: 22, x: 0, y: 6)
    }
}
