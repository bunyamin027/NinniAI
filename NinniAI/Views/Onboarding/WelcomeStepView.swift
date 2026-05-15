import SwiftUI

// MARK: - Welcome Step View
/// Onboarding'in ilk ekranı — uygulama tanıtımı ve karşılama.
/// Ay + yıldız animasyonu ile "Antigravity" estetiğini ilk andan hissettirir.
struct WelcomeStepView: View {
    
    let onNext: () -> Void
    
    @State private var isAppeared = false
    @State private var moonScale: CGFloat = 0.5
    @State private var starsOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Ay ve yıldız animasyonu
            ZStack {
                // Yıldızlar
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 2...4))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -200...100)
                        )
                        .opacity(starsOpacity * Double.random(in: 0.3...1.0))
                }
                
                // Ay ışığı halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accentPrimary.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(moonScale)
                
                // Ay ikonu
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(moonScale)
            }
            .frame(height: 300)
            
            Spacer()
                .frame(height: AppTheme.spacingXL)
            
            // Başlık ve açıklama
            VStack(spacing: AppTheme.spacingMD) {
                Text("NinniAI")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.textPrimary, AppTheme.accentPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 20)
                
                Text("Akıllı Uyku Asistanı")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textSecondary)
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 15)
                
                Text("Bebeğinizin gelişimine uyum sağlayan,\nkişiselleştirilmiş uyku deneyimi")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 10)
                    .padding(.horizontal, AppTheme.spacingXL)
            }
            
            Spacer()
            
            // Başla butonu
            Button(action: onNext) {
                HStack(spacing: AppTheme.spacingSM) {
                    Text("Başlayalım")
                        .font(.headline)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppTheme.playerGradient)
                .clipShape(Capsule())
                .shadow(color: AppTheme.shadowColorPrimary, radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppTheme.spacingLG)
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared ? 0 : 30)
            
            Spacer()
                .frame(height: AppTheme.spacingXXL)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                moonScale = 1.0
            }
            withAnimation(.easeIn(duration: 1.5).delay(0.3)) {
                starsOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                isAppeared = true
            }
        }
    }
}

#Preview {
    ZStack {
        GradientBackground(.onboarding)
        WelcomeStepView(onNext: {})
    }
}
