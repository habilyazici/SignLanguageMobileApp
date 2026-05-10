## 1. Mac Gereksinimleri
| Gereksinim | Minimum Versiyon | Kontrol |
|-----------|-----------------|---------|
| macOS | Ventura 13.0+ | Apple menüsü → Bu Mac Hakkında |
| Xcode | 15.0+ | `xcode-select --version` |
| Xcode Command Line Tools | 15.0+ | `xcodebuild -version` |
| CocoaPods | 1.14+ | `pod --version` |
| Flutter | 3.10.8+ | `flutter --version` |
| Ruby | 3.0+ | `ruby --version` (CocoaPods için) |
| Dart | 3.10.8+ | Flutter ile gelir |
| iOS Deployment Target | **15.5** | Proje sabit — değiştirilmez |


## 2. Geliştirme Ortamı Kurulumu
### Homebrew Kur (yoksa)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Apple Silicon Mac'te kurulum sonrası PATH'e ekle:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Flutter Kur
```bash
# Flutter SDK'yı indir
brew install --cask flutter
# Kurulumu doğrula
flutter --version
```

### Xcode Kur
1. **App Store** → "Xcode" ara → Yükle (büyük dosya, ~15 GB)
2. Kurulumdan sonra Xcode'u bir kez aç, lisansı kabul et
3. Command Line Tools'u aktifleştir:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### CocoaPods Kur
CocoaPods, iOS bağımlılık yöneticisidir. Bu projede TFLite custom ops pod'u için zorunludur.
```bash
# Sistem Ruby ile (önerilmez, sudo gerektirir)
sudo gem install cocoapods
# VEYA rbenv ile (önerilir, sudo gerektirmez)
brew install rbenv ruby-build
rbenv install 3.2.2
rbenv global 3.2.2
gem install cocoapods
# Kurulumu doğrula
pod --version
```

### Flutter Doctor Çalıştır
Tüm kurulumları doğrular:
```bash
flutter doctor -v
```
Beklenen çıktı (tüm yeşil olmalı):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Xcode - develop for iOS and macOS (Xcode 15.x)
[✓] CocoaPods (1.14.x)


## 3. Projeyi Klonla
```bash
git clone https://github.com/habilyazici/SignLanguage_MobileApp.git
cd SignLanguage_MobileApp
```
> **ZIP ile indirme:** GitHub → yeşil **Code** butonu → **Download ZIP** ile de indirilip kurulabilir, geri kalan adımlar aynıdır. Ancak ZIP ile sonradan güncelleme alınamaz. Güncelleme almak istiyorsan `git clone` kullan — yeni değişiklikleri almak için proje klasöründe `git pull` çalıştırmak yeterli olur.
---


## 4. Flutter .env Ayarı
```bash
cd ../frontend
cp .env.example .env
```
`.env` dosyasını aç ve düzenle:
```env
# Yerel backend kullanıyorsan (simülatör için):
BASE_IP=localhost
PORT=3000
# ngrok kullanıyorsan (gerçek cihaz veya simülatör için):
BASE_IP=xxxx-xxxx.ngrok-free.dev
PORT=443
```


## 5. Flutter Bağımlılıkları
```bash
# frontend/ dizininde olduğundan emin ol
cd frontend   # klonladığın ana dizindeysen
flutter pub get
```
Bu komut `pubspec.yaml`'daki tüm paketleri indirir (~30-60 saniye):
- `tflite_flutter` — TFLite model çalıştırma
- `google_mlkit_pose_detection` — Vücut iskelet tespiti
- `opencv_dart` — iOS için görüntü dönüşümü (BGRA → BGR)
- `hand_detection` — El tespiti
- `flutter_secure_storage` — JWT token şifreli saklama
- ve diğerleri...


