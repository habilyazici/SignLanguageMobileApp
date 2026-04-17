<!--
  UYGULAMA DURUMU: ✅ TAMAMLANDI (2026-04-17)
  Bu dosya yalnızca referans belgesidir — canlı kod değildir.
  Gerçek implementasyon: frontend/lib/core/utils/landmark_normalizer.dart
  Kullanım yeri: recognition_provider.dart → _runInference() → LandmarkNormalizer.normalizeWindow()
  Python karşılığı (model_training.py normalize_landmarks_pro) ile birebir eşleştiği doğrulandı.
-->

/// HEAR ME OUT - Flutter AI Preprocessing (Normalization)
/// 
/// Python'daki `normalize_landmarks_pro` fonksiyonunun Dart dilindeki birebir karşılığıdır.
/// TFLite modelinin doğru tahmin yapabilmesi için kamera karelerinin, eğitimdeki
/// veriyle tamamen aynı matematiksel formata (normalizasyona) sokulması zorunludur.

class LandmarkNormalizer {
  /// Sabit Değer
  static const double epsilon = 1e-6; // Sıfıra bölme hatasını engellemek için

  /// Eğitilmiş model her karede (frame) tam olarak 106 koordinatlık veri bekler:
  /// - 0..41   : Sağ el (21 nokta * x,y)
  /// - 42..83  : Sol el (21 nokta * x,y)
  /// - 84..105 : Üst vücut/Pose (11 nokta * x,y)
  static List<double> normalizeFramePro(List<double> frame) {
    if (frame.length != 106) {
      throw ArgumentError('Bir karenin koordinat dizisi tam olarak 106 uzunluğunda olmalıdır (Şu an: ${frame.length}).');
    }

    // Orijinal veriyi bozmamak için kopyasını oluşturuyoruz
    List<double> normalized = List<double>.from(frame);

    // 1. SAĞ EL HİZALAMA VE ÖLÇEKLENDİRME (0 - 41. indeksler)
    if (!_isAllZero(normalized, 0, 42)) {
      // a. Bileğe Göre Merkezle (Bilek noktası: indeks 0 ve 1)
      double wristX = normalized[0];
      double wristY = normalized[1];

      for (int i = 0; i < 42; i += 2) {
        normalized[i] -= wristX;       // X ekseni
        normalized[i + 1] -= wristY;   // Y ekseni
      }

      // b. Ölçeklendir (Max-Abs Scaling)
      double maxAbs = _getMaxAbs(normalized, 0, 42);
      double scale = maxAbs + epsilon;

      for (int i = 0; i < 42; i++) {
        normalized[i] /= scale;
      }
    }

    // 2. SOL EL HİZALAMA VE ÖLÇEKLENDİRME (42 - 83. indeksler)
    if (!_isAllZero(normalized, 42, 42)) {
      // a. Bileğe Göre Merkezle (Bilek noktası: indeks 42 ve 43)
      double wristX = normalized[42];
      double wristY = normalized[43];

      for (int i = 0; i < 42; i += 2) {
        normalized[42 + i] -= wristX;
        normalized[43 + i] -= wristY;
      }

      // b. Ölçeklendir (Max-Abs Scaling)
      double maxAbs = _getMaxAbs(normalized, 42, 42);
      double scale = maxAbs + epsilon;

      for (int i = 0; i < 42; i++) {
        normalized[42 + i] /= scale;
      }
    }

    // 3. POSE HİZALAMA (Omuz genişliğine göre) (84 - 105. indeksler)
    if (!_isAllZero(normalized, 84, 22)) {
      // a. Burna Göre Merkezle (Burun noktası: indeks 84 ve 85)
      double noseX = normalized[84];
      double noseY = normalized[85];

      for (int i = 0; i < 22; i += 2) {
        normalized[84 + i] -= noseX;
        normalized[85 + i] -= noseY;
      }

      // b. Ölçeklendir (Max-Abs Scaling)
      double maxAbs = _getMaxAbs(normalized, 84, 22);
      double scale = maxAbs + epsilon;

      for (int i = 0; i < 22; i++) {
        normalized[84 + i] /= scale;
      }
    }

    return normalized;
  }

  /// 60 karelik tam bir Sliding Window listesini topluca normalize eder
  /// Input boyutu: 60 adet `List<double>` (her biri 106 uzunluğunda)
  /// Output boyutu: Optimize edilmiş, normalize edilmiş `List<List<double>>`
  static List<List<double>> normalizeWindowPro(List<List<double>> window) {
    if (window.isEmpty || window.length != 60) {
      throw ArgumentError('Pencere boyutu(window size) tam olarak 60 kare olmalıdır.');
    }
    
    return window.map((frame) => normalizeFramePro(frame)).toList();
  }

  // --- Yardımcı Metotlar ---

  /// Verilen aralıktaki tüm değerlerin 0.0 olup olmadığını kontrol eder
  /// Python'daki `not np.all(arr == 0)` kodu yerine geçer
  static bool _isAllZero(List<double> list, int start, int length) {
    for (int i = 0; i < length; i++) {
      if (list[start + i] != 0.0) return false;
    }
    return true;
  }

  /// Verilen aralıktaki en büyük mutlak (absolute) değeri bulur
  /// Python'daki `np.max(np.abs(arr))` kodu yerine geçer
  static double _getMaxAbs(List<double> list, int start, int length) {
    double max = 0.0;
    for (int i = 0; i < length; i++) {
      double absVal = list[start + i].abs();
      if (absVal > max) {
        max = absVal;
      }
    }
    return max;
  }
}
