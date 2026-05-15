import SwiftUI
import SwiftData

// MARK: - Sound Picker View
/// Ses seçme grid'i — kategoriye göre gruplanmış ses kataloğu.
/// PRD §3.3: Ses karıştırma için çoklu ses seçimi destekler.
struct SoundPickerView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Sound.sortOrder) private var allSounds: [Sound]
    @State private var selectedCategory: SoundCategory = .whiteNoise
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 0) {
                    // Kategori seçici
                    categoryPicker
                    
                    // Ses grid'i
                    soundGrid
                }
            }
            .navigationTitle("Ses Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Category Picker
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingSM) {
                ForEach(SoundCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(AppTheme.animationDefault) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.vertical, AppTheme.spacingSM)
        }
    }
    
    // MARK: - Sound Grid
    
    private var soundGrid: some View {
        let filteredSounds = allSounds.filter { $0.category == selectedCategory }
        
        return ScrollView {
            if filteredSounds.isEmpty {
                emptyCategoryView
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppTheme.spacingSM),
                        GridItem(.flexible(), spacing: AppTheme.spacingSM)
                    ],
                    spacing: AppTheme.spacingSM
                ) {
                    ForEach(filteredSounds, id: \.identifier) { sound in
                        SoundGridItem(
                            sound: sound,
                            isActive: appState.audioEngine.activeLayers[sound.identifier] != nil
                        ) {
                            toggleSound(sound)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.bottom, AppTheme.spacingXXL)
            }
        }
    }
    
    private var emptyCategoryView: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: selectedCategory.iconName)
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textTertiary)
            
            Text("Bu kategoride henüz ses yok")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Actions
    
    private func toggleSound(_ sound: Sound) {
        if appState.audioEngine.activeLayers[sound.identifier] != nil {
            appState.audioEngine.stop(identifier: sound.identifier)
        } else {
            appState.audioEngine.play(sound: sound, volume: sound.defaultVolume)
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: SoundCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingXS) {
                Image(systemName: category.iconName)
                    .font(.caption)
                
                Text(category.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.vertical, AppTheme.spacingSM)
            .background {
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(AppTheme.playerGradient)
                        : AnyShapeStyle(Color.white.opacity(0.08))
                    )
            }
            .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sound Grid Item

private struct SoundGridItem: View {
    let sound: Sound
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingSM) {
                // Kategori ikonu
                ZStack {
                    Circle()
                        .fill(
                            isActive
                            ? AppTheme.accentPrimary.opacity(0.2)
                            : Color.white.opacity(0.05)
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: sound.category.iconName)
                        .font(.title2)
                        .foregroundStyle(
                            isActive ? AppTheme.accentPrimary : AppTheme.textSecondary
                        )
                    
                    // Aktif göstergesi
                    if isActive {
                        Circle()
                            .stroke(AppTheme.accentPrimary, lineWidth: 2)
                            .frame(width: 56, height: 56)
                    }
                }
                
                // Ses adı
                Text(sound.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        isActive ? AppTheme.accentPrimary : AppTheme.textPrimary
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Premium rozet
                if sound.isPremium {
                    HStack(spacing: 2) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.warning)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if isActive {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                .stroke(AppTheme.accentPrimary.opacity(0.5), lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }
}

#Preview {
    SoundPickerView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
