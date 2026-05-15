import SwiftUI

// MARK: - Quick Action Grid
/// Dashboard hızlı erişim butonları.
/// PRD §4: "Tek elle kontrol, büyük hit alanları"
///
/// Kullanıcının en sık ihtiyaç duyduğu aksiyonlara hızlı erişim:
/// - Favori sesler, Zamanlayıcı, Son oturum, Analiz
struct QuickActionGrid: View {
    
    @Environment(AppState.self) private var appState
    
    private let actions: [QuickAction] = [
        QuickAction(icon: "heart.fill", title: "Favoriler", color: AppTheme.accentSecondary, tab: .player),
        QuickAction(icon: "timer", title: "Zamanlayıcı", color: AppTheme.accentPrimary, tab: .player),
        QuickAction(icon: "chart.line.uptrend.xyaxis", title: "Analizler", color: Color(hex: "34D399"), tab: .analytics),
        QuickAction(icon: "gearshape.fill", title: "Ayarlar", color: Color(hex: "60A5FA"), tab: .settings),
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.spacingSM),
        GridItem(.flexible(), spacing: AppTheme.spacingSM),
        GridItem(.flexible(), spacing: AppTheme.spacingSM),
        GridItem(.flexible(), spacing: AppTheme.spacingSM)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.spacingSM) {
            ForEach(actions) { action in
                quickActionButton(action)
            }
        }
    }
    
    private func quickActionButton(_ action: QuickAction) -> some View {
        Button {
            appState.selectedTab = action.tab
        } label: {
            VStack(spacing: AppTheme.spacingSM) {
                ZStack {
                    Circle()
                        .fill(action.color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(action.color)
                }
                
                Text(action.title)
                    .font(.system(size: 11))
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingSM)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Action Model
private struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let tab: AppTab
}

#Preview {
    ZStack {
        GradientBackground()
        QuickActionGrid()
            .padding()
    }
    .environment(AppState())
}
