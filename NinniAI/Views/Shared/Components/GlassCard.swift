import SwiftUI

// MARK: - Glass Card
/// Antigravity glassmorphism kart bileşeni.
/// PRD §4: "Cam efekti (glassmorphism), soft gölgeler"
///
/// Kullanım:
/// ```
/// GlassCard {
///     Text("İçerik")
/// }
/// ```
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content
    
    init(
        cornerRadius: CGFloat = AppTheme.cornerRadiusLG,
        padding: CGFloat = AppTheme.spacingMD,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: AppTheme.shadowColorDark,
                        radius: 20, x: 0, y: 10
                    )
            }
    }
}

#Preview {
    ZStack {
        AppTheme.backgroundGradient.ignoresSafeArea()
        
        VStack(spacing: 16) {
            GlassCard {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.title)
                        .foregroundStyle(AppTheme.accentPrimary)
                    
                    VStack(alignment: .leading) {
                        Text("İyi Geceler")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Uyku vakti yaklaşıyor")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            GlassCard(cornerRadius: 32) {
                Text("🌙 NinniAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }
}
