import SwiftUI
import SwiftData
import StoreKit

// MARK: - Paywall View
/// Premium Paywall ekranı — "Kişisel Uyku Koçu" vizyonu.
/// Apple Guideline 3.1.2 uyumlu: Abonelik şartları açıkça belirtilir.
/// Kartlar doğrudan satın alma tetikler — ayrı CTA butonu yok.
struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Query private var allSettings: [UserSettings]
    @State private var storeKit = StoreKitManager()
    @State private var isPurchasing = false
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var products: [Product] = []
    
    // Animasyon
    @State private var crownFloat = false
    @State private var glowPulse = false
    
    private var babyName: String {
        allSettings.first?.baby?.name ?? "Bebeğiniz"
    }
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            // Gece mavisi / lavanta degradeli arka plan
            paywallBackground
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: isIPad ? 16 : 24) {
                    // Kapat butonu
                    closeButton
                    
                    // Hero — duygusal koç başlığı
                    heroSection
                    
                    // Özellikler
                    featuresSection
                    
                    // Direct Purchase kartları
                    planCards
                    
                    // Geri yükleme
                    Button("Satın Alımları Geçmişe Dönük Yükle") {
                        Task { await storeKit.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
                    
                    // Yasal metin & linkler (Apple 3.1.2)
                    legalDisclosure
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                crownFloat = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .task {
            do {
                let ids = PremiumPlan.allCases.map(\.productIdentifier)
                products = try await Product.products(for: Set(ids))
            } catch {
                print("🔴 Ürünler yüklenemedi: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Paywall Background
    
    private var paywallBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "080C18"),
                    Color(hex: "15103A"),
                    Color(hex: "1A0E3E"),
                    Color(hex: "0D0B20")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Üst lavanta glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "A78BFA").opacity(glowPulse ? 0.18 : 0.10),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(y: -180)
                .blur(radius: 30)
            
            // Alt amber glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FBBF24").opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .frame(width: 300, height: 300)
                .offset(y: 340)
                .blur(radius: 40)
        }
    }
    
    // MARK: - Close Button
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
                    .environment(\.colorScheme, .dark)
            }
        }
        .padding(.top, 8)
        .padding(.trailing, 4)
    }
    
    // MARK: - Hero (Koç Odaklı)
    
    private var heroSection: some View {
        VStack(spacing: isIPad ? 8 : 14) {
            // Kavisli Metin ve Simge Kompozisyonu
            ZStack {
                // Neon glow arka planı
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "A78BFA").opacity(glowPulse ? 0.35 : 0.20),
                                Color(hex: "7C3AED").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 75
                        )
                    )
                    .frame(width: isIPad ? 100 : 150, height: isIPad ? 100 : 150)
                    .blur(radius: 10)
                
                // Cam benzeri (glassmorphism) rozet çemberi
                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: isIPad ? 80 : 110, height: isIPad ? 80 : 110)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.05),
                                        Color(hex: "A78BFA").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "7C3AED").opacity(0.25), radius: 10, x: 0, y: 8)
                
                // Simge Kompozisyonu: Hilal Ay, Taç ve Parıltılar
                ZStack {
                    // Hilal Ay
                    Image(systemName: "moon.fill")
                        .font(.system(size: isIPad ? 24 : 34))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FCD34D"), Color(hex: "FBBF24")],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .offset(x: isIPad ? -6 : -8, y: isIPad ? -4 : -6)
                        .rotationEffect(.degrees(-15))
                    
                    // Taç
                    Image(systemName: "crown.fill")
                        .font(.system(size: isIPad ? 18 : 26))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FBBF24"), Color(hex: "F59E0B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "FBBF24").opacity(0.4), radius: 6)
                        .offset(x: isIPad ? 8 : 10, y: isIPad ? 8 : 12)
                        .offset(y: crownFloat ? -3 : 3)
                    
                    // Parıltılar / Yıldızlar
                    Image(systemName: "sparkles")
                        .font(.system(size: isIPad ? 12 : 18))
                        .foregroundStyle(Color(hex: "A78BFA"))
                        .offset(x: isIPad ? -18 : -24, y: isIPad ? 16 : 22)
                        .opacity(glowPulse ? 0.9 : 0.5)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: isIPad ? 8 : 12))
                        .foregroundStyle(Color(hex: "FBBF24"))
                        .offset(x: isIPad ? 20 : 28, y: isIPad ? -14 : -20)
                        .opacity(glowPulse ? 0.9 : 0.4)
                }
                
                // Kavisli Metin "NİNNİ AI PRO"
                CurvedTextView(text: "NİNNİ AI PRO", radius: isIPad ? 52 : 72)
                    .offset(y: 4)
            }
            .frame(width: isIPad ? 120 : 170, height: isIPad ? 120 : 170)
            
            // Duygusal koç başlığı — bebek adıyla
            Text("\(babyName) için Uyku Koçu")
                .font(.system(size: isIPad ? 22 : 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .minimumScaleFactor(0.7)
            
            Text("Profesyonel Uyku Danışmanı.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
    }
    
    // MARK: - Features (Value Proposition)
    
    private var featuresSection: some View {
        VStack(spacing: 0) {
            if isIPad {
                // 2x2 grid
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        featureRow(
                            icon: "clock.badge.checkmark.fill",
                            iconColor: Color(hex: "A78BFA"),
                            text: "Ay ve gelişime göre otonom uyku pencereleri"
                        )
                        .frame(maxWidth: .infinity)
                        
                        featureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: Color(hex: "60A5FA"),
                            text: "Günlük uyku trendleri ve derin analizler"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                    featureDivider
                    
                    HStack(spacing: 0) {
                        featureRow(
                            icon: "moon.stars.fill",
                            iconColor: Color(hex: "C4B5FD"),
                            text: "Kilit ekranından anlık uyku takibi"
                        )
                        .frame(maxWidth: .infinity)
                        
                        featureRow(
                            icon: "sparkles",
                            iconColor: Color(hex: "FCD34D"),
                            text: "Kesintisiz, reklamsız ve dingin deneyim"
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // 1x4 list
                VStack(spacing: 0) {
                    featureRow(
                        icon: "clock.badge.checkmark.fill",
                        iconColor: Color(hex: "A78BFA"),
                        text: "Ay ve gelişime göre otonom uyku pencereleri"
                    )
                    featureDivider
                    featureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: Color(hex: "60A5FA"),
                        text: "Günlük uyku trendleri ve derin analizler"
                    )
                    featureDivider
                    featureRow(
                        icon: "moon.stars.fill",
                        iconColor: Color(hex: "C4B5FD"),
                        text: "Kilit ekranından anlık uyku takibi"
                    )
                    featureDivider
                    featureRow(
                        icon: "sparkles",
                        iconColor: Color(hex: "FCD34D"),
                        text: "Kesintisiz, reklamsız ve dingin deneyim"
                    )
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func featureRow(icon: String, iconColor: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                )
            
            Text(text)
                .font(.system(size: isIPad ? 11 : 13))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.success)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isIPad ? 8 : 12)
    }
    
    private var featureDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.06))
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
    
    // MARK: - Direct Purchase Cards
    
    private var planCards: some View {
        let yearlyProduct = products.first(where: { $0.id == PremiumPlan.yearly.productIdentifier })
        let monthlyProduct = products.first(where: { $0.id == PremiumPlan.monthly.productIdentifier })
        
        return HStack(spacing: 12) {
            // ── Yıllık — AVANTAJLI (parlayan kart) ──
            purchaseCard(
                plan: .yearly,
                label: "Yıllık",
                price: yearlyProduct?.displayPrice ?? "–",
                period: "/yıl",
                detail: yearlyMonthlyDetail(for: yearlyProduct),
                badge: "%40 TASARRUF",
                isSelected: selectedPlan == .yearly
            )
            
            // ── Aylık — sade kart ──
            purchaseCard(
                plan: .monthly,
                label: "Aylık",
                price: monthlyProduct?.displayPrice ?? "–",
                period: "/ay",
                detail: "Her ay yenilenir",
                badge: nil,
                isSelected: selectedPlan == .monthly
            )
        }
    }
    
    // MARK: - Yearly Per-Month Calculation
    
    /// Yıllık fiyatı 12'ye bölerek kullanıcının yerel para birimi formatında aylık maliyeti hesaplar.
    private func yearlyMonthlyDetail(for product: Product?) -> String {
        guard let product else { return "–" }
        let monthlyPrice = product.price / 12
        // Ürünün kendi locale ve para birimini kullanarak formatla
        let formatted = monthlyPrice.formatted(
            .currency(code: product.priceFormatStyle.currencyCode)
        )
        return "Aylık sadece \(formatted)"
    }
    
    private func purchaseCard(
        plan: PremiumPlan,
        label: String,
        price: String,
        period: String,
        detail: String,
        badge: String?,
        isSelected: Bool
    ) -> some View {
        Button {
            triggerPurchase(plan: plan)
        } label: {
            VStack(spacing: isIPad ? 8 : 12) {
                // Badge
                if let badge {
                    Text(badge)
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color(hex: "A78BFA"), Color(hex: "7C3AED")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                } else {
                    Spacer().frame(height: isIPad ? 14 : 22)
                }
                
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                
                // Fiyat
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.system(size: isIPad ? 18 : 20, weight: .bold))
                        .foregroundStyle(isSelected ? AppTheme.accentPrimary : .white.opacity(0.8))
                    
                    Text(period)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Text(detail)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(
                        isSelected
                        ? AppTheme.success.opacity(0.85)
                        : .white.opacity(0.35)
                    )
                
                // Kart içi CTA
                Text(isSelected ? "Hemen Başla" : "Seç")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isIPad ? 8 : 10)
                    .background(
                        Capsule().fill(
                            isSelected
                            ? LinearGradient(
                                colors: [Color(hex: "A78BFA"), Color(hex: "7C3AED")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [.white.opacity(0.12), .white.opacity(0.06)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .padding(.top, 2)
            }
            .padding(.vertical, isIPad ? 14 : 20)
            .padding(.horizontal, isIPad ? 10 : 14)
            .contentShape(Rectangle()) // Tıklama alanını tüm karta yayar
        }
        .buttonStyle(PaywallCardButtonStyle(isSelected: isSelected))
        .disabled(isPurchasing)
        .sensoryFeedback(.impact(weight: .medium), trigger: isPurchasing)
    }
    
    // MARK: - Purchase Trigger
    
    private func triggerPurchase(plan: PremiumPlan) {
        selectedPlan = plan
        print("🟢 ÖDEME TETİKLENDİ: \(plan)")
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            do {
                let productId = plan.productIdentifier
                if let product = products.first(where: { $0.id == productId }) {
                    // StoreKit 2 yerel satın alma mekanizması doğrudan tetiklenir
                    let result = try await product.purchase()
                    
                    switch result {
                    case .success(let verification):
                        if case .verified(let transaction) = verification {
                            await transaction.finish()
                            await storeKit.updateSubscriptionStatus()
                        }
                    default:
                        break
                    }
                } else {
                    print("🔴 Ürün bulunamadı: \(productId)")
                }
            } catch {
                print("🔴 STOREKIT HATASI: \(error)")
            }
        }
    }
    
    // MARK: - Legal Disclosure (Apple 3.1.2)
    
    private var legalDisclosure: some View {
        VStack(spacing: 12) {
            Text("Abonelik, seçilen plana göre otomatik olarak yenilenir. İstediğiniz zaman Ayarlar > Apple Kimliği > Abonelikler üzerinden iptal edebilirsiniz. İptal, mevcut dönemin sonunda geçerli olur.")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.28))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 10) {
                ParentalGateButton(destination: URL(string: "https://bunyamin027.github.io/Legal/#privacy")!) {
                    Text("Gizlilik Politikası")
                }
                
                Text("•")
                    .foregroundStyle(.white.opacity(0.2))
                
                ParentalGateButton(destination: URL(string: "https://bunyamin027.github.io/Legal/#terms")!) {
                    Text("Kullanım Şartları")
                }
                
                Text("•")
                    .foregroundStyle(.white.opacity(0.2))
                
                ParentalGateButton(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("EULA")
                }
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white.opacity(0.4))
            
            // Mikro İmza
            VStack(spacing: 2) {
                Text("Geliştirici: Kahramandev")
                ParentalGateButton(destination: URL(string: "mailto:bunyaminkahraman027@icloud.com")!) {
                    Text("Destek: bunyaminkahraman027@icloud.com")
                }
            }
            .font(.system(size: 10))
            .foregroundStyle(.white.opacity(0.25))
            .multilineTextAlignment(.center)
            .padding(.top, 4)
        }
        .padding(.horizontal, AppTheme.spacingSM)
    }
}

