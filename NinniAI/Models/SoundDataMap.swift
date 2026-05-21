import Foundation

// MARK: - Sound Track
/// Tek bir ses dosyasının UI tarafındaki premium temsili.
/// `filename` → Bundle'daki gerçek dosya adı (uzantısız).
/// `displayName` → Kullanıcıya gösterilen sakinleştirici premium isim.
struct SoundTrack: Identifiable, Hashable {
    let id: String
    let filename: String
    let displayName: String
    let description: String
    let iconName: String
    let isPremium: Bool
    let sortOrder: Int
    
    init(
        id: String = UUID().uuidString,
        filename: String,
        displayName: String,
        description: String = "",
        iconName: String = "waveform",
        isPremium: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.filename = filename
        self.displayName = displayName
        self.description = description
        self.iconName = iconName
        self.isPremium = isPremium
        self.sortOrder = sortOrder
    }
}

// MARK: - Sound Section
/// Bir kategorideki tüm sesleri UI-ready şekilde gruplar.
/// `SoundCategory` enum'una 1:1 bağlanır.
struct SoundSection: Identifiable {
    let id: String
    let category: SoundCategory
    let tracks: [SoundTrack]
    
    var displayTitle: LocalizedStringResource { category.displayTitle }
    var iconName: String { category.iconName }
}

// MARK: - Sound Data Map
/// Uygulamanın tüm ses içeriğinin merkezi statik haritası.
/// Gerçek dosya adlarını premium UI isimlerine dönüştürür.
///
/// Kullanım:
/// ```swift
/// let sections = SoundDataMap.allSections
/// let track = SoundDataMap.track(forFilename: "some-file-name")
/// ```
enum SoundDataMap {
    
    // MARK: - 1) Beyaz Gürültü
    
    static let whiteNoise = SoundSection(
        id: "white_noise",
        category: .whiteNoise,
        tracks: [
            SoundTrack(
                filename: "nonenothingnowhere-174-hz-pain-release-156261",
                displayName: String(localized: "Kozmik İyileşme"),
                description: String(localized: "174 Hz frekansında derin rahatlama titreşimi"),
                iconName: "waveform",
                sortOrder: 0
            ),
            SoundTrack(
                filename: "nonenothingnowhere-396-hz-root-chakra-156263",
                displayName: String(localized: "Topraklama Frekansı"),
                description: String(localized: "Güvenlik ve huzur hissi veren derin tonlar"),
                iconName: "waveform.circle.fill",
                sortOrder: 1
            ),
            SoundTrack(
                filename: "nonenothingnowhere-417-hz-sacral-chakra-156264",
                displayName: String(localized: "Yenilenme Dalgaları"),
                description: String(localized: "Tazeleyici ve arındırıcı ses frekansları"),
                iconName: "waveform.path.ecg",
                sortOrder: 2
            ),
            SoundTrack(
                filename: "nonenothingnowhere-432-hz-tune-in-with-nature-156265",
                displayName: String(localized: "Doğanın Frekansı"),
                description: String(localized: "Evrenin doğal titreşimiyle uyum"),
                iconName: "leaf.circle.fill",
                sortOrder: 3
            ),
            SoundTrack(
                filename: "nonenothingnowhere-639-hz-heart-chakra-156267",
                displayName: String(localized: "Sonsuz Şefkat Tonu"),
                description: String(localized: "Kalp merkezli sakinleştirici frekans"),
                iconName: "heart.circle.fill",
                isPremium: true,
                sortOrder: 4
            ),
            SoundTrack(
                filename: "hoggyart-285-hz-417-hz-741-hz-clearing-negative-energy-242900",
                displayName: String(localized: "Arınma Seremonisi"),
                description: String(localized: "Çoklu frekanslarla derinlemesine huzur"),
                iconName: "waveform.badge.magnifyingglass",
                isPremium: true,
                sortOrder: 5
            ),
            SoundTrack(
                filename: "siarhei_korbut-285-hz-star-chakra-484883",
                displayName: String(localized: "Yıldız Işığı Frekansı"),
                description: String(localized: "Yüksek titreşimli kozmik uyum dalgaları"),
                iconName: "sparkles",
                isPremium: true,
                sortOrder: 6
            ),
            SoundTrack(
                filename: "bearian-174hz-396hz-528hz-412308",
                displayName: String(localized: "Kutsal Üçlü Harmoni"),
                description: String(localized: "Üç iyileştirici frekansın büyülü buluşması"),
                iconName: "waveform.path",
                isPremium: true,
                sortOrder: 7
            ),
            SoundTrack(
                filename: "purebinaural-purebinaural-40-hz-gamma-binaural-beats-with-white-noise-484861",
                displayName: String(localized: "Kadife Beyaz Gürültü"),
                description: String(localized: "Binaural beatlerle zenginleştirilmiş yumuşak örtü"),
                iconName: "waveform.badge.plus",
                isPremium: true,
                sortOrder: 8
            )
        ]
    )
    
