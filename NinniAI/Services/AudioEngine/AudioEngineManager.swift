import AVFoundation
import Observation

// MARK: - Audio Engine Manager
/// AVAudioEngine üzerine kurulu merkezi ses yönetim servisi.
/// PRD §3.3: "Ses Karıştırma: Çoklu sesleri aynı anda çalma yeteneği"
///
/// Teknik: AVAudioPCMBuffer + .loops opsiyonu ile sıfır gecikmeli,
/// kusursuz döngü. scheduleBuffer(.loops) tek çağrıyla sonsuz döngü sağlar.
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
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private let fadeController = FadeController()
    private var timerTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init() {
        _ = engine.mainMixerNode // mainMixerNode'u initialize et
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    
    /// iOS Audio Session'ı arka plan + kilit ekranı çalma için ayarlar
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
    
    // MARK: - Play (Sound model ile)
    
    /// Sound modelden ses çal
    func play(sound: Sound, volume: Float = 0.7, fadeIn: Bool = true) {
        guard let url = sound.bundleURL else {
            print("⚠️ Ses dosyası bulunamadı: \(sound.fileName).\(sound.fileExtension)")
            return
        }
        playURL(
            url: url,
            identifier: sound.identifier,
            displayName: sound.displayName,
            volume: volume,
            fadeIn: fadeIn
        )
    }
    
    // MARK: - Play (URL ile — doğrudan dosya)
    
    /// URL'den ses çal — AVAudioPCMBuffer + .loops tekniği
    func playURL(
        url: URL,
        identifier: String,
        displayName: String,
        volume: Float = 0.7,
        fadeIn: Bool = true
    ) {
        guard activeLayers.count < AppConstants.maxMixSounds else {
            print("⚠️ Maksimum ses karıştırma limitine ulaşıldı (\(AppConstants.maxMixSounds))")
            return
        }
        
        // Zaten çalıyorsa atla
        guard activeLayers[identifier] == nil else { return }
        
        do {
            // 1. Ses dosyasını oku
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            let frameCount = AVAudioFrameCount(audioFile.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                print("⚠️ PCM buffer oluşturulamadı: \(identifier)")
                return
            }
            
            try audioFile.read(into: buffer)
            
            // 2. PlayerNode oluştur ve engine'e bağla
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            
            // 3. Engine'i başlat (henüz çalışmıyorsa)
            if !engine.isRunning {
                try engine.start()
            }
            
            // 4. Buffer'ı sonsuz döngüde schedule et
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
            
            // 5. Fade-in ayarı
            playerNode.volume = fadeIn ? 0 : volume * masterVolume
            
            // 6. Çalmaya başla
            playerNode.play()
            
            // 7. Fade-in uygula
            if fadeIn {
                fadeController.fadeIn(
                    node: playerNode,
                    to: volume * masterVolume,
                    duration: AppConstants.defaultFadeInDuration
                )
            }
            
            // 8. State güncelle
            playerNodes[identifier] = playerNode
            audioBuffers[identifier] = buffer
            activeLayers[identifier] = AudioLayer(
                identifier: identifier,
                displayName: displayName,
                volume: volume,
                isPlaying: true
            )
            isPlaying = true
            
            if sessionStartTime == nil {
                sessionStartTime = .now
            }
            
            print("✅ Ses çalınıyor: \(displayName) [\(identifier)]")
            
        } catch {
            print("⚠️ Ses çalınamadı (\(identifier)): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop Controls
    
    /// Belirli bir ses katmanını durdur
    func stop(identifier: String, fadeOut: Bool = true) {
        guard let node = playerNodes[identifier] else { return }
        
        if fadeOut {
            fadeController.fadeOut(
                node: node,
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
            for (_, node) in playerNodes {
                node.stop()
            }
            // Engine'den detach et
            for (_, node) in playerNodes {
                engine.detach(node)
            }
            playerNodes.removeAll()
            audioBuffers.removeAll()
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
        guard let node = playerNodes[identifier] else { return }
        activeLayers[identifier]?.volume = volume
        node.volume = volume * masterVolume
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
        playerNodes[identifier]?.stop()
        
        if let node = playerNodes[identifier] {
            engine.detach(node)
        }
        
        playerNodes.removeValue(forKey: identifier)
        audioBuffers.removeValue(forKey: identifier)
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
            playerNodes[identifier]?.volume = layer.volume * masterVolume
        }
    }
    
    // MARK: - Computed
    
    var activeLayerCount: Int { activeLayers.count }
    
    var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date.now.timeIntervalSince(start)
    }
    
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
