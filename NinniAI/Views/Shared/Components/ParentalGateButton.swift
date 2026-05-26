import SwiftUI

// MARK: - Parental Gate Button
/// Apple Guideline 1.3.0 (Kids Category) uyumlu:
/// Dış bağlantılara çıkış yapılmadan önce bir ebeveyn doğrulaması (basit matematik sorusu) gösterir.
struct ParentalGateButton<Label: View>: View {
    let destination: URL
    let label: Label
    
    @State private var showGate = false
    @Environment(\.openURL) private var openURL
    
    // Matematik sorusu durumu
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var inputAnswer = ""
    @State private var showError = false
    
    init(destination: URL, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        Button {
            generateQuestion()
            showGate = true
        } label: {
            label
        }
        .sheet(isPresented: $showGate) {
            NavigationStack {
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.accentPrimary)
                        .padding(.top, 40)
                        .shadow(color: AppTheme.accentPrimary.opacity(0.3), radius: 10)
                    
                    Text("Ebeveyn Doğrulaması")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("Devam etmek için lütfen aşağıdaki işlemi çözün. Bu alan ebeveynler içindir.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Text("\(num1) + \(num2) = ")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        
                        TextField("Cevap", text: $inputAnswer)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 90)
                            .font(.title.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                    
                    if showError {
                        Text("Hatalı cevap, lütfen tekrar deneyin.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.error)
                            .transition(.opacity)
                    }
                    
                    Button {
                        verifyAndOpen()
                    } label: {
                        Text("Doğrula ve Devam Et")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.playerGradient)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .background(GradientBackground().ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Vazgeç") {
                            showGate = false
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }
    
    private func generateQuestion() {
        num1 = Int.random(in: 10...30)
        num2 = Int.random(in: 10...30)
        inputAnswer = ""
        showError = false
    }
    
    private func verifyAndOpen() {
        if let ans = Int(inputAnswer), ans == (num1 + num2) {
            showGate = false
            openURL(destination)
        } else {
            withAnimation(AppTheme.animationFast) {
                showError = true
            }
        }
    }
}
