import AVFoundation

// MARK: - Seamless Looper
/// Zero-crossing noktasında birleşen kusursuz döngü motoru.
/// PRD §3.3: "Sıfır noktasında (zero-crossing) birleşen 10-15 saniyelik pürüzsüz sesler."
///
/// Her ses dosyası AVAudioPlayerNode üzerinden schedule edilir ve
/// dosya sonuna geldiğinde sıfır noktasından yeniden başlar.
/// Bu sayede kullanıcı herhangi bir kesinti/tıklama duyamaz.
final class SeamlessLooper {
    
    // MARK: - Properties
    
    /// Bu looper'ın sahip olduğu player node
    let playerNode: AVAudioPlayerNode
    
    /// Çalınacak ses dosyası
    private let audioFile: AVAudioFile
    
    /// Engine referansı
    private weak var engine: AVAudioEngine?
    
    /// Döngü aktif mi?
    private var isLooping: Bool = false
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - url: Ses dosyasının URL'si
    ///   - engine: AVAudioEngine referansı
    init(url: URL, engine: AVAudioEngine) throws {
        self.audioFile = try AVAudioFile(forReading: url)
        self.engine = engine
        self.playerNode = AVAudioPlayerNode()
        
        // Node'u engine'e bağla
        engine.attach(playerNode)
        engine.connect(
            playerNode,
            to: engine.mainMixerNode,
            format: audioFile.processingFormat
        )
    }
    
    // MARK: - Controls
    
    /// Döngülü çalmayı başlat
    func start() {
        guard !isLooping else { return }
        isLooping = true
        scheduleLoop()
        playerNode.play()
    }
    
    /// Döngüyü durdur
    func stop() {
        isLooping = false
        playerNode.stop()
    }
    
    /// Durakla
    func pause() {
        playerNode.pause()
    }
    
    /// Devam et
    func resume() {
        playerNode.play()
    }
    
    // MARK: - Private
    
    /// Dosyayı döngü olarak schedule et
    /// AVAudioPlayerNode'un `scheduleFile` callback'i ile
    /// dosya sonuna her gelindiğinde yeniden schedule edilir.
    private func scheduleLoop() {
        guard isLooping else { return }
        
        // Dosyanın okuma pozisyonunu başa al
        audioFile.framePosition = 0
        
        playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            guard let self = self, self.isLooping else { return }
            // Dosya bittiğinde yeniden schedule et (seamless)
            self.scheduleLoop()
        }
    }
}
