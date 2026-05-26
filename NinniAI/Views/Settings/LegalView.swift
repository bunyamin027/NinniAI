import SwiftUI

// MARK: - Legal View
/// Yasal bilgiler ekranı — Gizlilik, Şartlar, Lisanslar
struct LegalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        legalSection("Gizlilik Politikası", text: """
                        NinniAI, kullanıcı verilerinin gizliliğini en üst düzeyde korur. \
                        Tüm veriler yalnızca cihazınızda saklanır ve hiçbir üçüncü tarafla paylaşılmaz. \
                        Uygulama internet bağlantısı gerektirmez ve çevrimdışı çalışır.
                        """)
                        
                        legalSection("Kullanım Şartları", text: """
                        NinniAI'ı kullanarak bu koşulları kabul etmiş olursunuz. \
                        Uygulama yalnızca bilgilendirme amaçlıdır ve tıbbi tavsiye yerine geçmez. \
                        Bebeğinizin uyku sorunları için lütfen bir pediatrist ile görüşün.
                        """)
                        
                        legalSection("Abonelik Bilgileri", text: """
                        • Ödeme Apple ID hesabınız üzerinden işlenir.\n\
                        • Abonelik, dönem sona ermeden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir.\n\
                        • Ayarlar > Apple Kimliği > Abonelikler üzerinden yönetebilirsiniz.\n\
                        • Ücretsiz deneme süresi içinde iptal ederseniz ücret tahsil edilmez.
                        """)
                        
                        legalSection("Açık Kaynak Lisansları", text: """
                        NinniAI, SwiftUI ve AVFoundation framework'leri üzerine \
                        inşa edilmiştir. Üçüncü parti bağımlılık kullanılmamaktadır.
                        """)
                        
                        legalSection("Geliştirici & Destek Bilgileri", text: """
                        • Geliştirici: Kahramandev\n\
                        • İletişim & Destek: bunyaminkahraman027@icloud.com\n\
                        • Web Sitesi: bunyamin027.github.io/Legal
                        """)
                    }
                    .padding(AppTheme.spacingMD)
                }
            }
            .navigationTitle("Yasal Bilgiler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
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
