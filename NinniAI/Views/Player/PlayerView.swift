import SwiftUI
import SwiftData

// MARK: - Player View
struct PlayerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Sound.sortOrder) private var allSounds: [Sound]
    
    @State private var showTimerPicker = false
    @State private var selectedCategory: SoundCategory = .whiteNoise
    
    var body: some View {
        ZStack {
            // Arka plan
            GradientBackground(appState.audioEngine.isPlaying ? .playerActive : .default)
            
            // Dalga animasyonu kaldırıldı (Kullanıcı isteği: overlap/layout shift yapmaması için)
            
            VStack(spacing: 0) {
                // Üst Başlık (Agentic Header)
                agenticHeaderSection
                
                Spacer()
                
                // Ana Play Butonu (Antigravity Centerpiece)
                playButtonSection
                
                // Akıllı Zamanlayıcı Çubuğu
                smartTimerBar
                    .padding(.top, AppTheme.spacingXL)
                    .padding(.horizontal, AppTheme.spacingXL)
                
                Spacer()
                
                // Master Volume
                masterVolumeSlider
                    .padding(.horizontal, AppTheme.spacingXL)
                    .padding(.bottom, AppTheme.spacingLG)
                
                // Manuel Seçim Alanı (Kategori ve Sesler)
                explorationSection
            }
            .padding(.vertical, AppTheme.spacingMD)
        }
        .sheet(isPresented: $showTimerPicker) {
            TimerPickerView()
        }
        .onAppear {
            if appState.audioEngine.activeLayer == nil && !allSounds.isEmpty {
                // Sadece görsel olarak ilk sesi hazırda tutmak için (isteğe bağlı)
            }
        }
    }
    
    // MARK: - Agentic Header
    private var agenticHeaderSection: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text("SİSTEM ÖNERİSİ")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .opacity(0.8)
            
            Text(currentSoundName)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.spacingXL)
    }
    
    private var currentSoundName: String {
        appState.audioEngine.activeLayer?.displayName ?? allSounds.first?.displayName ?? "Kozmik Frekans"
    }
    
    // MARK: - Play Button Section (Antigravity Style)
    private var playButtonSection: some View {
        Button(action: {
            if appState.audioEngine.activeLayer == nil {
                if let firstSound = allSounds.first {
                    appState.audioEngine.play(sound: firstSound)
                }
            } else {
                appState.audioEngine.togglePlayPause()
            }
        }) {
            ZStack {
                // Soft Shadow / Antigravity Effect
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 10, y: 15)
                    .shadow(color: .white.opacity(0.1), radius: 20, x: -10, y: -10)
                
                // İç Kısım
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.secondarySystemBackground).opacity(0.5), Color(.systemBackground)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                
                Image(systemName: appState.audioEngine.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    // İkon için hafif inner glow hissi
                    .shadow(color: AppTheme.accentPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(AntigravityButtonStyle())
    }
    
    // MARK: - Smart Timer Bar
    private var smartTimerBar: some View {
        Button(action: { showTimerPicker = true }) {
            ZStack(alignment: .leading) {
                // Arka plan soft bar
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: 44)
                    .shadow(color: AppTheme.shadowColorDark, radius: 10, y: 5)
                
                // İlerleme dolumu
                if let remaining = appState.audioEngine.remainingSeconds, appState.audioEngine.timerDurationMinutes > 0 {
                    let totalSeconds = Double(appState.audioEngine.timerDurationMinutes * 60)
                    let progress = 1.0 - (remaining / totalSeconds)
                    
                    GeometryReader { geo in
                        Capsule()
                            .fill(AppTheme.accentPrimary.opacity(0.3))
                            .frame(width: max(0, geo.size.width * progress))
                            .animation(.linear(duration: 1.0), value: progress)
                    }
                    .frame(height: 44)
                }
                
                // İkon ve Süre
                HStack {
                    Image(systemName: "timer")
                        .font(.subheadline)
                    
                    if let remaining = appState.audioEngine.remainingSeconds, remaining > 0 {
                        Text(formatTime(remaining))
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.medium)
                    } else {
                        Text("Zamanlayıcı Kapalı")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .foregroundStyle(appState.audioEngine.remainingSeconds != nil ? AppTheme.accentPrimary : AppTheme.textSecondary)
                .padding(.horizontal, AppTheme.spacingMD)
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Exploration Section (Category & Sounds)
    private var explorationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            
            // 1. Kategoriler
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingSM) {
                    ForEach(SoundCategory.allCases) { category in
                        CategoryChipView(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(AppTheme.animationDefault) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
            }
            
            // 2. Keşfet (Seçili Kategori Sesleri)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingSM) {
                    ForEach(allSounds.filter { $0.category == selectedCategory }) { sound in
                        ExplorerSoundItemView(
                            sound: sound,
                            isSelected: appState.audioEngine.activeLayer?.identifier == sound.identifier
                        ) {
                            appState.audioEngine.play(sound: sound)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
            }
            .padding(.bottom, AppTheme.spacingLG)
        }
    }
    
    private struct CategoryChipView: View {
        let category: SoundCategory
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(category.displayTitle)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .bold : .medium)
                    
                    if category == .lullaby {
                        HStack(spacing: 2) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                            Text("PRO")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(AppTheme.warning)
                        .padding(.leading, 2)
                    }
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(AppTheme.accentPrimary.opacity(0.2)) : AnyShapeStyle(.ultraThinMaterial))
                )
                .background(
                    Capsule()
                        .stroke(isSelected ? AppTheme.accentPrimary.opacity(0.5) : .white.opacity(0.1), lineWidth: 1)
                )
                .foregroundStyle(isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary)
            }
        }
    }

    private struct ExplorerSoundItemView: View {
        let sound: Sound
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: AppTheme.spacingXS) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? AnyShapeStyle(AppTheme.accentPrimary.opacity(0.2)) : AnyShapeStyle(Color.white.opacity(0.05)))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: sound.category.iconName)
                            .font(.title2)
                            .foregroundStyle(isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary)
                        
                        if isSelected {
                            Circle()
                                .stroke(AppTheme.accentPrimary, lineWidth: 2)
                                .frame(width: 64, height: 64)
                        }
                    }
                    
                    Text(sound.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, AppTheme.spacingXS)
            }
        }
    }
    
    private var masterVolumeSlider: some View {
        @Bindable var state = appState
        return HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "speaker.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
            
            Slider(
                value: Binding(
                    get: { Double(state.audioEngine.masterVolume) },
                    set: { state.audioEngine.masterVolume = Float($0) }
                ),
                in: 0...1
            )
            .tint(AppTheme.accentPrimary)
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Antigravity Button Style
struct AntigravityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


// MARK: - Preview
#Preview {
    PlayerView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
