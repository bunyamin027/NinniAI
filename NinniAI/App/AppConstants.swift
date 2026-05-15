import Foundation

// MARK: - App Constants
/// Uygulama genelinde kullanılan sabitler.
/// Magic number kullanımını önler, tüm sabitler merkezi olarak yönetilir.
enum AppConstants {
    
    // MARK: - App Info
    
    static let appName = "NinniAI"
    static let appDisplayName = "NinniAI"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Audio Engine
    
    /// Varsayılan fade out süresi (saniye)
    static let defaultFadeOutDuration: TimeInterval = 10.0
    
    /// Varsayılan fade in süresi (saniye)
    static let defaultFadeInDuration: TimeInterval = 2.0
    
    /// Maksimum eş zamanlı ses karıştırma sayısı
    static let maxMixSounds: Int = 4
    
    /// Free kullanıcı için maksimum mix sayısı
    static let freeMixLimit: Int = 2
    
    /// Ses dosyası süresi hedefi (saniye) — zero-crossing loop
    static let soundLoopDuration: TimeInterval = 15.0
    
    /// Minimum loop süresi (saniye)
    static let minimumLoopDuration: TimeInterval = 10.0
    
    // MARK: - Timer Presets
    
    /// Zamanlayıcı seçenekleri (dakika)
    static let timerPresets: [Int] = [15, 30, 45, 60, 90, 120]
    
    /// Süresiz zamanlayıcı değeri
    static let infiniteTimer: Int = 0
    
    // MARK: - Analytics
    
    /// Başarı puanı için minimum kesintisiz süre (saniye) — 40 dakika
    static let successThresholdSeconds: TimeInterval = 40 * 60
    
    /// Haftalık rapor günü (1 = Pazar, 2 = Pazartesi ...)
    static let weeklyReportDay: Int = 2 // Pazartesi
    
    // MARK: - Onboarding
    
    /// Analiz illüzyonu animasyon süresi (saniye)
    static let analysisAnimationDuration: TimeInterval = 2.0
    
    /// Maksimum seçilebilir uyku problemi sayısı
    static let maxSleepProblemsSelection: Int = 2
    
    // MARK: - Milestone
    
    /// Milestone kontrol saati (gece yarısından sonraki dakika: 1 = 00:01)
    static let milestoneCheckMinuteAfterMidnight: Int = 1
    
    // MARK: - Night Mode
    
    /// Gece modunun başlangıç saati
    static let nightModeStartHour: Int = 0
    
    /// Gece modunun bitiş saati
    static let nightModeEndHour: Int = 6
    
    // MARK: - Limits
    
    /// Free favori limiti
    static let freeFavoriteLimit: Int = 5
    
    /// App Store Review istemek için minimum oturum sayısı
    static let reviewPromptMinSessions: Int = 5
    
    /// İki review isteme arasındaki minimum gün sayısı
    static let reviewPromptCooldownDays: Int = 60
    
    // MARK: - URLs
    
    static let privacyPolicyURL = URL(string: "https://ninni.ai/privacy")!
    static let termsOfServiceURL = URL(string: "https://ninni.ai/terms")!
    static let supportURL = URL(string: "https://ninni.ai/support")!
    static let instagramURL = URL(string: "https://instagram.com/ninniai")!
}
