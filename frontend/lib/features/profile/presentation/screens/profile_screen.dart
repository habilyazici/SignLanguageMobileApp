import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/nav_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = auth.isAuthenticated
        ? (auth.email ?? 'Kullanıcı')
        : 'Misafir Kullanıcı';
    final userInitials = auth.isAuthenticated
        ? userName.substring(0, 1).toUpperCase()
        : 'M';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // ── Minimal Modern Header ─────────────────────────────────────
            GestureDetector(
              onTap: auth.isAuthenticated ? null : () => context.push('/login'),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        userInitials,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (auth.isAuthenticated)
                            Text(
                              'Aktif Hesap',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white54
                                    : AppTheme.midGrey,
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Giriş Yap / Üye Ol',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        color: isDark ? Colors.white : AppTheme.primaryBlue,
                        onPressed: () => context.push('/settings'),
                        tooltip: 'Ayarlar',
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),

            const SizedBox(height: 32),

            // ── Menü Listesi ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  NavTile(
                    isDark: isDark,
                    icon: Icons.share_rounded,
                    iconColor: AppTheme.secondaryBlue,
                    title: 'Uygulamayı Paylaş',
                    subtitle: 'Hear Me Out\'u arkadaşlarınıza önerin',
                    onTap: () {
                      Share.share(
                        'Hear Me Out - İşaret Dili Uygulamasını keşfet! Harika özellikleriyle engelleri kaldırıyor. Hemen indir!',
                      );
                    },
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 12),

                  NavTile(
                    isDark: isDark,
                    icon: Icons.mail_rounded,
                    iconColor: AppTheme.primaryStatusYellow,
                    title: 'Bize Ulaşın',
                    subtitle: 'Öneri veya sorun bildirin',
                    onTap: () async {
                      final url = Uri.parse(
                        'mailto:habilyazici00@gmail.com?subject=Hear%20Me%20Out%20-%20Geri%20Bildirim',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mail uygulaması bulunamadı.'),
                            ),
                          );
                        }
                      }
                    },
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 12),

                  NavTile(
                    isDark: isDark,
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.primaryStatusGreen,
                    title: 'Nasıl Kullanılır?',
                    subtitle: 'Uygulama turunu tekrar başlat',
                    onTap: () => context.push('/onboarding'),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  // ── Çıkış Yap (Sadece giriş yapıldıysa) ───────────────────
                  if (auth.isAuthenticated) ...[
                    const SizedBox(height: 12),
                    NavTile(
                      isDark: isDark,
                      icon: Icons.logout_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Çıkış Yap',
                      subtitle: 'Hesabınızdan güvenli çıkış',
                      onTap: () => _confirmSignOut(context, ref),
                      showArrow: false,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  ],
                ],
              ),
            ),
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
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
