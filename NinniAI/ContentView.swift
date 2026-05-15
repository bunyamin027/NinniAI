import SwiftUI
import SwiftData

// MARK: - Content View
/// Ana uygulama görünümü.
/// Onboarding durumuna göre ya Onboarding akışını ya da TabView'u gösterir.
/// Faz 2'de Onboarding entegre edilecek, şu an doğrudan TabView gösterilir.
struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var appState = AppState()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: Binding(
                get: { appState.selectedTab },
                set: { appState.selectedTab = $0 }
            )) {
                // Dashboard (Faz 3'te detaylandırılacak)
                dashboardPlaceholder
                    .tag(AppTab.dashboard)
                    .tabItem {
                        Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.iconName)
                    }
                
                // Player
                PlayerView()
                    .tag(AppTab.player)
                    .tabItem {
                        Label(AppTab.player.title, systemImage: AppTab.player.iconName)
                    }
                
                // Analytics (Faz 4'te detaylandırılacak)
                analyticsPlaceholder
                    .tag(AppTab.analytics)
                    .tabItem {
                        Label(AppTab.analytics.title, systemImage: AppTab.analytics.iconName)
                    }
                
                // Settings (Faz 4'te detaylandırılacak)
                settingsPlaceholder
                    .tag(AppTab.settings)
                    .tabItem {
                        Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
                    }
            }
            .tint(AppTheme.accentPrimary)
            .preferredColorScheme(.dark)
            
            // Mini Player (tab bar üstünde)
            MiniPlayerBar()
                .padding(.bottom, 50) // Tab bar yüksekliği
        }
        .environment(appState)
        .fullScreenCover(isPresented: $appState.isFullPlayerPresented) {
            PlayerView()
                .environment(appState)
        }
    }
    
    // MARK: - Placeholder Views
    
    private var dashboardPlaceholder: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.accentPrimary)
                
                Text("NinniAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Akıllı Uyku Asistanı")
                    .font(.title3)
                    .foregroundStyle(AppTheme.textSecondary)
                
                Text("Faz 3'te burada dinamik dashboard olacak")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.top, AppTheme.spacingLG)
            }
        }
    }
    
    private var analyticsPlaceholder: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.accentPrimary)
                
                Text("Uyku Analitiği")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Faz 4'te burada grafikler olacak")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }
    
    private var settingsPlaceholder: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.accentPrimary)
                
                Text("Ayarlar")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Faz 4'te detaylandırılacak")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
