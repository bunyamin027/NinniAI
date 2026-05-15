import Foundation
import SwiftData

// MARK: - Sound Model
/// Uygulama içindeki her bir ses dosyasının metadata'sını temsil eder.
/// PRD §3.3: "100 adet gömülü .m4a ses dosyası"
@Model
final class Sound {
    
    @Attribute(.unique)
    var identifier: String
    
    var displayName: String
    var soundDescription: String?
    var fileName: String
    var fileExtension: String
    var categoryRawValue: String
    var durationInSeconds: Double
    var isPremium: Bool
    var isFavorite: Bool
    var isMixable: Bool
    var defaultVolume: Float
    var minimumAgeGroupRawValue: String?
    var sortOrder: Int
    var createdAt: Date
    
    // MARK: - Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \SoundUsage.sound)
    var usageRecords: [SoundUsage]
    
    // MARK: - Computed Properties
    
    var category: SoundCategory {
        get { SoundCategory(rawValue: categoryRawValue) ?? .whiteNoise }
        set { categoryRawValue = newValue.rawValue }
    }
    
    var minimumAgeGroup: AgeGroup? {
        get {
            guard let raw = minimumAgeGroupRawValue else { return nil }
            return AgeGroup(rawValue: raw)
        }
        set { minimumAgeGroupRawValue = newValue?.rawValue }
    }
    
    var bundleURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
    
    var totalPlayCount: Int {
        usageRecords.reduce(0) { $0 + $1.playCount }
    }
    
    var totalListenDuration: TimeInterval {
        usageRecords.reduce(0) { $0 + $1.totalDuration }
    }
    
    // MARK: - Initializer
    
    init(
        identifier: String,
        displayName: String,
        soundDescription: String? = nil,
        fileName: String,
        fileExtension: String = "m4a",
        category: SoundCategory,
        durationInSeconds: Double,
        isPremium: Bool = false,
        isMixable: Bool = true,
        defaultVolume: Float = 0.7,
        minimumAgeGroup: AgeGroup? = nil,
        sortOrder: Int = 0
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.soundDescription = soundDescription
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.categoryRawValue = category.rawValue
        self.durationInSeconds = durationInSeconds
        self.isPremium = isPremium
        self.isFavorite = false
        self.isMixable = isMixable
        self.defaultVolume = defaultVolume
        self.minimumAgeGroupRawValue = minimumAgeGroup?.rawValue
        self.sortOrder = sortOrder
        self.createdAt = .now
        self.usageRecords = []
    }
}
