import SwiftUI
import SwiftData

// MARK: - Settings View
/// Uygulama ayarları ekranı.
/// Apple Guideline uyumlu: Abonelik yönetimi, yasal metinler ve hesap silme.
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query private var allSettings: [UserSettings]
    
    @State private var showPaywall = false
    @State private var showBabyEdit = false
    @State private var showLegal = false
    @State private var showDeleteConfirm = false
    @State private var showSupport = false
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
                    
                    // Oynatıcı ayarları
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
        .sheet(isPresented: $showSupport) {
            DeveloperSupportView()
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
                
                premiumSettingToggle(
                    "Uyku Hatırlatma",
                    isOn: Binding(
                        get: { settings?.isSleepReminderEnabled ?? true },
                        set: { settings?.isSleepReminderEnabled = $0 }
                    )
                )
                
                premiumSettingToggle(
                    "Milestone Bildirimleri",
                    isOn: Binding(
                        get: { settings?.isMilestoneNotificationEnabled ?? true },
                        set: { settings?.isMilestoneNotificationEnabled = $0 }
                    )
                )
                
                premiumSettingToggle(
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
            }
        }
    }
    
    
    // MARK: - About Section (Antigravity Tasarım)
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            settingSectionTitle("Hakkında", icon: "info.circle.fill")
                .padding(.leading, 4)
            
            VStack(spacing: 10) {
                premiumAboutLinkRow(
                    title: "Gizlilik Politikası",
                    icon: "lock.shield.fill",
                    iconColor: Color(red: 0.7, green: 0.5, blue: 1.0),
                    url: URL(string: "https://bunyamin027.github.io/Legal/#privacy")!
                )
                
                premiumAboutLinkRow(
                    title: "Kullanım Şartları (EULA)",
                    icon: "doc.text.fill",
                    iconColor: Color(red: 0.4, green: 0.8, blue: 1.0),
                    url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
                )
                
                Button {
                    showSupport = true
                } label: {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "envelope.fill")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.4, green: 0.9, blue: 0.7))
                            .frame(width: 28)
                        
                        Text("Destek & Geri Bildirim")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Button {
                    showLegal = true
                } label: {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "building.columns.fill")
                            .font(.headline)
                            .foregroundStyle(Color(red: 1.0, green: 0.7, blue: 0.3))
                            .frame(width: 28)
                        
                        Text("Yasal Bilgiler & Lisanslar")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            
            // Dinamik Sürüm Bilgisi
            HStack {
                Spacer()
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                Text("Sürüm \(version) (Build \(build))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.top, 6)
                Spacer()
            }
        }
    }
    
    private func premiumAboutLinkRow(title: String, icon: String, iconColor: Color, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: AppTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                    .frame(width: 28)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                    .fill(.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
    
    private func premiumSettingToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
            
            Spacer()
            
            if subscriptionManager.isPro {
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(AppTheme.accentPrimary)
            } else {
                Button {
                    subscriptionManager.showPaywall = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                        Text("PRO")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(AppTheme.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.warning.opacity(0.15))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
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

// MARK: - Developer Support View
struct DeveloperSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacingXL) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.top, AppTheme.spacingMD)
                .padding(.trailing, AppTheme.spacingMD)
                
                Spacer()
                
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "laptopcomputer")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.accentPrimary)
                            .padding(.bottom, 8)
                        
                        Text("Destek & Geliştirici")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text("Developer: Kahramandev")
                                .font(.subheadline)
                            Text("Email: bunyaminkahraman027@icloud.com")
                                .font(.subheadline)
                            Text("Website: bunyamin027.github.io/Legal")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingMD)
                }
                .padding(.horizontal, AppTheme.spacingLG)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewSampleData.container)
}
