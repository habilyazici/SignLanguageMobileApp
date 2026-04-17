import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Uygulama geneli ayarlar
// ─────────────────────────────────────────────────────────────────────────────

class AppSettings {
  /// MaterialApp tema modu
  final ThemeMode themeMode;

  /// Kamera ekranında landmark overlay + istatistik paneli
  final bool devMode;

  /// İşaret tanındığında kelimeyi Türkçe seslendir (TTS)
  final bool ttsEnabled;

  /// Metin→İşaret ekranında sesli giriş (STT)
  final bool sttEnabled;

  /// 8 ardışık kare = 1 kelime (temporal smoothing)
  final bool temporalSmoothingEnabled;

  const AppSettings({
    this.themeMode               = ThemeMode.system,
    this.devMode                 = false,
    this.ttsEnabled              = true,
    this.sttEnabled              = true,
    this.temporalSmoothingEnabled = true,   // varsayılan: açık
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? devMode,
    bool? ttsEnabled,
    bool? sttEnabled,
    bool? temporalSmoothingEnabled,
  }) =>
      AppSettings(
        themeMode:                themeMode                ?? this.themeMode,
        devMode:                  devMode                  ?? this.devMode,
        ttsEnabled:               ttsEnabled               ?? this.ttsEnabled,
        sttEnabled:               sttEnabled               ?? this.sttEnabled,
        temporalSmoothingEnabled: temporalSmoothingEnabled ?? this.temporalSmoothingEnabled,
      );
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    ref.keepAlive();
    return const AppSettings();
  }

  void setThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  void toggleDevMode() =>
      state = state.copyWith(devMode: !state.devMode);

  void toggleTts() =>
      state = state.copyWith(ttsEnabled: !state.ttsEnabled);

  void toggleStt() =>
      state = state.copyWith(sttEnabled: !state.sttEnabled);

  void toggleTemporalSmoothing() =>
      state = state.copyWith(
        temporalSmoothingEnabled: !state.temporalSmoothingEnabled,
      );
}
