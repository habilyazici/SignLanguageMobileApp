# AI Pipeline -- Tam Teknik Dokümantasyon

Bu dosya, baska bir YZ asistanin hicbir ek baglam olmadan tum sistemi anlayabilmesi icin yazilmistir.
Her kararin gerekçesi dahildir.

---

## 0. Uygulamanin Amaci

Hear Me Out -- isitme engelliler icin Turkce isaretdili tanima uygulamasi.
Telefon kamerasi, kullanicinin elini/kolunu gercek zamanli izler, kelimeyi gosterir + sesli okur.
Model: offline, TFLite ile cihazda calisir, internet gerektirmez.

---

## 1. Buyuk Resim: Veri Akisi

```
[AUTSL videolari]
       |  feature_extraction_v2.py (Google Colab)
[.npy koordinat dosyalari]
       |  model_training_v2.py (Google Colab)
[sign_language_model_v2.tflite]
       |  kopyala -> frontend/assets/models/sign_language_model.tflite
[Flutter uygulamasi]
  CameraDataSource          -> ham kamera kareleri
  MlPipelineDatasource      -> her kareden 106-boyutlu koordinat vektoru
  RecognitionRepositoryImpl -> kayan pencere + hareket kapisi + inference tetikleme
  InferenceDatasource       -> resampling + normalizasyon + TFLite calistirma
  RecognitionNotifier       -> temporal smoothing + UI guncelleme
```

---

## 2. Veri Seti: AUTSL

- Nedir: Ankara Universitesi Turk Isaret Dili veri seti
- Icerik: ~28.000 video, 226 farkli TID kelimesi (her video = 1 kelime)
- Video formati: {id}_color.mp4, genellikle 512x512
- Cekim kosullari: Studyo, beyaz arka plan, kamera DOGRUDAN kisinin karsisinda
- Onemli: Bu ucuncu sahis bakisi. Gercek dunyada telefon farkli aci -> performans duzer.
- Klasorler: train/, val/, test/ + train_labels.csv vb.
- Etiket CSV: video_id,label (label = 0-225 tam sayi)
- Turkce etiketler: SignList_ClassId_TR_EN.csv -> id,tr_word,en_word

---

## 3. Kritik Sorun: Tool Mismatch (v1 -> v2 gecisinin nedeni)

Egitim (Python) ve cikarim (Flutter) FARKLI model agirlikları kullaniyor,
bu yuzden koordinat dagilimları uyusmuyordu:

```
v1 (ESKİ - Sorunlu):
  Python:  mediapipe.solutions.holistic.Holistic
  Flutter: hand_detection paketi -> hand_landmark_full.tflite
  Problem: Farkli model -> farkli koordinat dagilimi

v2 (YENİ - Dogru):
  Python:  mediapipe.tasks API - HandLandmarker + PoseLandmarker
  Flutter: hand_detection paketi -> hand_landmark_full.tflite
  Cozum:   HandLandmarker AYNI hand_landmark_full.tflite dosyasini kullaniyor
```

Sonuc: v1 modeli calisiyor ama dogruluğu dusuk (koordinat dagilimi farklı).
v2 ile egitim/inference koordinatlari eslesiyor.

---

## 4. Feature Vektoru: 106 Boyut

Her zaman adimi (video karesi) icin cikarilan vektor:

```
Indeks  0 ..  41  -> SAG EL  (21 landmark x 2 = 42 deger)
Indeks 42 ..  83  -> SOL EL  (21 landmark x 2 = 42 deger)
Indeks 84 .. 105  -> POSE    (11 secili landmark x 2 = 22 deger)
TOPLAM: 42 + 42 + 22 = 106
```

Her landmark icin yalnizca (x, y) -- z yok (asagida gerekce).

### El Landmark Sirasi (MediaPipe sabit)

```
0=bilek, 1-4=basparmak, 5-8=isaret, 9-12=orta, 13-16=yuzuk, 17-20=sorce
Bilek (nokta 0) normalizasyon referansidir.
```

### Secili Pose Noktalari

