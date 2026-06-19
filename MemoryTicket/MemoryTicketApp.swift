import SwiftUI

@main
struct MemoryTicketApp: App {
    @StateObject private var store = TicketStore()
    @State private var showSplash = true
    @AppStorage("has_onboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasOnboarded {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasOnboarded = true
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainTabView()
                        .environmentObject(store)
                        .opacity(showSplash ? 0 : 1)
                }

                if hasOnboarded && showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
