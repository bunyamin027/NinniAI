import Foundation
import SwiftData

// MARK: - User Settings Model
/// Kullanıcı tercihlerini ve uygulama ayarlarını saklar.
/// Her bebek profili için 1:1 ilişkili bir ayarlar kaydı tutulur.
///
/// Premium durumu StoreKitManager tarafından güncellenir.
/// ContextEngine bildirim ve tema tercihlerini buradan okur.
@Model
final class UserSettings {
    
    // MARK: - Premium Status
    
    /// Kullanıcı premium abone mi?
    var isPremium: Bool
    
    /// Premium aboneliğin bitiş tarihi (nil = premium değil veya ömür boyu)
    var premiumExpiryDate: Date?
    
    /// Premium plan türü rawValue'su
    var premiumPlanRawValue: String?
    
    // MARK: - Notification Preferences
    
    /// Uyku hatırlatma bildirimi açık mı?
    var isSleepReminderEnabled: Bool
    
    /// Uyku hatırlatma saati (dakika cinsinden, gece yarısından itibaren, örn: 1260 = 21:00)
    var sleepReminderTimeMinutes: Int
    
    /// Milestone bildirimleri açık mı?
    var isMilestoneNotificationEnabled: Bool
    
    /// Haftalık rapor bildirimi açık mı?
    var isWeeklyReportEnabled: Bool
    
    // MARK: - Player Preferences
    
    /// Varsayılan zamanlayıcı süresi (dakika)
    var defaultTimerDurationMinutes: Int
    
    /// Fade out süresi (saniye)
    var fadeOutDurationSeconds: Int
    
    /// Arka planda çalmaya devam et
    var continuePlaybackInBackground: Bool
    
    // MARK: - App Preferences
    
    /// Onboarding tamamlandı mı?
    var isOnboardingCompleted: Bool
    
    /// Uygulama ilk açılış tarihi
    var firstLaunchDate: Date?
    
    /// Uygulama toplam açılış sayısı
    var appLaunchCount: Int
    
    /// Son uygulama review isteme tarihi
    var lastReviewPromptDate: Date?
    
    // MARK: - Relationship
    
    /// Bu ayarların ait olduğu bebek
    var baby: Baby?
    
    // MARK: - Computed Properties
    
    var premiumPlan: PremiumPlan? {
        get {
            guard let raw = premiumPlanRawValue else { return nil }
            return PremiumPlan(rawValue: raw)
        }
        set { premiumPlanRawValue = newValue?.rawValue }
    }
    
    /// Premium geçerli mi? (Süresiz veya süresi dolmamış)
    var isPremiumActive: Bool {
        guard isPremium else { return false }
        if let expiry = premiumExpiryDate {
            return expiry > .now
        }
        return true // Süresi yok = aktif
    }
    
    /// Uyku hatırlatma zamanı (HH:mm formatında)
    var sleepReminderTime: (hour: Int, minute: Int) {
        (sleepReminderTimeMinutes / 60, sleepReminderTimeMinutes % 60)
    }
    
    // MARK: - Initializer
    
    init(baby: Baby? = nil) {
        self.baby = baby
        self.isPremium = false
        self.isSleepReminderEnabled = true
        self.sleepReminderTimeMinutes = 1260 // 21:00
        self.isMilestoneNotificationEnabled = true
        self.isWeeklyReportEnabled = true
        self.defaultTimerDurationMinutes = 30
        self.fadeOutDurationSeconds = 10
        self.continuePlaybackInBackground = true
        self.isOnboardingCompleted = false
        self.appLaunchCount = 0
    }
}

// MARK: - Premium Plan
/// Premium abonelik plan türleri
enum PremiumPlan: String, Codable, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayTitle: String {
        switch self {
        case .monthly:  return "Aylık"
        case .yearly:   return "Yıllık"
        }
    }
    
    /// StoreKit product identifier — App Store Connect'teki gerçek ID'ler
    var productIdentifier: String {
        switch self {
        case .monthly:  return "ninniai.monthly"
        case .yearly:   return "ninniai.yearly"
        }
    }
}
