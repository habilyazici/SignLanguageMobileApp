import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Profil bilgilerini alt sayfa (bottom sheet) olarak gösterir.
/// Home, Ayarlar vb. ekranlardaki profil butonuna basınca açılır.
void showProfileSheet(BuildContext context, dynamic auth) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProfileSheet(auth: auth),
  );
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.auth});
  final dynamic auth;

  @override
  Widget build(BuildContext context) {
    final isGuest = auth.isGuest as bool;
    final displayName = isGuest
        ? 'Misafir Kullanıcı'
        : ((auth.displayName as String?) ??
            (auth.email as String?)?.split('@').first ??
            'Kullanıcı');
    final email = isGuest ? null : auth.email as String?;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom +
            16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tutma çubuğu ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 24),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Avatar ────────────────────────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0046AF), Color(0xFF005CE1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 350.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 14),

          // ── İsim ─────────────────────────────────────────────────────
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

          if (email != null) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: AppTheme.midGrey),
            ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
          ],

          const SizedBox(height: 12),

          // ── Durum rozeti ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isGuest
                  ? AppTheme.bgSecondary
                  : AppTheme.primaryStatusGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isGuest
                    ? AppTheme.borderColor
                    : AppTheme.primaryStatusGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGuest
                        ? AppTheme.textMuted
                        : AppTheme.primaryStatusGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isGuest ? 'Misafir' : 'Aktif Hesap',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isGuest
                        ? AppTheme.midGrey
                        : AppTheme.primaryStatusGreen,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── İstatistik satırı ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.softGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      value: '0',
                      label: 'Çeviri',
                      icon: Icons.translate_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppTheme.borderColor),
                  Expanded(
                    child: _StatItem(
                      value: '0',
                      label: 'Kaydedilen',
                      icon: Icons.bookmark_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppTheme.borderColor),
                  Expanded(
                    child: _StatItem(
                      value: '0',
                      label: 'Gün Serisi',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // ── Aksiyon Butonları ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isGuest
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/login');
                          },
                          child: const Text('Giriş Yap'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/register');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Kapat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.midGrey,
                        side: const BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.midGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
