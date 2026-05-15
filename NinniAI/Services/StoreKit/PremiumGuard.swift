import Foundation
import Observation

// MARK: - Premium Guard
/// Premium erişim kontrol katmanı.
/// View'lar bu servisi kullanarak içeriğin premium-only olup olmadığını kontrol eder.
///
/// Kullanım:
/// ```swift
/// if premiumGuard.canAccess(.unlimitedMix) {
///     // Sınırsız mix
/// } else {
///     // Paywall göster
/// }
/// ```
@Observable
final class PremiumGuard {
    
    // MARK: - Dependencies
    
    private let storeKit: StoreKitManager
    
    // MARK: - Init
    
    init(storeKit: StoreKitManager) {
        self.storeKit = storeKit
    }
    
    // MARK: - Access Control
    
    /// Belirtilen özelliğe erişim var mı?
    func canAccess(_ feature: PremiumFeature) -> Bool {
        if storeKit.isSubscribed { return true }
        return feature.isFreeAccess
    }
    
    /// Premium gerektiriyor mu? (Paywall gösterilmeli mi?)
    func requiresPremium(_ feature: PremiumFeature) -> Bool {
        !canAccess(feature)
    }
    
    /// Abonelik aktif mi?
    var isActive: Bool {
        storeKit.isSubscribed
    }
}

// MARK: - Premium Feature
/// Premium ile kilitlenen özellikler
enum PremiumFeature: String, CaseIterable {
    /// Tüm ses kütüphanesine erişim
    case allSounds = "all_sounds"
    /// Sınırsız ses karıştırma (3+ ses)
    case unlimitedMix = "unlimited_mix"
    /// Gelişmiş uyku analitiği
    case advancedAnalytics = "advanced_analytics"
    /// Sınırsız favori
    case unlimitedFavorites = "unlimited_favorites"
    /// AI önerileri ve akıllı rutinler
    case smartRecommendations = "smart_recommendations"
    
    /// Free'de erişilebilir mi?
    var isFreeAccess: Bool {
        switch self {
        case .allSounds:             return false
        case .unlimitedMix:          return false
        case .advancedAnalytics:     return false
        case .unlimitedFavorites:    return false
        case .smartRecommendations:  return false
        }
    }
    
    var displayTitle: String {
        switch self {
        case .allSounds:            return "Tüm Sesler"
        case .unlimitedMix:         return "Sınırsız Mix"
        case .advancedAnalytics:    return "Gelişmiş Analizler"
        case .unlimitedFavorites:   return "Sınırsız Favori"
        case .smartRecommendations: return "Akıllı Öneriler"
        }
    }
    
    var iconName: String {
        switch self {
        case .allSounds:            return "music.note.list"
        case .unlimitedMix:         return "slider.horizontal.3"
        case .advancedAnalytics:    return "chart.xyaxis.line"
        case .unlimitedFavorites:   return "heart.fill"
        case .smartRecommendations: return "brain.head.profile"
        }
    }
}
