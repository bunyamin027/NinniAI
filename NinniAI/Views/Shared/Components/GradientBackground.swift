import SwiftUI

// MARK: - Gradient Background
/// Antigravity dinamik gradient arka planı.
/// PRD §4: "Gece mavisi, pastel mor" renk paleti
///
/// Saate ve duruma göre gradient varyantları sunar.
struct GradientBackground: View {
    let style: GradientStyle
    
    init(_ style: GradientStyle = .default) {
        self.style = style
    }
    
    var body: some View {
        ZStack {
            style.gradient
            
            // Üst kısımda hafif parlama
            RadialGradient(
                colors: [
                    style.glowColor.opacity(0.15),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Gradient Style
enum GradientStyle {
    /// Varsayılan gece teması
    case `default`
    /// Derin gece modu (03:00 modu)
    case nightMode
    /// Player aktifken
    case playerActive
    /// Onboarding
    case onboarding
    
    var gradient: LinearGradient {
        switch self {
        case .default:
            return LinearGradient(
                colors: [
                    Color(hex: "0A0E1A"),
                    Color(hex: "15103A"),
                    Color(hex: "0A0E1A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nightMode:
            return LinearGradient(
                colors: [Color.black, Color(hex: "050510")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .playerActive:
            return LinearGradient(
                colors: [
                    Color(hex: "0F0A2A"),
                    Color(hex: "1A0E3E"),
                    Color(hex: "0A0E1A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .onboarding:
            return LinearGradient(
                colors: [
                    Color(hex: "0D1025"),
                    Color(hex: "1A1040"),
                    Color(hex: "100828")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var glowColor: Color {
        switch self {
        case .default:      return AppTheme.accentPrimary
        case .nightMode:    return Color.clear
        case .playerActive: return AppTheme.accentSecondary
        case .onboarding:   return AppTheme.accentPrimary
        }
    }
}

#Preview {
    GradientBackground(.playerActive)
}
