import SwiftUI
import SwiftData

// MARK: - Content View
/// Ana uygulama görünümü.
/// Onboarding durumuna göre ya Onboarding akışını ya da ana TabView'u gösterir.
struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    @State private var appState = AppState()
    @State private var showOnboarding = true
    
    /// Onboarding tamamlanmış mı? (SwiftData'dan okunur)
    private var isOnboardingDone: Bool {
        allSettings.first?.isOnboardingCompleted ?? false
    }
    
    var body: some View {
        Group {
            if showOnboarding && !isOnboardingDone {
                OnboardingContainerView {
                    withAnimation(AppTheme.animationSlow) {
                        showOnboarding = false
                        appState.isOnboardingCompleted = true
                    }
                }
            } else {
                mainTabView
            }
        }
        .environment(appState)
        .onAppear {
            showOnboarding = !isOnboardingDone
            appState.isOnboardingCompleted = isOnboardingDone
            
            // Baby varsa ContextEngine'i güncelle
            if let baby = allSettings.first?.baby {
                appState.contextEngine.resolve(baby: baby)
            }
        }
    }
    
    // MARK: - Main Tab View
    
    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: Binding(
                get: { appState.selectedTab },
                set: { appState.selectedTab = $0 }
            )) {
                DashboardView()
                    .tag(AppTab.dashboard)
                    .tabItem {
                        Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.iconName)
                    }
                
                PlayerView()
                    .tag(AppTab.player)
                    .tabItem {
                        Label(AppTab.player.title, systemImage: AppTab.player.iconName)
                    }
                
                AnalyticsDashboardView()
                    .tag(AppTab.analytics)
                    .tabItem {
                        Label(AppTab.analytics.title, systemImage: AppTab.analytics.iconName)
                    }
                
                SettingsView()
                    .tag(AppTab.settings)
                    .tabItem {
                        Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
                    }
            }
            .tint(AppTheme.accentPrimary)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [
            Baby.self, Sound.self, SleepSession.self,
            Interruption.self, SoundUsage.self,
            Milestone.self, UserSettings.self
        ], inMemory: true)
}

#Preview("Main App") {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
