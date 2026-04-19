import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../widgets/guest_banner.dart';
import '../widgets/info_card.dart';
import '../widgets/nav_tile.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_title.dart';
import '../widgets/status_summary.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // ── Profil başlığı ────────────────────────────────────────────
            ProfileHeader(auth: auth, isDark: isDark)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.08, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // ── Misafir ise giriş CTA'sı ─────────────────────────────────
            if (auth.isGuest)
              GuestBanner(isDark: isDark)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 350.ms)
                  .slideY(begin: 0.06),

            // ── Aktif ayar özeti (giriş yapmış kullanıcılarda) ────────────
            if (auth.isAuthenticated)
              StatusSummary(settings: settings, isDark: isDark)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 350.ms)
                  .slideY(begin: 0.06),

            const SizedBox(height: 16),

            // ── Ayarlar ───────────────────────────────────────────────────
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NavTile(
                    isDark: isDark,
                    icon: Icons.settings_rounded,
                    iconColor: AppTheme.secondaryBlue,
                    title: 'Ayarlar',
                    subtitle: 'Tema, kamera, ses, gizlilik',
                    onTap: () => context.push('/settings'),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            const SizedBox(height: 10),

            // ── Turu Tekrarla ──────────────────────────────────────────────
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NavTile(
                    isDark: isDark,
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.primaryStatusYellow,
                    title: 'Nasıl Kullanılır?',
                    subtitle: 'Uygulama turunu tekrar başlat',
                    onTap: () => context.push('/onboarding'),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            // ── Çıkış (sadece giriş yapılmışsa) ──────────────────────────
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 10),
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: NavTile(
                      isDark: isDark,
                      icon: Icons.logout_rounded,
                      iconColor: Colors.orangeAccent,
                      title: 'Çıkış Yap',
                      subtitle: auth.email ?? '',
                      onTap: () => _confirmSignOut(context, ref),
                      showArrow: false,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    curve: Curves.easeOutBack,
                  )
                  .slideY(begin: 0.1, curve: Curves.easeOut),
            ],

            const SizedBox(height: 24),

            // ── Hakkında ──────────────────────────────────────────────────
            const SectionTitle('Hakkında'),
            InfoCard(
              isDark: isDark,
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }
}
