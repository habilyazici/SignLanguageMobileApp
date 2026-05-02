# Hear Me Out — Türk İşaret Dili Tanıma Uygulaması

Gerçek zamanlı Türk İşaret Dili (TİD) tanıma mobil uygulaması. Cihaz üzerinde çalışan derin öğrenme modeli (TFLite BiLSTM + Self-Attention) ile kamera görüntüsünden 226 farklı Türk işaret dilini internet bağlantısı gerektirmeden tanır.

> **Not:** Bu proje aktif geliştirme aşamasındadır.

---

## İçindekiler

- [Özellikler](#özellikler)
- [Proje Yapısı](#proje-yapısı)
- [Mimari](#mimari)
- [Tanıma Sistemi](#tanıma-sistemi-nasıl-çalışır)
- [ML Modeli](#ml-modeli)
- [Frontend Kurulum](#frontend-kurulum)
- [Backend Kurulum](#backend-kurulum)
- [API Referansı](#api-referansı)
- [Veritabanı Şeması](#veritabanı-şeması)
- [Ortam Değişkenleri](#ortam-değişkenleri)
- [Geliştirme Notları](#geliştirme-notları)
- [Teknoloji Stack](#teknoloji-stack)

---

## Özellikler

### İşaret Tanıma (Çevrimdışı)
Kamera görüntüsünden gerçek zamanlı TİD tanıma. Model tamamen cihaz üzerinde çalışır, internet gerekmez.
- 226 Türk İşaret Dili kelimesi (AUTSL veri seti)
- Paralel el + vücut landmark tespiti (MediaPipe)
- Temporal smoothing ile kararlı tahmin — tek gürültülü kare sonucu bozmaz
- Sol el modu, FPS limiti, güven eşiği gibi ayarlanabilir parametreler
- Geliştirici modu: landmark overlay, buffer doluluk, gecikme, top-3 tahmin

### Metin → İşaret Çevirisi
Girilen metni Türkçe sesli komutla veya klavyeyle alır, karşılık gelen işaret videolarını sırayla oynatır.
- Türkçe STT (speech_to_text) desteği
- Kelime kelime video oynatma
- Alternatif işaret gösterimi (birden fazla video versiyonu)

### Sözlük
226 işaretin video açıklamalı sözlüğü.
- Harf bazlı filtreleme (A-Z)
- Tam metin arama (Türkçe normalize)
- Video oynatma hız kontrolü (0.5x, 1x, 1.5x, 2x)
- Mobil veri tasarrufu modu
- Yer imi ekleme (giriş gerektirir)

### Kullanıcı Hesabı
- E-posta + şifre ile kayıt / giriş
- OTP ile şifre sıfırlama (Gmail SMTP)
- Profil güncelleme (ad, şifre)
- Hesap silme
- Misafir modu (kayıt olmadan temel özellikler)

### Geçmiş & Yer İmleri
- Tanınan her işaret otomatik kaydedilir
- Sıfır veri modu: geçmiş kaydı tamamen devre dışı
- Bulut senkronizasyonu toggle (açık/kapalı)
- Kelime bazlı yer imi; profil ekranından erişim

### Erişilebilirlik & Ayarlar
- TTS: tanınan işareti Türkçe seslendirir (flutter_tts)
- Açık / Koyu / Sistem teması
- Büyük metin modu
- Sol el modu (landmark aynalama)
- Gelişmiş AI ayarları: güven eşiği, kararlılık eşiği, hareket hassasiyeti

---

## Proje Yapısı

```
SignLanguage_MobileApp/
│
├── frontend/                        # Flutter mobil uygulama
│   ├── lib/
│   │   ├── main.dart                # Uygulama giriş noktası, provider overrides
│   │   ├── navigation/
│   │   │   ├── app_router.dart      # GoRouter route tanımları
│   │   │   └── scaffold_with_nav.dart  # Bottom nav + swipe navigasyon
│   │   ├── core/
│   │   │   ├── constants/           # API sabitleri, tanıma sabitleri
│   │   │   ├── network/             # HTTP istemci (api_client.dart)
│   │   │   ├── providers/           # Label, TTS, kamera lifecycle providers
│   │   │   ├── services/            # TTS servis implementasyonu
│   │   │   ├── theme/               # AppTheme renk paleti
│   │   │   └── utils/               # LandmarkNormalizer, sentinel pattern
│   │   └── features/
│   │       ├── recognition/         # Tanıma modülü (ML pipeline dahil)
│   │       ├── text_to_sign/        # Metin → işaret çevirisi
│   │       ├── dictionary/          # Sözlük & detay sayfası
│   │       ├── history/             # Geçmiş
│   │       ├── bookmarks/           # Yer imleri
│   │       ├── auth/                # Giriş, kayıt, şifre sıfırlama
│   │       ├── settings/            # Ayarlar
│   │       ├── home/                # Anasayfa
│   │       ├── profile/             # Profil & düzenleme
│   │       ├── onboarding/          # İlk açılış tanıtım ekranları
│   │       └── splash/              # Splash ekranı
│   ├── assets/
│   │   ├── models/
│   │   │   ├── sign_language_model_v2.tflite   # TFLite model
│   │   │   └── labels.csv                       # 226 sınıf etiket dosyası
│   │   └── ...
│   ├── .env.example
│   └── pubspec.yaml
│
├── backend/                         # Node.js + Express REST API
│   ├── src/
│   │   ├── index.ts                 # Express uygulaması, middleware zinciri
│   │   ├── config.ts                # Ortam değişkenleri doğrulama
│   │   ├── db.ts                    # Prisma istemcisi
│   │   ├── routes/
│   │   │   ├── auth.ts              # Kayıt, giriş, profil, şifre sıfırlama
│   │   │   ├── words.ts             # Kelime listesi, detay, manifest
│   │   │   ├── history.ts           # Geçmiş CRUD
│   │   │   └── bookmarks.ts         # Yer imi CRUD
│   │   ├── middleware/
│   │   │   └── requireAuth.ts       # JWT doğrulama middleware
│   │   └── services/
│   │       └── email.ts             # Gmail SMTP ile OTP gönderimi
│   ├── prisma/
│   │   ├── schema.prisma            # Veritabanı şeması
│   │   ├── seed.ts                  # Kelime veritabanı seed scripti
│   │   └── migrations/
│   ├── .env.example
│   └── tsconfig.json
│
└── ML/                              # Model eğitimi
    ├── feature_extraction_v2.py     # MediaPipe landmark çıkarma (Colab)
    └── model_training_v2.py         # BiLSTM + Self-Attention eğitimi (Colab)
```

---

## Mimari

### Frontend — Clean Architecture + Riverpod

Her feature modülü üç katmana ayrılır:

```
feature/
├── domain/
│   ├── entities/       # Saf Dart sınıfları, framework bağımlılığı yok
│   └── repositories/   # Abstract interface tanımları
├── data/
│   ├── datasources/    # API çağrıları, kamera, ML pipeline
│   └── repositories/   # Interface implementasyonları
└── presentation/
    ├── providers/       # Riverpod NotifierProvider'lar
    ├── screens/         # Widget ağacı
    └── widgets/         # Yeniden kullanılabilir bileşenler
```

**State Management:** Riverpod `NotifierProvider` kullanılır. Platform nesneleri (CameraController) `ValueNotifier` ile tutulur — her kare için Riverpod rebuild'i engellenir.

**Navigation:** GoRouter shell route ile 5 tab bottom nav. Swipe ile tab geçişi desteklenir. Translation ekranında iç tab swipe ile dış tab swipe birbirinden ayrılır (6 sanal pozisyon sistemi).

**Dependency Injection:** `main.dart` içinde `ProviderScope` override'ları ile SharedPreferences ve LabelRepository inject edilir.

### Backend — Katmanlı Express

```
İstek → Rate Limiter → CORS → Helmet → requireAuth (gerekirse) → Route Handler → Prisma → PostgreSQL
```

---

## Tanıma Sistemi Nasıl Çalışır

Tanıma pipeline'ı 4 aşamadan oluşur:

### 1. Kamera → ML Pipeline

Kamera 30 FPS'de görüntü akışı sağlar. Her kare `MlPipelineDatasource`'a iletilir. Pipeline meşgulse yeni kare `_pendingData`'ya yazılır (eski overwrite edilir) — stale kare işlenmez, her zaman en güncel kare alınır.

```
Kamera Karesi
    │
    ▼
NV21 Assembly (Android) / BGRA→BGR (iOS)
    │
    ├──► InputImage ──► MediaPipe Pose  ─┐
    │                                    ├── Future.wait (paralel)
    └──► OpenCV Mat ──► Hand Isolate   ─┘
              │
              ▼
    Feature Vektörü [106 boyut]
    [0..41]  = Sağ el (21 nokta × 2)
    [42..83] = Sol el (21 nokta × 2)
    [84..105]= Vücut (11 landmark × 2)
```

Pose ve el tespiti `Future.wait` ile paralel çalıştırılır. Toplam gecikme `max(pose_ms, hand_ms)` olur.

### 2. Kayan Zaman Penceresi

ML sonuçları `RecognitionRepositoryImpl` içinde 2000ms'lik kayan bir tampon (timed buffer) ile biriktirilir. Eski kareler otomatik temizlenir. El tespiti edilemeyen durumlarda 1 saniyelik grace period uygulanır — 1-2 kare kaybolduğunda buffer bozulmaz.

**Hareket kapısı:** Önceki kare ile mutlak koordinat farkı hesaplanır. Eşiğin (varsayılan 0.025) altındaki değişimler hareketsiz kabul edilir ve inference tetiklenmez. Bu sayede kameraya statik tutulan el gereksiz işlem yaptırmaz.

### 3. Inference Throttling

Zaman tabanlı throttle uygulanır: son inference'tan bu yana en az 200ms geçmişse yeni inference başlatılır (5 inference/saniye). Frame sayısı bazlı throttle kullanılmaz — cihaz hızından bağımsızdır.

Inference öncesi `_resampleBuffer` çağrılır: gerçek buffer (N kare) → 60 kareye yeniden örneklenir.
- `N < 60`: linspace upsampling
- `N > 60`: linspace downsampling (Python `dtype=int` ile birebir aynı)

### 4. Temporal Smoothing

Tek gürültülü kare sonucu bozmaz. Aynı sınıf ayarlanmış eşik kadar ardışık inference'ta görülmezse ekrana yansımaz. Yanlış sınıf görüldüğünde streak sıfıra düşmez — yavaşça azalır (soft decay). Bu sayede Gaussian gürültü augmentation ile eğitilen modelin toleransı korunur.

```
Inference Sonucu
    │
    ▼
Güven Eşiği Kontrolü (varsayılan %75)
    │
    ▼
Streak Sayacı (aynı sınıf tekrarı)
    │
    ▼
Kararlılık Eşiği (varsayılan 3 ardışık)
    │
    ▼
Ekran Güncelleme + TTS + Geçmiş Kaydı
```

### Cihaz Performans Referansı

| Cihaz | Hand Detection | 2s Buffer Dolumu |
|-------|---------------|-----------------|
| Samsung A32 (Helio G80) | ~130ms | ~10-13 kare |
| Redmi Note 12 / Galaxy A53 | ~65ms | ~25-30 kare |
| Galaxy A52s / Pixel 6a | ~35ms | ~40-50 kare |
| Flagship (S24 / Pixel 9) | ~12ms | ~55-60 kare |

---

## ML Modeli

### Veri Seti

AUTSL (Ankara University Turkish Sign Language) veri seti kullanılmıştır.
- 226 kelime sınıfı
- Her sınıf için birden fazla video kaydı (eğitim/doğrulama/test ayrımı mevcut)

### Özellik Çıkarma

`feature_extraction_v2.py` her video için:

1. OpenCV ile kare kare okuma
2. Her kare için MediaPipe Pose + Hand tespiti (paralel)
3. 21 el noktası × 2 el × 2 koordinat = 84 boyut + 11 vücut noktası × 2 koordinat = 22 boyut → **106 boyutlu vektör**
4. Koordinat normalizasyonu: kare kırpma + aspect-ratio korumalı ölçekleme, kamera yönü düzeltmesi
5. Video uzunluğu → 60 kareye yeniden örnekleme (linspace, uniform)
6. `.npy` dosyası olarak kayıt

### Normalizasyon

Koordinatlar `LandmarkNormalizer` ile eğitim ile birebir aynı şekilde normalize edilir. Python eğitim kodu ile Dart inference kodu aynı formülü kullanır — dağılım farkı olmaz.

### Model Mimarisi

```
Girdi: [batch, 60, 106]
    │
    ▼
BiLSTM (128 birim, her yönde 64) — temporal bağlamı öğrenir
    │
    ▼
Self-Attention — uzun mesafeli kare ilişkilerini yakalar
    │
    ▼
Dropout + Dense
    │
    ▼
Softmax [226 sınıf]
```

### Veri Artırma (Augmentation)

Modeli aşırı öğrenmeden korumak ve cihaz farklılıklarına karşı dayanıklı kılmak için:
- **Ölçek:** ±%10 koordinat ölçekleme
- **Zaman kaydırma:** ±3 kare öteleme
- **Kare maskeleme:** 1-3 rastgele kare sıfırlama
- **Gaussian gürültü:** σ=0.002

### Model → Uygulamaya Taşıma

```bash
# Eğitim tamamlandıktan sonra
cp sign_language_model_v2.tflite ../frontend/assets/models/
cp labels.csv ../frontend/assets/models/
```

Sınıf sayısı modelin çıkış tensor shape'inden otomatik okunur — `labels.csv` etiketleri ile eşleşmelidir.

---

## Frontend Kurulum

### Gereksinimler

- Flutter SDK 3.x+
- Dart SDK 3.10.8+
- Android SDK 21+ (Android 5.0) veya iOS 13+
- Backend sunucusu erişilebilir olmalı

### Adımlar

```bash
cd frontend

# Bağımlılıkları yükle
flutter pub get

# .env dosyasını oluştur
cp .env.example .env
```

`.env` dosyasını düzenle:

```env
BASE_IP=your-ngrok-domain.ngrok-free.dev
PORT=443
```

```bash
# Android için çalıştır
flutter run

# iOS için çalıştır
flutter run -d ios

# Release build (Android APK)
flutter build apk --release

# Release build (iOS IPA)
flutter build ipa --release
```

### Klasör Yapısı Detayı

```
lib/
├── main.dart
│     SharedPreferences ve LabelRepository uygulaması başlatılır,
│     ProviderScope override'ları ile inject edilir.
│
├── navigation/
│     app_router.dart   — Tüm route tanımları (GoRouter)
│     scaffold_with_nav — Bottom nav, 6-pozisyon swipe sistemi
│
├── core/
│   ├── constants/
│   │     api_constants.dart         — BASE_URL, ngrok headers
│   │     recognition_constants.dart — windowMs, minWindowMs, motionThreshold vb.
│   ├── network/
│   │     api_client.dart — ref.apiGet/apiPost/apiDelete extension'ları,
│   │                       401'de otomatik çıkış
│   ├── utils/
│   │     landmark_normalizer.dart — Koordinat normalizasyon (eğitimle birebir)
│   └── services/
│         tts_service.dart / tts_service_impl.dart — Türkçe TTS
│
└── features/recognition/
    ├── data/datasources/
    │     camera_datasource.dart       — Kamera init, stream, geçiş
    │     ml_pipeline_datasource.dart  — Pose+Hand paralel tespiti, NV21 assembly
    │     inference_datasource.dart    — TFLite IsolateInterpreter, resample
    ├── data/repositories/
    │     recognition_repository_impl.dart — Buffer yönetimi, hareket kapısı,
    │                                         inference throttle, stream'ler
    └── presentation/
          providers/recognition_provider.dart — Temporal smoothing, TTS, geçmiş
          screens/recognition_screen.dart     — Kamera önizleme, sonuç panel
```

---

## Backend Kurulum

### Gereksinimler

- Node.js 18+
- PostgreSQL 14+
- Gmail hesabı (şifre sıfırlama için; opsiyonel)

### Adımlar

```bash
cd backend

# Bağımlılıkları yükle
npm install

# .env dosyasını oluştur
cp .env.example .env
```

`.env` dosyasını düzenle (tüm alanlar için `.env.example`'a bak).

```bash
# Veritabanı tablolarını oluştur
npx prisma migrate dev --name init

# 226 kelimeyi veritabanına yükle (words.json gerekli)
npx prisma db seed

# TypeScript derleme + çalıştır
npm run dev          # Geliştirme (ts-node-dev, hot reload)
npm run build        # Production build
npm start            # Production (dist/ klasöründen)
```

### Dış Erişim (ngrok)

Backend lokal çalışırken mobil uygulama HTTPS üzerinden bağlanmalıdır.

```bash
# ngrok ile tünel aç
ngrok http --domain=your-domain.ngrok-free.dev 3000

# .env içinde BASE_URL'i güncelle
BASE_URL=https://your-domain.ngrok-free.dev

# frontend/.env içinde BASE_IP'yi güncelle
BASE_IP=your-domain.ngrok-free.dev
```

---

## API Referansı

Tüm yanıtlar JSON formatındadır. Korumalı endpoint'lere erişmek için `Authorization: Bearer <token>` header'ı gereklidir.

### Auth

#### `POST /api/auth/register`
```json
// İstek
{ "name": "Ad Soyad", "email": "kullanici@ornek.com", "password": "sifre123" }

// Yanıt 201
{ "token": "eyJ...", "user": { "id": "clx...", "name": "Ad Soyad", "email": "..." } }
```

#### `POST /api/auth/login`
```json
// İstek
{ "email": "kullanici@ornek.com", "password": "sifre123" }

// Yanıt 200
{ "token": "eyJ...", "user": { "id": "clx...", "name": "Ad Soyad", "email": "..." } }
```

#### `PUT /api/auth/profile` — Auth gerekli
```json
// İstek (tüm alanlar opsiyonel)
{ "name": "Yeni Ad", "currentPassword": "eski", "newPassword": "yeni123" }

// Yanıt 200
{ "name": "Yeni Ad" }
```

#### `DELETE /api/auth/profile` — Auth gerekli
```
Yanıt 204 No Content
```

#### `POST /api/auth/forgot-password`
```json
// İstek
{ "email": "kullanici@ornek.com" }

// Yanıt 200 (e-posta bulunamasa bile aynı yanıt — bilgi sızdırmaz)
{ "message": "Sıfırlama kodu e-posta adresinize gönderildi." }
```

#### `POST /api/auth/reset-password`
```json
// İstek
{ "email": "kullanici@ornek.com", "code": "123456", "newPassword": "yeni123" }

// Yanıt 200
{ "message": "Şifreniz başarıyla sıfırlandı." }
```

---

### Kelimeler

#### `GET /api/words?page=1&limit=50&letter=A&q=merhaba`
```json
// Yanıt 200
{
  "data": [
    {
      "id": 1,
      "word": "MERHABA",
      "letter": "M",
      "meaningEn": "Hello",
      "videoUrl": "https://..."
    }
  ],
  "total": 226,
  "page": 1,
  "pages": 5
}
```

#### `GET /api/words/:id`
```json
// Yanıt 200
{
  "id": 1,
  "word": "MERHABA",
  "letter": "M",
  "meaningEn": "Hello",
  "videoUrl": "https://...",
  "allVideos": ["https://...", "https://..."]
}
```

#### `GET /api/words/manifest`
Model tarafından kullanılan `kelime → videoUrl` eşlem tablosu. 5 dakika önbelleklenir.
```json
// Yanıt 200
{ "words": { "MERHABA": "https://...", "GÜNAYDIN": "https://..." } }
```

---

### Geçmiş — Auth gerekli

#### `GET /api/history?limit=20&offset=0`
```json
// Yanıt 200
[
  { "id": "clx...", "text": "MERHABA", "createdAt": "2026-04-30T10:00:00Z" }
]
```

#### `POST /api/history`
```json
// İstek
{ "text": "MERHABA" }

// Yanıt 201
{ "id": "clx...", "text": "MERHABA", "createdAt": "2026-04-30T10:00:00Z" }
```

#### `DELETE /api/history`
```
Yanıt 204 No Content — kullanıcının tüm geçmişi silinir
```

---

### Yer İmleri — Auth gerekli

#### `GET /api/bookmarks`
```json
// Yanıt 200
[
  { "wordId": 1, "word": "MERHABA", "letter": "M", "videoUrl": "https://..." }
]
```

#### `POST /api/bookmarks`
```json
// İstek
{ "wordId": 1 }

// Yanıt 201
{ "wordId": 1 }
```

#### `DELETE /api/bookmarks/:wordId`
```
Yanıt 204 No Content
```

---

## Veritabanı Şeması

```prisma
model User {
  id           String     @id @default(cuid())
  email        String     @unique         // Giriş için benzersiz
  name         String
  passwordHash String                     // bcrypt, 10 salt round
  createdAt    DateTime   @default(now())
  history      History[]
  bookmarks    Bookmark[]
}

model Word {
  id            Int        @id @default(autoincrement())
  wordId        String     @unique        // AUTSL orijinal ID
  word          String                    // Türkçe kelime
  letter        String                    // İlk harf (filtreleme için)
  meaningEn     String?
  videoFilename String?                   // Lokal video dosyası adı
  cdnVideoUrl   String                    // CDN / ngrok video URL
  allVideos     String[]                  // Alternatif video URL'leri
  detailUrl     String?
  bookmarks     Bookmark[]

  @@index([letter])
  @@index([word])                         // Substring arama için
}

model History {
  id        String   @id @default(cuid())
  userId    String
  text      String
  createdAt DateTime @default(now())
  user      User     @relation(onDelete: Cascade)

  @@index([userId])
  @@index([userId, createdAt])            // Sayfalı sorgular için
}

model Bookmark {
  id        String   @id @default(cuid())
  userId    String
  wordId    Int
  createdAt DateTime @default(now())
  user      User     @relation(onDelete: Cascade)
  word      Word     @relation(onDelete: Cascade)

  @@unique([userId, wordId])              // Aynı kelime iki kez yer imine eklenemez
  @@index([userId])
}

model PasswordResetToken {
  id        String   @id @default(cuid())
  email     String
  codeHash  String                        // bcrypt ile hash'lenmiş 6 haneli OTP
  expiresAt DateTime                      // 15 dakika geçerlilik
  used      Boolean  @default(false)
  createdAt DateTime @default(now())

  @@index([email, used, expiresAt])       // Şifre sıfırlama sorgusunu hızlandırır
}
```

---

## Ortam Değişkenleri

### Frontend (`frontend/.env`)

| Değişken | Açıklama | Örnek |
|----------|----------|-------|
| `BASE_IP` | Backend domain (protokol hariç) | `abc123.ngrok-free.dev` |
| `PORT` | Backend port (ngrok için 443) | `443` |

### Backend (`backend/.env`)

| Değişken | Zorunlu | Açıklama | Örnek |
|----------|---------|----------|-------|
| `PORT` | Hayır | Sunucu portu | `3000` |
| `NODE_ENV` | Hayır | Ortam | `development` |
| `JWT_SECRET` | **Evet** | JWT imza anahtarı | `güçlü-rastgele-anahtar` |
| `DATABASE_URL` | **Evet** | PostgreSQL bağlantı dizesi | `postgresql://user:pass@localhost:5432/db` |
| `BASE_URL` | Hayır | Video URL'leri için base | `https://abc.ngrok-free.dev` |
| `SMTP_USER` | Hayır | Gmail adresi (şifre sıfırlama) | `ornek@gmail.com` |
| `SMTP_PASS` | Hayır | Gmail uygulama şifresi | `xxxx xxxx xxxx xxxx` |
| `ALLOWED_ORIGINS` | Hayır | CORS origin listesi (virgüllü) | `https://myapp.com` |

> **Güvenlik:** `JWT_SECRET` için production'da `openssl rand -hex 64` ile üretilmiş değer kullanın. `.env` dosyasını asla git'e commit etmeyin.

---

## Geliştirme Notları

### Tanıma Sabitleri (`recognition_constants.dart`)

| Sabit | Değer | Açıklama |
|-------|-------|----------|
| `windowSize` | 60 | Model girdi kare sayısı |
| `featureSize` | 106 | Kare başına özellik boyutu |
| `windowMs` | 2000 | Kayan pencere süresi (ms) |
| `minWindowMs` | 600 | İlk inference için minimum bekleme |
| `inferIntervalMs` | 200 | İki inference arası minimum süre |
| `motionThreshold` | 0.025 | Hareket kapısı eşiği |
| `motionWindowMs` | 1000 | Son hareketten sonra inference süresi |
| `stableFrames` | 5 | Varsayılan kararlılık eşiği |

### Kamera Koordinat Sistemi

Android ve iOS farklı kamera formatları kullanır:
- **Android:** YUV_420_888 (3 plane) → NV21'e dönüştürülür
- **iOS:** BGRA8888 (tek plane) → BGR'ye dönüştürülür

Sensör 90°/270° döndürüldüğünde genişlik/yükseklik değerleri yer değiştirir. Tüm koordinat hesaplamaları (`_calcCropSide`, `_sXToMX`, `_sYToMY`) bu durumu ele alır.

### Sol El Modu

`leftHandMode = true` olduğunda el etiketleri aynılanır: sağ el landmark'ları sol ele, sol el landmark'ları sağa yazılır. Model hep baskın elin [0..41] kanalında olduğunu varsayar.

### Yeni Kelime Ekleme

1. AUTSL verisine yeni video ekle
2. `feature_extraction_v2.py` ile özellik çıkar
3. `model_training_v2.py` ile modeli yeniden eğit
4. `sign_language_model_v2.tflite` ve `labels.csv` dosyalarını güncelle
5. Backend `words` tablosuna kaydı ekle / `prisma db seed` güncelle

---

## Teknoloji Stack

| Katman | Teknoloji | Versiyon | Amaç |
|--------|-----------|----------|------|
| Mobil | Flutter | 3.x | Çapraz platform UI |
| State | flutter_riverpod | ^3.3.1 | Reaktif state yönetimi |
| Navigation | go_router | ^17.2.1 | Declarative routing |
| ML Inference | tflite_flutter | ^0.12.1 | BiLSTM model, IsolateInterpreter |
| Pose Tespiti | google_mlkit_pose_detection | ^0.14.1 | MediaPipe BlazePose |
| El Tespiti | hand_detection | ^2.0.8 | MediaPipe Hand Landmarks |
| Görüntü İşleme | opencv_dart | ^2.2.1 | NV21/BGRA → BGR dönüşümü |
| TTS | flutter_tts | ^4.2.0 | Türkçe seslendirme |
| STT | speech_to_text | ^7.0.0 | Sesli metin girişi |
| Video | video_player | ^2.9.3 | İşaret videosu oynatma |
| HTTP | http | ^1.3.0 | REST API istemcisi |
| Backend | Express + TypeScript | 5.x | REST API sunucusu |
| ORM | Prisma | 6.x | Tip güvenli veritabanı erişimi |
| Veritabanı | PostgreSQL | 14+ | İlişkisel veri |
| Auth | jsonwebtoken + bcrypt | — | JWT (7 gün), bcrypt (10 round) |
| Güvenlik | helmet, cors, express-rate-limit | — | HTTP güvenlik başlıkları |
| Model Eğitimi | TensorFlow/Keras | — | BiLSTM + Self-Attention |
| Özellik Çıkarma | MediaPipe Python | — | Landmark tespiti (Colab) |
