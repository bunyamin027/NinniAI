import SwiftUI
import SwiftData

// MARK: - Dashboard View
/// Dinamik Ana Ekran — saate ve bağlama göre değişen arayüz.
/// PRD §3.2: "Saate ve bağlama göre değişen arayüz."
///
/// ContextResolver'ın çözümlediği bağlama göre:
/// - Gece 00-06: NightModeView (simsiyah ekran)
/// - Normal saatler: Karşılama + QuickActions + Son oturum + Milestone
struct DashboardView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    @Query(sort: \SleepSession.startedAt, order: .reverse) private var recentSessions: [SleepSession]
    @Query(
        filter: #Predicate<Milestone> { !$0.isSeen },
        sort: \Milestone.achievedAt,
        order: .reverse
    ) private var unseenMilestones: [Milestone]
    
    @State private var showMilestoneCard = false
    @State private var activeMilestone: Milestone?
    
    private var baby: Baby? {
        allSettings.first?.baby
    }
    
    private var context: ResolvedContext {
        appState.contextEngine.currentContext
    }
    
    var body: some View {
        ZStack {
            // Gece modu kontrolü
            if context.isNightMode && !appState.contextEngine.nightMode.isManuallyDismissed {
                NightModeView()
            } else {
                normalDashboard
            }
            
            // Milestone kutlama overlay
            if showMilestoneCard, let milestone = activeMilestone {
                MilestoneCardView(
                    milestone: milestone,
                    onDismiss: dismissMilestone
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(10)
            }
        }
        .onAppear {
            refreshContext()
            checkForMilestones()
        }
    }
    
    // MARK: - Normal Dashboard
    
    private var normalDashboard: some View {
        ZStack {
            GradientBackground(context.timeOfDay.gradientStyle)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingLG) {
                    // Üst karşılama alanı
                    headerSection
                        .padding(.top, AppTheme.spacingMD)
                    
                    // Hızlı başlatma
                    quickStartSection
                    
                    // Hızlı aksiyonlar
                    QuickActionGrid()
                    
                    // Son oturum özeti
                    if let lastSession = recentSessions.first, lastSession.endedAt != nil {
                        lastSessionCard(lastSession)
                    }
                    
                    // Önerilen ses
                    suggestedSoundSection
                    
                    Spacer(minLength: 100) // MiniPlayer alanı
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            // Karşılama
            Text(context.greeting)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(context.subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
            
            // Bebek yaş bilgisi
            if let baby {
                HStack(spacing: AppTheme.spacingXS) {
                    Image(systemName: "birthday.cake.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.accentSecondary)
                    
                    Text(Date.now.babyAgeString(from: baby.dateOfBirth))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.accentSecondary)
                    
                    Text("•")
                        .foregroundStyle(AppTheme.textTertiary)
                    
                    Text(baby.ageGroup.displayTitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(.top, AppTheme.spacingXS)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spacingSM)
    }
    
    // MARK: - Quick Start
    
    private var quickStartSection: some View {
        GlassCard(cornerRadius: AppTheme.cornerRadiusXL) {
            VStack(spacing: AppTheme.spacingMD) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text(appState.audioEngine.isPlaying ? "Şu An Çalıyor" : "Hızlı Başlat")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text(
                            appState.audioEngine.isPlaying
                            ? activeLayersText
                            : "Tek dokunuşla uyku seslerini başlat"
                        )
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    PulseButton(
                        isActive: appState.audioEngine.isPlaying,
                        icon: appState.audioEngine.isPlaying ? "pause.fill" : "play.fill",
                        size: 60
                    ) {
                        if appState.audioEngine.isPlaying {
                            appState.audioEngine.stopAll(fadeOut: true)
                        } else {
                            appState.selectedTab = .player
                        }
                    }
                }
                
                // Aktif timer göstergesi
                if let remaining = appState.audioEngine.remainingSeconds, remaining > 0 {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accentPrimary)
                        
                        ProgressView(value: 1 - (remaining / Double(appState.audioEngine.timerDurationMinutes * 60)))
                            .tint(AppTheme.accentPrimary)
                        
                        Text(formatTime(remaining))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(AppTheme.accentPrimary)
                    }
                }
            }
        }
    }
    
    private var activeLayersText: String {
        return appState.audioEngine.activeLayer?.displayName ?? "Ses"
    }
    
    // MARK: - Last Session Card
    
    private func lastSessionCard(_ session: SleepSession) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack {
                    Image(systemName: session.sessionType.iconName)
                        .foregroundStyle(AppTheme.accentPrimary)
                    
                    Text("Son Oturum")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    if let rating = session.qualityRating {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundStyle(
                                        star <= rating ? AppTheme.warning : AppTheme.textTertiary
                                    )
                            }
                        }
                    }
                }
                
                HStack(spacing: AppTheme.spacingMD) {
                    StatPill(
                        icon: "clock.fill",
                        value: session.durationInMinutes.map { "\(Int($0))dk" } ?? "--",
                        color: AppTheme.accentPrimary
                    )
                    
                    StatPill(
                        icon: "bell.slash.fill",
                        value: "\(session.interruptionCount) kesinti",
                        color: session.interruptionCount == 0 ? AppTheme.success : AppTheme.warning
                    )
                    
                    Spacer()
                }
                
                Text(session.startedAt.shortFormatted + " • " + session.sessionType.displayTitle)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }
    
    // MARK: - Suggested Sound
    
    private var suggestedSoundSection: some View {
        let category = context.suggestedCategory
        
        return GlassCard {
            HStack(spacing: AppTheme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.iconName)
                        .font(.title3)
                        .foregroundStyle(AppTheme.accentPrimary)
                }
                
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text("Önerilen Kategori")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                    
                    Text(category.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Button {
                    appState.selectedTab = .player
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func refreshContext() {
        appState.contextEngine.resolve(baby: baby)
    }
    
    private func checkForMilestones() {
        if let milestone = unseenMilestones.first {
            activeMilestone = milestone
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(AppTheme.animationSlow) {
                    showMilestoneCard = true
                }
            }
        }
    }
    
    private func dismissMilestone() {
        activeMilestone?.isSeen = true
        withAnimation(AppTheme.animationSlow) {
            showMilestoneCard = false
            activeMilestone = nil
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Stat Pill
private struct StatPill: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
