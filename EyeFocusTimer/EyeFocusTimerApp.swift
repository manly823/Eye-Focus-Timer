import SwiftUI

@main
struct EyeFocusTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var manager = EyeManager()
    @StateObject private var appStateManager = AppStateManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(manager)
                .environmentObject(appStateManager)
                .environmentObject(networkMonitor)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var manager: EyeManager
    @EnvironmentObject var appStateManager: AppStateManager

    var body: some View {
        ZStack {
            switch appStateManager.currentState {
            case .loading:
                LoadingView(message: appStateManager.loadingProgress)
                    .transition(.opacity)

            case .noInternet:
                NoInternetView {
                    await appStateManager.retryConnection()
                }
                .transition(.opacity)

            case .pushPermission:
                PushPermissionView(
                    onAccept: {
                        await appStateManager.onPushPermissionAccepted()
                    },
                    onSkip: {
                        await appStateManager.onPushPermissionSkipped()
                    }
                )
                .transition(.opacity)

            case .webView(let url):
                FullscreenWebView(urlString: url)
                    .transition(.opacity)

            case .native:
                Group {
                    if manager.onboardingDone { MainView() }
                    else { OnboardingView() }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appStateManager.currentState.description)
        .task {
            await appStateManager.initializeApp()
        }
    }
}
