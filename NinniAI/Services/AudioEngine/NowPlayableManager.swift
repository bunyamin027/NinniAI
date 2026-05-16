import MediaPlayer
import AVFoundation

// MARK: - Now Playable Manager
/// Kilit ekranı ve Control Center ses kontrollerini yönetir.
/// Kullanıcı kilit ekranından play/pause/stop yapabilir.
/// MPRemoteCommandCenter ve MPNowPlayingInfoCenter entegrasyonu.
@Observable
final class NowPlayableManager {
    
    // MARK: - Properties
    
    /// Kilit ekranında gösterilen ses adı
    private(set) var currentTitle: String = ""
    
    /// Kilit ekranında gösterilen alt başlık
    private(set) var currentSubtitle: String = "NinniAI"
    
    // MARK: - Private
    
    private weak var audioManager: AudioEngineManager?
    
    // MARK: - Init
    
    init(audioManager: AudioEngineManager) {
        self.audioManager = audioManager
        setupRemoteCommands()
    }
    
    // MARK: - Setup
    
    /// Kilit ekranı komutlarını kayıt et
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            // TODO: Faz 3'te AudioEngineManager.resume() ile bağlanacak
            return .success
        }
        
        // Pause
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.audioManager?.stopAll(fadeOut: false)
            return .success
        }
        
        // Toggle (kulaklık butonu)
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.audioManager?.isPlaying == true {
                self.audioManager?.stopAll(fadeOut: true)
            }
            return .success
        }
        
        // İleri/geri atlama devre dışı (mantıksız bir uyku uygulamasında)
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }
    
    // MARK: - Now Playing Info Update
    
    /// Kilit ekranındaki bilgileri güncelle
    func updateNowPlayingInfo(
        title: String,
        subtitle: String = "NinniAI",
        duration: TimeInterval? = nil,
        elapsed: TimeInterval? = nil
    ) {
        currentTitle = title
        currentSubtitle = subtitle
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: subtitle,
            MPMediaItemPropertyAlbumTitle: "NinniAI",
            MPNowPlayingInfoPropertyIsLiveStream: duration == nil
        ]
        
        if let duration {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        if let elapsed {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        }
        
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /// Bilgileri temizle
    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        currentTitle = ""
    }
}
