import SwiftUI

// MARK: - Success Score View
/// Başarı puanı gösterimi.
/// PRD §3.4: "En uzun süre kesintisiz dinlenen seslerin
/// 'Başarı Puanı' artırılarak kullanıcıya önerilmesi."
///
/// Dairesel ilerleme göstergesi ile haftalık başarı puanını gösterir.
struct SuccessScoreView: View {
    
    let sessions: [SleepSession]
    
    /// Başarı puanı (0-100)
    private var score: Int {
        guard !sessions.isEmpty else { return 0 }
        
        let totalSessions = sessions.count
        
        // Kesintisiz oturum oranı
        let uninterruptedCount = sessions.filter { $0.interruptionCount == 0 }.count
        let uninterruptedRatio = Double(uninterruptedCount) / Double(totalSessions)
        
        // Ortalama uyku süresi faktörü (30dk üstü başarılı sayılır)
        let avgMinutes = sessions.compactMap(\.durationInMinutes).reduce(0, +) / Double(totalSessions)
        let durationFactor = min(avgMinutes / 60.0, 1.0) // Max 1 saat = tam puan
        
        // Kalite puanı ortalaması
        let ratings = sessions.compactMap(\.qualityRating)
        let avgRating = ratings.isEmpty ? 3.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
        let ratingFactor = avgRating / 5.0
        
        // Ağırlıklı toplam
        let rawScore = (uninterruptedRatio * 0.4 + durationFactor * 0.35 + ratingFactor * 0.25) * 100
        
        return min(100, max(0, Int(rawScore)))
    }
    
    /// Puanın yüzdelik değeri (0.0 - 1.0)
    private var progress: Double {
        Double(score) / 100.0
    }
    
    /// Puan seviyesi
    private var level: ScoreLevel {
        ScoreLevel.from(score: score)
    }
    
    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingLG) {
                // Dairesel ilerleme
                ZStack {
                    // Arka plan halkası
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // İlerleme halkası
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [level.color, level.color.opacity(0.5)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(level.color)
                        
                        Text("puan")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                
                // Detaylar
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Başarı Puanı")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text(level.message)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(2)
                    
                    // Seviye rozeti
                    HStack(spacing: 4) {
                        Image(systemName: level.icon)
                            .font(.caption2)
                        Text(level.title)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(level.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(level.color.opacity(0.12))
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Score Level
private enum ScoreLevel {
    case beginner   // 0-25
    case developing // 26-50
    case good       // 51-75
    case excellent  // 76-100
    
    static func from(score: Int) -> ScoreLevel {
        switch score {
        case 0...25:  return .beginner
        case 26...50: return .developing
        case 51...75: return .good
        default:      return .excellent
        }
    }
    
    var title: String {
        switch self {
        case .beginner:   return "Başlangıç"
        case .developing: return "Gelişiyor"
        case .good:       return "İyi"
        case .excellent:  return "Mükemmel"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner:   return "leaf.fill"
        case .developing: return "arrow.up.right"
        case .good:       return "star.fill"
        case .excellent:  return "trophy.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner:   return AppTheme.textTertiary
        case .developing: return AppTheme.warning
        case .good:       return AppTheme.accentPrimary
        case .excellent:  return AppTheme.success
        }
    }
    
    var message: String {
        switch self {
        case .beginner:   return "Birkaç oturum daha kaydedince daha net sonuçlar çıkacak."
        case .developing: return "Uyku düzeni gelişiyor. Doğru yoldasınız!"
        case .good:       return "Harika gidiyorsunuz! Uyku düzeni oturmaya başladı."
        case .excellent:  return "Mükemmel bir hafta! Uyku kalitesi çok iyi."
        }
    }
}

#Preview {
    ZStack {
        GradientBackground()
        SuccessScoreView(sessions: [])
            .padding()
    }
}
