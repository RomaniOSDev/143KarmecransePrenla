import SwiftUI

struct ScreenTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundStyle(Color.appTextSecondary)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
    }
}

extension View {
    func screenTitleStyle() -> some View {
        modifier(ScreenTitleStyle())
    }

    func bodyTextStyle() -> some View {
        modifier(BodyTextStyle())
    }

    func screenPadding() -> some View {
        padding(16)
    }
}

struct PrimaryProminentButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(configuration.isPressed ? 0.78 : 1),
                                Color.appPrimary.opacity(configuration.isPressed ? 0.62 : 0.82),
                                Color.appAccent.opacity(configuration.isPressed ? 0.42 : 0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.45), radius: configuration.isPressed ? 6 : 14, x: 0, y: configuration.isPressed ? 3 : 8)
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
            )
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct SecondarySurfaceButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(configuration.isPressed ? 0.72 : 0.92),
                                Color.appSurface.opacity(configuration.isPressed ? 0.55 : 0.68),
                                Color.appBackground.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.32), radius: 12, x: 0, y: 6)
            )
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Play tab toolbar (Home + Practice hub)

struct PlayTabTrailingToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 4) {
                NavigationLink {
                    HowItWorksView()
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("How it works"))

                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("Open settings"))
            }
        }
    }
}
