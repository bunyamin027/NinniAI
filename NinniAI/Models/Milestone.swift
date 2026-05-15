import Foundation
import SwiftData

// MARK: - Milestone Model
/// Bebeğin gelişim kilometre taşlarını temsil eder.
/// PRD §3.2: "Bebeğin her yeni ayına geçişte özel karşılama ekranları."
///
/// MilestoneTracker servisi her gün kontrol eder ve yeni aya geçişte
/// otomatik olarak bir Milestone kaydı oluşturur.
/// Dashboard bu modeli MilestoneCardView'da göstermek için kullanır.
@Model
final class Milestone {
    
    /// Milestone'un türü rawValue'su
    var typeRawValue: String
    
    /// Milestone'un tetiklendiği tarih
    var achievedAt: Date
    
    /// Milestone'un ait olduğu bebek ayı (örn: 3 = 3. ay geçişi)
    var monthNumber: Int
    
    /// Milestone başlığı (kullanıcıya gösterilecek)
    var title: String
    
    /// Milestone açıklaması
    var milestoneDescription: String
    
    /// Kullanıcı bu milestone'u gördü mü?
    var isSeen: Bool
    
    /// Kullanıcı bu milestone'u kaydetti / paylaştı mı?
    var isShared: Bool
    
    // MARK: - Relationship
    
    /// Bu milestone'un ait olduğu bebek
    var baby: Baby?
    
    // MARK: - Computed Properties
    
    var type: MilestoneType {
        get { MilestoneType(rawValue: typeRawValue) ?? .monthTransition }
        set { typeRawValue = newValue.rawValue }
    }
    
    // MARK: - Initializer
    
    init(
        baby: Baby? = nil,
        type: MilestoneType = .monthTransition,
        monthNumber: Int,
        title: String,
        description: String
    ) {
        self.baby = baby
        self.typeRawValue = type.rawValue
        self.achievedAt = .now
        self.monthNumber = monthNumber
        self.title = title
        self.milestoneDescription = description
        self.isSeen = false
        self.isShared = false
    }
}

// MARK: - Milestone Type
/// Kilometre taşı türleri
enum MilestoneType: String, Codable, CaseIterable {
    /// Yeni aya geçiş (her ay otomatik)
    case monthTransition = "month_transition"
    /// Uyku başarısı (örn: "İlk 8 saat kesintisiz gece!")
    case sleepAchievement = "sleep_achievement"
    /// Kullanım başarısı (örn: "100. uyku seansınız!")
    case usageAchievement = "usage_achievement"
    /// Yaş grubu geçişi (örn: yenidoğan → bebek)
    case ageGroupTransition = "age_group_transition"
    
    var iconName: String {
        switch self {
        case .monthTransition:    return "star.fill"
        case .sleepAchievement:   return "trophy.fill"
        case .usageAchievement:   return "medal.fill"
        case .ageGroupTransition: return "arrow.up.right.circle.fill"
        }
    }
}
