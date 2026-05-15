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
                
                VStack(spacing: AppTheme.spacingXL) {
                    // Başlık
                    VStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "timer")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.accentPrimary)
                        
                        Text("Zamanlayıcı")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Süre bittiğinde sesler yavaşça kapanır")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, AppTheme.spacingXL)
                    
                    // Preset butonları
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: AppTheme.spacingSM
                    ) {
                        ForEach(AppConstants.timerPresets, id: \.self) { minutes in
                            TimerPresetButton(
                                minutes: minutes,
                                isSelected: selectedMinutes == minutes
                            ) {
                                withAnimation(AppTheme.animationDefault) {
                                    selectedMinutes = minutes
                                }
                            }
                        }
                        
                        // Süresiz seçenek
                        TimerPresetButton(
                            minutes: 0,
                            isSelected: selectedMinutes == 0,
                            label: "∞",
                            subtitle: "Süresiz"
                        ) {
                            withAnimation(AppTheme.animationDefault) {
                                selectedMinutes = 0
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    
                    Spacer()
                    
                    // Başlat butonu
                    Button {
                        appState.audioEngine.startTimer(minutes: selectedMinutes)
                        dismiss()
                    } label: {
                        Text(selectedMinutes > 0 ? "Zamanlayıcıyı Başlat" : "Süresiz Çal")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingMD)
                            .background(AppTheme.playerGradient)
                            .clipShape(Capsule())
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
                .padding(.bottom, AppTheme.spacingXL)
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
        .presentationDetents([.medium])
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
