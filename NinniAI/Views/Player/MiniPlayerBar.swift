import SwiftUI

// MARK: - Mini Player Bar
/// Ekranın alt kısmında görünen kompakt player kontrolü.
/// Kullanıcı sesler çalarken diğer tab'larda gezinirken görünür.
/// Dokunulduğunda tam ekran PlayerView açılır.
struct MiniPlayerBar: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        if appState.audioEngine.isPlaying {
            miniPlayerContent
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var miniPlayerContent: some View {
        Button {
            appState.isFullPlayerPresented = true
        } label: {
            HStack(spacing: AppTheme.spacingSM) {
                // Animasyonlu dalga göstergesi
                WaveIndicator()
                
                // Ses bilgisi
                VStack(alignment: .leading, spacing: 2) {
                    Text(activeSoundsText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    if let remaining = appState.audioEngine.remainingSeconds, remaining > 0 {
                        Text(formatTime(remaining))
                            .font(.caption2)
                            .foregroundStyle(AppTheme.accentPrimary)
                    }
                }
                
                Spacer()
                
                // Durdur butonu
                Button {
                    appState.audioEngine.stopAll(fadeOut: true)
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.vertical, AppTheme.spacingSM)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.shadowColorDark, radius: 10, y: -5)
            }
            .padding(.horizontal, AppTheme.spacingSM)
        }
        .buttonStyle(.plain)
    }
    
    private var activeSoundsText: String {
        let names = appState.audioEngine.activeLayers.values.map(\.displayName)
        if names.isEmpty { return "Çalıyor..." }
        if names.count == 1 { return names[0] }
        return "\(names[0]) + \(names.count - 1) diğer"
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Wave Indicator
/// Çalma durumunu gösteren küçük dalga animasyonu
private struct WaveIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppTheme.accentPrimary)
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 8...18) : 6)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 16, height: 20)
        .onAppear { isAnimating = true }
    }
}

#Preview {
    ZStack {
        AppTheme.backgroundGradient.ignoresSafeArea()
        
        VStack {
            Spacer()
            MiniPlayerBar()
        }
    }
    .environment(AppState())
}