    // MARK: - 2) Doğa Sesleri
    
    static let natureSounds = SoundSection(
        id: "nature_sounds",
        category: .nature,
        tracks: [
            SoundTrack(
                filename: "clavier-music-dark-rain-deep-relaxing-ambient-soundscape-with-soothing-rain-318232",
                displayName: String(localized: "Gece Yağmuru Fısıltısı"),
                description: String(localized: "Karanlıkta huzurla yağan damlalar"),
                iconName: "cloud.rain.fill",
                sortOrder: 0
            ),
            SoundTrack(
                filename: "konstantinpazuzustudio-quiet-rain-thunder-rain-and-piano-512040",
                displayName: String(localized: "Gümüş Yağmur Damlaları"),
                description: String(localized: "Uzak gök gürültüsü ve piyanonun dansı"),
                iconName: "cloud.bolt.rain.fill",
                sortOrder: 1
            ),
            SoundTrack(
                filename: "lorenzobuczek-sleepy-rain-116521",
                displayName: String(localized: "Uykulu Yağmur"),
                description: String(localized: "Uyku getiren hafif yağmur melodisi"),
                iconName: "cloud.drizzle.fill",
                sortOrder: 2
            ),
            SoundTrack(
                filename: "soutera-cosmic-ocean-284361",
                displayName: String(localized: "Derin Okyanus"),
                description: String(localized: "Sonsuz maviliğin derin ve ritmik dalgaları"),
                iconName: "water.waves",
                isPremium: true,
                sortOrder: 3
            ),
            SoundTrack(
                filename: "music_for_video-forest-lullaby-110624",
                displayName: String(localized: "Orman Ninnisi"),
                description: String(localized: "Ağaçların arasından süzülen doğa melodisi"),
                iconName: "tree.fill",
                sortOrder: 4
            ),
            SoundTrack(
                filename: "low_atmos-desert-night-sleep-atmosphere-513282",
                displayName: String(localized: "Çöl Gecesi Sessizliği"),
                description: String(localized: "Yıldızlı çölün büyüleyici atmosferi"),
                iconName: "moon.haze.fill",
                isPremium: true,
                sortOrder: 5
            )
        ]
    )
    
    // MARK: - 3) Ninniler
    
