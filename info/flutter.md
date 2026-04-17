<!--
  UYGULAMA DURUMU (2026-04-17)
  ✅ Paketler:
      flutter_riverpod, go_router, google_fonts, dio, camera, tflite_flutter,
      permission_handler, google_mlkit_pose_detection, hand_detection, opencv_dart,
      flutter_tts, speech_to_text, shimmer, flutter_animate, share_plus
  ⬜ Paketler (spec'te var, henüz eklenmedi):
      hive_flutter (local storage), flutter_cache_manager (video cache)
  ✅ Feature-first mimari — recognition, home, profile, settings features mevcut
  ⬜ Eksik features: translator, dictionary, emergency (sadece PlaceholderScreen var)
  ✅ GoRouter ShellRoute — 5 tab, /home başlangıç noktası
  ⬜ Eksik rotalar: /splash, /onboarding, /settings, /emergency, /word/:id
  ✅ Normalization utility — core/utils/landmark_normalizer.dart
  ✅ Label mapper — core/utils/label_mapper.dart (CSV, 226 sınıf)
  ✅ TTS service + provider — core/services/tts_service.dart + core/providers/tts_provider.dart
  ✅ Camera lifecycle provider — core/providers/camera_lifecycle_provider.dart
  ✅ Settings provider — features/settings/presentation/providers/settings_provider.dart
-->

# 📱 HEAR ME OUT — Flutter Mimari Notları

## 1. Temel Stack
- **Framework:** Flutter (Dart).
- **Core Packages:** `flutter_riverpod` (State), `go_router` (Routing), `dio` (API), `hive_flutter` (Storage).
- **AI & OS Bridge:** `camera`, `tflite_flutter`, `google_mlkit_pose_detection`, `flutter_tts`, `speech_to_text`.
- **UI:** `shimmer`, `flutter_animate`.

## 2. Dizin Organizasyonu (Feature-First)
Her feature, Presentation, Domain, ve Data katmanlarını tek çatı altında barındırır.
```text
lib/
 ├─ core/
 │   ├─ constants/ (API_URL, strings, colors, asset yolları)
 │   ├─ theme/     (M3 theme configurations, glassmorphism statics)
 │   ├─ network/   (Dio instance)
 │   └─ utils/     
 ├─ shared/        (Global widgetlar, global tts, cache servisleri)
 ├─ navigation/    (GoRouter configuration)
 └─ features/
     ├─ recognition/   (Kamera, Tflite, LandmarkOverlay, Confidence buffer)
     ├─ translator/    (VideoPlayer, STT/Text Input UI)
     ├─ dictionary/    
     ├─ emergency/     (Sağlık kartı display modülü, Acil durum ekranı)
     ├─ profile/       
     ├─ home/          
     └─ settings/      
```

## 3. GoRouter Şeması
- `/splash` 
- `/onboarding`
- `/home` (Shell Route Root)
- `/dictionary` (Tab)
- `/çeviri` (Tab)
- `/translator` (Tab)
- `/profile` (Tab)
- `/settings`
- `/emergency`
- `/word/:id` 

## 4. Video Akışı & Backend Hosting Stratejisi
Projenin boyutunu devasa boyutlara ulaştırmamak adına **"Metin -> İşaret" çevirisinde kullanılan MP4/GIF videoları şuanlık tamamen Backend üzerinde tutulacaktır.** 
- **Streaming & Cache:** API'dan video linkleri istendikten sonra oynatıcıya verilir ve süreçte `flutter_cache_manager` devreye girer. Bu sayede ilk defa izlenen video Backend üzerinden aktarılır (stream edilir), eğer aynı kelime daha sonra tekrar aranırsa Backend'e çıkılmaz, direkt olarak cihazın local Cache (Önbellek) klasöründen oynatılarak veri tasarrufu yapılır.
- **Cache Temizliği:** Kullanıcı ayarlar üzerinden bu cache birikintilerini "Ayarlar -> Önbelleği Temizle" komutuyla boşaltabilir. Cache Manager default olarak LRU (Least Recently Used) algoritmasıyla doluluk limitine geldiğinde en eski izlenenleri (storage hit) temizler.
