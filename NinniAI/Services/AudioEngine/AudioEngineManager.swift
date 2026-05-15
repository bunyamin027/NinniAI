import AVFoundation
import Observation

// MARK: - Audio Engine Manager
/// AVAudioEngine üzerine kurulu merkezi ses yönetim servisi.
/// PRD §3.3: "Ses Karıştırma: Çoklu sesleri aynı anda çalma yeteneği"
///
/// Bu sınıf tüm ses çalma operasyonlarını yönetir:
/// - Tekli veya çoklu ses çalma
/// - Seamless loop (SeamlessLooper ile)
/// - Fade in/out kontrolü (FadeController ile)
/// - Arka planda çalma (Background Audio)
/// - Kilit ekranı kontrolü (NowPlayable)
@Observable
final class AudioEngineManager {
    
    // MARK: - State
    
    /// Şu anda çalan ses katmanları (identifier → layer)
    private(set) var activeLayers: [String: AudioLayer] = [:]
    
    /// Player genel durumu
    private(set) var isPlaying: Bool = false
    
    /// Zamanlayıcı kalan saniye (nil = süresiz)
    private(set) var remainingSeconds: TimeInterval?
    
    /// Genel master ses seviyesi (0.0 - 1.0)
    var masterVolume: Float = 0.7 {
        didSet { updateMasterVolume() }
    }
    
    /// Zamanlayıcı başlangıç süresi (dakika)
    private(set) var timerDurationMinutes: Int = 0
    
    /// Oturum başlangıç zamanı
    private(set) var sessionStartTime: Date?
    
    // MARK: - Private
    
    private let engine = AVAudioEngine()
    private let mainMixerNode: AVAudioMixerNode
    private var loopers: [String: SeamlessLooper] = [:]
    private let fadeController = FadeController()
    private var timerTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init() {
        mainMixerNode = engine.mainMixerNode
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    
    /// iOS Audio Session'ı arka plan çalma için ayarlar
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print("⚠️ AudioSession yapılandırılamadı: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Play Controls
    
    /// Tek bir sesi çalmaya başla
    /// - Parameters:
    ///   - sound: Çalınacak ses modeli
    ///   - volume: Katman ses seviyesi (0.0 - 1.0)
    ///   - fadeIn: Fade in uygulansın mı
    func play(sound: Sound, volume: Float = 0.7, fadeIn: Bool = true) {
        guard let url = sound.bundleURL else {
            print("⚠️ Ses dosyası bulunamadı: \(sound.fileName)")
            return
        }
        
        guard activeLayers.count < AppConstants.maxMixSounds else {
            print("⚠️ Maksimum ses karıştırma limitine ulaşıldı")
            return
        }
        
        // Zaten çalıyorsa atla
        guard activeLayers[sound.identifier] == nil else { return }
        
        do {
            let looper = try SeamlessLooper(url: url, engine: engine)
            loopers[sound.identifier] = looper
            
            let layer = AudioLayer(
                identifier: sound.identifier,
                displayName: sound.displayName,
                volume: volume,
                isPlaying: true
            )
            activeLayers[sound.identifier] = layer
            
            looper.playerNode.volume = fadeIn ? 0 : volume * masterVolume
            
            if !engine.isRunning {
                try engine.start()
            }
            
            looper.start()
            
            if fadeIn {
                fadeController.fadeIn(
                    node: looper.playerNode,
                    to: volume * masterVolume,
                    duration: AppConstants.defaultFadeInDuration
                )
            }
            
            isPlaying = true
            
            if sessionStartTime == nil {
                sessionStartTime = .now
            }
            
        } catch {
            print("⚠️ Ses çalınamadı (\(sound.identifier)): \(error.localizedDescription)")
        }
    }
    
    /// Belirli bir ses katmanını durdur
    func stop(identifier: String, fadeOut: Bool = true) {
        guard let looper = loopers[identifier] else { return }
        
        if fadeOut {
            fadeController.fadeOut(
                node: looper.playerNode,
                duration: AppConstants.defaultFadeOutDuration
            ) { [weak self] in
                self?.removeLayer(identifier: identifier)
            }
        } else {
            removeLayer(identifier: identifier)
        }
    }
    
    /// Tüm sesleri durdur
    func stopAll(fadeOut: Bool = true) {
        if fadeOut {
            let identifiers = Array(activeLayers.keys)
            for identifier in identifiers {
                stop(identifier: identifier, fadeOut: true)
            }
        } else {
            for (_, looper) in loopers {
                looper.stop()
            }
            loopers.removeAll()
            activeLayers.removeAll()
            
            if engine.isRunning {
                engine.stop()
            }
            
            isPlaying = false
            sessionStartTime = nil
            cancelTimer()
        }
    }
    
    /// Belirli bir katmanın ses seviyesini ayarla
    func setVolume(_ volume: Float, for identifier: String) {
        guard let looper = loopers[identifier] else { return }
        activeLayers[identifier]?.volume = volume
        looper.playerNode.volume = volume * masterVolume
    }
    
    // MARK: - Timer
    
    /// Zamanlayıcı başlat (dakika cinsinden)
    func startTimer(minutes: Int) {
        cancelTimer()
        
        guard minutes > 0 else {
            timerDurationMinutes = 0
            remainingSeconds = nil
            return
        }
        
        timerDurationMinutes = minutes
        remainingSeconds = TimeInterval(minutes * 60)
        
        // Countdown task
        countdownTask = Task { @MainActor [weak self] in
            while let self = self,
                  let remaining = self.remainingSeconds,
                  remaining > 0,
                  !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    self.remainingSeconds = max(0, remaining - 1)
                }
            }
        }
        
        // Stop task
        timerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(TimeInterval(minutes * 60)))
            guard !Task.isCancelled, let self else { return }
            await MainActor.run { [weak self] in
                self?.stopAll(fadeOut: true)
            }
        }
    }
    
    /// Zamanlayıcı iptal et
    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        countdownTask?.cancel()
        countdownTask = nil
        remainingSeconds = nil
        timerDurationMinutes = 0
    }
    
    // MARK: - Private Helpers
    
    private func removeLayer(identifier: String) {
        loopers[identifier]?.stop()
        
        // Node'u engine'den çıkarmadan önce detach et
        if let looper = loopers[identifier] {
            engine.detach(looper.playerNode)
        }
        
        loopers.removeValue(forKey: identifier)
        activeLayers.removeValue(forKey: identifier)
        
        if activeLayers.isEmpty {
            if engine.isRunning {
                engine.stop()
            }
            isPlaying = false
            sessionStartTime = nil
            cancelTimer()
        }
    }
    
    private func updateMasterVolume() {
        for (identifier, layer) in activeLayers {
            loopers[identifier]?.playerNode.volume = layer.volume * masterVolume
        }
    }
    
    // MARK: - Computed
    
    /// Aktif ses sayısı
    var activeLayerCount: Int { activeLayers.count }
    
    /// Şu anki oturumun süresi
    var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date.now.timeIntervalSince(start)
    }
    
    /// Aktif ses identifier'ları
    var activeSoundIdentifiers: [String] {
        Array(activeLayers.keys)
    }
}

// MARK: - Audio Layer
/// Tek bir ses katmanının view-tarafındaki state'i
struct AudioLayer: Identifiable {
    let id: String
    let identifier: String
    let displayName: String
    var volume: Float
    var isPlaying: Bool
    
    init(identifier: String, displayName: String, volume: Float, isPlaying: Bool) {
        self.id = identifier
        self.identifier = identifier
        self.displayName = displayName
        self.volume = volume
        self.isPlaying = isPlaying
    }
}
