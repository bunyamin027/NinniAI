import SwiftUI
import SwiftData

/// NinniAI — Akıllı Uyku Asistanı
/// iOS 17+ | SwiftData | AVAudioEngine | %100 Offline
@main
struct NinniAIApp: App {
    
    /// SwiftData Model Container — tüm modeller burada kayıt edilir
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Baby.self,
            Sound.self,
            SleepSession.self,
            Interruption.self,
            SoundUsage.self,
            Milestone.self,
            UserSettings.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("SwiftData ModelContainer oluşturulamadı: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView(sharedModelContainer: sharedModelContainer)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root View
/// Anlık dil değişimlerinde tüm hiyerarşiyi anında yeniden oluşturan dinamik kök görünüm.
struct RootView: View {
    let sharedModelContainer: ModelContainer
    
    @State private var languageManager = LanguageManager.shared
    @State private var appState = AppState()
    @State private var subscriptionManager = SubscriptionManager(storeKit: StoreKitManager())
    
    var body: some View {
        ContentView(appState: appState, subscriptionManager: subscriptionManager)
            .environment(languageManager)
            .environment(appState)
            .environment(subscriptionManager)
            .environment(\.locale, languageManager.locale)
            .id("root_view_lang_\(languageManager.languageChangeCounter)_\(languageManager.currentLanguage.rawValue)")
            .onAppear {
                // İlk açılışta ses kataloğunu seed et
                let context = sharedModelContainer.mainContext
                SoundSeeder.seedIfNeeded(context: context)
            }
            .onOpenURL { url in
                if url.host == "stopSleep" {
                    LiveActivityManager.shared.stopLiveActivity()
                }
            }
    }
}
