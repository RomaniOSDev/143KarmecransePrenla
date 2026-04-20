import SwiftUI

struct MainShellView: View {
    @EnvironmentObject private var dataModel: DataModel
    @State private var tab: MainTab = .play

    var body: some View {
        ZStack(alignment: .bottom) {
            AppAmbientBackgroundFill()

            Group {
                switch tab {
                case .play:
                    NavigationStack {
                        PlayTabView()
                    }
                case .library:
                    NavigationStack {
                        LibraryTabView()
                    }
                case .discover:
                    NavigationStack {
                        DiscoverTabView()
                    }
                }
            }
            .padding(.bottom, 88)

            CustomTabBar(selectedTab: $tab)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .environment(\.mainTabSelection, $tab)
    }
}
