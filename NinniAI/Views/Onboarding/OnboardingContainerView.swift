import SwiftUI
import SwiftData

// MARK: - Onboarding Container View
/// Ajan (Agentic) Onboarding akışının ana kapsayıcısı.
/// PRD §3.1: "Kullanıcıdan bebeğin adı, doğum tarihi ve temel uyku problemleri alınır."
///
/// 4 adımlı adım-adım (step-by-step) akış:
/// 1. Karşılama → 2. Bebek Bilgileri → 3. Uyku Problemleri → 4. Analiz İllüzyonu
struct OnboardingContainerView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    /// Mevcut adım (0-3)
    @State private var currentStep: Int = 0
    
    /// Toplanan veriler
    @State private var babyName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(
        byAdding: .month, value: -3, to: .now
    ) ?? .now
    @State private var selectedProblems: [SleepProblem] = []
    
    /// Geçiş animasyonu
    @State private var isTransitioning: Bool = false
    
    /// Onboarding tamamlandığında çağrılır
    let onComplete: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GradientBackground(.onboarding)
            
            VStack(spacing: 0) {
                // İlerleme göstergesi (ilk adımda gizli)
                if currentStep > 0 && currentStep < 3 {
                    progressIndicator
                        .padding(.top, AppTheme.spacingMD)
                        .transition(.opacity)
                }
                
                // Adım içeriği
                TabView(selection: $currentStep) {
                    WelcomeStepView(onNext: nextStep)
                        .tag(0)
                    
                    BabyInfoStepView(
                        babyName: $babyName,
                        dateOfBirth: $dateOfBirth,
                        onNext: nextStep
                    )
                    .tag(1)
                    
                    SleepProblemsStepView(
                        selectedProblems: $selectedProblems,
                        onNext: nextStep
                    )
                    .tag(2)
                    
                    AnalysisAnimationView(
                        babyName: babyName,
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(AppTheme.animationSlow, value: currentStep)
                .interactiveDismissDisabled()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: AppTheme.spacingSM) {
            ForEach(1..<4, id: \.self) { step in
                Capsule()
                    .fill(
                        step <= currentStep
                        ? AppTheme.accentPrimary
                        : Color.white.opacity(0.15)
                    )
                    .frame(
                        width: step == currentStep ? 32 : 16,
                        height: 4
                    )
                    .animation(AppTheme.animationDefault, value: currentStep)
            }
        }
        .padding(.horizontal, AppTheme.spacingXL)
    }
    
    // MARK: - Navigation
    
    private func nextStep() {
        guard currentStep < 3 else { return }
        withAnimation(AppTheme.animationSlow) {
            currentStep += 1
        }
    }
    
    // MARK: - Complete Onboarding
    
    private func completeOnboarding() {
        // Baby profili oluştur
        let baby = Baby(
            name: babyName.trimmingCharacters(in: .whitespacesAndNewlines),
            dateOfBirth: dateOfBirth,
            sleepProblems: selectedProblems
        )
        modelContext.insert(baby)
        
        // UserSettings oluştur
        let settings = UserSettings(baby: baby)
        settings.isOnboardingCompleted = true
        settings.firstLaunchDate = .now
        modelContext.insert(settings)
        baby.settings = settings
        
        // Context'i yeni bebekle güncelle
        appState.contextEngine.resolve(baby: baby)
        appState.contextEngine.milestoneTracker.checkForNewMilestones(
            baby: baby,
            context: modelContext
        )
        
        // Kaydet
        try? modelContext.save()
        
        // Tamamla
        onComplete()
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
