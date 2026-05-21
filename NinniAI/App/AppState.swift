import SwiftUI
import SwiftData

// MARK: - App State
/// Uygulama genelindeki paylaşılan durum yöneticisi.
/// @Observable macro ile tüm view'lar otomatik güncellenir.
@Observable
final class AppState {
    
    // MARK: - Services
    
    /// Merkezi ses motoru
    let audioEngine: AudioEngineManager
    
    /// Kilit ekranı kontrol yöneticisi
    let nowPlayable: NowPlayableManager
    
    /// Yerel Bağlam Motoru
    let contextEngine: ContextResolver
    
    // MARK: - Navigation State
    
    /// Ana tab seçimi
    var selectedTab: AppTab = .dashboard
    
    /// Full-screen player açık mı?
    var isFullPlayerPresented: Bool = false
    
    /// Onboarding tamamlandı mı? (UserSettings'den okunur)
    var isOnboardingCompleted: Bool = false
    
    // MARK: - Init
    
    init() {
        let engine = AudioEngineManager()
        self.audioEngine = engine
        self.nowPlayable = NowPlayableManager(audioManager: engine)
        self.contextEngine = ContextResolver()
    }
}

// MARK: - App Tab
/// Ana tab bar seçenekleri
enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "dashboard"
    case player = "player"
    case analytics = "analytics"
    case settings = "settings"
    
    var id: String { rawValue }
    
    var title: LocalizedStringResource {
        switch self {
        case .dashboard: return "Ana Sayfa"
        case .player:    return "Sesler"
        case .analytics: return "Analizler"
        case .settings:  return "Ayarlar"
        }
    }
    
    var iconName: String {
        switch self {
        case .dashboard: return "moon.stars.fill"
        case .player:    return "waveform.circle.fill"
        case .analytics: return "chart.bar.fill"
        case .settings:  return "gearshape.fill"
        }
    }
}
