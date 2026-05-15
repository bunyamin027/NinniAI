import Foundation
import SwiftData

// MARK: - Interruption Model
/// Bir uyku oturumu sırasındaki kesinti kaydı.
/// PRD §3.4: "uyanma sayısı" verisi bu modelden toplanır.
///
/// Kullanıcı player'ı durdurduğunda veya bebeğin uyandığını kaydettiğinde oluşturulur.
/// AnalyticsEngine bu modeli kesintisiz uyku süresi hesaplamak için kullanır.
@Model
final class Interruption {
    
    /// Kesintinin gerçekleştiği zaman
    var occurredAt: Date
    
    /// Kesintinin süresi (saniye, nil = bilinmiyor)
    var durationInSeconds: Double?
    
    /// Kesinti sebebi
    var reasonRawValue: String?
    
    /// Opsiyonel not
    var note: String?
    
    // MARK: - Relationship
    
    /// Bu kesintinin ait olduğu uyku oturumu
    var session: SleepSession?
    
    // MARK: - Computed Properties
    
    var reason: InterruptionReason? {
        get {
            guard let raw = reasonRawValue else { return nil }
            return InterruptionReason(rawValue: raw)
        }
        set { reasonRawValue = newValue?.rawValue }
    }
    
    // MARK: - Initializer
    
    init(
        session: SleepSession? = nil,
        reason: InterruptionReason? = nil,
        note: String? = nil
    ) {
        self.occurredAt = .now
        self.reasonRawValue = reason?.rawValue
        self.note = note
        self.session = session
    }
}

// MARK: - Interruption Reason
/// Uyku kesintisi sebebi. Opsiyonel olarak kullanıcı tarafından kaydedilir.
enum InterruptionReason: String, Codable, CaseIterable {
    case feeding = "feeding"           // Beslenme
    case diaperChange = "diaper"       // Alt değiştirme
    case crying = "crying"             // Ağlama
    case noise = "noise"               // Dış ses
    case unknown = "unknown"           // Bilinmiyor
    
    var displayTitle: String {
        switch self {
        case .feeding:      return "Beslenme"
        case .diaperChange: return "Alt Değiştirme"
        case .crying:       return "Ağlama"
        case .noise:        return "Dış Ses"
        case .unknown:      return "Bilinmiyor"
        }
    }
    
    var iconName: String {
        switch self {
        case .feeding:      return "cup.and.saucer.fill"
        case .diaperChange: return "arrow.triangle.2.circlepath"
        case .crying:       return "drop.fill"
        case .noise:        return "speaker.wave.3.fill"
        case .unknown:      return "questionmark.circle"
        }
    }
}
