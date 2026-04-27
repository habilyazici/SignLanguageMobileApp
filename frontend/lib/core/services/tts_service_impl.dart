import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TTS Servisi — Türkçe kelime seslendirme
//
// Kullanım: Her yeni onaylanan işaret kelimesi anında okunur (kelime kelime).
// Ayarlar ekranından ttsEnabled toggle edilebilir.
// ─────────────────────────────────────────────────────────────────────────────

class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  // TTS hazır olmadan speak() çağrılırsa kelimeyi beklet; hazır olunca çal.
  String? _pendingWord;

  @override
  Future<void> initialize({void Function(bool isSpeaking)? onSpeakingChanged}) async {
    try {
      if (Platform.isAndroid) {
        await _tts.setQueueMode(1); // FLUSH — yeni kelime eskiyi keser
      }

      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // getLanguages dönüş tipi platforma göre değişebilir, güvenli kontrol.
      final dynamic rawLangs = await _tts.getLanguages;
      final languages = rawLangs is List ? rawLangs : null;
      if (languages != null && !languages.contains('tr-TR')) {
        await _tts.setLanguage('tr');
      }

      if (onSpeakingChanged != null) {
        _tts.setStartHandler(() => onSpeakingChanged(true));
        _tts.setCompletionHandler(() => onSpeakingChanged(false));
        _tts.setCancelHandler(() => onSpeakingChanged(false));
        _tts.setErrorHandler((_) => onSpeakingChanged(false));
      }

      _ready = true;
      if (kDebugMode) debugPrint('✅ TTS hazır (tr-TR)');

      if (_pendingWord != null) {
        final word = _pendingWord!;
        _pendingWord = null;
        await _tts.speak(word);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ TTS başlatma hatası: $e');
    }
  }

  /// Yeni kelime geldiğinde çağrılır — önceki konuşmayı keserek başlar.
  @override
  Future<void> speak(String word) async {
    if (word.isEmpty) return;
    if (!_ready) {
      // TTS henüz hazır değil — en son kelimeyi beklet (eski bekleme iptal).
      _pendingWord = word;
      return;
    }
    try {
      await _tts.stop();
      await _tts.speak(word);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ TTS speak hatası: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ TTS stop hatası: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
