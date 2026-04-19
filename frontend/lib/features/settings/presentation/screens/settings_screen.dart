import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_dialogs.dart';
import '../widgets/settings_rows.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final isGuest = ref.watch(authProvider).isGuest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.softGrey,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.softGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppTheme.primaryBlue,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ayarlar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primaryBlue,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Genel Cihaz & Görünüm ──────────────────────────────────────────
          const SettingsSection('Genel Cihaz & Görünüm'),
          SettingsCard(
                isDark: isDark,
                children: [
                  ThemeRow(
                    current: settings.themeMode,
                    onChanged: n.setThemeMode,
                    isDark: isDark,
                  ),
                  SettingsDivider(isDark: isDark),
                  TextSizeRow(
                    current: settings.textSize,
                    onChanged: n.setTextSize,
                    isDark: isDark,
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.back_hand_rounded,
                    iconColor: const Color(0xFF7C4DFF),
                    title: 'Solak Modu',
                    subtitle: 'Kamera deklanşörünü sola hizalar',
                    value: settings.leftHandMode,
                    onChanged: (_) => n.toggleLeftHandMode(),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 60.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          // ── Kamera & Yapay Zeka ────────────────────────────────────────────
          const SettingsSection('Kamera & Yapay Zeka'),
          SettingsCard(
                isDark: isDark,
                children: [
                  ConfidenceRow(
                    current: settings.confidenceLevel,
                    onChanged: n.setConfidenceLevel,
                    isDark: isDark,
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.blur_on_rounded,
                    iconColor: Colors.purpleAccent,
                    title: 'Temporal Düzleme',
                    subtitle: '2 ardışık onay eşleşirse kelimeyi ekrana yaz',
                    value: settings.temporalSmoothingEnabled,
                    onChanged: (_) => n.toggleTemporalSmoothing(),
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.speed_rounded,
                    iconColor: Colors.orangeAccent,
                    title: 'Düşük Güç Modu (15 FPS)',
                    subtitle:
                        'Pil tasarrufu — kamera kare hızını 15\'e indirir',
                    value: settings.fpsLimitEnabled,
                    onChanged: (_) => n.toggleFpsLimit(),
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.vibration_rounded,
                    iconColor: Colors.tealAccent,
                    title: 'Titreşim Geri Bildirimi',
                    subtitle: 'Kelime tanındığında hafif titreşim',
                    value: settings.hapticEnabled,
                    onChanged: (_) => n.toggleHaptic(),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 120.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          // ── Ses ───────────────────────────────────────────────────────────
          const SettingsSection('Ses'),
          SettingsCard(
                isDark: isDark,
                children: [
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.volume_up_rounded,
                    iconColor: Colors.deepOrangeAccent,
                    title: 'Sesli Okuma (TTS)',
                    subtitle: 'Tanınan kelimeyi Türkçe seslendir',
                    value: settings.ttsEnabled,
                    onChanged: (_) => n.toggleTts(),
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.mic_rounded,
                    iconColor: Colors.pinkAccent,
                    title: 'Sesli Giriş (STT)',
                    subtitle: 'Metin→İşaret ekranında mikrofon',
                    value: settings.sttEnabled,
                    onChanged: (_) => n.toggleStt(),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 160.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          // ── Veri Kullanımı & Video ─────────────────────────────────────────
          const SettingsSection('Veri Kullanımı & Video'),
          SettingsCard(
                isDark: isDark,
                children: [
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.signal_cellular_off_rounded,
                    iconColor: Colors.redAccent,
                    title: 'Mobil Veri\'de Video Kapalı',
                    subtitle: 'Wi-Fi yokken işaret videoları oynatılmaz',
                    value: settings.cellularVideoDisabled,
                    onChanged: (_) => n.toggleCellularVideo(),
                  ),
                  SettingsDivider(isDark: isDark),
                  VideoQualityRow(
                    current: settings.videoQuality,
                    onChanged: n.setVideoQuality,
                    isDark: isDark,
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsActionRow(
                    isDark: isDark,
                    icon: Icons.cleaning_services_rounded,
                    iconColor: Colors.blueAccent,
                    title: 'Önbelleği Temizle',
                    subtitle: 'İndirilen videoları sil',
                    label: 'Temizle',
                    labelColor: Colors.blueAccent,
                    onTap: () =>
                        SettingsDialogs.showCacheDialog(context, isDark),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          // ── Gizlilik & Veri Kontrolü ───────────────────────────────────────
          const SettingsSection('Gizlilik & Veri Kontrolü'),
          SettingsCard(
                isDark: isDark,
                children: [
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.visibility_off_rounded,
                    iconColor: Colors.grey,
                    title: 'Sıfır-Veri Modu',
                    subtitle: 'Çeviri geçmişini hiç kaydetme',
                    value: settings.zeroDataMode,
                    onChanged: (_) => n.toggleZeroDataMode(),
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.cloud_sync_rounded,
                    iconColor: AppTheme.secondaryBlue,
                    title: 'Bulut Eşzamanlaması',
                    subtitle: isGuest
                        ? 'Giriş yaparak etkinleştir'
                        : 'Ayarları ve Sağlık Kartını senkronize et',
                    value: settings.cloudSyncEnabled,
                    onChanged: isGuest
                        ? (_) => context.push('/login')
                        : (_) => n.toggleCloudSync(),
                  ),
                  SettingsDivider(isDark: isDark),
                  SettingsActionRow(
                    isDark: isDark,
                    icon: Icons.delete_forever_rounded,
                    iconColor: Colors.red,
                    title: 'Hesabı Sil',
                    subtitle: 'Tüm verilerini kalıcı olarak sil (GDPR/KVKK)',
                    label: 'Sil',
                    labelColor: Colors.red,
                    onTap: () => SettingsDialogs.showDeleteAccountDialog(
                      context,
                      isDark,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 240.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          // ── Geliştirici ────────────────────────────────────────────────────
          const SettingsSection('Geliştirici'),
          SettingsCard(
                isDark: isDark,
                children: [
                  SettingsSwitchRow(
                    isDark: isDark,
                    icon: Icons.developer_mode_rounded,
                    iconColor: Colors.cyanAccent,
                    title: 'Geliştirici Modu',
                    subtitle: 'Landmark noktaları + istatistik paneli',
                    value: settings.devMode,
                    onChanged: (_) => n.toggleDevMode(),
                  ),
                  if (settings.devMode) ...[
                    SettingsDivider(isDark: isDark),
                    LandmarkLegend(isDark: isDark),
                  ],
                ],
              )
              .animate()
              .fadeIn(delay: 280.ms, duration: 350.ms)
              .slideY(begin: 0.06),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