    static let lullabies = SoundSection(
        id: "lullabies",
        category: .lullaby,
        tracks: [
            SoundTrack(
                filename: "backgroundmusicforvideos-lullaby-baby-sleep-music-388567",
                displayName: String(localized: "Yıldız Tozu Ninnisi"),
                description: String(localized: "Gökyüzünden süzülen büyülü bir melodi"),
                iconName: "sparkles",
                sortOrder: 0
            ),
            SoundTrack(
                filename: "clavier-music-lullaby-sleep-piano-music-285599",
                displayName: String(localized: "Ay Işığı Piyanisi"),
                description: String(localized: "Dolunayın altında dans eden piyano notaları"),
                iconName: "moon.stars.fill",
                sortOrder: 1
            ),
            SoundTrack(
                filename: "denis-pavlov-music-calm-baby-lullaby-sweet-dreams-music-box-397059",
                displayName: String(localized: "Tatlı Rüyalar Kutusu"),
                description: String(localized: "Müzik kutusundan dökülen pamuk şeker melodiler"),
                iconName: "music.note.house.fill",
                sortOrder: 2
            ),
            SoundTrack(
                filename: "denis-pavlov-music-lullaby-baby-cradle-song-music-box-233532",
                displayName: String(localized: "Beşik Şarkısı"),
                description: String(localized: "Nesillerden süzülen sıcacık beşik melodisi"),
                iconName: "bed.double.fill",
                sortOrder: 3
            ),
            SoundTrack(
                filename: "monume-lullaby-baby-sleep-music-509508",
                displayName: String(localized: "Bulutların Üzerinde"),
                description: String(localized: "Pamuk bulutlarda süzülen hafif ninni"),
                iconName: "cloud.fill",
                sortOrder: 4
            ),
            SoundTrack(
                filename: "mountaindweller-calm-lullaby-for-irish-harp-243170",
                displayName: String(localized: "Arp Masalı"),
                description: String(localized: "İrlanda arpının büyüleyici huzur ezgisi"),
                iconName: "guitars.fill",
                isPremium: true,
                sortOrder: 5
            ),
            SoundTrack(
                filename: "sleepvolume-the-quiet-night-lullaby-music-instrumental-346577",
                displayName: String(localized: "Sessiz Gece Melodisi"),
                description: String(localized: "Gecenin derinliğinden yükselen uyku ezgisi"),
                iconName: "moon.fill",
                sortOrder: 6
            ),
            SoundTrack(
                filename: "tunetank-kids-relaxing-lullaby-music-349558",
                displayName: String(localized: "Uyku Perisi"),
                description: String(localized: "Gözleri tatlı tatlı kapatan sihirli melodi"),
                iconName: "wand.and.stars",
                sortOrder: 7
            ),
            SoundTrack(
                filename: "tunetank-lullaby-baby-sleep-music-347721",
                displayName: String(localized: "Rüya Bahçesi"),
                description: String(localized: "Çiçeklerin arasında dans eden notalar"),
                iconName: "leaf.fill",
                isPremium: true,
                sortOrder: 8
            ),
            SoundTrack(
                filename: "tunetank-lullaby-dreamy-children-music-347722",
                displayName: String(localized: "Bulut Beşiği"),
                description: String(localized: "Rüyalar diyarına taşıyan yumuşak ezgi"),
                iconName: "cloud.moon.fill",
                sortOrder: 9
            ),
            SoundTrack(
                filename: "tunetank-music-box-sleep-lullaby-349471",
                displayName: String(localized: "Kristal Müzik Kutusu"),
                description: String(localized: "Antik müzik kutusunun büyülü tınısı"),
                iconName: "music.note.list",
                isPremium: true,
                sortOrder: 10
            ),
            SoundTrack(
                filename: "delon_boomkin-baby-sleep-music-1-sound-effects-297159",
                displayName: String(localized: "Ninni Esintisi"),
                description: String(localized: "Hafif bir esinti gibi saran uyku melodisi"),
                iconName: "wind",
                sortOrder: 11
            ),
            SoundTrack(
                filename: "the_mountain-soft-loop-130012",
                displayName: String(localized: "Sonsuz Beşik Salınımı"),
                description: String(localized: "Hiç bitmeyen, nazikçe sallanan ninni döngüsü"),
                iconName: "infinity",
                sortOrder: 12
            ),
            SoundTrack(
                filename: "relaxingtime-sleep-music-vol15-195425",
                displayName: String(localized: "Kadife Uyku"),
                description: String(localized: "Kadife gibi sarmalayan derin uyku melodisi"),
                iconName: "powersleep",
                isPremium: true,
                sortOrder: 13
            )
        ].map { track in
            SoundTrack(
                id: track.id,
                filename: track.filename,
                displayName: track.displayName,
                description: track.description,
                iconName: track.iconName,
                isPremium: true,
                sortOrder: track.sortOrder
            )
        }
    )
    
    // MARK: - 4) Kalp Atışı
    
    static let heartbeat = SoundSection(
        id: "heartbeat",
        category: .heartbeat,
        tracks: [
            SoundTrack(
                filename: "don_vitaliy-time-heartbeat-fusion-169017",
                displayName: String(localized: "Anne Şefkati Ritimleri"),
                description: String(localized: "Annenin kalbinden yayılan güven dolu ritim"),
                iconName: "heart.fill",
                sortOrder: 0
            ),
            SoundTrack(
                filename: "lazarosv-electric-heartbeat-i-492330",
                displayName: String(localized: "Güvenli Kucak"),
                description: String(localized: "Bebeği saran koruyucu kalp atışı"),
                iconName: "heart.circle.fill",
                sortOrder: 1
            ),
            SoundTrack(
                filename: "shadowsandechoes-the-womb-dark-ambient-background-mystery-music-155682",
                displayName: String(localized: "Anne Karnı Huzuru"),
                description: String(localized: "Rahmin sıcak ve korunaklı sessizliği"),
                iconName: "figure.and.child.holdinghands",
                isPremium: true,
                sortOrder: 2
            )
        ]
    )
    
