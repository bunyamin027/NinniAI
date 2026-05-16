import AVFoundation
import Observation

// MARK: - Audio Engine Manager
/// AVAudioEngine üzerine kurulu merkezi ses yönetim servisi.
/// KESİN KURAL: Sadece tek bir ses çalabilir. Yeni ses seçildiğinde eskisi anında durur.
/// Teknik: AVAudioPCMBuffer + .loops opsiyonu ile sıfır gecikmeli, kusursuz döngü.
@Observable
final class AudioEngineManager {
    
    // MARK: - State
    
    /// Şu anda çalan aktif ses
    private(set) var activeLayer: AudioLayer?
    
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
    private var playerNode: AVAudioPlayerNode?
    private var audioBuffer: AVAudioPCMBuffer?
    private let fadeController = FadeController()
    private var timerTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init() {
        _ = engine.mainMixerNode // mainMixerNode'u initialize et
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    
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
    
    func playURL(
        url: URL,
        identifier: String,
        displayName: String,
        volume: Float = 0.7,
        fadeIn: Bool = true
    ) {
        // Zaten aynı ses çalıyorsa devam ettir veya yoksay
        if activeLayer?.identifier == identifier {
            if !isPlaying { resume() }
            return
        }
        
        // Yeni bir ses seçildiğinde eskisini anında durdur
        stopAll(fadeOut: false)
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            let frameCount = AVAudioFrameCount(audioFile.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                print("⚠️ PCM buffer oluşturulamadı: \(identifier)")
                return
            }
            
            try audioFile.read(into: buffer)
            
            let newNode = AVAudioPlayerNode()
            engine.attach(newNode)
            engine.connect(newNode, to: engine.mainMixerNode, format: format)
            
            if !engine.isRunning {
                try engine.start()
            }
            
            newNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            newNode.volume = fadeIn ? 0 : volume * masterVolume
            newNode.play()
            
            if fadeIn {
                fadeController.fadeIn(
                    node: newNode,
                    to: volume * masterVolume,
                    duration: AppConstants.defaultFadeInDuration
                )
            }
            
            playerNode = newNode
            audioBuffer = buffer
            activeLayer = AudioLayer(
                identifier: identifier,
                displayName: displayName,
                volume: volume,
                isPlaying: true
            )
            isPlaying = true
            
            if sessionStartTime == nil {
                sessionStartTime = .now
            }
            
            print("✅ Ses çalınıyor (Sonsuz Döngü, Tek Kanal): \(displayName) [\(identifier)]")
            
        } catch {
            print("⚠️ Ses çalınamadı (\(identifier)): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Play/Pause Controls
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        playerNode?.pause()
        engine.pause()
        isPlaying = false
    }
    
    func resume() {
        guard activeLayer != nil else { return }
        do {
            if !engine.isRunning { try engine.start() }
            playerNode?.play()
            isPlaying = true
        } catch {
            print("⚠️ Engine resume hatası: \(error)")
        }
    }
    
    // MARK: - Stop Controls
    
    func stopAll(fadeOut: Bool = true) {
        guard let node = playerNode else { return }
        
        if fadeOut {
            fadeController.fadeOut(
                node: node,
                duration: AppConstants.defaultFadeOutDuration
            ) { [weak self] in
                self?.removeCurrentLayer()
            }
        } else {
            removeCurrentLayer()
        }
    }
    
    func setVolume(_ volume: Float) {
        activeLayer?.volume = volume
        playerNode?.volume = volume * masterVolume
    }
    
    // MARK: - Timer
    
    func startTimer(minutes: Int) {
        cancelTimer()
        guard minutes > 0 else { return }
        
        timerDurationMinutes = minutes
        remainingSeconds = TimeInterval(minutes * 60)
        
        countdownTask = Task { @MainActor [weak self] in
            while let self = self,
                  let remaining = self.remainingSeconds,
                  remaining > 0,
                  !Task.isCancelled {
                
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                
                // SADECE çalarken sayacı eksilt
                if self.isPlaying {
                    let newRemaining = max(0, remaining - 1)
                    self.remainingSeconds = newRemaining
                    
                    // Süre sıfırlandıysa müziği durdur ve zamanlayıcıyı kapat
                    if newRemaining == 0 {
                        self.pause()
                        self.cancelTimer()
                    }
                }
            }
        }
    }
    
    func cancelTimer() {
        timerTask?.cancel() // Sadece geriye dönük uyumluluk için, artık kullanılmıyor
        timerTask = nil
        countdownTask?.cancel()
        countdownTask = nil
        remainingSeconds = nil
        timerDurationMinutes = 0
    }
    
    // MARK: - Private Helpers
    
    private func removeCurrentLayer() {
        playerNode?.stop()
        if let node = playerNode {
            engine.detach(node)
        }
        playerNode = nil
        audioBuffer = nil
        activeLayer = nil
        
        if engine.isRunning {
            engine.stop()
        }
        isPlaying = false
        sessionStartTime = nil
        cancelTimer()
    }
    
    private func updateMasterVolume() {
        if let layer = activeLayer {
            playerNode?.volume = layer.volume * masterVolume
        }
    }
    
    // MARK: - Computed
    
    var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date.now.timeIntervalSince(start)
    }
}

// MARK: - Audio Layer
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
