import Foundation

// MARK: - Sound Category
/// Ses dosyalarının kategorilendirme yapısı.
/// PRD §3.3: "100 adet gömülü .m4a ses dosyası" — bunlar kategorilere ayrılır.
/// Player'daki SoundPickerView bu kategorileri kullanarak grid oluşturur.
enum SoundCategory: String, Codable, CaseIterable, Identifiable {
    
    /// Beyaz gürültü türevleri (fan, saç kurutma, TV cızırtısı vb.)
    case whiteNoise = "white_noise"
    
    /// Doğa sesleri (yağmur, okyanus, rüzgar, kuş vb.)
    case nature = "nature"
    
    /// Ninniler (enstrümantal, vokal-sız melodiler)
    case lullaby = "lullaby"
    
    /// Kalp atışı ve rahim sesleri (yenidoğan özelleştirilmiş)
    case heartbeat = "heartbeat"
    
    /// Ortam sesleri (tren, araba, şömine vb.)
    case ambient = "ambient"
    
    var id: String { rawValue }
    
    /// Kullanıcıya gösterilecek başlık
    var displayTitle: String {
        switch self {
        case .whiteNoise: return "Beyaz Gürültü"
        case .nature:     return "Doğa Sesleri"
        case .lullaby:    return "Ninniler"
        case .heartbeat:  return "Kalp Atışı"
        case .ambient:    return "Ortam Sesleri"
        }
    }
    
    /// Kategoriye ait SF Symbol ikonu
    var iconName: String {
        switch self {
        case .whiteNoise: return "waveform"
        case .nature:     return "leaf.fill"
        case .lullaby:    return "music.note"
        case .heartbeat:  return "heart.fill"
        case .ambient:    return "house.fill"
        }
    }
    
    /// Kategorinin Resources/Sounds altındaki klasör adı
    var folderName: String {
        switch self {
        case .whiteNoise: return "WhiteNoise"
        case .nature:     return "Nature"
        case .lullaby:    return "Lullaby"
        case .heartbeat:  return "Heartbeat"
        case .ambient:    return "Ambient"
        }
    }
    
    /// Kategorinin varsayılan gradient renk çifti (hex)
    /// Antigravity tema sistemine bağlanır
    var gradientColors: (start: String, end: String) {
        switch self {
        case .whiteNoise: return ("#A78BFA", "#7C3AED") // Mor tonları
        case .nature:     return ("#34D399", "#059669") // Yeşil tonları
        case .lullaby:    return ("#F9A8D4", "#DB2777") // Pembe tonları
        case .heartbeat:  return ("#F87171", "#DC2626") // Kırmızı tonları
        case .ambient:    return ("#60A5FA", "#2563EB") // Mavi tonları
        }
    }
    
    /// Bu kategorinin hangi yaş gruplarına özellikle uygun olduğu
    var recommendedAgeGroups: [AgeGroup] {
        switch self {
        case .whiteNoise:
            return AgeGroup.allCases // Tüm yaş gruplarına uygun
        case .nature:
            return [.crawler, .cruiser, .toddlerEarly, .toddlerLate, .preschooler]
        case .lullaby:
            return AgeGroup.allCases
        case .heartbeat:
            return [.newborn, .infant] // Özellikle yenidoğan ve bebekler için
        case .ambient:
            return [.infant, .crawler, .cruiser, .toddlerEarly, .toddlerLate]
        }
    }
}