```python
POSE_INDICES = [0, 2, 5, 7, 8, 11, 12, 13, 14, 15, 16]
#   burun, sol_goz, sag_goz, sol_kulak, sag_kulak,
#   sol_omuz, sag_omuz, sol_dirsek, sag_dirsek, sol_bilek, sag_bilek
# Alt govde dahil degil.
# Pose[0] = burun -> normalizasyon referansi (indeks 84-85)
```

### Z Koordinati Neden Yok?

MediaPipe z, 2D goruntuden TAHMIN edilir (gercek derinlik degil).
AUTSL ve telefon kamerasinda guvenilmez. Gurultu arttirir, bilgi eklemez.

---

## 5. Handedness Convention (ONEMLI!)

### Anatomik Sag/Sol Nedir?

MediaPipe, elin SEKLINDEN (parmak yapisi) hangi el oldugunu belirler:
- "Right" = kisinin kendi sag eli (anatomik)
- "Left"  = kisinin kendi sol eli (anatomik)

Kamera goruntusu aynalanmissa: sag el ekranin solunda gorunur ama yine de "Right" doner.

### Slot Atamasi

```python
# Python:
offset = 0 if side == "Right" else 42
```

```dart
// Flutter:
final bool isAnatomicalRight = (hand.handedness == Handedness.right);
final bool useRightSlot = leftHandMode ? !isAnatomicalRight : isAnatomicalRight;
final offset = useRightSlot ? 0 : 42;
```

Her iki taraf ayni convention -> egitim/inference eslesiyor.

### Swap Denenip Reddedildi

isFlipped durumunda Handedness.left/right swap yapildi, test edildi,
tanima FENA bozuldu, geri alindi. Neden yanlis?
hand_detection paketi de anatomik handedness kullaniyor (Tasks API ile ayni).
Swap yapilmamali.

### Sol El Modu

leftHandMode=true -> slot atamasi tersine. Sol elini kullanan kisi,
modelin sag el slotuna kendi sol elini koyar. Simetrik isaretdili icin.

### Pozisyon Bazli Fallback

Sekil belirlenemezse x-koordinatina gore tahmin edilir.
Hem Tasks API hem hand_detection ayni -- tutarli, sorun degil.

---

## 6. Koordinat Cikarimi -- Python (feature_extraction_v2.py)

### Her Video Icin Yeni Detector

Tasks API VIDEO modu timestamp-bazli. Her video kendi serisini 0dan baslatir.
Bu yuzden her video icin yeni detector olusturulup kapatilir.

### FPS Hesabi

```python
fps = cap.get(cv2.CAP_PROP_FPS)
if fps <= 0: fps = 30.0  # float 0.0 kontrolu -- "fps or 30.0" CALISMAZ
ts_ms = int(frame_idx * (1000.0 / fps))
```

### Kare -> 106 Vektor

```python
frame = np.zeros(106)
# Eller: handedness -> "Right"/"Left" -> offset 0/42
#        lm.x, lm.y normalize [0,1]
# Pose:  POSE_INDICES secilmis 11 nokta, lm.x lm.y
```

### Video -> 60 Kare

```python
# Kisa: son kare tekrarlanir
# Uzun: np.linspace(0, n-1, 60, dtype=int) ile ornekleme
# Flutter _resampleBuffer ile BIREBIR AYNI
```

### Checkpoint

Her 100 videoda temp_X/y_{split}.npy yedeklenir. Kesintide devam eder.
Calistirma sirasi: Val -> Test -> Train

---

## 7. Model Egitimi -- Python (model_training_v2.py)

### Normalizasyon

Flutter LandmarkNormalizer ile BIREBIR AYNI:

```python
# Sag el (0..41):
rh[0::2] -= rh[0]; rh[1::2] -= rh[1]  # bilek merkezli
rh /= (max(abs(rh)) + 1e-6)            # max-abs olcekleme

# Sol el (42..83): ayni, lh[0]=sol bilek x
# Pose (84..105): ayni, pose[0]=burun x
# Sifir segment -> ATLA (el gorunmuyor)
# epsilon = 1e-6 (Flutter _eps=1e-6 ile ayni)
```

