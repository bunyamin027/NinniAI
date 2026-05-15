import SwiftUI
import SwiftData
import Charts

// MARK: - Analytics Dashboard View
/// Uyku analitiği ana ekranı.
/// PRD §3.4: "SwiftData ile toplanan verilerin görselleştirilmesi."
///
/// Haftalık uyku grafiği, başarı puanı ve özet istatistikleri gösterir.
struct AnalyticsDashboardView: View {
    
    @Environment(AppState.self) private var appState
    @Query(sort: \SleepSession.startedAt, order: .reverse) private var sessions: [SleepSession]
    @Query private var allSettings: [UserSettings]
    
    private var baby: Baby? { allSettings.first?.baby }
    
    /// Son 7 günün oturumları
    private var weekSessions: [SleepSession] {
        let weekAgo = Date.now.daysAgo(7)
        return sessions.filter {
            $0.startedAt >= weekAgo && $0.endedAt != nil
        }
    }
    
    /// Toplam uyku süresi (bu hafta, saat)
    private var totalSleepHours: Double {
        weekSessions.compactMap(\.durationInMinutes).reduce(0, +) / 60.0
    }
    
    /// Ortalama oturum süresi (dakika)
    private var averageSessionMinutes: Double {
        let durations = weekSessions.compactMap(\.durationInMinutes)
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    /// Toplam kesinti sayısı
    private var totalInterruptions: Int {
        weekSessions.reduce(0) { $0 + $1.interruptionCount }
    }
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingLG) {
                    // Başlık
                    headerSection
                        .padding(.top, AppTheme.spacingMD)
                    
                    // Özet kartları
                    summaryCards
                    
                    // Haftalık grafik
                    SleepChartView(sessions: weekSessions)
                    
                    // Başarı puanı
                    SuccessScoreView(sessions: weekSessions)
                    
                    // Haftalık rapor
                    WeeklyReportView(
                        totalHours: totalSleepHours,
                        avgMinutes: averageSessionMinutes,
                        sessionCount: weekSessions.count,
                        interruptions: totalInterruptions
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Uyku Analitiği")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Son 7 günlük uyku verileriniz")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spacingSM)
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: AppTheme.spacingSM) {
            SummaryCard(
                icon: "clock.fill",
                title: "Toplam",
                value: String(format: "%.1f sa", totalSleepHours),
                color: AppTheme.accentPrimary
            )
            
            SummaryCard(
                icon: "moon.fill",
                title: "Oturum",
                value: "\(weekSessions.count)",
                color: AppTheme.accentSecondary
            )
            
            SummaryCard(
                icon: "bell.slash.fill",
                title: "Kesinti",
                value: "\(totalInterruptions)",
                color: totalInterruptions < 5 ? AppTheme.success : AppTheme.warning
            )
        }
    }
}

// MARK: - Summary Card
private struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: AppTheme.cornerRadiusMD, padding: AppTheme.spacingSM) {
            VStack(spacing: AppTheme.spacingXS) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingXS)
        }
    }
}

#Preview {
    AnalyticsDashboardView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
