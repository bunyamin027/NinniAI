import UserNotifications
import Observation

// MARK: - Notification Manager
/// Koşullu Akıllı Bildirim Motoru.
/// PRD §5: "Empatik Bildirimler: Önceki oturumların verisine dayanan tetikleyicilerle çalışır."
///
/// Bildirim türleri:
/// - Uyku hatırlatma (akşam rutini)
/// - Milestone kutlama
/// - Haftalık rapor
/// - Empatik geri bildirim
@Observable
final class NotificationManager {
    
    static let shared = NotificationManager()
    static let sleepWindowReminderIdentifier = "smart_sleep_window_reminder"
    
    // MARK: - State
    
    /// Bildirim izni verilmiş mi?
    private(set) var isAuthorized: Bool = false
    
    /// İzin durumu
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Init
    
    init() {
        Task { await checkAuthorization() }
    }
    
    // MARK: - Authorization
    
    /// Bildirim izni iste
    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("⚠️ Bildirim izni hatası: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Mevcut izin durumunu kontrol et
    @MainActor
    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Sleep Reminder
    
    /// Uyku hatırlatma bildirimini planla
    func scheduleSleepReminder(hour: Int, minute: Int, babyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Uyku Vakti 🌙".localized
        content.body = String(format: "%@ için uyku rutinine başlama zamanı. NinniAI'ı açıp sakinleştirici sesler başlatabilirsiniz.".localized, babyName)
        content.sound = .default
        content.categoryIdentifier = "SLEEP_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "sleep_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Smart Sleep Window Reminder
    
    /// Akıllı Uyku Penceresi bildirimini planlar (İdeal uyku vaktinden 15 dakika önce)
    func scheduleSleepWindowReminder(optimalSleepTime: Date, babyName: String) {
        // Önceki bekleyen pencere bildirimini temizle
        cancelSleepWindowReminder()
        
        // İdeal saatten 15 dakika öncesi
        let reminderDate = optimalSleepTime.addingTimeInterval(-15 * 60)
        let timeInterval = reminderDate.timeIntervalSinceNow
        
        // Bildirim zamanı geçmişte ise gönderme
        guard timeInterval > 0 else {
            print("ℹ️ Bildirim zamanı geçmişte kaldığı için planlanmadı.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Uyku Vakti Yaklaşıyor! 🌙".localized
        content.body = String(format: "%@ için uyku penceresi kapanmak üzere. Odayı karartıp beyaz gürültüyü açmanın tam zamanı.".localized, babyName)
        content.sound = .default
        content.categoryIdentifier = "SLEEP_WINDOW"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: Self.sleepWindowReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Akıllı uyku penceresi bildirimi eklenemedi: \(error.localizedDescription)")
            } else {
                print("✅ Akıllı uyku penceresi bildirimi planlandı (\(babyName)): \(reminderDate.formatted(date: .omitted, time: .shortened))")
            }
        }
    }
    
    /// Bekleyen uyku penceresi hatırlatmasını iptal et
    func cancelSleepWindowReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.sleepWindowReminderIdentifier])
    }
    
    // MARK: - Milestone Notification
    
    /// Milestone bildirimini gönder
    func sendMilestoneNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "MILESTONE"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "milestone_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Weekly Report
    
    /// Haftalık rapor bildirimini planla
    func scheduleWeeklyReport(weekday: Int = AppConstants.weeklyReportDay) {
        let content = UNMutableNotificationContent()
        content.title = "Haftalık Uyku Raporu 📊".localized
        content.body = "Geçen haftanın uyku analizi hazır. Detayları görmek için tıklayın.".localized
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REPORT"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "weekly_report",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Empathic Notification
    
    /// Empatik geri bildirim bildirimi
    func sendEmpatheticNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "NinniAI 💜"
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "empathetic_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Cancel
    
    /// Tüm planlanmış bildirimleri iptal et
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Belirli bir bildirimi iptal et
    func cancel(identifier: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
