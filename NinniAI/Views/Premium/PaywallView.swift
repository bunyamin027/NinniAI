import SwiftUI
import StoreKit

// MARK: - Paywall View
/// Premium Paywall ekranı.
/// PRD §5: "Zarif bir Premium ekranıyla karşılaşmalıdır."
/// Apple Guideline 3.1.2 uyumlu: Abonelik şartları açıkça belirtilir.
struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var storeKit = StoreKitManager()
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var isPurchasing = false
    
    var body: some View {
        ZStack {
            GradientBackground(.onboarding)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingLG) {
                    // Kapat butonu
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingSM)
                    
                    // Hero bölümü
                    heroSection
                    
                    // Özellik listesi
                    featuresSection
                    
                    // Plan seçimi
                    planSelectionSection
                    
                    // CTA butonu
                    ctaButton
                    
                    // Geri yükleme
                    Button("Satın Alımları Geri Yükle") {
                        Task { await storeKit.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                    
                    // Yasal metin (Apple 3.1.2)
                    legalDisclosure
                    
                    Spacer(minLength: AppTheme.spacingXL)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.accentPrimary.opacity(0.2), .clear],
                            center: .center, startRadius: 20, endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.warning, Color(hex: "F59E0B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("NinniAI Pro")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Bebeğinizin uyku deneyimini\nbir üst seviyeye taşıyın")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        VStack(spacing: AppTheme.spacingSM) {
            featureRow(icon: "music.note.list", text: "100+ premium ses ve ninni")
            featureRow(icon: "slider.horizontal.3", text: "Sınırsız ses karıştırma")
            featureRow(icon: "chart.xyaxis.line", text: "Gelişmiş uyku analitiği ve grafikler")
            featureRow(icon: "heart.fill", text: "Sınırsız favori rutin")
            featureRow(icon: "brain.head.profile", text: "Akıllı öneriler ve otonom rutinler")
            featureRow(icon: "applewatch", text: "Apple Watch desteği")
        }
        .padding(.horizontal, AppTheme.spacingSM)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(AppTheme.success)
            
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Plan Selection
    
    private var planSelectionSection: some View {
        VStack(spacing: AppTheme.spacingSM) {
            planCard(
                plan: .yearly,
                price: storeKit.yearlyProduct?.displayPrice ?? "₺499,99/yıl",
                subtitle: "En Popüler • Aylık ₺41,67",
                badge: "TASARRUF"
            )
            
            planCard(
                plan: .monthly,
                price: storeKit.monthlyProduct?.displayPrice ?? "₺69,99/ay",
                subtitle: "Her ay yenilenir",
                badge: nil
            )
            
            planCard(
                plan: .lifetime,
                price: storeKit.lifetimeProduct?.displayPrice ?? "₺999,99",
                subtitle: "Tek seferlik ödeme • Sonsuza kadar",
                badge: "ÖMÜR BOYU"
            )
        }
    }
    
    private func planCard(
        plan: PremiumPlan,
        price: String,
        subtitle: String,
        badge: String?
    ) -> some View {
        Button {
            withAnimation(AppTheme.animationDefault) {
                selectedPlan = plan
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Text(plan.displayTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.accentPrimary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                
                Spacer()
                
                Text(price)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        selectedPlan == plan ? AppTheme.accentPrimary : AppTheme.textSecondary
                    )
            }
            .padding(AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                            .stroke(
                                selectedPlan == plan
                                ? AppTheme.accentPrimary
                                : Color.white.opacity(0.08),
                                lineWidth: selectedPlan == plan ? 2 : 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedPlan)
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button {
            Task {
                isPurchasing = true
                let product: Product? = {
                    switch selectedPlan {
                    case .monthly:  return storeKit.monthlyProduct
                    case .yearly:   return storeKit.yearlyProduct
                    case .lifetime: return storeKit.lifetimeProduct
                    }
                }()
                if let product {
                    _ = await storeKit.purchase(product)
                }
                isPurchasing = false
            }
        } label: {
            HStack(spacing: AppTheme.spacingSM) {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Premium'a Geç")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.playerGradient)
            .clipShape(Capsule())
            .shadow(color: AppTheme.shadowColorPrimary, radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
        .padding(.top, AppTheme.spacingSM)
    }
    
    // MARK: - Legal Disclosure (Apple 3.1.2)
    
    private var legalDisclosure: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text("Abonelik, seçilen plana göre otomatik olarak yenilenir. İstediğiniz zaman Ayarlar > Apple Kimliği > Abonelikler üzerinden iptal edebilirsiniz. İptal, mevcut dönemin sonunda geçerli olur.")
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: AppTheme.spacingMD) {
                Link("Gizlilik Politikası", destination: AppConstants.privacyPolicyURL)
                Text("•").foregroundStyle(AppTheme.textTertiary)
                Link("Kullanım Şartları", destination: AppConstants.termsOfServiceURL)
            }
            .font(.system(size: 10))
            .foregroundStyle(AppTheme.accentPrimary.opacity(0.7))
        }
        .padding(.horizontal, AppTheme.spacingMD)
    }
}

#Preview {
    PaywallView()
}
