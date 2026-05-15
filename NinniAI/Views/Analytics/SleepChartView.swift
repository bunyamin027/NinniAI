import SwiftUI
import Charts

// MARK: - Sleep Chart View
/// Haftalık uyku süresi grafiği — Swift Charts.
/// PRD §3.4: "SwiftData ile toplanan verilerin görselleştirilmesi."
struct SleepChartView: View {
    
    let sessions: [SleepSession]
    
    /// Günlük toplam uyku verileri
    private var dailyData: [DailySleepData] {
        var data: [DailySleepData] = []
        
        for dayOffset in (0..<7).reversed() {
            let date = Date.now.daysAgo(dayOffset)
            let dayStart = date.startOfDay
            let dayEnd = date.endOfDay
            
            let daySessions = sessions.filter {
                $0.startedAt >= dayStart && $0.startedAt <= dayEnd
            }
            
            let totalMinutes = daySessions
                .compactMap(\.durationInMinutes)
                .reduce(0, +)
            
            let interruptions = daySessions
                .reduce(0) { $0 + $1.interruptionCount }
            
            data.append(DailySleepData(
                date: dayStart,
                totalMinutes: totalMinutes,
                sessionCount: daySessions.count,
                interruptions: interruptions
            ))
        }
        
        return data
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                // Başlık
                HStack {
                    Text("Haftalık Uyku")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text("Son 7 gün")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                
                // Grafik
                if dailyData.isEmpty || dailyData.allSatisfy({ $0.totalMinutes == 0 }) {
                    emptyChartView
                } else {
                    chart
                }
            }
        }
    }
    
    private var chart: some View {
        Chart(dailyData) { data in
            BarMark(
                x: .value("Gün", data.date, unit: .day),
                y: .value("Dakika", data.totalMinutes)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dayAbbreviation(date))
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let minutes = value.as(Double.self) {
                        Text("\(Int(minutes / 60))sa")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.white.opacity(0.05))
            }
        }
        .frame(height: 180)
    }
    
    private var emptyChartView: some View {
        VStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title)
                .foregroundStyle(AppTheme.textTertiary)
            
            Text("Henüz yeterli veri yok")
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
            
            Text("Birkaç uyku oturumu kaydettikten sonra\ngrafikler burada görünecek")
                .font(.caption2)
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Daily Sleep Data
struct DailySleepData: Identifiable {
    let id = UUID()
    let date: Date
    let totalMinutes: Double
    let sessionCount: Int
    let interruptions: Int
}

#Preview {
    ZStack {
        GradientBackground()
        SleepChartView(sessions: [])
            .padding()
    }
}