// MARK: - Curved Text Component
struct CurvedTextView: View {
    let text: String
    let radius: Double
    
    var body: some View {
        ZStack {
            ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                CharacterView(letter: letter, index: index, totalCount: text.count, radius: radius)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

struct CharacterView: View {
    let letter: Character
    let index: Int
    let totalCount: Int
    let radius: Double
    
    var body: some View {
        // Upward-curving yay: Üst tarafa ortalanmış (-90 derecenin etrafında)
        // Karakter sayısına göre yay açıklığı (span) hesaplanır.
        let angleSpan = 140.0 // Karakterlerin yayılacağı toplam açı derecesi
        let startAngle = -90.0 - (angleSpan / 2.0)
        let angle = startAngle + (Double(index) * (angleSpan / Double(max(1, totalCount - 1))))
        
        Text(String(letter))
            .font(.system(size: radius < 60 ? 10 : 13, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: Color(hex: "A78BFA").opacity(0.8), radius: 3)
            .offset(y: -radius)
            .rotationEffect(Angle(degrees: angle))
    }
}

// MARK: - Paywall Card Button Style
struct PaywallCardButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected
                        ? LinearGradient(
                            colors: [
                                AppTheme.accentPrimary.opacity(0.7),
                                AppTheme.accentPrimary.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.white.opacity(0.1), .white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.accentPrimary.opacity(0.2) : .clear,
                radius: 20, x: 0, y: 10
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PaywallView()
        .modelContainer(PreviewSampleData.container)
}
