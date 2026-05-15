import SwiftUI

// MARK: - View Extensions
/// Genel View yardımcıları ve custom modifier'lar.
extension View {
    
    /// Antigravity glassmorphism efekti uygular
    func glassEffect(
        cornerRadius: CGFloat = AppTheme.cornerRadiusLG
    ) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
    }
    
    /// Shimmer loading efekti
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
    
    /// Koşullu modifier uygulama
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Shimmer Modifier
/// Yükleme sırasında içerik üzerinde kayan ışık efekti.
/// Onboarding "Analiz İllüzyonu" ve veri yükleme durumlarında kullanılır.
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.12),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: phase * geometry.size.width * 1.6 - geometry.size.width * 0.3)
                    }
                    .mask(content)
                }
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}
