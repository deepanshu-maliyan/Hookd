import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                if appState.needsOnboarding {
                    onboardingView
                } else {
                    MainTabView()
                }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
        .animation(.easeInOut, value: appState.needsOnboarding)
    }
    
    @ViewBuilder
    private var onboardingView: some View {
        switch appState.onboardingStep {
        case .intent:
            OnboardingIntentView()
        case .tags:
            OnboardingTagsView()
        case .photos:
            PhotoUploadView()
        case .complete:
            MainTabView()
        }
    }
}
