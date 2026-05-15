import Foundation
import SwiftData

// MARK: - Sleep Session Model
/// Tek bir uyku oturumunu temsil eder.
/// PRD §3.4: "SwiftData ile toplanan verilerin (uyku süresi, uyanma sayısı) görselleştirilmesi."
///
/// Player başlatıldığında oluşturulur, durdurulduğunda tamamlanır.
/// AnalyticsEngine bu modelden trend ve başarı puanı hesaplar.
@Model
final class SleepSession {
    
    // MARK: - Stored Properties
    
    /// Oturumun başlangıç zamanı
    var startedAt: Date
    
    /// Oturumun bitiş zamanı (nil = hâlâ aktif)
    var endedAt: Date?
    
    /// Oturum sırasında çalınan ses ID'leri (mix destekli)
    var playedSoundIdentifiers: [String]
    
    /// Ayarlanan zamanlayıcı süresi (dakika, 0 = süresiz)
    var timerDurationMinutes: Int
    
    /// Oturum sırasındaki ortalama ses seviyesi
    var averageVolume: Float
    
    /// Oturum türü
    var sessionTypeRawValue: String
    
    /// Oturum tamamlandıktan sonra kullanıcının verdiği uyku kalitesi notu (1-5)
    var qualityRating: Int?
    
    /// Opsiyonel not
    var note: String?
    
    /// Oluşturulma zamanı
    var createdAt: Date
    
    // MARK: - Relationships
    
    /// Bu oturumun ait olduğu bebek
    var baby: Baby?
    
    /// Oturum sırasındaki kesintiler
    @Relationship(deleteRule: .cascade, inverse: \Interruption.session)
    var interruptions: [Interruption]
    
    // MARK: - Computed Properties
    
    /// Oturum türü enum değeri
    var sessionType: SessionType {
        get { SessionType(rawValue: sessionTypeRawValue) ?? .nightSleep }
        set { sessionTypeRawValue = newValue.rawValue }
    }
    
    /// Oturum süresi (saniye)
    var durationInSeconds: TimeInterval? {
        guard let endedAt else { return nil }
        return endedAt.timeIntervalSince(startedAt)
    }
    
    /// Oturum süresi (dakika)
    var durationInMinutes: Double? {
        guard let seconds = durationInSeconds else { return nil }
        return seconds / 60.0
    }
    
    /// Oturum aktif mi?
    var isActive: Bool {
        endedAt == nil
    }
    
    /// Kesintisiz uyku süresi (saniye) — en uzun kesintisiz aralık
    var longestUninterruptedStretch: TimeInterval {
        guard !interruptions.isEmpty else {
            return durationInSeconds ?? 0
        }
        
        let sorted = interruptions.sorted { $0.occurredAt < $1.occurredAt }
        var stretches: [TimeInterval] = []
        var lastPoint = startedAt
        
        for interruption in sorted {
            stretches.append(interruption.occurredAt.timeIntervalSince(lastPoint))
            lastPoint = interruption.occurredAt
        }
        
        if let endedAt {
            stretches.append(endedAt.timeIntervalSince(lastPoint))
        }
        
        return stretches.max() ?? 0
    }
    
    /// Kesinti sayısı
    var interruptionCount: Int {
        interruptions.count
    }
    
    // MARK: - Initializer
    
    init(
        baby: Baby? = nil,
        soundIdentifiers: [String] = [],
        timerDurationMinutes: Int = 0,
        averageVolume: Float = 0.7,
        sessionType: SessionType = .nightSleep
    ) {
        self.startedAt = .now
        self.playedSoundIdentifiers = soundIdentifiers
        self.timerDurationMinutes = timerDurationMinutes
        self.averageVolume = averageVolume
        self.sessionTypeRawValue = sessionType.rawValue
        self.createdAt = .now
        self.baby = baby
        self.interruptions = []
    }
    
    // MARK: - Methods
    
    /// Oturumu tamamla
    func complete(qualityRating: Int? = nil, note: String? = nil) {
        self.endedAt = .now
        self.qualityRating = qualityRating
        self.note = note
    }
}

// MARK: - Session Type
/// Uyku oturumunun türü. Dashboard ve Analytics bu bilgiyi gruplamak için kullanır.
enum SessionType: String, Codable, CaseIterable {
    case nightSleep = "night_sleep"     // Gece uykusu
    case nap = "nap"                     // Gündüz uykusu (şekerleme)
    case calming = "calming"             // Sakinleştirme oturumu
    
    var displayTitle: String {
        switch self {
        case .nightSleep: return "Gece Uykusu"
        case .nap:        return "Gündüz Uykusu"
        case .calming:    return "Sakinleştirme"
        }
    }
    
    var iconName: String {
        switch self {
        case .nightSleep: return "moon.stars.fill"
        case .nap:        return "sun.and.horizon.fill"
        case .calming:    return "sparkles"
        }
    }
}
