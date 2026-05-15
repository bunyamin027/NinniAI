import SwiftUI
import SwiftData

// MARK: - Player View
/// Ana Player ekranı — uykulu ebeveyn dostu tasarım.
/// PRD §3.3: "Uykulu ebeveyn dostu büyük play butonu, tek dokunuşta başlatma"
///
/// Bu ekran şu bileşenleri içerir:
/// - Dalga animasyonu arka planı
/// - Devasa play/pause butonu
/// - Aktif ses katmanları listesi
/// - Ses seviyesi kontrolü
/// - Zamanlayıcı seçici
struct PlayerView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Sound.sortOrder) private var allSounds: [Sound]
    
    @State private var showSoundPicker = false
    @State private var showTimerPicker = false
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Arka plan
            GradientBackground(appState.audioEngine.isPlaying ? .playerActive : .default)
            
            // Dalga animasyonu (aktifken)
            if appState.audioEngine.isPlaying {
                WaveAnimationView(phase: $wavePhase)
                    .opacity(0.3)
            }
            
            VStack(spacing: 0) {
                // Üst başlık
                headerSection
                
                Spacer()
                
                // Aktif katmanlar (çalan sesler)
                if !appState.audioEngine.activeLayers.isEmpty {
                    activeLayersSection
                }
                
                Spacer()
                
                // Ana play butonu
                playButtonSection
                
                Spacer()
                
                // Alt kontroller (timer + ses seçici)
                bottomControlsSection
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.vertical, AppTheme.spacingMD)
        }
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView()
        }
        .sheet(isPresented: $showTimerPicker) {
            TimerPickerView()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingSM) {
            Text(headerTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
            
            if let remaining = appState.audioEngine.remainingSeconds, remaining > 0 {
                Text(formatTime(remaining))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.accentPrimary)
            }
        }
        .padding(.top, AppTheme.spacingLG)
    }
    
    private var headerTitle: String {
        if appState.audioEngine.isPlaying {
            return "Çalıyor..."
        }
        return "Bir ses seçin"
    }
    
    // MARK: - Active Layers Section
    
    private var activeLayersSection: some View {
        VStack(spacing: AppTheme.spacingSM) {
            ForEach(Array(appState.audioEngine.activeLayers.values)) { layer in
                ActiveLayerRow(
                    layer: layer,
                    onVolumeChange: { volume in
                        appState.audioEngine.setVolume(volume, for: layer.identifier)
                    },
                    onRemove: {
                        withAnimation(AppTheme.animationDefault) {
                            appState.audioEngine.stop(identifier: layer.identifier)
                        }
                    }
                )
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Play Button Section
    
    private var playButtonSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            PulseButton(
                isActive: appState.audioEngine.isPlaying,
                icon: appState.audioEngine.isPlaying ? "pause.fill" : "play.fill",
                size: 90
            ) {
                if appState.audioEngine.isPlaying {
                    appState.audioEngine.stopAll(fadeOut: true)
                } else {
                    showSoundPicker = true
                }
            }
            
            // Master volume slider
            if appState.audioEngine.isPlaying {
                masterVolumeSlider
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
        .padding(.horizontal, AppTheme.spacingXL)
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControlsSection: some View {
        HStack(spacing: AppTheme.spacingXL) {
            // Ses ekle
            ControlButton(
                icon: "plus.circle.fill",
                label: "Ses Ekle",
                badge: appState.audioEngine.activeLayerCount
            ) {
                showSoundPicker = true
            }
            
            // Zamanlayıcı
            ControlButton(
                icon: "timer",
                label: timerLabel,
                isActive: appState.audioEngine.remainingSeconds != nil
            ) {
                showTimerPicker = true
            }
        }
        .padding(.bottom, AppTheme.spacingLG)
    }
    
    private var timerLabel: String {
        if let remaining = appState.audioEngine.remainingSeconds {
            return formatTime(remaining)
        }
        return "Zamanlayıcı"
    }
    
    // MARK: - Helpers
    
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

// MARK: - Active Layer Row

private struct ActiveLayerRow: View {
    let layer: AudioLayer
    let onVolumeChange: (Float) -> Void
    let onRemove: () -> Void
    
    @State private var volume: Float
    
    init(layer: AudioLayer, onVolumeChange: @escaping (Float) -> Void, onRemove: @escaping () -> Void) {
        self.layer = layer
        self.onVolumeChange = onVolumeChange
        self.onRemove = onRemove
        self._volume = State(initialValue: layer.volume)
    }
    
    var body: some View {
        GlassCard(cornerRadius: AppTheme.cornerRadiusMD, padding: AppTheme.spacingSM) {
            HStack(spacing: AppTheme.spacingSM) {
                // Ses adı
                Text(layer.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                // Volume slider (compact)
                Slider(
                    value: Binding(
                        get: { Double(volume) },
                        set: {
                            volume = Float($0)
                            onVolumeChange(volume)
                        }
                    ),
                    in: 0...1
                )
                .tint(AppTheme.accentPrimary)
                .frame(width: 100)
                
                // Kaldır butonu
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Control Button

private struct ControlButton: View {
    let icon: String
    let label: String
    var badge: Int = 0
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingXS) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(
                            isActive ? AppTheme.accentPrimary : AppTheme.textSecondary
                        )
                    
                    if badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(AppTheme.accentPrimary)
                            .clipShape(Circle())
                            .offset(x: 8, y: -4)
                    }
                }
                
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wave Animation View

private struct WaveAnimationView: View {
    @Binding var phase: CGFloat
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let midY = size.height * 0.5
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for i in 0..<3 {
                    let amplitude = CGFloat(20 - i * 5)
                    let frequency = CGFloat(0.8 + Double(i) * 0.3)
                    let speed = CGFloat(0.5 + Double(i) * 0.2)
                    let opacity = 0.3 - Double(i) * 0.08
                    
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: midY))
                    
                    for x in stride(from: 0, through: size.width, by: 2) {
                        let relativeX = x / size.width
                        let y = midY + sin(
                            relativeX * .pi * 2 * frequency + time * speed
                        ) * amplitude
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                    
                    context.fill(
                        path,
                        with: .color(AppTheme.accentPrimary.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PlayerView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
