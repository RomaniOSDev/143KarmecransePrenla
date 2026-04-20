import SwiftUI

struct OnboardingFlowView: View {
    @State private var page: Int = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                TabView(selection: $page) {
                    OnboardingPageOneView {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            page = 1
                        }
                    }
                    .tag(0)

                    OnboardingPageTwoView {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            page = 2
                        }
                    }
                    .tag(1)

                    OnboardingPageThreeView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background {
                    AppAmbientBackgroundFill()
                }

                OnboardingProgressStrip(selection: page, total: 3)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .allowsHitTesting(false)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Progress

private struct OnboardingProgressStrip: View {
    let selection: Int
    let total: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Group {
                    if index == selection {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 40, height: 10)
                            .shadow(color: Color.appPrimary.opacity(0.4), radius: 10, x: 0, y: 3)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 2)
                    } else {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSurface.opacity(0.65), Color.appBackground.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 10, height: 10)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
                .animation(.spring(response: 0.42, dampingFraction: 0.78), value: selection)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(Color.appSurface.opacity(0.35))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
        }
    }
}