Neden: bilek/burun merkezleme = konum onemli degil, sekil onemli.
       max-abs = boyut onemli degil.

### Augmentation

```python
noise = normal(0, sigma=0.002)
X_aug = concat([X, X + noise])  # 2x veri
```

### Model Mimarisi

```
Input(1, 60, 106)
-> LayerNorm
-> BiLSTM(128, seq=True) + BN + Drop(0.4)
-> BiLSTM(64,  seq=True) + BN + Drop(0.4)
-> SelfAttention: et=tanh(x@W+b), at=softmax(et), out=sum(x*at)
-> Dense(256, relu) + BN + Drop(0.3)
-> Dense(128, relu) + BN
-> Dense(num_classes, softmax)
Output(1, num_classes)
```

BiLSTM: video = zaman serisi, her iki yonde bagimliligi yakalar.
SelfAttention: hangi karelerin onemli oldugunu ogrenilir.

### Egitim Parametreleri

```
Adam(lr=1e-3), EarlyStopping(patience=15), ReduceLROnPlateau(factor=0.5)
batch=64, max_epoch=100
num_classes veriden okunur -- hardcode degil
```

### TFLite Donusumu

```python
fixed_in = tf.keras.Input(shape=(60, 106), batch_size=1)  # mobil zorunlu
converter.optimizations = [DEFAULT]  # INT8 quantization
# Cikti: sign_language_model_v2.tflite
# Kopyala: frontend/assets/models/sign_language_model.tflite
```

---

## 8. Flutter Koordinat Cikarimi (MlPipelineDatasource)

### Kamera Formatlari

```
Android: NV21 (YUV, 3 plane) veya BGRA (1 plane)
iOS:     BGRA8888 (her zaman)
Android sensoru LANDSCAPE uretir (orn. 320x240 @ResolutionPreset.low)
```

### Sensor -> Model Koordinat Donusumu

Sorun: Sensor landscape, AUTSL 512x512 portrait.

```
sensorOrientation=90 (tipik Android arka kamera):
  modelX = 1.0 - sy/cropSide
  modelY = (sx - cropXOff)/cropSide

cropSide = min(320, 240) = 240   (kare kirpma)
cropXOff = (320-240)/2 = 40      (yatay kirpma ofseti)

On kamera (isFlipped=true): modelX = 1.0 - modelX
```

