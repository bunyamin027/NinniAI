import Foundation
import Observation

// MARK: - Night Mode Resolver
/// Gece Modu çözümleyicisi.
/// PRD §3.2: "Gece 03:00 Modu: Gece yarısı açıldığında sadece devasa bir
/// 'Gece Uykusuna Dön' butonu içeren simsiyah bir ekran."
///
/// 00:00 - 06:00 arasında uygulama açıldığında gece modunu aktifleştirir.
/// Bu modda ekran minimum parlaklıkta, minimum UI ile çalışır.
@Observable
final class NightModeResolver {
    
    // MARK: - State
    
    /// Gece modu aktif mi?
    private(set) var isActive: Bool = false
    
    /// Kullanıcı tarafından manuel olarak kapatıldı mı?
    /// (Bu oturum boyunca tekrar açılmaz)
    private(set) var isManuallyDismissed: Bool = false
    
    // MARK: - Resolution
    
    /// Gece modunun aktifleştirilip aktifleştirilmeyeceğini belirle
    /// - Parameter date: Kontrol edilecek tarih/saat
    /// - Returns: Gece modu aktifleştirilmeli mi?
    func shouldActivate(at date: Date = .now) -> Bool {
        guard !isManuallyDismissed else { return false }
        
        let hour = date.hour
        let shouldBeActive = hour >= AppConstants.nightModeStartHour
            && hour < AppConstants.nightModeEndHour
        
        isActive = shouldBeActive
        return shouldBeActive
    }
    
    /// Gece modunu manuel olarak kapat
    func dismiss() {
        isActive = false
        isManuallyDismissed = true
    }
    
    /// Oturum sıfırlama (yeni gün veya uygulama yeniden açılışında)
    func resetSession() {
        isManuallyDismissed = false
    }
}
