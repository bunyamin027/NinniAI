import SwiftUI

// MARK: - Premium Lock Modifier
/// Antigravity tasarım diline uygun premium kilit overlay'i.
/// `isPro == false` iken view'ı blurlar, tıklamaları engeller ve
/// şık bir cam katman + kilit ikonu gösterir.
/// Overlay'e tıklandığında `showPaywall = true` olur.
///
/// Direkt kullanım yerine `View.premiumLocked()` extension'ını tercih edin.
struct PremiumLockModifier: ViewModifier {
    
    @Environment(SubscriptionManager.self) private var subscription
    @State private var pulseAnimation: Bool = false
    
    func body(content: Content) -> some View {
        if subscription.isPro {
            // ── Pro kullanıcı: Hiçbir değişiklik yapmadan serbest bırak
            content
        } else {
            // ── Free kullanıcı: Blur + Cam overlay + Kilit ikonu
            @Bindable var subscription = subscription
            
            content
                .blur(radius: 6)
                .allowsHitTesting(false)
                .overlay {
                    lockOverlay
                }
                .animation(AppTheme.animationDefault, value: subscription.isPro)
        }
    }
    
    // MARK: - Lock Overlay
    
    /// Antigravity cam efektli kilit katmanı
    private var lockOverlay: some View {
        @Bindable var subscription = subscription
        
        return ZStack {
            // ── Cam arka plan
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(
                    color: AppTheme.shadowColorPrimary.opacity(0.15),
                    radius: 20, x: 0, y: 8
                )
            
            // ── Ortalanmış kilit içeriği
            VStack(spacing: AppTheme.spacingSM) {
                // Glow halkası + ikon
                ZStack {
                    // Soft glow — nefes alan halka
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.accentPrimary.opacity(0.3),
                                    AppTheme.accentPrimary.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 16,
                                endRadius: 44
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseAnimation ? 1.15 : 0.95)
                        .opacity(pulseAnimation ? 0.8 : 0.4)
                    
                    // Kilit ikonu
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.accentPrimary,
                                    AppTheme.accentSecondary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: AppTheme.accentPrimary.opacity(0.5),
                            radius: 8, x: 0, y: 0
                        )
                }
                
                // Etiket
                Text("Pro")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.accentPrimary,
                                AppTheme.accentSecondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(1.5)
                    .textCase(.uppercase)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG))
        .onTapGesture {
            subscription.showPaywall = true
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                pulseAnimation = true
            }
        }
    }
}
