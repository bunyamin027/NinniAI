import Foundation
import SwiftData
import Observation

// MARK: - Milestone Tracker
/// Kilometre Taşı takipçisi.
/// PRD §3.2: "Bebeğin her yeni ayına geçişte özel karşılama ekranları."
/// PRD: "Her gece saat 00:01'de sistem doğum tarihini kontrol eder."
///
/// Bu servis periyodik olarak bebeğin yaşını kontrol eder ve
/// yeni bir aya geçildiğinde Milestone kaydı oluşturur.
@Observable
final class MilestoneTracker {
    
    // MARK: - State
    
    /// Gösterilmeyi bekleyen milestone (nil = bekleyen yok)
    private(set) var pendingMilestone: PendingMilestone?
    
    // MARK: - Check
    
    /// Yeni milestone olup olmadığını kontrol et
    /// - Parameters:
    ///   - baby: Kontrol edilecek bebek
    ///   - context: SwiftData context (yeni kayıt için)
    func checkForNewMilestones(baby: Baby, context: ModelContext) {
        let currentMonth = baby.ageInMonths
        
        // Zaten bu ay için milestone var mı?
        let existingMonths = Set(baby.milestones.map(\.monthNumber))
        
        guard !existingMonths.contains(currentMonth), currentMonth > 0 else {
            return
        }
        
        // Yeni ay geçişi tespit edildi — Milestone oluştur
        let milestone = createMonthMilestone(
            baby: baby,
            month: currentMonth
        )
        
        context.insert(milestone)
        
        // Yaş grubu geçişi kontrolü
        let previousMonth = currentMonth - 1
        let previousAgeGroup = AgeGroup.from(months: previousMonth)
        let currentAgeGroup = AgeGroup.from(months: currentMonth)
        
        if previousAgeGroup != currentAgeGroup {
            let transitionMilestone = createAgeGroupTransitionMilestone(
                baby: baby,
                month: currentMonth,
                newAgeGroup: currentAgeGroup
            )
            context.insert(transitionMilestone)
        }
        
        // Pending milestone'u gösterilmek üzere kaydet
        pendingMilestone = PendingMilestone(
            title: milestone.title,
            description: milestone.milestoneDescription,
            monthNumber: currentMonth,
            ageGroup: currentAgeGroup
        )
    }
    
    /// Pending milestone'u gösterildi olarak işaretle
    func dismissPendingMilestone() {
        pendingMilestone = nil
    }
    
    // MARK: - Milestone Creation
    
    private func createMonthMilestone(baby: Baby, month: Int) -> Milestone {
        let title = monthMilestoneTitle(month: month, babyName: baby.name)
        let description = monthMilestoneDescription(month: month)
        
        return Milestone(
            baby: baby,
            type: .monthTransition,
            monthNumber: month,
            title: title,
            description: description
        )
    }
    
    private func createAgeGroupTransitionMilestone(
        baby: Baby,
        month: Int,
        newAgeGroup: AgeGroup
    ) -> Milestone {
        return Milestone(
            baby: baby,
            type: .ageGroupTransition,
            monthNumber: month,
            title: "\(newAgeGroup.displayTitle) Dönemine Hoş Geldin! 🌟",
            description: "\(baby.name) artık \(newAgeGroup.displayTitle.lowercased()) döneminde. Uyku alışkanlıkları değişiyor olabilir."
        )
    }
    
    // MARK: - Content Generation
    
    private func monthMilestoneTitle(month: Int, babyName: String) -> String {
        let emoji = monthEmoji(month)
        return "\(month). Ay Kutlu Olsun! \(emoji)"
    }
    
    private func monthMilestoneDescription(month: Int) -> String {
        switch month {
        case 1:  return "İlk ay tamamlandı! Yenidoğan döneminin en yoğun zamanını atlattınız."
        case 2:  return "Bebeğiniz artık çevresini daha çok fark ediyor. Uyku düzeni yavaş yavaş oturmaya başlıyor."
        case 3:  return "3. ay bir dönüm noktası! Gece uykuları uzamaya başlayabilir."
        case 4:  return "4. ay uyku gerilemesi yaşanabilir — bu tamamen normal ve geçici."
        case 5:  return "Bebeğiniz artık daha uzun aralıklarla uyuyabiliyor."
        case 6:  return "Yarım yıl tamamlandı! Gece uykusu artık daha düzenli olmalı."
        case 7:  return "Emekleme dönemi uyku düzenini etkileyebilir. Sabırlı olun."
        case 8:  return "Ayrılık kaygısı bu dönemde uyku etkileyen bir faktör olabilir."
        case 9:  return "9 ay! Bebeğiniz artık çok daha bağımsız uyuyabiliyor."
        case 10: return "Tutunma ve ayakta durma heyecanı uykuyu etkileyebilir."
        case 11: return "Neredeyse 1 yaş! Uyku rutininiz artık iyice oturmuş olmalı."
        case 12: return "1 yaş kutlu olsun! 🎂 Harika bir yıl geçirdiniz."
        case 18: return "1.5 yaş! Gündüz uykusu tek şekerlemeye doğru geçiş yapabilir."
        case 24: return "2 yaş kutlu olsun! 🎉 Artık büyük çocuk yatağına geçiş düşünülebilir."
        case 36: return "3 yaş! Bebeğiniz artık bir okul öncesi çocuğu. Harika bir yolculuktu. 💫"
        default: return "\(month). aya ulaştınız. Uyku yolculuğunuzda harika ilerliyorsunuz!"
        }
    }
    
    private func monthEmoji(_ month: Int) -> String {
        switch month {
        case 1:  return "🌱"
        case 2:  return "🌸"
        case 3:  return "⭐️"
        case 4:  return "🦋"
        case 5:  return "🌈"
        case 6:  return "🎉"
        case 7:  return "🐣"
        case 8:  return "🌻"
        case 9:  return "🎈"
        case 10: return "🌟"
        case 11: return "✨"
        case 12: return "🎂"
        default: return "🎊"
        }
    }
}

// MARK: - Pending Milestone
/// Gösterilmeyi bekleyen milestone verisi (view için)
struct PendingMilestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let monthNumber: Int
    let ageGroup: AgeGroup
}
