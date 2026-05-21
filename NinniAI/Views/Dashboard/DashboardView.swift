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
    
    @Query private var allSounds: [Sound]
    
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
            
        }
        .onAppear {
            refreshContext()
        }
        .sheet(isPresented: $showTimePickerSheet) {
            timePickerSheet
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Normal Dashboard
    
    private var normalDashboard: some View {
        ZStack {
            // Theme: Deep navy blue (#020617 / #0f172a)
            LinearGradient(
                colors: [Color(hex: "020617"), Color(hex: "0F172A")],
                startPoint: .top,
                endPoint: .bottom
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
        VStack(alignment: .leading, spacing: 6) {
            let babyName = baby?.name ?? "Beren"
            let ageText = baby != nil ? "\(baby!.ageInMonths) aylık" : "7 aylık"
            let recommended = recommendedSleep
            
            Text("\(babyName) nasıl? \(babyName) bugün tam \(ageText).")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text("Bugün hedef: \(recommended) saat uyku")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8")) // Light gray
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Agent Suggestion Card
    
    @State private var pulseGlow = false
    
    private var suggestedSound: Sound? {
        if context.isNightMode {
            return allSounds.first(where: { $0.displayName.contains("Anne Karnı") || $0.categoryRawValue == "white_noise" }) ?? allSounds.first
        } else {
            return allSounds.first(where: { $0.displayName.contains("Okyanus") || $0.categoryRawValue == "nature" }) ?? allSounds.first
        }
    }
    
    private var agentSuggestionCard: some View {
        VStack(spacing: 24) {
            // Header
            HStack(alignment: .top) {
                // Status Badge
                Text(isBabyAwake ? "Uyanık" : "Uyuyor")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color(hex: "0F172A").opacity(0.8))
                            Capsule()
                                .stroke(isBabyAwake ? AppTheme.accentPrimary : Color.indigo, lineWidth: 1)
                        }
                    )
                    .shadow(color: isBabyAwake ? AppTheme.accentPrimary.opacity(pulseGlow ? 0.6 : 0.2) : Color.indigo.opacity(pulseGlow ? 0.6 : 0.2), radius: pulseGlow ? 12 : 4)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            pulseGlow = true
                        }
                    }
                
                Spacer()
                
                Text("UYKU KOÇU (PRO)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "94A3B8"))
                    .tracking(1)
            }
            
            // Center Content
            VStack(spacing: 8) {
                Text(isBabyAwake ? "Tahmini Uyku Vakti" : "Şu An Uykuda")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "94A3B8"))
                
                Text(isBabyAwake ? nextSleepWindowText : currentSleepDurationText)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            // Subtle Player Interface
            if isBabyAwake {
                HStack {
                    Text(suggestedSound?.displayName ?? "Okyanus Sesi")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "94A3B8"))
                    
                    Spacer()
                    
                    Button(action: {
                        if let sound = suggestedSound {
                            appState.audioEngine.play(sound: sound)
                        }
                        appState.selectedTab = .player
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(Color(hex: "1E293B").opacity(0.5)) // Dark elegant card
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .premiumLocked()
    }
    
    // MARK: - Quick Trackers
    
    private var quickTrackersSection: some View {
        HStack(spacing: 16) {
            // Left: Amber glowing Sun
            Button(action: {
                selectedTime = Date()
                isSettingWakeTime = true
                showTimePickerSheet = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "FBBF24"))
                        .shadow(color: Color(hex: "FBBF24").opacity(0.6), radius: 8)
                    
                    Text("Bebek\nUyandı")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "FDE68A"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "452A0F").opacity(0.6)) // Amber dark base
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "B45309").opacity(0.5), lineWidth: 1)
                    }
                )
                .shadow(color: Color(hex: "B45309").opacity(0.2), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            
            // Right: Indigo glowing Moon
            Button(action: {
                selectedTime = Date()
                isSettingWakeTime = false
                showTimePickerSheet = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "A78BFA"))
                        .shadow(color: Color(hex: "A78BFA").opacity(0.6), radius: 8)
                    
                    Text("Bebek\nUyudu")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "E0E7FF"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "1E1B4B").opacity(0.6)) // Indigo dark base
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "4338CA").opacity(0.5), lineWidth: 1)
                    }
                )
                .shadow(color: Color(hex: "4338CA").opacity(0.2), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Pediatric Coach Advice
    
    private var developmentCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(Color(hex: "FDE047")) // Soft yellow
                .font(.title2)
                .shadow(color: Color(hex: "FDE047").opacity(0.5), radius: 8)
            
            Text("Ayrılık Kaygısı Dönemi: Uykuya dalışta yanınızda olmak isteyebilir. Rutinleri koruyun.")
                .font(.subheadline)
                .lineSpacing(4)
                .foregroundStyle(Color(hex: "E2E8F0"))
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color(hex: "334155").opacity(0.4)) // Soft dark gray
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
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
