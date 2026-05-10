import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.isGuest;
    final displayName = isGuest
        ? 'Misafir Kullanıcı'
        : (auth.displayName ?? auth.email?.split('@').first ?? 'Kullanıcı');
    final email = isGuest ? null : auth.email;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';

    return Scaffold(
      backgroundColor: AppTheme.softGrey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // ── Başlık + Ayarlar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profilim',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hesabını ve tercihlerini yönet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            size: 15,
                            color: AppTheme.midGrey,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Ayarlar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.midGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 12),

            // ── Profil Kartı ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isGuest
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primaryBlue, AppTheme.primaryBlueEnd],
                        ),
                  color: isGuest ? Colors.white : null,
                  borderRadius: BorderRadius.circular(20),
                  border: isGuest
                      ? Border.all(color: AppTheme.borderColor)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isGuest
                          ? Colors.black.withValues(alpha: 0.04)
                          : AppTheme.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGuest
                            ? AppTheme.primaryBlueTint
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isGuest ? AppTheme.primaryBlue : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isGuest ? AppTheme.textPrimary : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (email != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: isGuest
                                    ? AppTheme.midGrey
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 60.ms, duration: 400.ms)
                .slideY(begin: 0.06, end: 0),


            // ── Uygulama Bölümü ───────────────────────────────────────────
            _SectionLabel('Uygulama'),
            _Card(
              children: [
                _Tile(
                  icon: Icons.share_rounded,
                  iconColor: AppTheme.secondaryBlue,
                  title: 'Uygulamayı Paylaş',
                  onTap: () => Share.share(
                    'Hear Me Out - İşaret Dili Uygulamasını keşfet!',
                  ),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.mail_rounded,
                  iconColor: AppTheme.primaryStatusYellow,
                  title: 'Bize Ulaşın',
                  onTap: () async {
                    final uri = Uri.parse(
                      'mailto:habilyazici00@gmail.com?subject=Hear%20Me%20Out%20-%20Geri%20Bildirim',
                    );
                    final launched = await launchUrl(uri);
                    if (!launched && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('E-posta uygulaması açılamadı.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                _Divider(),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppTheme.primaryStatusGreen,
                  title: 'Nasıl Kullanılır?',
                  onTap: () => context.push('/onboarding'),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.settings_rounded,
                  iconColor: AppTheme.midGrey,
                  title: 'Ayarlar',
                  onTap: () => context.push('/settings'),
                ),
              ],
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),

            // ── Hesap Bölümü — sadece üye ─────────────────────────────────
            if (!isGuest) ...[
              _SectionLabel('Hesap'),
              _Card(
                children: [
                  _Tile(
                    icon: Icons.edit_outlined,
                    iconColor: AppTheme.secondaryBlue,
                    title: 'Profili Düzenle',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _Divider(),
                  _Tile(
                    icon: Icons.logout_rounded,
                    iconColor: AppTheme.primaryStatusRed,
                    title: 'Çıkış Yap',
                    titleColor: AppTheme.primaryStatusRed,
                    showArrow: false,
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ).animate().fadeIn(delay: 220.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryStatusRed,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.midGrey,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      color: Colors.black.withValues(alpha: 0.05),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.showArrow = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final bool showArrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppTheme.textPrimary,
                ),
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
