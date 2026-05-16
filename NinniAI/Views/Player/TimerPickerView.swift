import SwiftUI

// MARK: - Timer Picker View
/// Zamanlayıcı seçim ekranı.
/// Preset süreler veya özel süre seçimi sunar.
/// Timer bittiğinde AudioEngineManager fade-out ile tüm sesleri kapatır.
struct TimerPickerView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMinutes: Int = 30
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.spacingLG) {
                        // Başlık
                        VStack(spacing: AppTheme.spacingXS) {
                            Image(systemName: "timer")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.accentPrimary)
                            
                            Text("Zamanlayıcı")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text("Süre bittiğinde sesler yavaşça kapanır")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.top, AppTheme.spacingMD)
                        
                        // Preset butonları (2x2 Grid)
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: AppTheme.spacingMD),
                                GridItem(.flexible(), spacing: AppTheme.spacingMD)
                            ],
                            spacing: AppTheme.spacingMD
                        ) {
                            ForEach([15, 30, 45, 60], id: \.self) { minutes in
                                TimerPresetButton(
                                    minutes: minutes,
                                    isSelected: selectedMinutes == minutes
                                ) {
                                    withAnimation(AppTheme.animationDefault) {
                                        selectedMinutes = minutes
                                    }
                                    appState.audioEngine.startTimer(minutes: minutes)
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingLG)
                        
                        // Süresiz Seçeneği
                        TimerPresetButton(
                            minutes: 0,
                            isSelected: selectedMinutes == 0,
                            label: "∞",
                            subtitle: "Süresiz (Kapatana Kadar Çalar)"
                        ) {
                            withAnimation(AppTheme.animationDefault) {
                                selectedMinutes = 0
                            }
                            appState.audioEngine.startTimer(minutes: 0)
                            dismiss()
                        }
                        .padding(.horizontal, AppTheme.spacingLG)
                        
                        // İptal butonu (aktif timer varsa)
                        if appState.audioEngine.remainingSeconds != nil {
                            Button {
                                appState.audioEngine.cancelTimer()
                                dismiss()
                            } label: {
                                Text("Zamanlayıcıyı İptal Et")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.error)
                            }
                        }
                    }
                    .padding(.bottom, AppTheme.spacingLG)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .onAppear {
            if appState.audioEngine.timerDurationMinutes > 0 {
                selectedMinutes = appState.audioEngine.timerDurationMinutes
            }
        }
    }
}

// MARK: - Timer Preset Button

private struct TimerPresetButton: View {
    let minutes: Int
    let isSelected: Bool
    var label: String?
    var subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingXS) {
                Text(label ?? "\(minutes)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        isSelected ? .white : AppTheme.textPrimary
                    )
                
                Text(subtitle ?? "dakika")
                    .font(.caption2)
                    .foregroundStyle(
                        isSelected ? .white.opacity(0.8) : AppTheme.textTertiary
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                    .fill(
                        isSelected
                        ? AnyShapeStyle(AppTheme.playerGradient)
                        : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                .stroke(AppTheme.accentPrimary.opacity(0.5), lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    TimerPickerView()
        .environment(AppState())
}