Hand Detection: once normalize mi piksel mi kontrol (<=1.05), sonra *320/*240, sonra donusum.
Pose (ML Kit): rotation metadata kendisi isler, portrait piksel koordinati doner.

---

## 9. Kayan Pencere ve Inference (RecognitionRepositoryImpl)

### Sabitler (RecognitionConstants)

```dart
windowSize=60, featureSize=106
windowMs=2000, minWindowMs=800, inferEvery=5
motionThreshold=0.025, motionWindowMs=1000
```

### Buffer

```dart
List<(int timestamp, List<double> features)> _timedBuffer
// Her karede: ekle + 2000ms eski sil
// Sonuc: son 2 saniyelik kareler
```

### Inference Tetik (4 kosulun tamami)

```
1. anyDetected == true
2. timeSinceLastMotion <= 1000ms
3. windowAge >= 800ms
4. _frameCounter % 5 == 0
```

### Hareket Hesabi

```dart
// SADECE el koordinatlari (0..83) -- pose kasitli haric
sum |current[i] - prev[i]| / 84  >= 0.025 -> hareket var
```

### No-Detection Grace Period

El kaybolunca 1 saniye beklenir, sonra buffer temizlenir.
Gecici kayiplarda (parmak bukusu vb.) buffer korunur.

---

## 10. TFLite Inference (InferenceDatasource)

### Resampling -> 60 Kare

```dart
// N < 60: son kare padding
// N > 60: src = (i*(n-1)/(60-1)).round() -- np.linspace karsiligi
```

### Normalizasyon

LandmarkNormalizer.normalizeWindow -> her kareye normalizeFrame
Python normalize_landmarks_pro ile birebir ayni matematik.

### TFLite Calistirma

```dart
// Input:  [1, 60, 106] Float32
// Output: [1, numClasses] Float32 softmax
// IsolateInterpreter -> UI thread bloklamaz
// numClasses model cikis tensorundan okunur
```

---

## 11. Temporal Smoothing (RecognitionNotifier)

```dart
// Ayni sinif streak sayar
// streak >= threshold VE score >= confidenceThreshold
// -> kelimeyi goster + TTS + haptic + cumlele ekle (max 6)
// -> 4 saniye sonra ekran sifirlanir
```

Ayarlanabilir: confidenceThreshold, stableFramesThreshold, targetFps,
               hapticEnabled, ttsEnabled, leftHandMode

---

## 12. Kritik Eslesmeler (Training <-> Inference)

Bunlardan biri yanlis olursa model duzgun calismaz:

```
Ozellik          | Python (egitim)              | Flutter (inference)
-----------------|------------------------------|--------------------------
Kare sayisi      | sequence_length=60           | windowSize=60
Feature boyutu   | 106                          | featureSize=106
Sag el slotu     | offset=0 ("Right")           | offset=0 (Handedness.right)
Sol el slotu     | offset=42 ("Left")           | offset=42
Pose indeksleri  | [0,2,5,7,8,11,12,13,14,15,16]| _poseIndices ayni
Resampling       | np.linspace                  | i*(n-1)/(60-1).round()
El referansi     | bilek=lm[0]                  | f[0] / f[42]
Pose referansi   | burun=pose[0]                | f[84]
Epsilon          | 1e-6                         | _eps=1e-6
```

---

## 13. Dosya Referanslari

```
frontend/lib/core/constants/recognition_constants.dart    <- windowMs, featureSize vb.
frontend/lib/core/utils/landmark_normalizer.dart           <- Python normalize eslegi
frontend/lib/features/recognition/data/datasources/
  camera_datasource.dart                                   <- Kamera acma/stream
  ml_pipeline_datasource.dart                              <- Koordinat cikarimi
  inference_datasource.dart                                <- Resampling + TFLite
frontend/lib/features/recognition/data/repositories/
  recognition_repository_impl.dart                         <- Buffer, motion gate
frontend/lib/features/recognition/presentation/
  providers/recognition_provider.dart                      <- Smoothing, TTS, UI
frontend/assets/models/sign_language_model.tflite          <- Aktif model
frontend/assets/labels/SignList_ClassId_TR_EN.csv           <- Etiketler

info/ai_kismi/feature_extraction_v2.py   <- Colab: AUTSL -> .npy
info/ai_kismi/model_training_v2.py       <- Colab: .npy -> .tflite
```

---

## 14. Bilinen Sinirlamalar

1. Veri seti/ortam farki: AUTSL studyo vs gercek dunya. Asilamaz sinir.
2. Bakis acisi farki: AUTSL onde, telefon elde farkli aci.
3. Iki elli karislikligi: Dev modda sag/sol degisimi gorunebilir. Normaldir.
4. Z yok: 2D tahmini derinlik guvenilmez, kasitli eklenmedi.
5. 226 kelime siniri: Yeni kelime = yeni veri + yeniden egitim.

---

## 15. Sonraki Adimlar

```
[TAMAM]  feature_extraction_v2.py yazildi, Colabda baslandi
[TAMAM]  Val, Test setleri tamamlandi
[DEVAM]  Train seti devam ediyor (~28k video, ~2-3 gun)
[BEKLER] Train bitince model_training_v2.py calistir
[BEKLER] sign_language_model_v2.tflite -> frontend/assets/models/sign_language_model.tflite
[BEKLER] Uygulamayi test et, dev modunda koordinatlar dogru mu?
[EKSIK]  Text-to-sign: backend/video hazir degil (kod stub modda)
[GELECEK] Parmak alfabesi: eksik TID videolari icin harf harf gosterim
```

