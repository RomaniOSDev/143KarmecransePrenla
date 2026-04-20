import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let segment = width / CGFloat(MainTab.allCases.count)
            let activeIndex = CGFloat(index(for: selectedTab))

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.98),
                                Color.appSurface.opacity(0.72),
                                Color.appBackground.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.appTextPrimary.opacity(0.12),
                                        Color.appTextPrimary.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.55), radius: 28, x: 0, y: 16)
                    .shadow(color: Color.appPrimary.opacity(0.18), radius: 22, x: 0, y: 4)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.28),
                                Color.appAccent.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: max(44, segment - 12), height: 56)
                    .offset(x: 6 + segment * activeIndex, y: -8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.82), value: selectedTab)
                    .shadow(color: Color.appPrimary.opacity(0.35), radius: 12, x: 0, y: 4)

                HStack(spacing: 0) {
                    ForEach(MainTab.allCases) { tab in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tab.symbolName)
                                    .font(.system(size: 18, weight: .semibold))
                                Text(tab.title)
                                    .font(.footnote.weight(.semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.appTextSecondary)
                            .frame(width: segment, height: 64)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(tab.title)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .frame(height: 76)
    }

    private func index(for tab: MainTab) -> Int {
        MainTab.allCases.firstIndex(of: tab) ?? 0
    }
}
