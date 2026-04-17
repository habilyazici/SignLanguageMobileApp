import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // ── Profil başlığı ─────────────────────────────────────────────
            _ProfileHeader(isDark: isDark),

            const SizedBox(height: 24),

            // ── Görünüm ────────────────────────────────────────────────────
            _SectionTitle('Görünüm'),
            _SettingsCard(
              isDark: isDark,
              children: [
                _ThemeRow(
                  current: settings.themeMode,
                  onChanged: settingsNotifier.setThemeMode,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Tanıma ─────────────────────────────────────────────────────
            _SectionTitle('Tanıma'),
            _SettingsCard(
              isDark: isDark,
              children: [
                _SwitchRow(
                  isDark: isDark,
                  icon: Icons.blur_on_rounded,
                  iconColor: Colors.purpleAccent,
                  title: 'Temporal Düzleme',
                  subtitle: '8 ardışık kare = 1 kelime',
                  value: settings.temporalSmoothingEnabled,
                  onChanged: (_) => settingsNotifier.toggleTemporalSmoothing(),
                ),
                _Divider(isDark: isDark),
                _InfoRow(
                  isDark: isDark,
                  icon: Icons.memory_rounded,
                  iconColor: AppTheme.secondaryBlue,
                  title: 'Model',
                  value: 'BiLSTM · 226 sınıf',
                ),
                _Divider(isDark: isDark),
                _InfoRow(
                  isDark: isDark,
                  icon: Icons.speed_rounded,
                  iconColor: Colors.greenAccent,
                  title: 'İşlem hızı',
                  value: 'Her 5. kare',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Ses ───────────────────────────────────────────────────────
            _SectionTitle('Ses'),
            _SettingsCard(
              isDark: isDark,
              children: [
                _SwitchRow(
                  isDark: isDark,
                  icon: Icons.volume_up_rounded,
                  iconColor: Colors.deepOrangeAccent,
                  title: 'Sesli Okuma (TTS)',
                  subtitle: 'Tanınan kelimeyi Türkçe seslendir',
                  value: settings.ttsEnabled,
                  onChanged: (_) => settingsNotifier.toggleTts(),
                ),
                _Divider(isDark: isDark),
                _SwitchRow(
                  isDark: isDark,
                  icon: Icons.mic_rounded,
                  iconColor: Colors.pinkAccent,
                  title: 'Sesli Giriş (STT)',
                  subtitle: 'Metin→İşaret ekranında mikrofon',
                  value: settings.sttEnabled,
                  onChanged: (_) => settingsNotifier.toggleStt(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Geliştirici ────────────────────────────────────────────────
            _SectionTitle('Geliştirici'),
            _SettingsCard(
              isDark: isDark,
              children: [
                _SwitchRow(
                  isDark: isDark,
                  icon: Icons.developer_mode_rounded,
                  iconColor: Colors.cyanAccent,
                  title: 'Geliştirici Modu',
                  subtitle: 'Landmark noktaları + istatistik paneli',
                  value: settings.devMode,
                  onChanged: (_) => settingsNotifier.toggleDevMode(),
                ),
                if (settings.devMode) ...[
                  _Divider(isDark: isDark),
                  _LegendRow(isDark: isDark),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ── Hakkında ───────────────────────────────────────────────────
            _SectionTitle('Hakkında'),
            _SettingsCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  isDark: isDark,
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.midGrey,
                  title: 'Sürüm',
                  value: '1.0.0',
                ),
                _Divider(isDark: isDark),
                _InfoRow(
                  isDark: isDark,
                  icon: Icons.accessibility_new_rounded,
                  iconColor: AppTheme.primaryBlue,
                  title: 'Amaç',
                  value: 'TİD → Türkçe çeviri',
                ),
                _Divider(isDark: isDark),
                _InfoRow(
                  isDark: isDark,
                  icon: Icons.school_rounded,
                  iconColor: Colors.amber,
                  title: 'Veri seti',
                  value: 'AUTSL · 226 işaret',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profil başlığı
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkSurface, const Color(0xFF1A3055)]
              : [AppTheme.primaryBlue, AppTheme.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'HM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hear Me Out',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'İşaret dili çeviri uygulaması',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bölüm başlığı
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.midGrey,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ayar kartı (grouped rows)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tema satırı — 3 segment buton
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBox(
            Icons.palette_rounded,
            AppTheme.secondaryBlue,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tema',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          _SegmentControl(
            current: current,
            onChanged: onChanged,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = [
      (ThemeMode.light, Icons.wb_sunny_rounded, 'Açık'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Sistem'),
      (ThemeMode.dark, Icons.nightlight_round, 'Koyu'),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final (mode, icon, label) = item;
          final isSelected = current == mode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppTheme.secondaryBlue : AppTheme.primaryBlue)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Switch satırı
// ─────────────────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBox(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.midGrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.secondaryBlue,
            inactiveThumbColor: isDark ? Colors.white38 : Colors.white,
            inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bilgi satırı (değer etiketi)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBox(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppTheme.midGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dev mode renk gösterge açıklaması
// ─────────────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamera üzerinde gösterilen noktalar:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppTheme.midGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _dot(Colors.greenAccent),
              const SizedBox(width: 6),
              const Text('Pose iskelet (11 nokta)', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              _dot(Colors.cyanAccent),
              const SizedBox(width: 6),
              const Text('Sağ el (21 nokta)', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _dot(Colors.orangeAccent),
              const SizedBox(width: 6),
              const Text('Sol el (21 nokta)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Yardımcılar
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 58,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
    );
  }
}

Widget _iconBox(IconData icon, Color color) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 18),
  );
}