    // MARK: - 5) Ortam Sesleri
    
    static let ambientSounds = SoundSection(
        id: "ambient_sounds",
        category: .ambient,
        tracks: [
            SoundTrack(
                filename: "absolutesound-meditation-meditation-music-510801",
                displayName: String(localized: "Huzur Tapınağı"),
                description: String(localized: "Derin meditasyonun sakin atmosferi"),
                iconName: "building.columns.fill",
                sortOrder: 0
            ),
            SoundTrack(
                filename: "alan_frijns-valley-of-silence-meditation-yoga-relaxation-work-study-sleep-music-122612",
                displayName: String(localized: "Sessizlik Vadisi"),
                description: String(localized: "Dağların arasındaki sonsuz huzur"),
                iconName: "mountain.2.fill",
                sortOrder: 1
            ),
            SoundTrack(
                filename: "imaginedragon-meditation-blue-138131",
                displayName: String(localized: "Mavi Düşler"),
                description: String(localized: "Gökyüzünün mavisinde süzülen dinginlik"),
                iconName: "drop.fill",
                sortOrder: 2
            ),
            SoundTrack(
                filename: "mondamusic-meditation-512846",
                displayName: String(localized: "İç Huzur Yolculuğu"),
                description: String(localized: "Ruhun derinliklerine yapılan sakin yolculuk"),
                iconName: "figure.mind.and.body",
                sortOrder: 3
            ),
            SoundTrack(
                filename: "prettyjohn1-meditation-495676",
                displayName: String(localized: "Sabah Çiği Meditasyonu"),
                description: String(localized: "Şafakta parlayan çiy damlalarının sessizliği"),
                iconName: "sunrise.fill",
                sortOrder: 4
            ),
            SoundTrack(
                filename: "quietphase-meditative-meditation-482094",
                displayName: String(localized: "Zen Bahçesi"),
                description: String(localized: "Taş bahçesinin derin ve arındırıcı huzuru"),
                iconName: "camera.macro",
                isPremium: true,
                sortOrder: 5
            ),
            SoundTrack(
                filename: "music_for_video-please-calm-my-mind-125566",
                displayName: String(localized: "Sakin Kütüphane"),
                description: String(localized: "Kitaplar arasında süzülen dingin melodi"),
                iconName: "books.vertical.fill",
                sortOrder: 6
            ),
            SoundTrack(
                filename: "music_for_video-sedative-110241",
                displayName: String(localized: "Kadife Sessizlik"),
                description: String(localized: "Her şeyin durduğu derin bir an"),
                iconName: "moon.haze.fill",
                sortOrder: 7
            ),
            SoundTrack(
                filename: "music_for_video-pray-for-ukraine-sleep-21715",
                displayName: String(localized: "Barış Duası"),
                description: String(localized: "Huzur dolu piyanonun duygusal ezgisi"),
                iconName: "hands.and.sparkles.fill",
                isPremium: true,
                sortOrder: 8
            ),
            SoundTrack(
                filename: "oceanframemusic-guitar-relaxation-524560",
                displayName: String(localized: "Altın Gitar Huzuru"),
                description: String(localized: "Akustik gitarın sıcacık dokunuşu"),
                iconName: "guitars.fill",
                sortOrder: 9
            ),
            SoundTrack(
                filename: "piano_music-calm-relaxation-122811",
                displayName: String(localized: "Sıcak Şömine Piyanisi"),
                description: String(localized: "Şömine başında çalınan huzurlu piyano"),
                iconName: "flame.fill",
                sortOrder: 10
            ),
            SoundTrack(
                filename: "pretex-briefing-ambience-341525",
                displayName: String(localized: "Uzay İstasyonu"),
                description: String(localized: "Yörüngede süzülen kozmik ortam sesleri"),
                iconName: "airplane",
                isPremium: true,
                sortOrder: 11
            ),
            SoundTrack(
                filename: "low_atmos-orbit-sleep-background-514712",
                displayName: String(localized: "Gece Yolculuğu"),
                description: String(localized: "Yıldızların arasında uyku yolculuğu"),
                iconName: "moon.stars.fill",
                isPremium: true,
                sortOrder: 12
            ),
            SoundTrack(
                filename: "ceeprolific-kiss-the-rain-274811",
                displayName: String(localized: "Yağmurun Öpücüğü"),
                description: String(localized: "Yağmur damlalarıyla dans eden piyano"),
                iconName: "cloud.rain.fill",
                sortOrder: 13
            ),
            SoundTrack(
                filename: "multimusicas-sweet-samba-that-is-contagious-486886",
                displayName: String(localized: "Tatlı Rüzgar Dansı"),
                description: String(localized: "Neşeli ve hafif sallanan uyku ritmi"),
                iconName: "wind",
                sortOrder: 14
            ),
            SoundTrack(
                filename: "angel4leon-baby-smile-190123",
                displayName: String(localized: "Melek Gülümsemesi"),
                description: String(localized: "Bebeğin yüzündeki gülümsemeyi getiren melodi"),
                iconName: "face.smiling.fill",
                sortOrder: 15
            ),
            SoundTrack(
                filename: "the_mountain-baby-joy-130049",
                displayName: String(localized: "Küçük Sevinçler"),
                description: String(localized: "Minicik kalplerin neşe dolu anları"),
                iconName: "heart.fill",
                sortOrder: 16
            ),
            SoundTrack(
                filename: "the_mountain-baby-sleep-143300",
                displayName: String(localized: "Pamuk Uyku"),
                description: String(localized: "Bulutlar kadar yumuşak uyku atmosferi"),
                iconName: "cloud.fill",
                sortOrder: 17
            ),
            SoundTrack(
                filename: "audiocoffee-positive-happy-kids-background-468931",
                displayName: String(localized: "Güneşli Sabah"),
                description: String(localized: "Neşeli bir güne uyanışın melodisi"),
                iconName: "sun.max.fill",
                sortOrder: 18
            ),
            SoundTrack(
                filename: "freemusicforvideo-kids-cartoon-495621",
                displayName: String(localized: "Rüya Atölyesi"),
                description: String(localized: "Hayal gücüyle dolu renkli bir dünya"),
                iconName: "paintpalette.fill",
                sortOrder: 19
            ),
            SoundTrack(
                filename: "mfcc-baby-baby-kids-children-music-522351",
                displayName: String(localized: "Peri Masalı"),
                description: String(localized: "Masalların dünyasına açılan sihirli kapı"),
                iconName: "wand.and.stars",
                sortOrder: 20
            ),
            SoundTrack(
                filename: "miromaxmusic-fun-kids-music-438477",
                displayName: String(localized: "Oyun Kutusu"),
                description: String(localized: "Neşeli ve keyifli çocukluk anıları"),
                iconName: "teddybear.fill",
                sortOrder: 21
            ),
            SoundTrack(
                filename: "mondamusic-kids-cartoon-499179",
                displayName: String(localized: "Gökkuşağı Yolculuğu"),
                description: String(localized: "Rengarenk bir düşler diyarına yolculuk"),
                iconName: "rainbow",
                sortOrder: 22
            ),
            SoundTrack(
                filename: "viacheslavstarostin-baby-kids-children-music-471917",
                displayName: String(localized: "Küçük Kaşif"),
                description: String(localized: "Meraklı gözlerle keşfedilen yeni dünya"),
                iconName: "binoculars.fill",
                sortOrder: 23
            ),
            SoundTrack(
                filename: "viacheslavstarostin-kids-baby-children-music-382060",
                displayName: String(localized: "Yıldız Parkı"),
                description: String(localized: "Yıldızların altında oynanan oyunlar"),
                iconName: "star.fill",
                sortOrder: 24
            )
        ]
    )
    
    // MARK: - Tüm Bölümler
    
    /// UI'da listelenecek tüm ses bölümleri, sıralı.
    static let allSections: [SoundSection] = [
        whiteNoise,
        natureSounds,
        lullabies,
        heartbeat,
        ambientSounds
    ]
    
    /// Tüm seslerin düz listesi.
    static var allTracks: [SoundTrack] {
        allSections.flatMap(\.tracks)
    }
    
    /// Dosya adıyla hızlı erişim (AudioEngine ↔ UI köprüsü).
    static func track(forFilename filename: String) -> SoundTrack? {
        allTracks.first { $0.filename == filename }
    }
    
    /// Kategori enum'u ile bölüm eşleştirme.
    static func section(for category: SoundCategory) -> SoundSection? {
        allSections.first { $0.category == category }
    }
}
