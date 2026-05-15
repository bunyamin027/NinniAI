import SwiftUI

// MARK: - Night Mode View
/// Gece 03:00 Modu — simsiyah tam ekran.
/// PRD §3.2: "Gece yarısı açıldığında sadece devasa bir
/// 'Gece Uykusuna Dön' butonu içeren simsiyah bir ekran."
///
/// Minimum ışık, minimum UI, maksimum karanlık.
/// Uykulu ebeveyn gece uyandığında gözlerini yormamak için tasarlandı.
struct NightModeView: View {
    
    @Environment(AppState.self) private var appState
    @State private var isBreathing = false
    @State private var showTime = false
    
    var body: some View {
        ZStack {
            // Saf siyah arka plan
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Çok hafif saat göstergesi
                if showTime {
                    Text(Date.now.timeFormatted)
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.15))
                        .padding(.bottom, AppTheme.spacingXXL)
                }
                
                // Devasa buton
                Button {
                    // Sesler tab'ına git ve gece modunu kapat
                    appState.contextEngine.nightMode.dismiss()
                    appState.selectedTab = .player
                } label: {
                    VStack(spacing: AppTheme.spacingMD) {
                        // Nefes alan ay ikonu
                        ZStack {
                            // Dış halo
                            Circle()
                                .fill(AppTheme.accentPrimary.opacity(0.05))
                                .frame(width: 180, height: 180)
                                .scaleEffect(isBreathing ? 1.1 : 0.95)
                            
                            Circle()
                                .fill(AppTheme.accentPrimary.opacity(0.08))
                                .frame(width: 130, height: 130)
                                .scaleEffect(isBreathing ? 1.05 : 0.98)
                            
                            Image(systemName: "moon.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.accentPrimary.opacity(0.6))
                        }
                        
                        Text("Gece Uykusuna Dön")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white.opacity(0.5))
                        
                        Text("Sakin seslerle tekrar uykuya dal")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.2))
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Alt kısımda gece modundan çıkış
                Button {
                    withAnimation(AppTheme.animationSlow) {
                        appState.contextEngine.nightMode.dismiss()
                    }
                } label: {
                    Text("Normal moda geç")
                        .font(.caption2)
                        .foregroundStyle(Color.white.opacity(0.12))
                }
                .padding(.bottom, AppTheme.spacingXL)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                isBreathing = true
            }
            
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                showTime = true
            }
        }
        .statusBarHidden()
    }
}

#Preview {
    NightModeView()
        .environment(AppState())
}
