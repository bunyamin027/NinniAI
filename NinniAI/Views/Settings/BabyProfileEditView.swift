import SwiftUI
import SwiftData

// MARK: - Baby Profile Edit View
struct BabyProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var baby: Baby
    
    @State private var editedName: String = ""
    @State private var editedDOB: Date = .now
    @State private var editedProblems: [SleepProblem] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(spacing: AppTheme.spacingLG) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("Bebeğin Adı").font(.caption).foregroundStyle(AppTheme.textTertiary)
                                TextField("Ad", text: $editedName)
                                    .font(.title3).fontWeight(.medium)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .textInputAutocapitalization(.words)
                            }
                        }
                        GlassCard {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("Doğum Tarihi").font(.caption).foregroundStyle(AppTheme.textTertiary)
                                DatePicker("", selection: $editedDOB, in: ...Date.now, displayedComponents: .date)
                                    .datePickerStyle(.compact).labelsHidden()
                                    .tint(AppTheme.accentPrimary)
                                    .environment(\.locale, Locale(identifier: "tr_TR"))
                                Text("📅 \(Date.now.babyAgeString(from: editedDOB))")
                                    .font(.caption).foregroundStyle(AppTheme.accentPrimary)
                            }
                        }
                    }
                    .padding(AppTheme.spacingMD)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }.foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        baby.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        baby.dateOfBirth = editedDOB
                        baby.sleepProblems = editedProblems
                        baby.updatedAt = .now
                        dismiss()
                    }
                    .fontWeight(.semibold).foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
        .onAppear {
            editedName = baby.name
            editedDOB = baby.dateOfBirth
            editedProblems = baby.sleepProblems
        }
    }
}
