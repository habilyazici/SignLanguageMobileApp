import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Kamera yaşam döngüsü — navigasyon katmanı ile recognition arasındaki köprü
//
// ScaffoldWithNav bu provider'a yazar (true = kamera ekranı aktif).
// RecognitionNotifier bu provider'ı dinleyerek image stream'i başlatır/durdurur.
// Böylece navigation katmanı recognition feature'ını doğrudan import etmez.
// ─────────────────────────────────────────────────────────────────────────────

final cameraActiveProvider =
    NotifierProvider<CameraActiveNotifier, bool>(CameraActiveNotifier.new);

class CameraActiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive({required bool active}) => state = active;
}
