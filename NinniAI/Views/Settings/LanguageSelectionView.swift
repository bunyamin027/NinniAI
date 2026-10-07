import SwiftUI

// MARK: - Language Selection View
/// Kullanıcının uygulama dilini seçtiği modern glassmorphism modal ekranı.
struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var languageManager = LanguageManager.shared
    
    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacingLG) {
                // Sürükleme Çubuğu ve Başlık
                headerView
                
                // Dil Seçenekleri Listesi
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        languageOptionRow(lang)
                    }
                }
                .padding(.horizontal, AppTheme.spacingMD)
                
                Spacer()
            }
            .padding(.top, AppTheme.spacingMD)
        }
        .presentationDetents([.fraction(0.48), .medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Dil Seçimi".localized)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.top, 8)
            
            Text("Uygulama için tercih ettiğiniz dili seçin".localized)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.spacingLG)
        }
    }
    
    // MARK: - Option Row
    
    private func languageOptionRow(_ language: AppLanguage) -> some View {
        let isSelected = languageManager.currentLanguage == language
        
        return Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(AppTheme.animationFast) {
                languageManager.setLanguage(language)
            }
            // Kısa bir gecikmeyle kapat (kullanıcı seçim animasyonunu görsün)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                dismiss()
            }
        } label: {
            HStack(spacing: 14) {
                Text(language.flag)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text(language.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accentPrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                    .fill(isSelected ? AppTheme.accentPrimary.opacity(0.15) : .white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                    .stroke(
                        isSelected ? AppTheme.accentPrimary.opacity(0.8) : .white.opacity(0.1),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: isSelected ? AppTheme.accentPrimary.opacity(0.2) : .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguageSelectionView()
}
