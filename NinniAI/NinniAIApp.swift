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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
