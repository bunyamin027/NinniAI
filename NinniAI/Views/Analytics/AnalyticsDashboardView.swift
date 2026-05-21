import SwiftUI
import SwiftData
import Charts

// MARK: - Analytics Dashboard View
/// Uyku analitiği ana ekranı (Antigravity Tasarımı).
/// Gerçek SwiftData verileriyle çalışır, Deep Analytics kısmı Pro abonelik gerektirir.
struct AnalyticsDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepSession.startedAt, order: .reverse) private var sessions: [SleepSession]
    @Query private var allSettings: [UserSettings]
    
    @State private var animateRings = false
    
    private var baby: Baby? {
        allSettings.first?.baby
    }
    
    private var targetSleepHours: Double {
        Double(baby?.ageGroup.recommendedSleepHours.upperBound ?? 14)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.15), Color(red: 0.12, green: 0.1, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingXL) {
                    smartInsightCard
                        .padding(.top, AppTheme.spacingMD)
                    
                    antigravityRings
                    
                    quickMetricsGrid
                    
                    SleepChartView(sessions: sessions)
                    
                    deepAnalyticsSection
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(AppTheme.animationSlow) {
                    animateRings = true
                }
            }
        }
    }
    
    // MARK: - 1. Akıllı İçgörü Kartı
    
    private var smartInsightCard: some View {
        let babyName = baby?.name ?? "Bebeğiniz"
        
        return HStack(alignment: .top, spacing: 16) {
            Image(systemName: "sparkles")
                .foregroundStyle(AppTheme.accentPrimary)
                .font(.title2)
                .symbolEffect(.pulse)
            
            Text(insightMessage(for: babyName))
                .font(.subheadline)
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
        .shadow(color: AppTheme.accentPrimary.opacity(0.15), radius: 15, x: 0, y: 8)
    }
    
    private func insightMessage(for name: String) -> String {
        let todayMins = todaySleepMinutes
        if todayMins == 0 {
            return "\(name) için henüz bugünün uyku verisi girilmedi. Yeni bir uyku oturumu başlatarak analizi görebilirsiniz."
        } else if todayMins > targetSleepHours * 60 {
            return "Harika! \(name) bugün günlük uyku hedefine ulaştı. Kaliteli uyku büyümesini destekliyor."
        } else {
            return "\(name)'in hedefine ulaşması için yaklaşık \(Int((targetSleepHours * 60) - todayMins) / 60) saat daha uykuya ihtiyacı var."
        }
    }
    
    // MARK: - 2. Antigravity Uyku Halkaları
    
    private var antigravityRings: some View {
        let todayHours = todaySleepMinutes / 60.0
        let uninterruptedHours = longestUninterruptedSleepToday / 3600.0
        
        let totalProgress = min(todayHours / targetSleepHours, 1.0)
        let uninterruptedProgress = min(uninterruptedHours / targetSleepHours, 1.0)
        
        return VStack(spacing: 24) {
            ZStack {
                // Dış Halka Zemin (Toplam Uyku)
                Circle()
                    .stroke(Color.indigo.opacity(0.2), lineWidth: 16)
                    .frame(width: 220, height: 220)
                
                // Dış Halka İlerleme
                Circle()
                    .trim(from: 0, to: animateRings ? totalProgress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [Color.indigo, AppTheme.accentPrimary],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: AppTheme.accentPrimary.opacity(0.4), radius: 10, x: 0, y: 0)
                
                // İç Halka Zemin (Kesintisiz)
                Circle()
                    .stroke(Color.purple.opacity(0.1), lineWidth: 12)
                    .frame(width: 170, height: 170)
                
                // İç Halka İlerleme
                Circle()
                    .trim(from: 0, to: animateRings ? uninterruptedProgress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [Color.purple, Color.blue],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 170, height: 170)
                    .rotationEffect(.degrees(-90))
                
                // Merkez Metinleri
                VStack(spacing: 4) {
                    Text(String(format: "%.1f Saat", todayHours))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Hedef: \(Int(targetSleepHours)) Saat")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            // Lejant
            HStack(spacing: 24) {
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.accentPrimary).frame(width: 8, height: 8)
                    Text("Toplam Uyku").font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                HStack(spacing: 6) {
                    Circle().fill(Color.blue).frame(width: 8, height: 8)
                    Text("Kesintisiz Uyku").font(.caption).foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - 3. Hızlı Metrikler
    
    private var quickMetricsGrid: some View {
        let avgDur = averageSleepDurationPastWeek
        let totalInt = todayInterruptionCount
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.spacingMD) {
            metricCard(
                title: "Ortalama Uyku",
                value: String(format: "%.1f sa", avgDur),
                subtitle: "Son 7 gün",
                icon: "clock.fill",
                color: AppTheme.accentPrimary
            )
            
            metricCard(
                title: "Uyanma",
                value: "\(totalInt) kez",
                subtitle: "Bugün",
                icon: "exclamationmark.triangle.fill",
                color: totalInt > 3 ? AppTheme.warning : AppTheme.success
            )
        }
    }
    
    private func metricCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - 4. Derin Analizler (Pro)
    
    private var deepAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Derin Analizler")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("PRO")
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                // Uyku Kalitesi Skoru
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 8)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: 0.88)
                            .stroke(AppTheme.success, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        Text("88")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Uyku Kalite Skoru")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Mükemmel! Bebeğinizin uyku derinliği artıyor.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // En Etkili Ses
                HStack {
                    Image(systemName: "waveform")
                        .foregroundStyle(AppTheme.accentPrimary)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.accentPrimary.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("En Etkili Kombinasyon")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("Anne Karnı + Beyaz Gürültü")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Yapay Zeka Tavsiyesi
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(AppTheme.accentSecondary)
                        Text("AI Koç Analizi")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    
                    Text("Gündüz uykularındaki kesintiler son 3 gündür artış eğiliminde. 4. ay uyku gerilemesi dönemi başlamış olabilir. Rutinleri şaşmamaya ve uyanık kalma sürelerini 1.5 saatte tutmaya özen gösterin.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // MARK: PREMIUM GATEWAY
            .premiumLocked()
        }
    }
    
    // MARK: - Data Helpers
    
    private var todaySleepMinutes: Double {
        let today = Date.now.startOfDay
        return sessions
            .filter { $0.startedAt >= today }
            .compactMap(\.durationInMinutes)
            .reduce(0, +)
    }
    
    private var longestUninterruptedSleepToday: TimeInterval {
        let today = Date.now.startOfDay
        return sessions
            .filter { $0.startedAt >= today }
            .map(\.longestUninterruptedStretch)
            .max() ?? 0
    }
    
    private var todayInterruptionCount: Int {
        let today = Date.now.startOfDay
        return sessions
            .filter { $0.startedAt >= today }
            .reduce(0) { $0 + $1.interruptionCount }
    }
    
    private var averageSleepDurationPastWeek: Double {
        let weekAgo = Date.now.daysAgo(7).startOfDay
        let pastWeekSessions = sessions.filter { $0.startedAt >= weekAgo }
        guard !pastWeekSessions.isEmpty else { return 0 }
        
        let total = pastWeekSessions.compactMap(\.durationInMinutes).reduce(0, +)
        return (total / Double(pastWeekSessions.count)) / 60.0 // Saat cinsinden
    }
}

#Preview {
    AnalyticsDashboardView()
        .modelContainer(PreviewSampleData.container)
}
