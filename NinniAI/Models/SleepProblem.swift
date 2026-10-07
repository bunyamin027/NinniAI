import Foundation

// MARK: - Sleep Problem
/// Onboarding sırasında kullanıcının seçtiği uyku problemleri.
/// Bu değerler ContextEngine tarafından ses önerisi ve ipucu üretmek için kullanılır.
/// PRD §3.1: "Kullanıcıdan bebeğin temel uyku problemleri alınır."
enum SleepProblem: String, Codable, CaseIterable, Identifiable {
    
    /// Uykuya dalma güçlüğü
    case difficultyFallingAsleep = "difficulty_falling_asleep"
    
    /// Gece sık uyanma
    case frequentNightWaking = "frequent_night_waking"
    
    /// Kısa gündüz uykusu
    case shortNaps = "short_naps"
    
    /// Düzensiz uyku programı
    case irregularSchedule = "irregular_schedule"
    
    /// Gece korkuları
    case nightTerrors = "night_terrors"
    
    /// Uyku gerileme dönemleri (sleep regression)
    case sleepRegression = "sleep_regression"
    
    /// Kucakta uyuma bağımlılığı
    case needsHolding = "needs_holding"
    
    /// Emzirerek uyuma bağımlılığı
    case feedToSleep = "feed_to_sleep"
    
    var id: String { rawValue }
    
    /// Kullanıcıya gösterilecek başlık
    var displayTitle: String {
        switch self {
        case .difficultyFallingAsleep: return "Uykuya dalma güçlüğü".localized
        case .frequentNightWaking:     return "Gece sık uyanma".localized
        case .shortNaps:               return "Kısa gündüz uykusu".localized
        case .irregularSchedule:       return "Düzensiz uyku programı".localized
        case .nightTerrors:            return "Gece korkuları".localized
        case .sleepRegression:         return "Uyku gerileme dönemi".localized
        case .needsHolding:            return "Kucakta uyuma".localized
        case .feedToSleep:             return "Emzirerek uyuma".localized
        }
    }
    
    /// Kullanıcıya gösterilecek açıklama
    var displayDescription: String {
        switch self {
        case .difficultyFallingAsleep:
            return "Bebeğiniz yatağa konulduğunda uzun süre uykuya dalamıyor.".localized
        case .frequentNightWaking:
            return "Gece boyunca sık sık uyanıyor ve tekrar uyumakta zorlanıyor.".localized
        case .shortNaps:
            return "Gündüz uykuları genellikle 30 dakikadan kısa sürüyor.".localized
        case .irregularSchedule:
            return "Uyku ve uyanma saatleri her gün farklılık gösteriyor.".localized
        case .nightTerrors:
            return "Gece uykusunda ağlama ve korku nöbetleri yaşıyor.".localized
        case .sleepRegression:
            return "Daha önce iyi uyurken artık uyku düzeni bozuldu.".localized
        case .needsHolding:
            return "Sadece kucakta veya sallanarak uyuyabiliyor.".localized
        case .feedToSleep:
            return "Uyumak için mutlaka emzirilmesi veya biberonla beslenmesi gerekiyor.".localized
        }
    }
    
    /// Problem için uygun SF Symbol ikonu
    var iconName: String {
        switch self {
        case .difficultyFallingAsleep: return "moon.zzz"
        case .frequentNightWaking:     return "bell.and.waves.left.and.right"
        case .shortNaps:               return "clock.badge.exclamationmark"
        case .irregularSchedule:       return "calendar.badge.clock"
        case .nightTerrors:            return "exclamationmark.triangle"
        case .sleepRegression:         return "arrow.uturn.backward"
        case .needsHolding:            return "hands.and.sparkles"
        case .feedToSleep:             return "cup.and.saucer"
        }
    }
}
