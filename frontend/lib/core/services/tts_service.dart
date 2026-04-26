/// TTS servisi için soyut arayüz.
/// Gerçek implementasyon: TtsServiceImpl (flutter_tts tabanlı).
/// Test/stub implementasyonları bu arayüzü kullanarak enjekte edilebilir.
abstract interface class TtsService {
  Future<void> initialize({void Function(bool isSpeaking)? onSpeakingChanged});
  Future<void> speak(String word);
  Future<void> stop();
  void dispose();
}
