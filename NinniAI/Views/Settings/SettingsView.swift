import SwiftUI
import SwiftData

// MARK: - Settings View
/// Uygulama ayarları ekranı.
/// Apple Guideline uyumlu: Abonelik yönetimi, yasal metinler ve hesap silme.
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    
    @State private var showPaywall = false
    @State private var showBabyEdit = false
    @State private var showLegal = false
    @State private var showDeleteConfirm = false
    @State private var notificationManager = NotificationManager()
    
    private var settings: UserSettings? { allSettings.first }
    private var baby: Baby? { settings?.baby }
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.spacingLG) {
                    // Başlık
                    Text("Ayarlar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.spacingSM)
                        .padding(.top, AppTheme.spacingMD)
                    
                    // Premium durum
                    premiumSection
                    
                    // Bebek profili
                    if let baby {
                        babyProfileSection(baby)
                    }
                    
                    // Bildirimler
                    notificationSection
                    
                    // Player ayarları
                    playerSection
                    
                    // Hakkında ve yasal
                    aboutSection
                    
                    // Tehlike bölgesi
                    dangerZone
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showBabyEdit) {
            if let baby {
                BabyProfileEditView(baby: baby)
            }
        }
        .sheet(isPresented: $showLegal) {
            LegalView()
        }
    }
    
    // MARK: - Premium Section
    
    private var premiumSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack {
                    Image(systemName: settings?.isPremiumActive == true ? "crown.fill" : "crown")
                        .font(.title2)
                        .foregroundStyle(AppTheme.warning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(settings?.isPremiumActive == true ? "NinniAI Pro" : "Ücretsiz Plan")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text(settings?.isPremiumActive == true
                             ? "Tüm özellikler aktif"
                             : "Premium'a geçerek tüm özellikleri açın"
                        )
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                
                if settings?.isPremiumActive != true {
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Premium'a Geç")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.playerGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                // Apple subscription management
                Button("Abonelikleri Yönet") {
                    // ManageSubscriptionsSheet açılır
                }
                .font(.caption)
                .foregroundStyle(AppTheme.accentPrimary)
            }
        }
    }
    
    // MARK: - Baby Profile Section
    
    private func babyProfileSection(_ baby: Baby) -> some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(baby.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("\(Date.now.babyAgeString(from: baby.dateOfBirth)) • \(baby.ageGroup.displayTitle)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Button {
                    showBabyEdit = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
    }
    
    // MARK: - Notification Section
    
    private var notificationSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                settingSectionTitle("Bildirimler", icon: "bell.fill")
                
                settingToggle(
                    "Uyku Hatırlatma",
                    isOn: Binding(
                        get: { settings?.isSleepReminderEnabled ?? true },
                        set: { settings?.isSleepReminderEnabled = $0 }
                    )
                )
                
                settingToggle(
                    "Milestone Bildirimleri",
                    isOn: Binding(
                        get: { settings?.isMilestoneNotificationEnabled ?? true },
                        set: { settings?.isMilestoneNotificationEnabled = $0 }
                    )
                )
                
                settingToggle(
                    "Haftalık Rapor",
                    isOn: Binding(
                        get: { settings?.isWeeklyReportEnabled ?? true },
                        set: { settings?.isWeeklyReportEnabled = $0 }
                    )
                )
            }
        }
    }
    
    // MARK: - Player Section
    
    private var playerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                settingSectionTitle("Player", icon: "waveform")
                
                settingToggle(
                    "Arka Planda Çalmaya Devam",
                    isOn: Binding(
                        get: { settings?.continuePlaybackInBackground ?? true },
                        set: { settings?.continuePlaybackInBackground = $0 }
                    )
                )
                
                HStack {
                    Text("Varsayılan Zamanlayıcı")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("\(settings?.defaultTimerDurationMinutes ?? 30) dk")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                HStack {
                    Text("Fade Out Süresi")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("\(settings?.fadeOutDurationSeconds ?? 10) sn")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                settingSectionTitle("Hakkında", icon: "info.circle.fill")
                
                settingLink("Gizlilik Politikası", url: AppConstants.privacyPolicyURL)
                settingLink("Kullanım Şartları", url: AppConstants.termsOfServiceURL)
                settingLink("Destek", url: AppConstants.supportURL)
                
                Button { showLegal = true } label: {
                    HStack {
                        Text("Yasal Bilgiler")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                
                HStack {
                    Text("Sürüm")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("\(AppConstants.appVersion) (\(AppConstants.appBuild))")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Danger Zone
    
    private var dangerZone: some View {
        GlassCard {
            Button {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(AppTheme.error)
                    Text("Tüm Verileri Sil")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.error)
                    Spacer()
                }
            }
            .alert("Tüm Veriler Silinecek", isPresented: $showDeleteConfirm) {
                Button("Sil", role: .destructive) {
                    // TODO: Tüm SwiftData verilerini sil
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Bu işlem geri alınamaz. Tüm bebek profili, uyku verileri ve ayarlar silinecektir.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func settingSectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppTheme.accentPrimary)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
    
    private func settingToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .tint(AppTheme.accentPrimary)
    }
    
    private func settingLink(_ title: String, url: URL) -> some View {
        Link(destination: url) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewSampleData.container)
}
