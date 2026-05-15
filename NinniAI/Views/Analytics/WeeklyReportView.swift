import SwiftUI

// MARK: - Weekly Report View
/// Haftalık uyku rapor kartı.
/// Özet istatistikler ve tavsiye mesajı içerir.
struct WeeklyReportView: View {
    
    let totalHours: Double
    let avgMinutes: Double
    let sessionCount: Int
    let interruptions: Int
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                // Başlık
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(AppTheme.accentPrimary)
                    
                    Text("Haftalık Rapor")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(Date.now.startOfWeek.shortFormatted)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                
                // İstatistik satırları
                VStack(spacing: AppTheme.spacingSM) {
                    reportRow(
                        icon: "bed.double.fill",
                        label: "Toplam uyku süresi",
                        value: String(format: "%.1f saat", totalHours)
                    )
                    
                    Divider().overlay(Color.white.opacity(0.05))
                    
                    reportRow(
                        icon: "clock.fill",
                        label: "Ortalama oturum",
                        value: "\(Int(avgMinutes)) dakika"
                    )
                    
                    Divider().overlay(Color.white.opacity(0.05))
                    
                    reportRow(
                        icon: "play.circle.fill",
                        label: "Toplam oturum",
                        value: "\(sessionCount) seans"
                    )
                    
                    Divider().overlay(Color.white.opacity(0.05))
                    
                    reportRow(
                        icon: "exclamationmark.circle.fill",
                        label: "Toplam kesinti",
                        value: "\(interruptions) kez"
                    )
                }
                
                // Tavsiye mesajı
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.warning)
                    
                    Text(adviceMessage)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(2)
                }
                .padding(AppTheme.spacingSM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.warning.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
            }
        }
    }
    
    private func reportRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
    
    private var adviceMessage: String {
        if sessionCount == 0 {
            return "Bu hafta henüz kayıt yok. Düzenli kayıt tutmak uyku düzenini takip etmenize yardımcı olur."
        }
        if interruptions == 0 {
            return "Harika! Bu hafta hiç kesinti olmadı. Aynı sesleri kullanmaya devam edin."
        }
        if avgMinutes < 30 {
            return "Oturumlar biraz kısa kalmış. Zamanlayıcıyı 45 dakikaya çıkarmayı deneyin."
        }
        return "Güzel bir hafta geçirdiniz. Düzenli rutine devam edin, sonuçlar giderek iyileşecek."
    }
}

#Preview {
    ZStack {
        GradientBackground()
        WeeklyReportView(
            totalHours: 42.5,
            avgMinutes: 48,
            sessionCount: 12,
            interruptions: 3
        )
        .padding()
    }
}
