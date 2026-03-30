import SwiftUI

@main
struct EyeFocusTimerApp: App {
    @StateObject private var manager = EyeManager()
    var body: some Scene {
        WindowGroup {
            Group {
                if manager.onboardingDone { MainView() }
                else { OnboardingView() }
            }
            .environmentObject(manager)
            .preferredColorScheme(.dark)
        }
    }
}
