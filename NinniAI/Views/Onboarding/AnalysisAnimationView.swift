import SwiftUI

// MARK: - Analysis Animation View
/// Onboarding'in son adımı — "Analiz İllüzyonu" animasyonu.
/// PRD §3.1: "1.5-2 saniyelik bir animasyon gösterilerek
/// sistemin akıllı olduğu algısı pekiştirilir."
///
/// Sahte bir analiz süreci gösterilir:
/// 1. "Uyku profili oluşturuluyor..." (spinning)
/// 2. "Ses kütüphanesi kişiselleştiriliyor..." (progress)
/// 3. "Her şey hazır!" (tamamlanma animasyonu)
struct AnalysisAnimationView: View {
    
    let babyName: String
    let onComplete: () -> Void
    
    @State private var currentPhase: AnalysisPhase = .profiling
    @State private var progress: Double = 0
    @State private var isComplete = false
    @State private var particleSystem: [Particle] = []
    
    var body: some View {
        VStack(spacing: AppTheme.spacingXL) {
            Spacer()
            
            // Ana animasyon alanı
            ZStack {
                // Parçacık efekti (tamamlanınca)
                ForEach(particleSystem) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
                
                // Dönen halka
                if !isComplete {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppTheme.accentPrimary,
                                    AppTheme.accentSecondary,
                                    AppTheme.accentPrimary
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(progress * 360))
                }
                
                // Merkez ikon
                Image(systemName: isComplete ? "checkmark.circle.fill" : currentPhase.iconName)
                    .font(.system(size: isComplete ? 64 : 48))
                    .foregroundStyle(
                        isComplete
                        ? AppTheme.success
                        : AppTheme.accentPrimary
                    )
                    .scaleEffect(isComplete ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isComplete)
            }
            .frame(width: 200, height: 200)
            
            // Durum mesajı
            VStack(spacing: AppTheme.spacingSM) {
                Text(isComplete ? "Her Şey Hazır! ✨" : currentPhase.message)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .animation(.easeInOut, value: currentPhase)
                    .multilineTextAlignment(.center)
                
                if !isComplete {
                    Text(currentPhase.subtitle(babyName: babyName))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                } else {
                    Text("\(babyName) için kişiselleştirilmiş\nuyku profili oluşturuldu")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, AppTheme.spacingXL)
            
            Spacer()
            
            // Tamamla butonu (analiz bitince görünür)
            if isComplete {
                Button(action: onComplete) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Text("Keşfetmeye Başla")
                            .font(.headline)
                        Image(systemName: "sparkles")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.playerGradient)
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.shadowColorPrimary, radius: 16, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppTheme.spacingLG)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer()
                .frame(height: AppTheme.spacingXXL)
        }
        .onAppear {
            startAnalysisSequence()
        }
    }
    
    // MARK: - Analysis Sequence
    
    private func startAnalysisSequence() {
        let phases: [(AnalysisPhase, Double)] = [
            (.profiling, 0.3),
            (.personalizing, 0.7),
            (.optimizing, 1.0)
        ]
        
        var totalDelay: Double = 0
        
        for (phase, targetProgress) in phases {
            let delay = totalDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPhase = phase
                }
                withAnimation(.easeInOut(duration: 0.8)) {
                    progress = targetProgress
                }
            }
            
            totalDelay += 0.8
        }
        
        // Tamamlanma
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isComplete = true
            }
            spawnParticles()
        }
    }
    
    // MARK: - Particle Effect
    
    private func spawnParticles() {
        for i in 0..<20 {
            let particle = Particle(
                id: i,
                x: 0, y: 0,
                size: CGFloat.random(in: 4...10),
                color: [AppTheme.accentPrimary, AppTheme.accentSecondary, AppTheme.success].randomElement()!,
                opacity: 1
            )
            particleSystem.append(particle)
            
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 60...140)
            let targetX = cos(angle) * distance
            let targetY = sin(angle) * distance
            
            withAnimation(
                .easeOut(duration: Double.random(in: 0.6...1.2))
                .delay(Double(i) * 0.03)
            ) {
                particleSystem[i].x = targetX
                particleSystem[i].y = targetY
                particleSystem[i].opacity = 0
            }
        }
    }
}

// MARK: - Analysis Phase

private enum AnalysisPhase: CaseIterable {
    case profiling
    case personalizing
    case optimizing
    
    var message: String {
        switch self {
        case .profiling:     return "Uyku Profili Oluşturuluyor..."
        case .personalizing: return "Ses Kütüphanesi Kişiselleştiriliyor..."
        case .optimizing:    return "Öneriler Hazırlanıyor..."
        }
    }
    
    func subtitle(babyName: String) -> String {
        switch self {
        case .profiling:
            return "\(babyName) için en uygun uyku stratejisi belirleniyor"
        case .personalizing:
            return "Gelişim dönemine uygun sesler seçiliyor"
        case .optimizing:
            return "Kişisel uyku takvimi oluşturuluyor"
        }
    }
    
    var iconName: String {
        switch self {
        case .profiling:     return "brain.head.profile"
        case .personalizing: return "waveform.circle"
        case .optimizing:    return "sparkle.magnifyingglass"
        }
    }
}

// MARK: - Particle

private struct Particle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

#Preview {
    ZStack {
        GradientBackground(.onboarding)
        AnalysisAnimationView(babyName: "Elif", onComplete: {})
    }
}
