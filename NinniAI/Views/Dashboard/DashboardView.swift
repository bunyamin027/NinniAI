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
    
    @Query private var allSounds: [Sound]
    
    @State private var showMilestoneCard = false
    @State private var activeMilestone: Milestone?
    
    // Agentic Dashboard State
    @AppStorage("lastWakeUpTime") private var lastWakeUpTime: Double = Date.now.timeIntervalSince1970
    @AppStorage("lastSleepTime") private var lastSleepTime: Double = Date.now.timeIntervalSince1970
    @AppStorage("isBabyAwake") private var isBabyAwake: Bool = true
    
    // Time Picker State
    @State private var showTimePickerSheet = false
    @State private var isSettingWakeTime = true
    @State private var selectedTime: Date = Date()
    
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
        .sheet(isPresented: $showTimePickerSheet) {
            timePickerSheet
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Normal Dashboard
    
    private var normalDashboard: some View {
        ZStack {
            // Gece mavisi / Antigravity gradient arkaplan
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.15), Color(red: 0.12, green: 0.1, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingLG) {
                    smartHeaderSection
                        .padding(.top, AppTheme.spacingMD)
                    
                    agentSuggestionCard
                    
                    quickTrackersSection
                    
                    developmentCard
                    
                    Spacer(minLength: 120) // MiniPlayer ve alt bar alanı
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
    }
    
    // MARK: - Smart Header
    
    private var smartHeaderSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
            let babyName = baby?.name ?? "Bebeğiniz"
            let ageText = baby != nil ? "\(baby!.ageInMonths) aylık" : ""
            
            Text("\(context.greeting), \(babyName) bugün tam \(ageText).")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text("Bugün hedef: \(recommendedSleep) saat uyku")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spacingSM)
    }
    
    // MARK: - Agent Suggestion Card
    
    private var agentSuggestionCard: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(red: 0.85, green: 0.71, blue: 0.89)) // Pastel lavanta
                    .font(.title2)
                
                Text(isBabyAwake ? "Uyku Koçu" : "Uyku Modu")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if isBabyAwake {
                    Text("Uyanık")
                        .font(.caption2).bold()
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                } else {
                    Text("Uyuyor")
                        .font(.caption2).bold()
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.indigo.opacity(0.3))
                        .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 1.0))
                        .clipShape(Capsule())
                }
            }
            
            VStack(spacing: AppTheme.spacingSM) {
                if isBabyAwake {
                    Text("Tahmini Uyku Vakti")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(nextSleepWindowText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.85, green: 0.71, blue: 0.89))
                        .shadow(color: Color(red: 0.85, green: 0.71, blue: 0.89).opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Text("Uyanık kaldığı süreye ve gelişim ayına göre hesaplandı.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                } else {
                    Text("Şu An Uykuda")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(currentSleepDurationText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.6, green: 0.8, blue: 1.0)) // soft mavi
                        .shadow(color: Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Text("dinleniyor...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, AppTheme.spacingMD)
            
            if isBabyAwake {
                Button(action: {
                    if let oceanSound = allSounds.first(where: { $0.fileName == "soutera-cosmic-ocean-284361" }) {
                        appState.audioEngine.play(sound: oceanSound)
                    }
                }) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                        Text("Esnemeler başlamadan okyanus sesini hazırlayalım.")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingSM)
                    .foregroundStyle(.white)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.85, green: 0.71, blue: 0.89).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            } else {
                Text("Büyüme hormonu salgılanıyor, rüyalara daldı.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.spacingLG)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 25, x: 0, y: 12)
    }
    
    // MARK: - Quick Trackers
    
    private var quickTrackersSection: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Button(action: {
                selectedTime = Date()
                isSettingWakeTime = true
                showTimePickerSheet = true
            }) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.yellow)
                    Text("Bebek Uyandı")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingMD)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .clipShape(Capsule())
                .shadow(color: isBabyAwake ? Color.yellow.opacity(0.15) : .clear, radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                selectedTime = Date()
                isSettingWakeTime = false
                showTimePickerSheet = true
            }) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(Color(red: 0.85, green: 0.71, blue: 0.89))
                    Text("Bebek Uyudu")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingMD)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .clipShape(Capsule())
                .shadow(color: !isBabyAwake ? Color(red: 0.85, green: 0.71, blue: 0.89).opacity(0.15) : .clear, radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Pediatric Coach Advice
    
    private var developmentCard: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingMD) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            
            Text(coachAdviceText)
                .font(.footnote)
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.85))
            
            Spacer(minLength: 0)
        }
        .padding(AppTheme.spacingLG)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
    }
    
    // MARK: - Agentic Logic Helpers
    
    private var maxWakeWindowHours: Double {
        let age = baby?.ageInMonths ?? 0
        switch age {
        case 0...1: return 1.0
        case 2: return 1.5
        case 3...4: return 2.0
        case 5...6: return 2.5
        case 7...9: return 3.0
        case 10...12: return 3.5
        case 13...18: return 4.5
        default: return 5.0
        }
    }
    
    private var recommendedSleep: Int {
        Int(baby?.ageGroup.recommendedSleepHours.upperBound ?? 14)
    }
    
    private var nextSleepWindowText: String {
        let wakeDate = Date(timeIntervalSince1970: lastWakeUpTime)
        let nextSleepStart = wakeDate.addingTimeInterval(maxWakeWindowHours * 3600)
        let nextSleepEnd = nextSleepStart.addingTimeInterval(15 * 60)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return "\(formatter.string(from: nextSleepStart)) - \(formatter.string(from: nextSleepEnd))"
    }
    
    private var coachAdviceText: String {
        let age = baby?.ageInMonths ?? 0
        switch age {
        case 0...2: return "Yenidoğan Dönemi: Bebeğiniz henüz gece/gündüz ayrımını bilmiyor. Gündüzleri aydınlık, geceleri loş ortam sağlayın."
        case 3...4: return "⚠️ 4. Ay Uyku Gerilemesi Dönemi: Bebeğiniz sirkadiyen ritim geliştiriyor, gündüz uykularını 2 saatten uzun tutmamaya özen gösterin."
        case 5...6: return "Katı Gıdaya Geçiş: Uyku öncesi aşırı beslenmeden kaçının. Gece uyanmaları azalabilir."
        case 7...9: return "Ayrılık Kaygısı Dönemi: Uykuya dalışta yanınızda olmak isteyebilir. Rutinleri koruyun."
        case 10...12: return "Hareketli Dönem: Emekleme/yürüme çalışmaları uykuyu bölebilir. Gündüz bol aktivite yaptırın."
        default: return "Rutin Dönemi: İstikrarlı bir uyku rutini bebeğinizin gelişimini destekler. Saatleri korumaya çalışın."
        }
    }
    
    private var currentSleepDurationText: String {
        let sleepDate = Date(timeIntervalSince1970: lastSleepTime)
        let diff = Date().timeIntervalSince(sleepDate)
        if diff < 0 { return "0 dk" }
        let minutes = Int(diff) / 60
        let hours = minutes / 60
        let remMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours) saat \(remMinutes) dk"
        } else {
            return "\(minutes) dk"
        }
    }
    
    // MARK: - Time Picker Sheet
    
    private var timePickerSheet: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text(isSettingWakeTime ? "Saat kaçta uyandı?" : "Saat kaçta uyudu?")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.top, AppTheme.spacingMD)
            
            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            
            Button(action: saveTime) {
                Text("Kaydet")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingMD)
                    .background(AppTheme.accentPrimary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.bottom, AppTheme.spacingLG)
        }
    }
    
    private func saveTime() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if isSettingWakeTime {
                lastWakeUpTime = selectedTime.timeIntervalSince1970
                isBabyAwake = true
                LiveActivityManager.shared.stopLiveActivity()
            } else {
                lastSleepTime = selectedTime.timeIntervalSince1970
                isBabyAwake = false
                LiveActivityManager.shared.startLiveActivity(
                    babyName: baby?.name ?? "Bebeğiniz",
                    soundName: appState.audioEngine.activeLayer?.displayName ?? "Sessiz"
                )
            }
        }
        showTimePickerSheet = false
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
