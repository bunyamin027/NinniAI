import Foundation
import SwiftData

// MARK: - Sound Seeder
/// Bundle içindeki .m4a dosyalarını tarayıp SwiftData'ya
/// kaydeden ilk çalışma servisi.
///
/// Dosya adlarındaki anahtar kelimelere göre
/// otomatik kategori ve görüntülenme adı üretir.
enum SoundSeeder {
    
    /// Eğer Sound tablosu boşsa, Bundle'daki tüm .m4a dosyalarını seed'le
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        // Zaten seed edilmiş mi kontrol et
        let descriptor = FetchDescriptor<Sound>()
        let existingSounds = (try? context.fetch(descriptor)) ?? []
        
        guard existingSounds.isEmpty else {
            // Zaten seed edilmiş, verileri SoundDataMap ile eşitleyip güncelle
            var updatedCount = 0
            for sound in existingSounds {
                if let mappedTrack = SoundDataMap.track(forFilename: sound.fileName) {
                    let category = SoundDataMap.allSections.first { $0.tracks.contains(mappedTrack) }?.category ?? sound.category
                    
                    var didUpdate = false
                    
                    if sound.displayName != mappedTrack.displayName {
                        sound.displayName = mappedTrack.displayName
                        didUpdate = true
                    }
                    if sound.soundDescription != mappedTrack.description {
                        sound.soundDescription = mappedTrack.description
                        didUpdate = true
                    }
                    if sound.categoryRawValue != category.rawValue {
                        sound.categoryRawValue = category.rawValue
                        didUpdate = true
                    }
                    if sound.isPremium != mappedTrack.isPremium {
                        sound.isPremium = mappedTrack.isPremium
                        didUpdate = true
                    }
                    if sound.sortOrder != mappedTrack.sortOrder {
                        sound.sortOrder = mappedTrack.sortOrder
                        didUpdate = true
                    }
                    
                    if didUpdate {
                        updatedCount += 1
                    }
                }
            }
            
            if updatedCount > 0 {
                try? context.save()
                print("✅ \(updatedCount) mevcut ses dosyası SoundDataMap isimleriyle güncellendi")
            } else {
                print("✅ Sound seed zaten mevcut ve güncel (\(existingSounds.count) ses)")
            }
            return
        }
        
        // Bundle'daki tüm .m4a dosyalarını tara
        guard let soundURLs = Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: nil) else {
            print("⚠️ Bundle'da .m4a dosyası bulunamadı")
            return
        }
        
        let sortedURLs = soundURLs.sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        for (index, url) in sortedURLs.enumerated() {
            let fileName = url.deletingPathExtension().lastPathComponent
            
            // Önce SoundDataMap'ten premium UI verisini ara
            let mappedTrack = SoundDataMap.track(forFilename: fileName)
            
            let displayName = mappedTrack?.displayName ?? generateDisplayName(from: fileName)
            let category = mappedTrack.flatMap { track in
                SoundDataMap.allSections.first { $0.tracks.contains(track) }?.category
            } ?? detectCategory(from: fileName)
            let isPremium = mappedTrack?.isPremium ?? (index >= 15)
            let sortOrder = mappedTrack?.sortOrder ?? index
            
            let sound = Sound(
                identifier: fileName,
                displayName: displayName,
                soundDescription: mappedTrack?.description,
                fileName: fileName,
                fileExtension: "m4a",
                category: category,
                durationInSeconds: 60,
                isPremium: isPremium,
                sortOrder: sortOrder
            )
            context.insert(sound)
        }
        
        try? context.save()
        print("✅ \(sortedURLs.count) ses dosyası seed edildi (SoundDataMap aktif)")
    }
    
    // MARK: - Display Name Generator
    
    /// Dosya adından okunabilir bir görüntüleme adı üretir
    /// Örnek: "backgroundmusicforvideos-lullaby-baby-sleep-music-388567" → "Lullaby Baby Sleep Music"
    private static func generateDisplayName(from fileName: String) -> String {
        // Son sayısal ID'yi kaldır (ör: -388567)
        var cleaned = fileName
        if let lastDashRange = cleaned.range(of: #"-\d+$"#, options: .regularExpression) {
            cleaned = String(cleaned[cleaned.startIndex..<lastDashRange.lowerBound])
        }
        
        // İlk kısmı (sanatçı adını) kaldır
        if let firstDash = cleaned.firstIndex(of: "-") {
            cleaned = String(cleaned[cleaned.index(after: firstDash)...])
        }
        
        // Tire ve alt çizgileri boşluğa çevir, capitalize et
        let words = cleaned
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
        
        return words.isEmpty ? fileName : words
    }
    
    // MARK: - Category Detection
    
    /// Dosya adındaki anahtar kelimelere göre kategori belirle
    private static func detectCategory(from fileName: String) -> SoundCategory {
        let lower = fileName.lowercased()
        
        // Heartbeat
        if lower.contains("heartbeat") || lower.contains("heart") || lower.contains("womb") {
            return .heartbeat
        }
        
        // Nature
        if lower.contains("rain") || lower.contains("ocean") || lower.contains("forest")
            || lower.contains("nature") || lower.contains("thunder") {
            return .nature
        }
        
        // White Noise / Binaural
        if lower.contains("white-noise") || lower.contains("binaural")
            || lower.contains("hz") || lower.contains("chakra") || lower.contains("frequency") {
            return .whiteNoise
        }
        
        // Lullaby
        if lower.contains("lullaby") || lower.contains("cradle") || lower.contains("music-box")
            || lower.contains("baby-sleep") || lower.contains("sleep-music")
            || lower.contains("ninni") || lower.contains("soft-loop") {
            return .lullaby
        }
        
        // Meditation / Ambient
        if lower.contains("meditation") || lower.contains("ambient")
            || lower.contains("relaxation") || lower.contains("relaxing")
            || lower.contains("calm") || lower.contains("sedative")
            || lower.contains("silence") || lower.contains("cosmic") {
            return .ambient
        }
        
        // Kids
        if lower.contains("kids") || lower.contains("children") || lower.contains("cartoon")
            || lower.contains("baby-smile") || lower.contains("baby-joy") {
            return .lullaby
        }
        
        // Varsayılan
        return .ambient
    }
}
