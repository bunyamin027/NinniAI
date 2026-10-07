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
        case .system:  return "Sistem Dili".localized
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    /// Açıklayıcı alt metin
    var subtitle: String {
        switch self {
        case .system:  return "Cihazınızın varsayılan dilini kullanır".localized
        case .turkish: return "Varsayılan".localized
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
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            let val = bundle.localizedString(forKey: key, value: value, table: tableName)
            if val != key {
                return val
            }
        }
        if let direct = LanguageManager.shared.directLookup(key: key) {
            return direct
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
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
/// iOS 17+ @Observable mimarisi ile tüm görünüm ağacına reaktif yenileme sağlar.
@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    static let storageKey = "app_selected_language"
    
    /// Seçili dil
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
            languageChangeCounter += 1
            applyLanguage(currentLanguage)
        }
    }
    
    /// Görünüm hiyerarşisinin anlık yeniden oluşturulmasını tetikleyen sayaç
    var languageChangeCounter: Int = 0
    
    /// SwiftUI Environment `\.locale` için aktif Locale nesnesi
    var locale: Locale {
        switch currentLanguage {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "tr"
            return Locale(identifier: preferred.hasPrefix("en") ? "en" : "tr")
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
        self.languageChangeCounter = 0
        applyLanguage(language)
    }
    
    /// Dili değiştir ve anında tüm bundle ve sistem ayarlarına yansıt
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }
    
    private func applyLanguage(_ language: AppLanguage) {
        let code = activeLanguageCode
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        Bundle.setLanguage(code)
        UserDefaults.standard.synchronize()
    }
    
    /// Herhangi bir metin anahtarını anında aktif dile çevirir
    func localized(_ key: String) -> String {
        let code = activeLanguageCode
        if code == "tr" {
            // Türkçe için varsayılan kaynak dildir
            return key
        }
        
        // 1. Doğrudan bellek içi sözlük kontrolü
        if let translation = LocalizationData.english[key] {
            return translation
        }
        
        // 2. Bundle içindeki .lproj kontrolü
        if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let res = bundle.localizedString(forKey: key, value: nil, table: nil)
            if res != key {
                return res
            }
        }
        
        return key
    }
    
    func directLookup(key: String) -> String? {
        let code = activeLanguageCode
        if code == "en" {
            return LocalizationData.english[key]
        }
        return nil
    }
}

// MARK: - String Localization Extension
extension String {
    /// Aktif dile göre anlık çeviri
    var localized: String {
        LanguageManager.shared.localized(self)
    }
    
    /// Parametreli anlık çeviri
    func localized(with arguments: CVarArg...) -> String {
        let format = self.localized
        return String(format: format, locale: LanguageManager.shared.locale, arguments: arguments)
    }
}
