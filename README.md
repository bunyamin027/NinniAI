# NinniAI - Akıllı Bebek Uyku Koçu ve Ninni Uygulaması

NinniAI, bebeklerin gelişim evrelerine ve günlük uyku trendlerine uygun olarak tasarlanmış, **Kişisel Uyku Koçu** vizyonuna sahip modern bir iOS uygulamasıdır. Ebeveynlerin bebeklerinin uykularını analiz etmelerini, otonom uyku pencerelerini takip etmelerini ve rahatlatıcı ninniler çalabilmelerini sağlar.

---

## 🌟 Öne Çıkan Özellikler

*   🤖 **Gelişim Odaklı Uyku Pencereleri:** Bebeğinizin yaşına ve gelişim evresine (Milestone) göre otonom olarak hesaplanan en uygun uyku pencereleri.
*   📊 **Derinlemesine Uyku Analizi:** Günlük uyku kalitesi skorlamaları, trendler ve uyku bölünme analizleri içeren detaylı analitik paneli.
*   🎵 **Çevrimdışı Ninni Çalar:** İnternet bağlantısı gerektirmeyen, arka planda çalabilen ve kilit ekranından kontrol edilebilen dingin ses kütüphanesi.
*   🕒 **Kilit Ekranı Takibi (Live Activities):** WidgetKit ve ActivityKit entegrasyonu sayesinde uygulamayı açmadan anlık uyku takibi.
*   🔒 **Güvenlik ve Gizlilik:** 
    *   Tüm veriler yalnızca cihazınızda (SwiftData) saklanır.
    *   Apple Guideline 1.3.0 (Kids Category) uyumlu **Ebeveyn Doğrulama Kilidi (Parental Gate)** ile korunan dış bağlantılar.
    *   %100 veri gizliliği (üçüncü taraf reklam veya izleme SDK'sı barındırmaz).
*   💳 **App Store 3.1.2 Uyumlu Abonelik:** StoreKit 2 altyapısı ile şeffaf abonelik modelleri ve yerel satın alım/yükleme özellikleri.

---

## 🛠️ Kullanılan Teknolojiler

*   **Dil:** Swift 5.9+
*   **Arayüz:** SwiftUI (Modern HSL renk paleti, koyu mod tasarımı ve pürüzsüz animasyonlar)
*   **Veritabanı:** SwiftData (Çevrimdışı yerel depolama)
*   **Ses Kontrolü:** AVFoundation & AudioEngine (Kesintisiz çalma, fade-out geçişleri)
*   **Araçlar & Canlı Takip:** WidgetKit & ActivityKit (Live Activities)
*   **Proje Yönetimi:** XcodeGen (Xcode projesini `project.yml` üzerinden dinamik üretme)

---

## 🚀 Başlangıç & Kurulum

Bu projeyi yerel bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

### Gereksinimler
*   macOS (Son sürüm önerilir)
*   Xcode 15.0 veya daha yeni bir sürüm
*   [XcodeGen](https://github.com/yonaskolb/XcodeGen) (Projeyi oluşturmak için)

### Adım Adım Kurulum

1.  **Projeyi Klonlayın:**
    ```bash
    git clone https://github.com/bunyamin027/NinniAI.git
    cd NinniAI
    ```

2.  **Xcode Projesini Üretin (XcodeGen):**
    Uygulama klasöründeki `project.yml` şablonunu kullanarak `.xcodeproj` dosyasını oluşturun:
    ```bash
    xcodegen generate
    ```

3.  **Xcode Projesini Açın:**
    ```bash
    open NinniAI.xcodeproj
    ```

4.  **Derleyin ve Çalıştırın:**
    Hedef cihaz olarak bir iOS Simülatörü seçin ve `⌘ + R` tuşlarına basarak projeyi derleyin.

---

## 🔒 Yasal Bilgiler & Geliştirici

*   **Geliştirici:** Kahramandev
*   **E-posta & Destek:** [bunyaminkahraman027@icloud.com](mailto:bunyaminkahraman027@icloud.com)
*   **Gizlilik Politikası & Kullanım Şartları:** [bunyamin027.github.io/Legal](https://bunyamin027.github.io/Legal)
