import SwiftUI

// MARK: - Baby Info Step View
/// Onboarding Adım 2 — Bebek adı ve doğum tarihi girişi.
/// PRD §3.1: "Kullanıcıdan bebeğin adı, doğum tarihi alınır."
///
/// Tek elle kullanım için büyük input alanları ve
/// DatePicker ile kolay tarih seçimi sunar.
struct BabyInfoStepView: View {
    
    @Binding var babyName: String
    @Binding var dateOfBirth: Date
    let onNext: () -> Void
    
    @FocusState private var isNameFocused: Bool
    @State private var isAppeared = false
    
    /// Doğum tarihi aralığı: bugünden 3 yıl öncesine kadar
    private var dateRange: ClosedRange<Date> {
        let threeYearsAgo = Calendar.current.date(
            byAdding: .year, value: -3, to: .now
        ) ?? .now
        return threeYearsAgo...Date.now
    }
    
    /// İsim geçerli mi? (en az 1 karakter)
    private var isValid: Bool {
        !babyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: AppTheme.spacingXXL)
            
            // Başlık
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 52))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .opacity(isAppeared ? 1 : 0)
                    .scaleEffect(isAppeared ? 1 : 0.7)
                
                Text("Bebeğinizi Tanıyalım")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(isAppeared ? 1 : 0)
                
                Text("Kişiselleştirilmiş uyku deneyimi için\nbirkaç bilgiye ihtiyacımız var")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(isAppeared ? 1 : 0)
            }
            
            Spacer()
                .frame(height: AppTheme.spacingXL)
            
            // Form alanları
            VStack(spacing: AppTheme.spacingMD) {
                // Bebek adı
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Bebeğinizin adı")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textSecondary)
                    
                    TextField("", text: $babyName, prompt: Text("Adını yazın...").foregroundStyle(AppTheme.textTertiary))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textPrimary)
                        .focused($isNameFocused)
                        .padding(.horizontal, AppTheme.spacingMD)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                        .stroke(
                                            isNameFocused
                                            ? AppTheme.accentPrimary.opacity(0.6)
                                            : Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)
                
                // Doğum tarihi
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Doğum tarihi")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textSecondary)
                    
                    DatePicker(
                        "",
                        selection: $dateOfBirth,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(AppTheme.accentPrimary)
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            }
                    }
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    // Yaş göstergesi
                    if isValid {
                        let ageText = Date.now.babyAgeString(from: dateOfBirth)
                        Text("📅 \(ageText)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accentPrimary)
                            .transition(.opacity)
                    }
                }
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 25)
            }
            .padding(.horizontal, AppTheme.spacingLG)
            
            Spacer()
            
            // Devam butonu
            Button(action: {
                isNameFocused = false
                onNext()
            }) {
                HStack(spacing: AppTheme.spacingSM) {
                    Text("Devam")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isValid
                    ? AnyShapeStyle(AppTheme.playerGradient)
                    : AnyShapeStyle(Color.white.opacity(0.1))
                )
                .clipShape(Capsule())
                .shadow(
                    color: isValid ? AppTheme.shadowColorPrimary : .clear,
                    radius: 16, y: 8
                )
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
            .padding(.horizontal, AppTheme.spacingLG)
            .opacity(isAppeared ? 1 : 0)
            
            Spacer()
                .frame(height: AppTheme.spacingXXL)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                isAppeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .onTapGesture {
            isNameFocused = false
        }
    }
}

#Preview {
    ZStack {
        GradientBackground(.onboarding)
        BabyInfoStepView(
            babyName: .constant("Elif"),
            dateOfBirth: .constant(.now.monthsAgo(6)),
            onNext: {}
        )
    }
}
