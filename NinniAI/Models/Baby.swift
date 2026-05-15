import Foundation
import SwiftData

// MARK: - Baby Model
/// Bebeğin ana profil modeli.
/// Onboarding sırasında oluşturulur ve uygulamanın tüm bağlamsal kararlarının merkezindedir.
/// Doğum tarihinden türetilen `ageInMonths`, ContextEngine ve MilestoneTracker için kritiktir.
@Model
final class Baby {
    
    // MARK: - Stored Properties
    
    /// Bebeğin adı (Onboarding Step 2'de alınır)
    var name: String
    
    /// Doğum tarihi — ay hesaplama, milestone ve bağlam motorunun temel girdisi
    var dateOfBirth: Date
    
    /// Bebeğin profil fotoğrafı (opsiyonel, cihazda saklanır)
    /// Binary olarak tutulur — küçük boyutlu bir thumbnail
    @Attribute(.externalStorage)
    var avatarData: Data?
    
    /// Onboarding'de seçilen uyku problemleri
    /// SleepProblem enum'unun rawValue'ları saklanır
    var sleepProblemRawValues: [String]
    
    /// Profil oluşturulma zamanı
    var createdAt: Date
    
    /// Son güncelleme zamanı
    var updatedAt: Date
    
    // MARK: - Relationships
    
    /// Bu bebeğe ait tüm uyku oturumları
    @Relationship(deleteRule: .cascade, inverse: \SleepSession.baby)
    var sleepSessions: [SleepSession]
    
    /// Bu bebeğin geçtiği kilometre taşları
    @Relationship(deleteRule: .cascade, inverse: \Milestone.baby)
    var milestones: [Milestone]
    
    /// Bu bebeğe ait kullanıcı ayarları (1:1 ilişki)
    @Relationship(deleteRule: .cascade, inverse: \UserSettings.baby)
    var settings: UserSettings?
    
    // MARK: - Computed Properties
    
    /// Bebeğin aylık yaşı — ContextEngine, Dashboard ve Milestone için kritik
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: .now).month ?? 0
    }
    
    /// Bebeğin gün cinsinden yaşı
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: dateOfBirth, to: .now).day ?? 0
    }
    
    /// Bebeğin yaş aralığı grubu (0-3, 4-6, 7-9, 10-12, 13-18, 19-24, 25-36 ay)
    var ageGroup: AgeGroup {
        AgeGroup.from(months: ageInMonths)
    }
    
    /// Uyku problemlerinin enum listesi
    var sleepProblems: [SleepProblem] {
        get {
            sleepProblemRawValues.compactMap { SleepProblem(rawValue: $0) }
        }
        set {
            sleepProblemRawValues = newValue.map(\.rawValue)
        }
    }
    
    // MARK: - Initializer
    
    init(
        name: String,
        dateOfBirth: Date,
        avatarData: Data? = nil,
        sleepProblems: [SleepProblem] = []
    ) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.avatarData = avatarData
        self.sleepProblemRawValues = sleepProblems.map(\.rawValue)
        self.createdAt = .now
        self.updatedAt = .now
        self.sleepSessions = []
        self.milestones = []
    }
}

// MARK: - Age Group
/// Bebeğin gelişim dönemini temsil eder.
/// ContextEngine bu bilgiyi ses önerileri ve dashboard içeriği için kullanır.
enum AgeGroup: String, Codable, CaseIterable {
    case newborn = "newborn"          // 0-3 ay
    case infant = "infant"            // 4-6 ay
    case crawler = "crawler"          // 7-9 ay
    case cruiser = "cruiser"          // 10-12 ay
    case toddlerEarly = "toddler_early" // 13-18 ay
    case toddlerLate = "toddler_late"   // 19-24 ay
    case preschooler = "preschooler"    // 25-36 ay
    
    static func from(months: Int) -> AgeGroup {
        switch months {
        case 0...3:   return .newborn
        case 4...6:   return .infant
        case 7...9:   return .crawler
        case 10...12: return .cruiser
        case 13...18: return .toddlerEarly
        case 19...24: return .toddlerLate
        default:      return .preschooler
        }
    }
    
    /// Bu yaş grubuna önerilen uyku süresi aralığı (saat cinsinden)
    var recommendedSleepHours: ClosedRange<Double> {
        switch self {
        case .newborn:      return 14...17
        case .infant:       return 12...16
        case .crawler:      return 12...16
        case .cruiser:      return 11...14
        case .toddlerEarly: return 11...14
        case .toddlerLate:  return 11...14
        case .preschooler:  return 10...13
        }
    }
    
    /// Kullanıcıya gösterilecek açıklayıcı başlık
    var displayTitle: String {
        switch self {
        case .newborn:      return "Yenidoğan"
        case .infant:       return "Bebek"
        case .crawler:      return "Emekleyen"
        case .cruiser:      return "Tutunan"
        case .toddlerEarly: return "Yürümeye Başlayan"
        case .toddlerLate:  return "Yürüyen"
        case .preschooler:  return "Okul Öncesi"
        }
    }
}
