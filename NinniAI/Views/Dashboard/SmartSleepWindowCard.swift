import SwiftUI

// MARK: - Smart Sleep Window Card
/// Akıllı Uyku Penceresi (Smart Sleep Window) takip kartı.
/// Ebeveynleri pasif olarak bekleyen değil, aktif olarak yönlendiren proaktif arayüz.
/// - Bebeğin uyanış saatine göre ideal uyku saatini hesaplar
/// - İdeal saatten 15 dk öncesine lokal bildirim kurar
/// - Kalan süreyi ve uyku penceresi durumunu canlı gösterir
struct SmartSleepWindowCard: View {
    
    let baby: Baby?
    @Binding var lastWakeUpTime: Double
    @Binding var lastSleepTime: Double
    @Binding var isBabyAwake: Bool
    let onOpenTimePicker: (_ isWakeTime: Bool) -> Void
    
    @State private var pulseGlow: Bool = false
    
    private var optimalSleepTime: Date {
        let wakeDate = Date(timeIntervalSince1970: lastWakeUpTime)
        let age = baby?.ageInMonths ?? 6
        return SleepWindowService.shared.calculateNextSleepTime(wakeUpTime: wakeDate, ageInMonths: age)
    }
    
    private var optimalSleepTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: optimalSleepTime)
    }
    
    private var reminderTimeFormatted: String {
        let reminderDate = SleepWindowService.shared.calculateReminderTime(optimalSleepTime: optimalSleepTime, leadMinutes: 15)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: reminderDate)
    }
    
    private var remainingWakeTimeText: String {
        SleepWindowService.shared.remainingTimeText(to: optimalSleepTime)
    }
    
    private var sleepWindowStatus: SleepWindowStatus {
        let wakeDate = Date(timeIntervalSince1970: lastWakeUpTime)
        let age = baby?.ageInMonths ?? 6
        return SleepWindowService.shared.evaluateStatus(wakeUpTime: wakeDate, ageInMonths: age)
    }
    
    private var statusColor: Color {
        switch sleepWindowStatus {
        case .playing:     return Color(hex: "34D399") // Emerald yeşil
        case .approaching: return Color(hex: "FBBF24") // Kehribar sarı
        case .optimal:     return AppTheme.accentPrimary // Neon mor
        case .overtired:   return Color(hex: "F87171") // Kırmızı uyarı
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
    
    var body: some View {
        VStack(spacing: 20) {
            // ─── Üst Başlık & Durum Rozeti ───
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isBabyAwake ? statusColor : Color.indigo)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseGlow ? 1.3 : 1.0)
                    
                    Text(isBabyAwake ? sleepWindowStatus.title : "Şu An Uykuda")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isBabyAwake ? statusColor : Color.indigo)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((isBabyAwake ? statusColor : Color.indigo).opacity(0.12))
                .clipShape(Capsule())
                
                Spacer()
                
                Text("AKILLI UYKU PENCERESİ")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "94A3B8"))
                    .tracking(1.2)
            }
            
            // ─── Merkez Bilgi: Bir Sonraki Tahmini Uyku ───
            VStack(spacing: 6) {
                Text(isBabyAwake ? "Bir sonraki tahmini uyku" : "Toplam Uyku Süresi")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "94A3B8"))
                
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text(isBabyAwake ? optimalSleepTimeFormatted : currentSleepDurationText)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    if isBabyAwake {
                        Button {
                            onOpenTimePicker(true)
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "94A3B8"))
                        }
                    }
                }
                
                if isBabyAwake {
                    HStack(spacing: 8) {
                        Text("Kalan: \(remainingWakeTimeText)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(statusColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.12))
                            .clipShape(Capsule())
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bell.badge.fill")
                                .font(.caption2)
                            Text("\(reminderTimeFormatted) bildirim 🌙")
                                .font(.caption2)
                        }
                        .foregroundStyle(Color(hex: "94A3B8"))
                    }
                    .padding(.top, 2)
                }
            }
            
            // ─── Hızlı Aksiyon Butonları (1-Tık Entegrasyonu) ───
            HStack(spacing: 12) {
                // 1) Bebek Uyandı Butonu
                Button(action: recordBabyWokeUpNow) {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.subheadline)
                        Text("Bebek Uyandı")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(isBabyAwake ? .white : Color(hex: "FDE68A"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isBabyAwake ? Color(hex: "D97706") : Color(hex: "452A0F").opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "F59E0B").opacity(isBabyAwake ? 0.8 : 0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // 2) Bebek Uyudu Butonu
                Button(action: recordBabyFellAsleepNow) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.subheadline)
                        Text("Bebek Uyudu")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(!isBabyAwake ? .white : Color(hex: "E0E7FF"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(!isBabyAwake ? Color(hex: "4F46E5") : Color(hex: "1E1B4B").opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "6366F1").opacity(!isBabyAwake ? 0.8 : 0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: "1E293B").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [statusColor.opacity(0.4), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: statusColor.opacity(0.15), radius: 20, x: 0, y: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }
    
    // MARK: - 1-Tık Hızlı Tetikleyiciler
    
    /// Tek tıkla "Şimdi Uyandı" kaydı alır ve 15 dk öncesine lokal bildirimi kurar
    private func recordBabyWokeUpNow() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let now = Date()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            lastWakeUpTime = now.timeIntervalSince1970
            isBabyAwake = true
        }
        
        LiveActivityManager.shared.stopLiveActivity()
        
        // 15 dakika öncesine Akıllı Uyku Bildirimi kur
        let age = baby?.ageInMonths ?? 6
        let babyName = baby?.name ?? "Bebeğiniz"
        let optimal = SleepWindowService.shared.calculateNextSleepTime(wakeUpTime: now, ageInMonths: age)
        NotificationManager.shared.scheduleSleepWindowReminder(optimalSleepTime: optimal, babyName: babyName)
    }
    
    /// Tek tıkla "Şimdi Uyudu" kaydı alır, bildirimi iptal eder ve Live Activity başlatır
    private func recordBabyFellAsleepNow() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let now = Date()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            lastSleepTime = now.timeIntervalSince1970
            isBabyAwake = false
        }
        
        // Bekleyen pencere hatırlatmasını iptal et
        NotificationManager.shared.cancelSleepWindowReminder()
        
        LiveActivityManager.shared.startLiveActivity(
            babyName: baby?.name ?? "Bebeğiniz",
            soundName: "Sessiz",
            startTime: now
        )
    }
}
