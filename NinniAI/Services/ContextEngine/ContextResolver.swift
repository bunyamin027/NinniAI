import Foundation
import Observation

// MARK: - Context Resolver
/// Yerel Bağlam Motoru — Uygulamanın "beyni".
/// PRD §3: "İnternet bağlantısına ihtiyaç duymayan, cihaz içinde çalışan
/// deterministik Yerel Bağlam Motoru (Local Context Engine)."
///
/// Bu motor, saate, bebeğin yaşına ve kullanım geçmişine göre
/// dinamik kararlar alır:
/// - Dashboard'da hangi içeriğin gösterileceği
/// - Gece modu aktifleştirilmeli mi
/// - Hangi sesler önerilebilir
/// - Karşılama mesajı ne olmalı
@Observable
final class ContextResolver {
    
    // MARK: - Resolved Context
    
    /// Şu anki çözümlenmiş bağlam
    private(set) var currentContext: ResolvedContext
    
    /// Gece modu çözümleyici
    let nightMode: NightModeResolver
    
    /// Milestone takipçisi
    let milestoneTracker: MilestoneTracker
    
    // MARK: - Init
    
    init() {
        self.nightMode = NightModeResolver()
        self.milestoneTracker = MilestoneTracker()
        self.currentContext = ResolvedContext()
        resolve()
    }
    
    // MARK: - Resolve
    
    /// Bağlamı yeniden çözümle (her uygulama açılışında ve periyodik olarak çağrılır)
    func resolve(baby: Baby? = nil) {
        let now = Date.now
        let hour = now.hour
        
        // Zaman dilimi
        let timeOfDay = TimeOfDay.from(hour: hour)
        
        // Karşılama mesajı
        let greeting = resolveGreeting(timeOfDay: timeOfDay, baby: baby)
        
        // Alt başlık (bağlamsal mesaj)
        let subtitle = resolveSubtitle(timeOfDay: timeOfDay, baby: baby)
        
        // Gece modu durumu
        let isNightMode = nightMode.shouldActivate(at: now)
        
        // Önerilen ses kategorisi
        let suggestedCategory = resolveSuggestedCategory(
            timeOfDay: timeOfDay,
            baby: baby
        )
        
        // Önerilen zamanlayıcı süresi
        let suggestedTimer = resolveSuggestedTimer(timeOfDay: timeOfDay)
        
        currentContext = ResolvedContext(
            timeOfDay: timeOfDay,
            greeting: greeting,
            subtitle: subtitle,
            isNightMode: isNightMode,
            suggestedCategory: suggestedCategory,
            suggestedTimerMinutes: suggestedTimer,
            resolvedAt: now
        )
    }
    
    // MARK: - Greeting Resolution
    
    private func resolveGreeting(timeOfDay: TimeOfDay, baby: Baby?) -> String {
        let babyName = baby?.name ?? ""
        
        switch timeOfDay {
        case .lateNight:
            return babyName.isEmpty ? "Geç saatlere kadar buradayız" : "\(babyName) için buradayız"
        case .earlyMorning:
            return "Günaydın ☀️"
        case .morning:
            return babyName.isEmpty ? "Günaydın!" : "Günaydın, \(babyName)!"
        case .noon:
            return "Öğle uykusu vakti 😴"
        case .afternoon:
            return babyName.isEmpty ? "İyi günler" : "\(babyName) nasıl?"
        case .evening:
            return "İyi akşamlar 🌙"
        case .night:
            return babyName.isEmpty ? "İyi geceler" : "İyi geceler, \(babyName) 🌙"
        }
    }
    
    // MARK: - Subtitle Resolution
    
