import SwiftData
import Foundation

/// SwiftUI Preview'lar için örnek veri üreten yardımcı.
/// Tüm Preview'lar bu container'ı kullanarak tutarlı test verisi ile çalışır.
@MainActor
enum PreviewSampleData {
    
    /// In-memory SwiftData container (Preview için)
    static let container: ModelContainer = {
        let schema = Schema([
            Baby.self,
            Sound.self,
            SleepSession.self,
            Interruption.self,
            SoundUsage.self,
            Milestone.self,
            UserSettings.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // Örnek veri oluştur
            populateSampleData(in: container.mainContext)
            
            return container
        } catch {
            fatalError("Preview ModelContainer oluşturulamadı: \(error)")
        }
    }()
    
    /// Örnek verileri context'e ekler
    private static func populateSampleData(in context: ModelContext) {
        
        // MARK: - Örnek Bebek
        let baby = Baby(
            name: "Elif",
            dateOfBirth: Calendar.current.date(
                byAdding: .month, value: -6, to: .now
            ) ?? .now,
            sleepProblems: [.frequentNightWaking, .shortNaps]
        )
        context.insert(baby)
        
        // MARK: - Örnek Ayarlar
        let settings = UserSettings(baby: baby)
        settings.isOnboardingCompleted = true
        context.insert(settings)
        baby.settings = settings
        
        // MARK: - Örnek Sesler
        let sampleSounds: [(String, String, SoundCategory, Bool)] = [
            ("rain_gentle", "Hafif Yağmur", .nature, false),
            ("ocean_waves", "Okyanus Dalgaları", .nature, false),
            ("white_noise_fan", "Fan Sesi", .whiteNoise, false),
            ("heartbeat_slow", "Kalp Atışı", .heartbeat, false),
            ("lullaby_piano_01", "Piyano Ninni", .lullaby, true),
            ("train_rhythm", "Tren Ritmi", .ambient, true),
        ]
        
        var sounds: [Sound] = []
        for (index, item) in sampleSounds.enumerated() {
            let sound = Sound(
                identifier: item.0,
                displayName: item.1,
                fileName: item.0,
                category: item.2,
                durationInSeconds: 15,
                isPremium: item.3,
                sortOrder: index
            )
            context.insert(sound)
            sounds.append(sound)
        }
        
        // MARK: - Örnek Uyku Oturumları
        for dayOffset in 0..<7 {
            let sessionDate = Calendar.current.date(
                byAdding: .day, value: -dayOffset, to: .now
            ) ?? .now
            
            let session = SleepSession(
                baby: baby,
                soundIdentifiers: [sounds.first?.identifier ?? "rain_gentle"],
                timerDurationMinutes: 30,
                sessionType: dayOffset % 3 == 0 ? .nap : .nightSleep
            )
            session.startedAt = sessionDate
            session.endedAt = sessionDate.addingTimeInterval(
                Double.random(in: 1800...28800) // 30dk - 8 saat
            )
            session.qualityRating = Int.random(in: 3...5)
            context.insert(session)
            
            // Bazı oturumlara kesinti ekle
            if dayOffset % 2 == 0 {
                let interruption = Interruption(
                    session: session,
                    reason: .feeding
                )
                interruption.occurredAt = sessionDate.addingTimeInterval(3600)
                context.insert(interruption)
            }
        }
        
        // MARK: - Örnek Milestone
        let milestone = Milestone(
            baby: baby,
            type: .monthTransition,
            monthNumber: 6,
            title: "6. Ay Kutlu Olsun! 🎉",
            description: "Elif artık 6 aylık! Uyku düzeni giderek oturuyor."
        )
        context.insert(milestone)
    }
}
