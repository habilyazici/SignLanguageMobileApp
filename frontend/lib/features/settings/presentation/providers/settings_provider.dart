import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum'lar
// ─────────────────────────────────────────────────────────────────────────────

enum AppTextSize {
  standard,   // varsayılan
  large,      // Büyük
  extraLarge, // Ekstra Büyük
}

enum ConfidenceLevel {
  low,    // %70 — daha duyarlı, daha fazla yanlış pozitif
  medium, // %80 — dengeli (varsayılan)
  high,   // %90 — daha katı, daha az tanıma
}

enum VideoQuality {
  high,      // 720p
  dataSaver, // 360p
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSettings veri modeli
// ─────────────────────────────────────────────────────────────────────────────

class AppSettings {
  // ── Görünüm ──────────────────────────────────────────────────────────────
  final ThemeMode themeMode;
  final AppTextSize textSize;
  final bool leftHandMode;

  // ── Kamera & Yapay Zeka ───────────────────────────────────────────────────
  final ConfidenceLevel confidenceLevel;
  final bool fpsLimitEnabled;   // 30fps → 15fps
  final bool hapticEnabled;     // Titreşim geri bildirimi
  final bool temporalSmoothingEnabled;

  // ── Veri & Video (backend hazır olduğunda aktif olacak) ───────────────────
  final bool cellularVideoDisabled;
  final VideoQuality videoQuality;

  // ── Gizlilik & Veri ───────────────────────────────────────────────────────
  final bool zeroDataMode;      // Çeviri geçmişini kaydetme
  final bool cloudSyncEnabled;  // Ayarları buluta senkronize et

  // ── Ses ───────────────────────────────────────────────────────────────────
  final bool ttsEnabled;
  final bool sttEnabled;

  // ── Geliştirici ───────────────────────────────────────────────────────────
  final bool devMode;

  const AppSettings({
    this.themeMode               = ThemeMode.system,
    this.textSize                = AppTextSize.standard,
    this.leftHandMode            = false,
    this.confidenceLevel         = ConfidenceLevel.medium,
    this.fpsLimitEnabled         = false,
    this.hapticEnabled           = true,
    this.temporalSmoothingEnabled = true,
    this.cellularVideoDisabled   = false,
    this.videoQuality            = VideoQuality.high,
    this.zeroDataMode            = false,
    this.cloudSyncEnabled        = false,
    this.ttsEnabled              = true,
    this.sttEnabled              = true,
    this.devMode                 = false,
  });

  /// Confidence level'ı TFLite threshold değerine dönüştürür.
  double get confidenceThreshold => switch (confidenceLevel) {
    ConfidenceLevel.low    => 0.70,
    ConfidenceLevel.medium => 0.80,
    ConfidenceLevel.high   => 0.90,
  };

  /// Hedef FPS değeri.
  int get targetFps => fpsLimitEnabled ? 15 : 30;

  AppSettings copyWith({
    ThemeMode?         themeMode,
    AppTextSize?       textSize,
    bool?              leftHandMode,
    ConfidenceLevel?   confidenceLevel,
    bool?              fpsLimitEnabled,
    bool?              hapticEnabled,
    bool?              temporalSmoothingEnabled,
    bool?              cellularVideoDisabled,
    VideoQuality?      videoQuality,
    bool?              zeroDataMode,
    bool?              cloudSyncEnabled,
    bool?              ttsEnabled,
    bool?              sttEnabled,
    bool?              devMode,
  }) =>
      AppSettings(
        themeMode:                themeMode                ?? this.themeMode,
        textSize:                 textSize                 ?? this.textSize,
        leftHandMode:             leftHandMode             ?? this.leftHandMode,
        confidenceLevel:          confidenceLevel          ?? this.confidenceLevel,
        fpsLimitEnabled:          fpsLimitEnabled          ?? this.fpsLimitEnabled,
        hapticEnabled:            hapticEnabled            ?? this.hapticEnabled,
        temporalSmoothingEnabled: temporalSmoothingEnabled ?? this.temporalSmoothingEnabled,
        cellularVideoDisabled:    cellularVideoDisabled    ?? this.cellularVideoDisabled,
        videoQuality:             videoQuality             ?? this.videoQuality,
        zeroDataMode:             zeroDataMode             ?? this.zeroDataMode,
        cloudSyncEnabled:         cloudSyncEnabled         ?? this.cloudSyncEnabled,
        ttsEnabled:               ttsEnabled               ?? this.ttsEnabled,
        sttEnabled:               sttEnabled               ?? this.sttEnabled,
        devMode:                  devMode                  ?? this.devMode,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    ref.keepAlive();
    return const AppSettings();
  }

  // Görünüm
  void setThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  void setTextSize(AppTextSize size) =>
      state = state.copyWith(textSize: size);

  void toggleLeftHandMode() =>
      state = state.copyWith(leftHandMode: !state.leftHandMode);

  // Kamera & AI
  void setConfidenceLevel(ConfidenceLevel level) =>
      state = state.copyWith(confidenceLevel: level);

  void toggleFpsLimit() =>
      state = state.copyWith(fpsLimitEnabled: !state.fpsLimitEnabled);

  void toggleHaptic() =>
      state = state.copyWith(hapticEnabled: !state.hapticEnabled);

  void toggleTemporalSmoothing() =>
      state = state.copyWith(
        temporalSmoothingEnabled: !state.temporalSmoothingEnabled,
      );

  // Veri & Video
  void toggleCellularVideo() =>
      state = state.copyWith(
        cellularVideoDisabled: !state.cellularVideoDisabled,
      );

  void setVideoQuality(VideoQuality q) =>
      state = state.copyWith(videoQuality: q);

  // Gizlilik
  void toggleZeroDataMode() =>
      state = state.copyWith(zeroDataMode: !state.zeroDataMode);

  void toggleCloudSync() =>
      state = state.copyWith(cloudSyncEnabled: !state.cloudSyncEnabled);

  // Ses
  void toggleTts() =>
      state = state.copyWith(ttsEnabled: !state.ttsEnabled);

  void toggleStt() =>
      state = state.copyWith(sttEnabled: !state.sttEnabled);

  // Geliştirici
  void toggleDevMode() =>
      state = state.copyWith(devMode: !state.devMode);
}
