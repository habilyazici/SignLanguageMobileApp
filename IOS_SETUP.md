# Hear Me Out — iOS Kurulum Rehberi (Mac)

iOS build yalnızca **Mac** üzerinde yapılabilir. Windows veya Linux'ta Flutter iOS build desteklenmez.

---

## İçindekiler

1. [Mac Gereksinimleri](#1-mac-gereksinimleri)
2. [Geliştirme Ortamı Kurulumu](#2-geliştirme-ortamı-kurulumu)
3. [Projeyi Klonla](#3-projeyi-klonla)
4. [Backend Kurulumu](#4-backend-kurulumu)
5. [Flutter .env Ayarı](#5-flutter-env-ayarı)
6. [Flutter Bağımlılıkları](#6-flutter-bağımlılıkları)
7. [CocoaPods Kurulumu (Kritik)](#7-cocoapods-kurulumu-kritik)
8. [Xcode İmzalama Ayarları](#8-xcode-i̇mzalama-ayarları)
9. [Simülatörde Çalıştırma](#9-simülatörde-çalıştırma)
10. [Gerçek Cihazda Çalıştırma](#10-gerçek-cihazda-çalıştırma)
11. [Sık Karşılaşılan Hatalar](#11-sık-karşılaşılan-hatalar)

---

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

> Simülatör için Apple Silicon (M1/M2/M3) veya Intel Mac fark etmez.
> Gerçek cihaz için USB kablosu ve Apple Developer hesabı gereklidir.

---

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

---

### Flutter Kur

```bash
# Flutter SDK'yı indir (FVM kullanmak istersen: brew install fvm)
brew install --cask flutter

# Kurulumu doğrula
flutter --version
# Flutter 3.x.x • channel stable
```

Alternatif olarak [flutter.dev](https://docs.flutter.dev/get-started/install/macos) üzerinden zip ile de kurulabilir.

---

### Xcode Kur

1. **App Store** → "Xcode" ara → Yükle (büyük dosya, ~15 GB)
2. Kurulumdan sonra Xcode'u bir kez aç, lisansı kabul et
3. Command Line Tools'u aktifleştir:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

---

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
# 1.14.x veya üzeri
```

> Apple Silicon Mac kullanıyorsan ve `pod install` sırasında mimari hatası alırsan:
> ```bash
> sudo arch -x86_64 gem install ffi
> arch -x86_64 pod install
> ```

---

### Flutter Doctor Çalıştır

Tüm kurulumları doğrular:

```bash
flutter doctor -v
```

Beklenen çıktı (tüm yeşil olmalı):

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Xcode - develop for iOS and macOS (Xcode 15.x)
[✓] CocoaPods (1.14.x)
```

`flutter doctor` bir sorun gösterirse, önce onu çöz.

---

## 3. Projeyi Klonla

```bash
git clone https://github.com/KULLANICI_ADI/SignLanguage_MobileApp.git
cd SignLanguage_MobileApp
```

---

## 4. Backend Kurulumu

Uygulama çevrimiçi özellikler (giriş, sözlük, geçmiş, yer imleri) için bir backend'e bağlanır. Backend çalışmadan da tanıma özelliği çalışır ama giriş yapılamaz.

### Seçenek A — Yerel Backend (Geliştirme)

```bash
cd backend
cp .env.example .env
```

`.env` dosyasını düzenle:

```env
PORT=3000
NODE_ENV=development
JWT_SECRET=guclu-bir-sifre-yaz-buraya
DATABASE_URL="postgresql://KULLANICI:SIFRE@localhost:5432/sign_language_app?schema=public"
BASE_URL=http://SENIN_MAC_IP_ADRESIN:3000
SMTP_USER=gmail-adresin@gmail.com
SMTP_PASS=gmail-uygulama-sifresi
```

Mac'inin yerel IP adresini öğrenmek için:

```bash
ipconfig getifaddr en0
# veya
ifconfig | grep "inet " | grep -v 127.0.0.1
```

PostgreSQL kur ve başlat:

```bash
brew install postgresql@15
brew services start postgresql@15
createdb sign_language_app
```

Backend'i başlat:

```bash
npm install
npx prisma migrate deploy
npm run dev
# Server: http://localhost:3000
```

### Seçenek B — ngrok ile Dış Erişim

Gerçek cihazda test için ngrok kullanılabilir (cihaz ve Mac aynı Wi-Fi'da olsa bile pratiktir):

```bash
# ngrok kur
brew install ngrok

# Backend'i çalıştır (Seçenek A gibi)
npm run dev

# Ayrı terminal'de tüneli aç
ngrok http 3000
# Forwarding: https://xxxx-xxxx.ngrok-free.dev → http://localhost:3000
```

Bu URL'yi frontend `.env` dosyasında kullanacaksın (sonraki adım).

---

## 5. Flutter .env Ayarı

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

> **Önemli:** Simülatör `localhost`'a erişebilir çünkü Mac ile aynı makinede çalışır.
> Gerçek fiziksel cihaz `localhost`'a erişemez — ngrok veya Mac'in yerel IP'si gerekir.

> **Güvenlik:** `.env` dosyası `.gitignore`'a eklenmiştir, GitHub'a gitmez.

---

## 6. Flutter Bağımlılıkları

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

Hata çıkarsa:

```bash
flutter clean
flutter pub get
```

---

## 7. CocoaPods Kurulumu (Kritik)

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

> **Uyarı:** `pod install` tamamlandıktan sonra artık `Runner.xcodeproj` değil,
> **`Runner.xcworkspace`** açılmalıdır. Xcode `.xcworkspace` yoksa pod'lar yüklenmez.

`pod install` tamamlandıktan sonra frontend dizinine dön:

```bash
cd ..
```

---

## 8. Xcode İmzalama Ayarları

iOS'ta her uygulama bir geliştirici imzasıyla imzalanmak zorundadır. Simülatör için ücretsiz Apple hesabı yeterlidir, gerçek cihaz için de ücretsiz hesap çalışır (7 günlük sertifika).

### Xcode'u Aç

```bash
open ios/Runner.xcworkspace
```

> **Dikkat:** `Runner.xcodeproj` değil, `Runner.xcworkspace` açılmalıdır.

### İmzalama Ayarla

1. Sol panelde **Runner** (mavi proje ikonuna tıkla) → **Runner** (TARGETS altında)
2. **Signing & Capabilities** sekmesine tıkla
3. **Automatically manage signing** kutucuğunu işaretle
4. **Team** açılır menüsünden Apple hesabını seç
   - Hesap yoksa: **Add an Account...** → Apple ID ile giriş yap (ücretsiz)
5. **Bundle Identifier** alanı: `com.hearmeout.frontend`
   - Eğer "already in use" hatası alırsan sonu değiştir: `com.hearmeout.frontend.senin-adin`

Yeşil onay işareti görünüyorsa imzalama tamam demektir.

---

## 9. Simülatörde Çalıştırma

Simülatör en hızlı test yöntemidir, USB kablosu veya Apple Developer hesabı gerektirmez.

### Simülatör Başlat

Xcode üzerinden:
- Üst toolbar'da device seçici → **iPhone 15 Pro** (iOS 17.x) veya **iPhone 15** seç
- iOS 15.5+ simülatör seçilmeli (proje minimum 15.5 gerektirir)

Simülatör yoksa indirmek için:
```
Xcode → Settings → Platforms → iOS → (+) iOS Simulator
```

### Flutter ile Çalıştır

```bash
# Mevcut cihazları listele
flutter devices

# Örnek çıktı:
# iPhone 15 Pro (simulator) • XXXXXXXX-XXXX • ios • com.apple.CoreSimulator...

# Belirli simülatörde çalıştır
flutter run -d "iPhone 15 Pro"

# Ya da sadece:
flutter run
# (Tek cihaz/simülatör varsa otomatik seçer)
```

İlk derleme ~3-5 dakika sürer (TFLite ve MLKit derleniyor).
Sonraki çalıştırmalar çok daha hızlıdır.

> **Not:** Simülatörde **kamera çalışmaz** — iOS Simulator gerçek kameraya erişemez.
> Tanıma özelliğini test etmek için gerçek cihaz gereklidir.
> Diğer tüm özellikler (sözlük, auth, TTS, video oynatma) simülatörde çalışır.

---

## 10. Gerçek Cihazda Çalıştırma

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

---

## 11. Sık Karşılaşılan Hatalar

### `pod install` başarısız — "Unable to find a specification for TensorFlowLiteSelectTfOps"

```bash
pod repo update
pod install
```

### `pod install` başarısız — CocoaPods eski versiyon

```bash
sudo gem update cocoapods
pod install
```

### Apple Silicon'da `ffi` hatası

```bash
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```

### "No such module 'Flutter'" hatası Xcode'da

`Runner.xcworkspace` yerine `Runner.xcodeproj` açılmış olabilir. Kapat ve doğru olanı aç:

```bash
open ios/Runner.xcworkspace
```

### "Automatically manage signing requires a development team" hatası

Xcode → Runner → Signing & Capabilities → Team seç (Apple hesabıyla giriş yap).

### "The iOS deployment target is set to X.X, but the range of supported deployment target versions is 15.5 to Y.Y"

Xcode → Runner → Build Settings → `IPHONEOS_DEPLOYMENT_TARGET` → `15.5` olduğunu doğrula.
`pod install` sonrasında da `Pods/` içindeki tüm target'lar 15.5 olarak ayarlanmış olmalıdır (Podfile bunu otomatik yapar).

### "flutter: No connected devices"

```bash
flutter doctor
# Xcode ve Simulator kurulumunu kontrol et

# Simülatörü manuel başlat
open -a Simulator
flutter devices   # simülatör göründüğünü doğrula
```

### Uygulama Crash — TFLite custom ops hatası

`TensorFlowLiteSelectTfOps` pod'u yüklü değil demektir. Podfile'ı kontrol et, `pod install` çalıştır.

### Backend'e bağlanamıyor (Gerçek cihaz)

`.env` dosyasında `BASE_IP=localhost` yazıyorsa gerçek cihazda çalışmaz.
ngrok başlat ve `BASE_IP=xxxx.ngrok-free.dev`, `PORT=443` yap, ardından:

```bash
flutter run
# Hot reload ile .env değişikliği algılanmaz, tam yeniden başlatma gerekir
```

### Kamera izni reddedildi / açılmıyor

Uygulama ilk açılışta kamera izni ister. Reddedildiyse:

```
iPhone → Ayarlar → Gizlilik ve Güvenlik → Kamera → Hear Me Out → İzin Ver
```

---

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

---

## Notlar

- **Model dosyası:** `frontend/assets/models/sign_language_model_v2.tflite` — 226 sınıflı BiLSTM + Self-Attention modeli. Git'e commit edilmiştir, ayrıca indirmeye gerek yoktur.
- **Video dosyaları:** `backend/public/videos/` — 1988 MP4 dosyası Git'e commit edilmiştir.
- **Bundle ID:** `com.hearmeout.frontend` — Xcode imzalama için gerekirse sonu değiştirilebilir.
- **iOS minimum:** 15.5 — Bu sürümün altındaki cihazlarda uygulama çalışmaz.
