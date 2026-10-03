import SwiftUI
import Foundation
import ObjectiveC

// MARK: - App Language
/// Desteklenen uygulama dilleri
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case turkish = "tr"
    case english = "en"
    
    var id: String { rawValue }
    
    /// BCP-47 dil kodu (nil = cihaz varsayılanı)
    var code: String? {
        switch self {
        case .system:  return nil
        case .turkish: return "tr"
        case .english: return "en"
        }
    }
    
    /// Ekranda gösterilen yerel isim
    var displayName: String {
        switch self {
        case .system:  return "Sistem Dili"
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    /// Açıklayıcı alt metin
    var subtitle: String {
        switch self {
        case .system:  return "Cihazınızın varsayılan dilini kullanır"
        case .turkish: return "Varsayılan"
        case .english: return "English (US/UK)"
        }
    }
    
    /// Bayrak ikonu
    var flag: String {
        switch self {
        case .system:  return "🌐"
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        }
    }
}

// MARK: - Bundle Dynamic Localization
private var bundleKey: UInt8 = 0

final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ languageCode: String) {
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : nil
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    static func resetLanguage() {
        objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Language Manager
/// Uygulama içi anlık dil değişim yöneticisi.
/// iOS 17+ @Observable mimarisi ile tüm widget ağacına anında reaktif bildirim sağlar.
@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    static let storageKey = "app_selected_language"
    
    /// Seçili dil
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
            applyLanguage(currentLanguage)
        }
    }
    
    /// SwiftUI Environment `\.locale` için aktif Locale nesnesi
    var locale: Locale {
        switch currentLanguage {
        case .system:
            return Locale.autoupdatingCurrent
        case .turkish:
            return Locale(identifier: "tr")
        case .english:
            return Locale(identifier: "en")
        }
    }
    
    /// BCP-47 dil kodu ("tr", "en" vb.)
    var activeLanguageCode: String {
        if let code = currentLanguage.code {
            return code
        }
        let preferred = Locale.preferredLanguages.first ?? "tr"
        return preferred.hasPrefix("en") ? "en" : "tr"
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppLanguage.system.rawValue
        let language = AppLanguage(rawValue: saved) ?? .system
        self.currentLanguage = language
        applyLanguage(language)
    }
    
    /// Dili değiştir ve anında tüm bundle ve sistem ayarlarına yansıt
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }
    
    private func applyLanguage(_ language: AppLanguage) {
        if let code = language.code {
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
            Bundle.setLanguage(code)
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            Bundle.resetLanguage()
        }
        UserDefaults.standard.synchronize()
    }
}
