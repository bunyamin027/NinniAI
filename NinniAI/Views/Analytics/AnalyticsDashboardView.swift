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
    @Query private var allSounds: [Sound]
    
    @State private var animateRings = false
    @State private var showTodayAnalysis = false
    
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
                    
                    Button(action: { showTodayAnalysis = true }) {
                        HStack {
                            Text("Günün Analizi Detayı")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    deepAnalyticsSection
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .sheet(isPresented: $showTodayAnalysis) {
            TodayAnalysisView()
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
        let todayMins = calculateTodaySleepMinutes(for: .now)
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
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let todayMins = calculateTodaySleepMinutes(for: context.date)
            let todayHours = todayMins / 60.0
            
            let uninterruptedMins = calculateLongestUninterruptedSleepToday(for: context.date) / 60.0
            let uninterruptedHours = uninterruptedMins / 60.0
            
            let totalProgress = min(todayHours / targetSleepHours, 1.0)
            let uninterruptedProgress = min(uninterruptedHours / targetSleepHours, 1.0)
            
            let activeSession = sessions.first { $0.isActive && $0.startedAt >= Date.now.startOfDay }
            
            VStack(spacing: 24) {
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
                        if activeSession != nil {
                            HStack(spacing: 4) {
                                Circle().fill(AppTheme.accentPrimary).frame(width: 6, height: 6)
                                Text("Şu an uyuyor")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(AppTheme.accentPrimary)
                            }
                            .padding(.bottom, 2)
                        }
                        
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
        let (score, scoreMessage) = calculateSleepQualityScore()
        let mostEffectiveSoundName = calculateMostEffectiveSound()
        let coachMessage = generateAICoachMessage()
        
        return VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
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
                            .trim(from: 0, to: CGFloat(score) / 100.0)
                            .stroke(score > 75 ? AppTheme.success : (score > 50 ? AppTheme.warning : .red), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(score)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Uyku Kalite Skoru")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(scoreMessage)
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
                        Text("En Etkili Ses")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                        Text(mostEffectiveSoundName)
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
                    
                    Text(coachMessage)
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
    
    private func calculateTodaySleepMinutes(for date: Date = .now) -> Double {
        let today = date.startOfDay
        return sessions
            .filter { $0.startedAt >= today }
            .reduce(0.0) { total, session in
                let duration = session.isActive ? date.timeIntervalSince(session.startedAt) : (session.durationInSeconds ?? 0)
                return total + (duration / 60.0)
            }
    }
    
    private func calculateLongestUninterruptedSleepToday(for date: Date = .now) -> TimeInterval {
        let today = date.startOfDay
        return sessions
            .filter { $0.startedAt >= today }
            .map { session in
                if session.isActive {
                    let uninterrupted = date.timeIntervalSince(session.startedAt) // Simplified for active session
                    return max(uninterrupted, session.longestUninterruptedStretch)
                }
                return session.longestUninterruptedStretch
            }
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
        let pastWeekSessions = sessions.filter { $0.startedAt >= weekAgo && !$0.isActive }
        guard !pastWeekSessions.isEmpty else { return 0 }
        
        let total = pastWeekSessions.compactMap(\.durationInMinutes).reduce(0.0, +)
        return (total / Double(pastWeekSessions.count)) / 60.0 // Saat cinsinden
    }
    
    private func calculateSleepQualityScore() -> (Int, String) {
        let todayMins = calculateTodaySleepMinutes(for: .now)
        if todayMins < 30 { return (0, "Henüz yeterli veri yok.") }
        
        var score = 100.0
        
        let targetMins = targetSleepHours * 60
        if todayMins < targetMins {
            score -= ((targetMins - todayMins) / targetMins) * 40 // Up to 40 points penalty
        }
        
        let totalInt = todayInterruptionCount
        score -= Double(totalInt * 5) // 5 points penalty per interruption
        
        score = max(min(score, 100), 10)
        
        let msg: String
        if score > 85 { msg = "Mükemmel! Bebeğinizin uyku derinliği çok iyi." }
        else if score > 60 { msg = "İyi. Kesintileri azaltmak için farklı sesler deneyebilirsiniz." }
        else { msg = "Düşük kalite. Uyku rutininizi gözden geçirmenizi öneririz." }
        
        return (Int(score), msg)
    }
    
    private func calculateMostEffectiveSound() -> String {
        guard !sessions.isEmpty else { return "Veri Bekleniyor" }
        
        var counts: [String: Int] = [:]
        for session in sessions where !session.playedSoundIdentifiers.isEmpty {
            for id in session.playedSoundIdentifiers {
                counts[id, default: 0] += 1
            }
        }
        
        if let topID = counts.max(by: { $0.value < $1.value })?.key,
           let sound = allSounds.first(where: { $0.identifier == topID }) {
            return sound.displayName
        }
        
        return "Anne Karnı (Varsayılan)"
    }
    
    private func generateAICoachMessage() -> String {
        let past3Days = Date.now.daysAgo(3).startOfDay
        let recentSessions = sessions.filter { $0.startedAt >= past3Days }
        
        if recentSessions.isEmpty {
            return "Düzenli uyku kaydı tutarak bebeğinizin gelişimine dair yapay zeka analizleri alabilirsiniz."
        }
        
        let totalInterruptions = recentSessions.reduce(0) { $0 + $1.interruptionCount }
        
        if totalInterruptions > 5 {
            return "Son 3 gündür kesintiler yüksek. 4. ay uyku gerilemesi dönemi veya diş çıkarma olabilir. Rutinleri şaşmamaya özen gösterin."
        } else if calculateTodaySleepMinutes(for: .now) < (targetSleepHours * 60) - 120 {
            return "Uyku hedefine ulaşmakta zorlanıyorsunuz. Gündüz uyanık kalma sürelerini (wake windows) uzatmayı deneyebilirsiniz."
        } else {
            return "Harika gidiyorsunuz! Son 3 gündür uyku düzeni çok istikrarlı. Mevcut rutini korumaya devam edin."
        }
    }
}

#Preview {
    AnalyticsDashboardView()
        .modelContainer(PreviewSampleData.container)
}

struct TodayAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SleepSession.startedAt, order: .reverse) private var sessions: [SleepSession]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.08, blue: 0.15), Color(red: 0.12, green: 0.1, blue: 0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        distributionSection
                        
                        comparisonSection
                        
                        interruptionSection
                        
                        timelineSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(AppTheme.spacingMD)
                }
            }
            .navigationTitle("Günün Analizi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.title3)
                    }
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
    
    // MARK: - Data Helpers
    
    private var todaySessions: [SleepSession] {
        let todayStart = Date.now.startOfDay
        return sessions.filter { $0.startedAt >= todayStart }
    }
    
    private var yesterdaySessions: [SleepSession] {
        let todayStart = Date.now.startOfDay
        let yesterdayStart = todayStart.addingTimeInterval(-24 * 60 * 60)
        return sessions.filter { $0.startedAt >= yesterdayStart && $0.startedAt < todayStart }
    }
    
    private var todayNightSleepMinutes: Double {
        todaySessions
            .filter { $0.sessionType == .nightSleep }
            .reduce(0.0) { $0 + (($1.isActive ? Date.now.timeIntervalSince($1.startedAt) : $1.durationInSeconds ?? 0) / 60.0) }
    }
    
    private var todayNapMinutes: Double {
        todaySessions
            .filter { $0.sessionType == .nap }
            .reduce(0.0) { $0 + (($1.isActive ? Date.now.timeIntervalSince($1.startedAt) : $1.durationInSeconds ?? 0) / 60.0) }
    }
    
    private var todayTotalMinutes: Double {
        todayNightSleepMinutes + todayNapMinutes
    }
    
    private var yesterdayTotalMinutes: Double {
        yesterdaySessions.compactMap(\.durationInMinutes).reduce(0.0, +)
    }
    
    // MARK: - Views
    
    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gece / Gündüz Dağılımı")
                .font(.headline)
                .foregroundStyle(.white)
            
            let total = max(todayTotalMinutes, 1) // Prevent division by zero
            let nightRatio = todayNightSleepMinutes / total
            let napRatio = todayNapMinutes / total
            
            GeometryReader { geo in
                HStack(spacing: 4) {
                    if nightRatio > 0 {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.indigo)
                            .frame(width: max(0, geo.size.width * nightRatio - 2))
                    }
                    
                    if napRatio > 0 {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                            .frame(width: max(0, geo.size.width * napRatio - 2))
                    }
                }
            }
            .frame(height: 24)
            .animation(.spring(), value: todayTotalMinutes)
            
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.indigo).frame(width: 8, height: 8)
                    Text("Gece: \(formatMinutes(todayNightSleepMinutes))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("Gündüz: \(formatMinutes(todayNapMinutes))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Düne Göre Karşılaştırma")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dün")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(formatMinutes(yesterdayTotalMinutes))
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.white.opacity(0.4))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bugün")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(formatMinutes(todayTotalMinutes))
                        .font(.title3.bold())
                        .foregroundStyle(todayTotalMinutes >= yesterdayTotalMinutes ? AppTheme.success : AppTheme.warning)
                }
                
                Spacer()
                
                if yesterdayTotalMinutes > 0 {
                    let diff = todayTotalMinutes - yesterdayTotalMinutes
                    let percent = abs(diff) / yesterdayTotalMinutes * 100
                    let isUp = diff >= 0
                    
                    HStack(spacing: 4) {
                        Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "%%%0.f", percent))
                    }
                    .font(.caption.bold())
                    .foregroundStyle(isUp ? AppTheme.success : AppTheme.warning)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background((isUp ? AppTheme.success : AppTheme.warning).opacity(0.2))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var interruptionSection: some View {
        let totalInt = todaySessions.reduce(0) { $0 + $1.interruptionCount }
        let stretches = todaySessions.map { $0.longestUninterruptedStretch }
        let avgStretch = stretches.isEmpty ? 0 : (stretches.reduce(0.0, +) / Double(stretches.count)) / 60.0
        
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kesintiler")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(totalInt) kez")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ort. Kesintisiz")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Text(formatMinutes(avgStretch))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Oturum Geçmişi (Bugün)")
                .font(.headline)
                .foregroundStyle(.white)
            
            if todaySessions.isEmpty {
                Text("Bugün henüz uyku kaydı yok.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)
            } else {
                ForEach(todaySessions) { session in
                    sessionCard(session)
                }
            }
        }
    }
    
    private func sessionCard(_ session: SleepSession) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(session.sessionType == .nightSleep ? Color.indigo.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: session.sessionType.iconName)
                    .foregroundStyle(session.sessionType == .nightSleep ? Color.indigo : Color.orange)
                    .font(.title3)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.displayTitle)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                
                HStack {
                    Text(session.startedAt, format: .dateTime.hour().minute())
                    Text("-")
                    if let endedAt = session.endedAt {
                        Text(endedAt, format: .dateTime.hour().minute())
                    } else {
                        Text("Devam Ediyor")
                            .foregroundStyle(AppTheme.accentPrimary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Duration
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                let duration = session.isActive ? context.date.timeIntervalSince(session.startedAt) : session.durationInSeconds ?? 0
                Text(formatMinutes(duration / 60.0))
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(session.isActive ? AppTheme.accentPrimary.opacity(0.2) : Color.white.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(session.isActive ? AppTheme.accentPrimary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // Formatter Helper
    private func formatMinutes(_ minutes: Double) -> String {
        if minutes < 60 {
            return "\(Int(minutes)) dk"
        } else {
            let h = Int(minutes) / 60
            let m = Int(minutes) % 60
            return "\(h) sa \(m) dk"
        }
    }
}
