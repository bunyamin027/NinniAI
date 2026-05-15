import SwiftUI

// MARK: - Milestone Card View
/// Kilometre taşı kutlama kartı.
/// PRD §3.2: "Bebeğin her yeni ayına geçişte özel karşılama ekranları."
/// PRD: "Cam efektli Kilometre Taşı başarı kartları"
///
/// Dashboard üzerinde overlay olarak gösterilir.
/// Kullanıcı kapatana kadar ekranda kalır, Instagram'da paylaşılabilir.
struct MilestoneCardView: View {
    
    let milestone: Milestone
    let onDismiss: () -> Void
    
    @State private var isAppeared = false
    @State private var confettiPhase = false
    
    var body: some View {
        ZStack {
            // Yarı saydam arka plan
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            // Kart
            VStack(spacing: AppTheme.spacingLG) {
                // Konfeti efekti
                ZStack {
                    ForEach(0..<12, id: \.self) { i in
                        ConfettiPiece(
                            index: i,
                            isActive: confettiPhase
                        )
                    }
                    
                    // Milestone ikonu
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.accentPrimary.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        Image(systemName: milestone.type.iconName)
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(height: 180)
                
                // Başlık
                Text(milestone.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Açıklama
                Text(milestone.milestoneDescription)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, AppTheme.spacingSM)
                
                Spacer().frame(height: AppTheme.spacingSM)
                
                // Butonlar
                VStack(spacing: AppTheme.spacingSM) {
                    // Paylaş butonu (Instagram Stories)
                    Button {
                        // TODO: Faz 4'te Instagram Stories paylaşımı
                        onDismiss()
                    } label: {
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Hikayede Paylaş")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.playerGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Kapat
                    Button(action: onDismiss) {
                        Text("Devam Et")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
            }
            .padding(AppTheme.spacingLG)
            .padding(.vertical, AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppTheme.accentPrimary.opacity(0.3),
                                        Color.white.opacity(0.1),
                                        AppTheme.accentSecondary.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: AppTheme.shadowColorPrimary.opacity(0.5), radius: 30, y: 10)
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .scaleEffect(isAppeared ? 1 : 0.8)
            .opacity(isAppeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAppeared = true
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                confettiPhase = true
            }
        }
    }
}

// MARK: - Confetti Piece
private struct ConfettiPiece: View {
    let index: Int
    let isActive: Bool
    
    private var angle: Double { Double(index) * (360.0 / 12.0) }
    private var color: Color {
        [AppTheme.accentPrimary, AppTheme.accentSecondary, AppTheme.success, AppTheme.warning][index % 4]
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 6, height: 12)
            .rotationEffect(.degrees(Double(index) * 30))
            .offset(
                x: isActive ? cos(angle * .pi / 180) * 100 : 0,
                y: isActive ? sin(angle * .pi / 180) * 100 : 0
            )
            .opacity(isActive ? 0 : 1)
            .scaleEffect(isActive ? 0.3 : 1)
    }
}

#Preview {
    MilestoneCardView(
        milestone: {
            let m = Milestone(
                type: .monthTransition,
                monthNumber: 6,
                title: "6. Ay Kutlu Olsun! 🎉",
                description: "Elif artık 6 aylık! Uyku düzeni giderek oturuyor."
            )
            return m
        }(),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
