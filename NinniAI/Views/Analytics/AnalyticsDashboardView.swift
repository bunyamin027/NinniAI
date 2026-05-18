import SwiftUI
import SwiftData
import Charts

// MARK: - Analytics Dashboard View
/// Uyku analitiği ana ekranı (Antigravity Tasarımı).
struct AnalyticsDashboardView: View {
    
    @State private var showPaywall = false
    
    // Geçici Dummy Data
    private struct DailySleep: Identifiable {
        let id = UUID()
        let day: String
        let hours: Double
    }
    
    private let dummyChartData: [DailySleep] = [
        DailySleep(day: "Pzt", hours: 11.0),
        DailySleep(day: "Sal", hours: 12.5),
        DailySleep(day: "Çar", hours: 13.0),
        DailySleep(day: "Per", hours: 12.2),
        DailySleep(day: "Cum", hours: 14.1),
        DailySleep(day: "Cmt", hours: 13.5),
        DailySleep(day: "Paz", hours: 12.5)
    ]
    
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
                VStack(spacing: 32) {
                    smartInsightCard
                        .padding(.top, 16)
                    
                    antigravityRings
                    
                    softTrendChart
                    
                    proLayer
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - 1. Akıllı İçgörü Kartı
    private var smartInsightCard: some View {
        let babyName = "Beren" // Şimdilik dummy, ileride SwiftData'dan gelecek
        return HStack(alignment: .top, spacing: 16) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color(red: 0.85, green: 0.71, blue: 0.89)) // Lavanta
                .font(.title2)
            
            Text("\(babyName) son 3 gündür gündüz uykularında 'Kozmik Rahim' frekansıyla %40 daha hızlı uykuya dalıyor.")
                .font(.subheadline)
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(red: 0.85, green: 0.71, blue: 0.89).opacity(0.15), radius: 15, x: 0, y: 8)
    }

    // MARK: - 2. Antigravity Uyku Halkaları
    private var antigravityRings: some View {
        VStack(spacing: 24) {
            ZStack {
                // Dış Halka Zemin
            Circle()
                .stroke(Color.indigo.opacity(0.2), lineWidth: 16)
                .frame(width: 220, height: 220)
            
            // Dış Halka İlerleme
            Circle()
                .trim(from: 0, to: 0.85) // 14 hedefin 12.5'i gibi
                .stroke(
                    AngularGradient(
                        colors: [Color.indigo, Color(red: 0.85, green: 0.71, blue: 0.89)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.indigo.opacity(0.4), radius: 10, x: 0, y: 0)
            
            // İç Halka Zemin
            Circle()
                .stroke(Color.purple.opacity(0.1), lineWidth: 12)
                .frame(width: 170, height: 170)
            
            // İç Halka İlerleme
            Circle()
                .trim(from: 0, to: 0.6)
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
                Text("12.5 Saat")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Hedef: 14 Saat")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            }
            
            // Lejant (Açıklama)
            HStack(spacing: 24) {
                HStack(spacing: 6) {
                    Circle().fill(Color.indigo).frame(width: 8, height: 8)
                    Text("Toplam Uyku").font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                HStack(spacing: 6) {
                    Circle().fill(Color.purple).frame(width: 8, height: 8)
                    Text("Kesintisiz Uyku").font(.caption).foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: - 3. Yumuşak Trend Grafiği (Charts)
    private var softTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son 7 Gün")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart(dummyChartData) { item in
                AreaMark(
                    x: .value("Gün", item.day),
                    y: .value("Saat", item.hours)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.71, blue: 0.89).opacity(0.5), Color.indigo.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Gün", item.day),
                    y: .value("Saat", item.hours)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color(red: 0.85, green: 0.71, blue: 0.89))
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [10, 12, 14, 16]) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - 4. Pro Katmanı (Freemium Blur Kancası)
    private var proLayer: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Derin Analizler")
                .font(.headline)
                .foregroundStyle(.white)
            
            ZStack {
                // Fake Blurred Content
                VStack(spacing: 16) {
                    ForEach(0..<2, id: \.self) { _ in
                        HStack {
                            Circle().fill(.white.opacity(0.2)).frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 6) {
                                RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.2)).frame(width: 120, height: 12)
                                RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.1)).frame(width: 80, height: 10)
                            }
                            Spacer()
                            RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.2)).frame(width: 40, height: 20)
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .blur(radius: 8) // Gizemli Blur Etkisi
                .allowsHitTesting(false) // Alt katman tıklamaları çalmasın
                
                // Pro CTA Butonu
                Button(action: {
                    showPaywall = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.4)) // Altın/Sarı
                        
                        Text("Derin analizler için Premium'a geç")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
        }
    }
}

#Preview {
    AnalyticsDashboardView()
}
