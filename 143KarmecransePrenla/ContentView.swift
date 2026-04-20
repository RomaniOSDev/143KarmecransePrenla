import SwiftUI

struct ContentView: View {
    @StateObject private var dataModel = DataModel()

    var body: some View {
        Group {
            if dataModel.hasSeenOnboarding {
                MainShellView()
            } else {
                OnboardingFlowView()
            }
        }
        .environmentObject(dataModel)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
