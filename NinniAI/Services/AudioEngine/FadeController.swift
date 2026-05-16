import AVFoundation

// MARK: - Fade Controller
/// Ses seviyesini yumuşak bir şekilde artıran veya azaltan kontrolcü.
/// PRD §3.3: "Fade Out: Süre bittiğinde sesin yavaşça kısılarak kapanması."
///
/// Timer bittiğinde veya kullanıcı durdurduğunda,
/// ses birden kesilmez — easeOut eğrisi ile yumuşakça sıfıra iner.
final class FadeController {
    
    // MARK: - Properties
    
    /// Aktif fade task'ları (node hash → task)
    private var fadeTasks: [Int: Task<Void, Never>] = [:]
    
    /// Fade adım aralığı (saniye) — 60fps hedefi
    private let stepInterval: TimeInterval = 1.0 / 60.0
    
    // MARK: - Fade In
    
    /// Sesi yumuşakça belirtilen seviyeye çıkar
    /// - Parameters:
    ///   - node: Hedef AVAudioPlayerNode
    ///   - targetVolume: Hedef ses seviyesi
    ///   - duration: Fade süresi (saniye)
    ///   - completion: Tamamlanma callback'i
    func fadeIn(
        node: AVAudioPlayerNode,
        to targetVolume: Float,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        cancelFade(for: node)
        
        let nodeHash = ObjectIdentifier(node).hashValue
        let totalSteps = Int(duration / stepInterval)
        
        node.volume = 0
        
        fadeTasks[nodeHash] = Task { @MainActor [weak node] in
            guard let node = node else { return }
            
            for step in 0...totalSteps {
                guard !Task.isCancelled else { return }
                
                // EaseOut eğrisi: hızlı başla, yavaş bitir
                let progress = Float(step) / Float(totalSteps)
                let easedProgress = easeOutCubic(progress)
                node.volume = targetVolume * easedProgress
                
                try? await Task.sleep(for: .seconds(self.stepInterval))
            }
            
            node.volume = targetVolume
            completion?()
        }
    }
    
    // MARK: - Fade Out
    
    /// Sesi yumuşakça sıfıra indir
    /// - Parameters:
    ///   - node: Hedef AVAudioPlayerNode
    ///   - duration: Fade süresi (saniye)
    ///   - completion: Sıfıra ulaştığında çağrılacak callback
    func fadeOut(
        node: AVAudioPlayerNode,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        cancelFade(for: node)
        
        let nodeHash = ObjectIdentifier(node).hashValue
        let startVolume = node.volume
        let totalSteps = Int(duration / stepInterval)
        
        fadeTasks[nodeHash] = Task { @MainActor [weak node] in
            guard let node = node else { return }
            
            for step in 0...totalSteps {
                guard !Task.isCancelled else { return }
                
                // EaseIn eğrisi: yavaş başla, hızlı bitir (doğal hissettiren kapanış)
                let progress = Float(step) / Float(totalSteps)
                let easedProgress = easeInCubic(progress)
                node.volume = startVolume * (1.0 - easedProgress)
                
                try? await Task.sleep(for: .seconds(self.stepInterval))
            }
            
            node.volume = 0
            completion?()
        }
    }
    
    // MARK: - Cross Fade
    
    /// Bir sesten diğerine yumuşak geçiş
    func crossFade(
        from fadeOutNode: AVAudioPlayerNode,
        to fadeInNode: AVAudioPlayerNode,
        targetVolume: Float,
        duration: TimeInterval
    ) {
        fadeOut(node: fadeOutNode, duration: duration)
        fadeIn(node: fadeInNode, to: targetVolume, duration: duration)
    }
    
    // MARK: - Cancel
    
    /// Belirli bir node için aktif fade'i iptal et
    func cancelFade(for node: AVAudioPlayerNode) {
        let nodeHash = ObjectIdentifier(node).hashValue
        fadeTasks[nodeHash]?.cancel()
        fadeTasks.removeValue(forKey: nodeHash)
    }
    
    /// Tüm fade'leri iptal et
    func cancelAll() {
        for (_, task) in fadeTasks {
            task.cancel()
        }
        fadeTasks.removeAll()
    }
    
    // MARK: - Easing Functions
    
    /// Cubic ease-out: t → 1 - (1 - t)³
    private func easeOutCubic(_ t: Float) -> Float {
        let inv = 1.0 - t
        return 1.0 - (inv * inv * inv)
    }
    
    /// Cubic ease-in: t → t³
    private func easeInCubic(_ t: Float) -> Float {
        return t * t * t
    }
}
