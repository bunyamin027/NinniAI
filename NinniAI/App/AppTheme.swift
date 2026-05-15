import SwiftUI

// MARK: - Antigravity Design Tokens
/// PRD §4: "Gece mavisi, pastel mor, soft krem"
/// Tüm uygulama genelinde kullanılacak renk, font ve spacing sabitleri.
enum AppTheme {
    
    // MARK: - Colors
    
    /// Ana arka plan — koyu gece mavisi
    static let backgroundPrimary = Color(hex: "0A0E1A")
    /// İkincil arka plan — hafif açık gece
    static let backgroundSecondary = Color(hex: "111827")
    /// Kart arka planı — glassmorphism base
    static let cardBackground = Color(hex: "1E2433")
    
    /// Ana vurgu rengi — lavanta/pastel mor
    static let accentPrimary = Color(hex: "A78BFA")
    /// İkincil vurgu — soft pembe
    static let accentSecondary = Color(hex: "F9A8D4")
    /// Üçüncül vurgu — soft krem
    static let accentTertiary = Color(hex: "FDF4E3")
    
    /// Başarı yeşili
    static let success = Color(hex: "34D399")
    /// Uyarı turuncu
    static let warning = Color(hex: "FBBF24")
    /// Hata kırmızı
    static let error = Color(hex: "F87171")
    
    /// Metin renkleri
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
    
    // MARK: - Gradients
    
    /// Ana gradient — dashboard ve player arka planı
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "0A0E1A"),
            Color(hex: "1A1040"),
            Color(hex: "0A0E1A")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Player butonu gradient
    static let playerGradient = LinearGradient(
        colors: [Color(hex: "A78BFA"), Color(hex: "7C3AED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gece modu gradient (saf siyah)
    static let nightModeGradient = LinearGradient(
        colors: [Color.black, Color(hex: "050510")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // MARK: - Corner Radius
    
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 16
    static let cornerRadiusLG: CGFloat = 24
    static let cornerRadiusXL: CGFloat = 32
    static let cornerRadiusFull: CGFloat = 100
    
    // MARK: - Animation
    
    /// Yavaş, sakinleştirici animasyon (PRD §4: "yavaş geçiş animasyonları")
    static let animationSlow = Animation.easeInOut(duration: 0.8)
    /// Normal animasyon
    static let animationDefault = Animation.easeInOut(duration: 0.35)
    /// Hızlı feedback animasyonu
    static let animationFast = Animation.easeOut(duration: 0.15)
    /// Spring animasyonu
    static let animationSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    
    // MARK: - Shadows
    
    static let shadowColorPrimary = Color(hex: "A78BFA").opacity(0.3)
    static let shadowColorDark = Color.black.opacity(0.4)
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
