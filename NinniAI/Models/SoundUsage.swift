import Foundation
import SwiftData

// MARK: - Sound Usage Model
/// Bir sesin kullanım istatistiklerini günlük bazda takip eder.
/// PRD §3.4: "En uzun süre kesintisiz dinlenen seslerin 'Başarı Puanı' artırılarak kullanıcıya önerilmesi."
///
/// SuccessScoreCalculator bu modeli kullanarak her ses için "başarı puanı" hesaplar.
/// Her gün yeni bir SoundUsage kaydı oluşturulur.
@Model
final class SoundUsage {
    
    /// Kullanım tarihi (sadece gün, saat sıfırlanmış)
    var date: Date
    
    /// Bu tarihte sesin kaç kez çalınmaya başlandığı
    var playCount: Int
    
    /// Bu tarihte sesin toplam dinlenme süresi (saniye)
    var totalDuration: TimeInterval
    
    /// Bu tarihteki en uzun kesintisiz dinlenme süresi (saniye)
    var longestStretch: TimeInterval
    
    /// Bu tarihte kaç oturumda sesin çalındığı sırada bebek kesintisiz uyudu
    var successfulSessionCount: Int
    
    /// Bu tarihte sesin çalındığı toplam oturum sayısı
    var totalSessionCount: Int
    
    // MARK: - Relationship
    
    /// Bu kullanım kaydının ait olduğu ses
    var sound: Sound?
    
    // MARK: - Computed Properties
    
    /// Başarı oranı (0.0 - 1.0)
    var successRate: Double {
        guard totalSessionCount > 0 else { return 0 }
        return Double(successfulSessionCount) / Double(totalSessionCount)
    }
    
    // MARK: - Initializer
    
    init(sound: Sound? = nil, date: Date = .now) {
        // Tarihi günün başlangıcına normalleştir
        self.date = Calendar.current.startOfDay(for: date)
        self.playCount = 0
        self.totalDuration = 0
        self.longestStretch = 0
        self.successfulSessionCount = 0
        self.totalSessionCount = 0
        self.sound = sound
    }
    
    // MARK: - Methods
    
    /// Bir çalma oturumunu kaydet
    func recordPlay(duration: TimeInterval, wasSuccessful: Bool) {
        playCount += 1
        totalDuration += duration
        totalSessionCount += 1
        if duration > longestStretch {
            longestStretch = duration
        }
        if wasSuccessful {
            successfulSessionCount += 1
        }
    }
}
