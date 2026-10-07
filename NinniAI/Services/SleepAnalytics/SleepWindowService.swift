import Foundation

// MARK: - Sleep Window Status
/// Uyku penceresi anlık durumu
enum SleepWindowStatus {
    case playing        // Bebeğin uyanık ve dinç olduğu ilk evre
    case approaching    // Uyku penceresi yaklaşıyor (15-30 dk kala)
    case optimal        // İdeal uyku penceresi aralığı (dalma zamanı)
    case overtired      // Aşırı yorulma evresi (uyku penceresi aşıldı)
    
    var title: String {
        switch self {
        case .playing:     return "Uyanık & Dinç".localized
        case .approaching: return "Uykuya Hazırlık".localized
        case .optimal:     return "İdeal Uyku Penceresi".localized
        case .overtired:   return "Aşırı Yorgunluk Riski".localized
        }
    }
}

// MARK: - Sleep Window Service
/// Akıllı Uyku Penceresi (Smart Sleep Window) Algoritması.
/// Bebeğin ayına göre uyanıklık pencerelerini (wake windows) hesaplar ve
/// ebeveynleri aşırı yorulmadan önce doğru anda yönlendirir.
final class SleepWindowService {
    
    static let shared = SleepWindowService()
    
    private init() {}
    
    // MARK: - Wake Window Mapping (Dakika Cinsinden)
    
    /// Bebeğin ayına göre ortalama ideal uyanıklık süreleri (dakika)
    /// Pediatrik uyku bilimsel standartları:
    /// - 0-1 ay: 60 dk (45-60 dk)
    /// - 2-3 ay: 90 dk (60-90 dk)
    /// - 4-6 ay: 120 dk (90-120 dk)
    /// - 7-9 ay: 180 dk (2.5 - 3 saat)
    /// - 10-12 ay: 210 dk (3 - 3.5 saat)
    /// - 13-18 ay: 270 dk (4 - 4.5 saat)
    /// - 19+ ay: 300 dk (5 saat)
    func wakeWindowMinutes(forAgeInMonths ageInMonths: Int) -> Int {
        switch ageInMonths {
        case 0...1:
            return 60
        case 2...3:
            return 90
        case 4...6:
            return 120
        case 7...9:
            return 180
        case 10...12:
            return 210
        case 13...18:
            return 270
        default:
            return 300
        }
    }
    
    // MARK: - Sleep Time Calculation
    
    /// Bebeğin uyandığı saate ve yaşına göre bir sonraki tahmini ideal uyku saatini hesaplar
    func calculateNextSleepTime(wakeUpTime: Date, ageInMonths: Int) -> Date {
        let windowMinutes = wakeWindowMinutes(forAgeInMonths: ageInMonths)
        return wakeUpTime.addingTimeInterval(TimeInterval(windowMinutes * 60))
    }
    
    /// Hatırlatma bildiriminin kurulacağı anı hesaplar (İdeal saatten 15 dk önce)
    func calculateReminderTime(optimalSleepTime: Date, leadMinutes: Int = 15) -> Date {
        return optimalSleepTime.addingTimeInterval(-TimeInterval(leadMinutes * 60))
    }
    
    // MARK: - Dynamic State Helpers
    
    /// Kalan süreyi insan tarafından okunabilir formata dönüştürür (Örn: "1 sa 15 dk", "45 dk")
    func remainingTimeText(from now: Date = Date(), to optimalSleepTime: Date) -> String {
        let diff = optimalSleepTime.timeIntervalSince(now)
        let saText = "sa".localized
        let dkText = "dk".localized
        
        if diff <= 0 {
            let pastMinutes = Int(abs(diff)) / 60
            let geciktiText = "dk gecikti".localized
            return pastMinutes > 0 ? "+\(pastMinutes) \(geciktiText)" : "Şimdi".localized
        }
        
        let totalMinutes = Int(diff) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours) \(saText) \(minutes) \(dkText)"
        } else {
            return "\(minutes) \(dkText)"
        }
    }
    
    /// Şu anki uyanıklık durumunu analiz eder
    func evaluateStatus(wakeUpTime: Date, ageInMonths: Int, now: Date = Date()) -> SleepWindowStatus {
        let optimalTime = calculateNextSleepTime(wakeUpTime: wakeUpTime, ageInMonths: ageInMonths)
        let diff = optimalTime.timeIntervalSince(now)
        
        if diff < 0 {
            return .overtired
        } else if diff <= 15 * 60 {
            return .optimal
        } else if diff <= 30 * 60 {
            return .approaching
        } else {
            return .playing
        }
    }
}
