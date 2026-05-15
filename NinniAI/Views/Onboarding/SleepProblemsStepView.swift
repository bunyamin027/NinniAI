import SwiftUI

// MARK: - Sleep Problems Step View
/// Onboarding Adım 3 — Uyku problemi seçimi.
/// PRD §3.1: "Maksimum 2 uyku problemi seçilir."
///
/// Grid düzeninde problem kartları gösterilir.
/// ContextEngine bu seçimleri ses önerisi ve ipucu üretmek için kullanır.
struct SleepProblemsStepView: View {
    
    @Binding var selectedProblems: [SleepProblem]
    let onNext: () -> Void
    
    @State private var isAppeared = false
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.spacingSM),
        GridItem(.flexible(), spacing: AppTheme.spacingSM)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: AppTheme.spacingXL)
            
            // Başlık
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .opacity(isAppeared ? 1 : 0)
                    .scaleEffect(isAppeared ? 1 : 0.7)
                
                Text("Uyku Zorlukları")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(isAppeared ? 1 : 0)
                
                Text("En fazla 2 zorluk seçin.\nSize özel öneriler sunalım.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(isAppeared ? 1 : 0)
                
                // Seçim sayacı
                HStack(spacing: 4) {
                    ForEach(0..<AppConstants.maxSleepProblemsSelection, id: \.self) { index in
                        Circle()
                            .fill(
                                index < selectedProblems.count
                                ? AppTheme.accentPrimary
                                : Color.white.opacity(0.15)
                            )
                            .frame(width: 8, height: 8)
                            .animation(AppTheme.animationDefault, value: selectedProblems.count)
                    }
                }
                .padding(.top, AppTheme.spacingXS)
            }
            
            Spacer()
                .frame(height: AppTheme.spacingLG)
            
            // Problem grid'i
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: AppTheme.spacingSM) {
                    ForEach(SleepProblem.allCases) { problem in
                        ProblemCard(
                            problem: problem,
                            isSelected: selectedProblems.contains(problem),
                            isDisabled: !selectedProblems.contains(problem)
                                && selectedProblems.count >= AppConstants.maxSleepProblemsSelection
                        ) {
                            toggleProblem(problem)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
            .opacity(isAppeared ? 1 : 0)
            
            Spacer()
                .frame(height: AppTheme.spacingMD)
            
            // Devam butonu
            VStack(spacing: AppTheme.spacingSM) {
                Button(action: onNext) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Text("Devam")
                            .font(.headline)
                        Image(systemName: "arrow.right")
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
                
                // Atla seçeneği
                Button("Şimdilik atlayın") {
                    selectedProblems = []
                    onNext()
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .opacity(isAppeared ? 1 : 0)
            
            Spacer()
                .frame(height: AppTheme.spacingLG)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                isAppeared = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleProblem(_ problem: SleepProblem) {
        withAnimation(AppTheme.animationSpring) {
            if let index = selectedProblems.firstIndex(of: problem) {
                selectedProblems.remove(at: index)
            } else if selectedProblems.count < AppConstants.maxSleepProblemsSelection {
                selectedProblems.append(problem)
            }
        }
    }
}

// MARK: - Problem Card

private struct ProblemCard: View {
    let problem: SleepProblem
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: problem.iconName)
                    .font(.title2)
                    .foregroundStyle(
                        isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary
                    )
                    .frame(width: 40, height: 40)
                
                Text(problem.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        isSelected ? AppTheme.textPrimary : AppTheme.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingMD)
            .padding(.horizontal, AppTheme.spacingSM)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                    .fill(
                        isSelected
                        ? AppTheme.accentPrimary.opacity(0.12)
                        : Color.white.opacity(0.04)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                            .stroke(
                                isSelected
                                ? AppTheme.accentPrimary.opacity(0.5)
                                : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    }
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    ZStack {
        GradientBackground(.onboarding)
        SleepProblemsStepView(
            selectedProblems: .constant([.frequentNightWaking]),
            onNext: {}
        )
    }
}