    private func resolveSubtitle(timeOfDay: TimeOfDay, baby: Baby?) -> String {
        // Bebek varsa yaşa göre bağlamsal mesaj
        if let baby {
            let ageMonths = baby.ageInMonths
            let ageGroup = baby.ageGroup
            
            switch timeOfDay {
            case .lateNight:
                return "Gece uykusuna dönmek için sakin sesler hazır"
            case .earlyMorning, .morning:
                if ageMonths <= 3 {
                    return "Yenidoğan döneminde kısa uyku araları normal"
                }
                return "Güne enerjik başlamak için hazır mısınız?"
            case .noon:
                return "\(ageGroup.displayTitle) döneminde öğle uykusu önemli"
            case .afternoon:
                if ageMonths <= 6 {
                    return "İkindi şekerlemesi bebeğiniz için iyi olabilir"
                }
                return "Akşam rutinine hazırlanma vakti yaklaşıyor"
            case .evening:
                return "Uyku rutinine başlamak için harika bir zaman"
            case .night:
                return "Sakin seslerle huzurlu bir gece dileriz"
            }
        }
        
        // Bebek yoksa (onboarding öncesi) genel mesajlar
        switch timeOfDay {
        case .lateNight:  return "Gece uykusuna yardımcı sesler"
        case .earlyMorning, .morning: return "Güne güzel başlayın"
        case .noon:       return "Öğle uykusu için ideal sesler"
        case .afternoon:  return "Sakinleştirici sesler hazır"
        case .evening:    return "Akşam rutini için sesler"
        case .night:      return "İyi geceler, tatlı rüyalar"
        }
    }
    
    // MARK: - Suggested Category
    
    private func resolveSuggestedCategory(
        timeOfDay: TimeOfDay,
        baby: Baby?
    ) -> SoundCategory {
        let ageGroup = baby?.ageGroup
        
        // Yenidoğan için kalp atışı öncelikli
        if ageGroup == .newborn {
            return timeOfDay == .night || timeOfDay == .lateNight
                ? .heartbeat
                : .whiteNoise
        }
        
        // Saate göre kategori önerisi
        switch timeOfDay {
        case .lateNight, .night:
            return .whiteNoise
        case .earlyMorning, .morning:
            return .nature
        case .noon:
            return .lullaby
        case .afternoon:
            return .ambient
        case .evening:
            return .lullaby
        }
    }
    
    // MARK: - Suggested Timer
    
    private func resolveSuggestedTimer(timeOfDay: TimeOfDay) -> Int {
        switch timeOfDay {
        case .lateNight:              return 30
        case .earlyMorning, .morning: return 30
        case .noon:                   return 45
        case .afternoon:              return 30
        case .evening:                return 60
        case .night:                  return 90
        }
    }
}

// MARK: - Resolved Context
/// Çözümlenmiş bağlam verisi — View'lar bu struct'ı okur.
struct ResolvedContext {
    let timeOfDay: TimeOfDay
    let greeting: String
    let subtitle: String
    let isNightMode: Bool
    let suggestedCategory: SoundCategory
    let suggestedTimerMinutes: Int
    let resolvedAt: Date
    
    init(
        timeOfDay: TimeOfDay = .night,
        greeting: String = "Hoş geldiniz",
        subtitle: String = "",
        isNightMode: Bool = false,
        suggestedCategory: SoundCategory = .whiteNoise,
        suggestedTimerMinutes: Int = 30,
        resolvedAt: Date = .now
    ) {
        self.timeOfDay = timeOfDay
        self.greeting = greeting
        self.subtitle = subtitle
        self.isNightMode = isNightMode
        self.suggestedCategory = suggestedCategory
        self.suggestedTimerMinutes = suggestedTimerMinutes
        self.resolvedAt = resolvedAt
    }
}

// MARK: - Time of Day
/// Günün zaman dilimi — ContextEngine'in temel kararlarından biri.
enum TimeOfDay: String, CaseIterable {
    case lateNight    = "late_night"     // 00:00 - 05:59
    case earlyMorning = "early_morning"  // 06:00 - 07:59
    case morning      = "morning"        // 08:00 - 11:59
    case noon         = "noon"           // 12:00 - 13:59
    case afternoon    = "afternoon"      // 14:00 - 17:59
    case evening      = "evening"        // 18:00 - 20:59
    case night        = "night"          // 21:00 - 23:59
    
    static func from(hour: Int) -> TimeOfDay {
        switch hour {
        case 0..<6:   return .lateNight
        case 6..<8:   return .earlyMorning
        case 8..<12:  return .morning
        case 12..<14: return .noon
        case 14..<18: return .afternoon
        case 18..<21: return .evening
        default:      return .night
        }
    }
    
    /// Bu zaman diliminin arka plan stili
    var gradientStyle: GradientStyle {
        switch self {
        case .lateNight:  return .nightMode
        case .night:      return .default
        default:          return .default
        }
    }
}