## 6. CocoaPods Kurulumu (Kritik)
Bu adım iOS'a özgüdür ve en uzun süren adımdır (~5-15 dakika ilk seferinde).
```bash
cd ios
pod install
```
Bu komut şunları yapar:
- Flutter paketlerinin iOS pod'larını indirir
- **`TensorFlowLiteSelectTfOps`** pod'unu indirir (~200 MB)
- Bu pod projede zorunludur çünkü `sign_language_model_v2.tflite` modeli standart TFLite'da bulunmayan custom operatörler kullanır (BiLSTM + Self-Attention). Olmadan uygulama başlatmada crash atar.
- `Pods/` klasörünü ve `Runner.xcworkspace`'i oluşturur
Başarılı çıktı örneği:
```
Analyzing dependencies
Downloading dependencies
Installing TensorFlowLiteSelectTfOps (2.x.x)
Installing tflite_flutter (0.12.x)
...
Pod installation complete! There are X dependencies from the Podfile and X total pods installed.
```
**Uyarı:** `pod install` tamamlandıktan sonra artık `Runner.xcodeproj` değil, **`Runner.xcworkspace`** açılmalıdır. Xcode `.xcworkspace` yoksa pod'lar yüklenmez.
`pod install` tamamlandıktan sonra frontend dizinine dön:
```bash
cd ..
```


## 7. Xcode İmzalama Ayarları
iOS'ta her uygulama bir geliştirici imzasıyla imzalanmak zorundadır. Simülatör için ücretsiz Apple hesabı yeterlidir, gerçek cihaz için de ücretsiz hesap çalışır (7 günlük sertifika).
### Xcode'u Aç
```bash
open ios/Runner.xcworkspace
```
**Dikkat:** `Runner.xcodeproj` değil, `Runner.xcworkspace` açılmalıdır.
### İmzalama Ayarla
1. Sol panelde **Runner** (mavi proje ikonuna tıkla) → **Runner** (TARGETS altında)
2. **Signing & Capabilities** sekmesine tıkla
3. **Automatically manage signing** kutucuğunu işaretle
4. **Team** açılır menüsünden Apple hesabını seç
   - Hesap yoksa: **Add an Account...** → Apple ID ile giriş yap (ücretsiz)
5. **Bundle Identifier** alanı: `com.hearmeout.frontend`
   - Eğer "already in use" hatası alırsan sonu değiştir: `com.hearmeout.frontend.senin-adin`
Yeşil onay işareti görünüyorsa imzalama tamam demektir.


## 8. Gerçek Cihazda Çalıştırma
Tanıma özelliği (kamera + TFLite model) için gerçek iPhone gereklidir.
### Gereksinimler
- iPhone: **iOS 15.5 veya üzeri**
- USB-C veya Lightning kablosu
- Mac ile **aynı Wi-Fi**'da olması önerilir (ngrok kullanıyorsan zorunlu değil)
- Ücretsiz Apple Developer hesabı (7 günlük sertifika — her hafta yenileme gerekir)
- Ücretli Apple Developer hesabı ($99/yıl) alınırsa sertifika 1 yıl geçerli olur
### Cihazı Bağla
1. iPhone'u USB ile Mac'e bağla
2. iPhone'da **"Bu Bilgisayara Güven"** uyarısı çıkarsa **Güven**'e bas
3. iPhone şifresini gir
### Geliştirici Modunu Aç (iOS 16+)
iOS 16 ve üzerinde geliştirici modu manuel açılmalıdır:
```
iPhone → Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu → Aç
```
iPhone yeniden başlar.
### flutter ile Çalıştır
```bash
flutter devices
# iPhone'un listede göründüğünü doğrula
flutter run -d "iPhone'unun-adi"
```
Xcode üzerinden de çalıştırılabilir:
- Üst toolbar'da cihazını seç → ▶ Çalıştır
### Güvenilmeyen Geliştirici Uyarısı
İlk kurulumda iPhone "Güvenilmeyen Geliştirici" uyarısı verebilir:
```
iPhone → Ayarlar → Genel → VPN ve Cihaz Yönetimi
→ Apple Development: APPLE-ID → Güven → Güven
```


## Hızlı Başlangıç Özeti

```bash
# 1. Ortam kurulumu (bir kez)
brew install --cask flutter
xcode-select --install
gem install cocoapods

# 2. Repo
git clone ...
cd SignLanguage_MobileApp

# 3. Backend
cd backend && cp .env.example .env  # doldur
npm install && npx prisma migrate deploy && npm run dev

# 4. Frontend
cd ../frontend
cp .env.example .env  # BASE_IP ve PORT doldur
flutter pub get
cd ios && pod install && cd ..

# 5. Çalıştır
flutter run
```