import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Uygulama geneli ayarlar — tema + geliştirici modu
// ─────────────────────────────────────────────────────────────────────────────

class AppSettings {
  /// MaterialApp'e iletilen tema modu
  final ThemeMode themeMode;

  /// Kamera ekranında landmark overlay + istatistik paneli
  final bool devMode;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.devMode = false,
  });

  AppSettings copyWith({ThemeMode? themeMode, bool? devMode}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        devMode: devMode ?? this.devMode,
      );
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    ref.keepAlive(); // Ayarlar uygulama boyunca canlı kalır
    return const AppSettings();
  }

  void setThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  void toggleDevMode() =>
      state = state.copyWith(devMode: !state.devMode);
}
