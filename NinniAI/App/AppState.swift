import SwiftUI
import SwiftData

// MARK: - App State
/// Uygulama genelindeki paylaşılan durum yöneticisi.
/// @Observable macro ile tüm view'lar otomatik güncellenir.
///
/// Bu sınıf şu sorumlulukları taşır:
/// - AudioEngineManager yaşam döngüsü
/// - NowPlayableManager yaşam döngüsü
/// - Aktif bebek profili referansı
/// - Navigasyon durumu
@Observable
final class AppState {
    
    // MARK: - Services
    
    /// Merkezi ses motoru
    let audioEngine: AudioEngineManager
    
    /// Kilit ekranı kontrol yöneticisi
    let nowPlayable: NowPlayableManager
    
    // MARK: - Navigation State
    
    /// Ana tab seçimi
    var selectedTab: AppTab = .dashboard
    
    /// Player sheet açık mı?
    var isPlayerPresented: Bool = false
    
    /// Full-screen player açık mı?
    var isFullPlayerPresented: Bool = false
    
    // MARK: - Init
    
    init() {
        let engine = AudioEngineManager()
        self.audioEngine = engine
        self.nowPlayable = NowPlayableManager(audioManager: engine)
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
    
    var title: String {
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
