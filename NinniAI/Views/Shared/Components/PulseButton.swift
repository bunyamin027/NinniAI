import SwiftUI

// MARK: - Pulse Button
/// Nefes alan, büyük hit alanlı play/stop butonu.
/// PRD §4: "Tek elle kontrol, büyük hit alanları, uykulu ebeveyn dostu UX"
///
/// Kullanım:
/// ```
/// PulseButton(isActive: $isPlaying, icon: "play.fill") {
///     // Aksiyon
/// }
/// ```
struct PulseButton: View {
    let isActive: Bool
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPulsing = false
    
    init(
        isActive: Bool,
        icon: String = "play.fill",
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) {
        self.isActive = isActive
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Dış pulse halkası (aktifken nefes alır)
                if isActive {
                    Circle()
                        .fill(AppTheme.accentPrimary.opacity(0.15))
                        .frame(width: size * 1.6, height: size * 1.6)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                    
                    Circle()
                        .fill(AppTheme.accentPrimary.opacity(0.08))
                        .frame(width: size * 2.0, height: size * 2.0)
                        .scaleEffect(isPulsing ? 1.2 : 0.95)
                }
                
                // Ana buton
                Circle()
                    .fill(
                        isActive
                        ? AnyShapeStyle(AppTheme.playerGradient)
                        : AnyShapeStyle(AppTheme.playerGradient.opacity(0.8))
                    )
                    .frame(width: size, height: size)
                    .shadow(
                        color: AppTheme.shadowColorPrimary,
                        radius: isActive ? 20 : 10,
                        x: 0,
                        y: isActive ? 8 : 4
                    )
                
                // İkon
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: isActive)
        .onAppear {
            guard isActive else { return }
            startPulsing()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startPulsing()
            } else {
                isPulsing = false
            }
        }
    }
    
    private func startPulsing() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isPulsing = true
        }
    }
}

#Preview {
    ZStack {
        AppTheme.backgroundGradient.ignoresSafeArea()
        
        VStack(spacing: 40) {
            PulseButton(isActive: false, icon: "play.fill") {}
            PulseButton(isActive: true, icon: "pause.fill") {}
        }
    }
}
