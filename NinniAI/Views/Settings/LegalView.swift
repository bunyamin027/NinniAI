import SwiftUI

// MARK: - Legal View
/// Yasal bilgiler ekranı — Gizlilik, Şartlar, Lisanslar
struct LegalView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var isEn: Bool {
        LanguageManager.shared.activeLanguageCode == "en"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        legalSection("Gizlilik Politikası".localized, text: isEn ? """
                        NinniAI protects user data privacy to the highest standard. \
                        All data is stored exclusively on your device and is never shared with third parties. \
                        The app does not require an internet connection and operates offline.
                        """ : """
                        NinniAI, kullanıcı verilerinin gizliliğini en üst düzeyde korur. \
                        Tüm veriler yalnızca cihazınızda saklanır ve hiçbir üçüncü tarafla paylaşılmaz. \
                        Uygulama internet bağlantısı gerektirmez ve çevrimdışı çalışır.
                        """)
                        
                        legalSection("Kullanım Şartları".localized, text: isEn ? """
                        By using NinniAI, you agree to these terms. \
                        The application is for informational purposes only and does not constitute medical advice. \
                        Please consult a pediatrician for any persistent sleep difficulties.
                        """ : """
                        NinniAI'ı kullanarak bu koşulları kabul etmiş olursunuz. \
                        Uygulama yalnızca bilgilendirme amaçlıdır ve tıbbi tavsiye yerine geçmez. \
                        Bebeğinizin uyku sorunları için lütfen bir pediatrist ile görüşün.
                        """)
                        
                        legalSection("Abonelik Bilgileri".localized, text: isEn ? """
                        • Payment is processed via your Apple ID account.\n\
                        • The subscription renews automatically unless cancelled at least 24 hours before the end of the current period.\n\
                        • You can manage your subscription via Settings > Apple ID > Subscriptions.\n\
                        • If you cancel during a trial period, no fee is charged.
                        """ : """
                        • Ödeme Apple ID hesabınız üzerinden işlenir.\n\
                        • Abonelik, dönem sona ermeden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir.\n\
                        • Ayarlar > Apple Kimliği > Abonelikler üzerinden yönetebilirsiniz.\n\
                        • Ücretsiz deneme süresi içinde iptal ederseniz ücret tahsil edilmez.
                        """)
                        
                        legalSection("Açık Kaynak Lisansları".localized, text: isEn ? """
                        NinniAI is built natively with SwiftUI and AVFoundation frameworks. \
                        No third-party proprietary tracking or external dependencies are used.
                        """ : """
                        NinniAI, SwiftUI ve AVFoundation framework'leri üzerine \
                        inşa edilmiştir. Üçüncü parti bağımlılık kullanılmamaktadır.
                        """)
                        
                        legalSection("Geliştirici & Destek Bilgileri".localized, text: isEn ? """
                        • Developer: Kahramandev\n\
                        • Contact & Support: bunyaminkahraman027@icloud.com\n\
                        • Website: bunyamin027.github.io/Legal
                        """ : """
                        • Geliştirici: Kahramandev\n\
                        • İletişim & Destek: bunyaminkahraman027@icloud.com\n\
                        • Web Sitesi: bunyamin027.github.io/Legal
                        """)
                    }
                    .padding(AppTheme.spacingMD)
                }
            }
            .navigationTitle("Yasal Bilgiler".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat".localized) { dismiss() }
                        .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
    
    private func legalSection(_ title: String, text: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text(title)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(text)
                    .font(.caption).foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
    }
}
