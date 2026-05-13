import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3356), AppTheme.primaryBlue, Color(0xFF0D2240)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ──────────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 44,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 20),

                // ── Uygulama adı ──────────────────────────────────────────
                Text(
                  'Hear Me Out',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOut),

                const SizedBox(height: 10),

                // ── Açıklama ──────────────────────────────────────────────
                Text(
                  'İşaret dili çevirisi ve iletişim aracınız.\nHer an, her yerde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.60),
                    height: 1.65,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                const SizedBox(height: 20),

                // ── Özellik etiketleri ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FeaturePill(
                      icon: Icons.bolt_rounded,
                      label: 'Gerçek Zamanlı',
                    ),
                    const SizedBox(width: 8),
                    _FeaturePill(
                      icon: Icons.sign_language_rounded,
                      label: '226 İşaret',
                    ),
                    const SizedBox(width: 8),
                    _FeaturePill(
                      icon: Icons.translate_rounded,
                      label: 'Türkçe',
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const Spacer(flex: 3),

                // ── Giriş Yap / Kayıt Ol — birincil ──────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => context.go('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Giriş Yap / Kayıt Ol',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 12),

                // ── Çeviriyi Hemen Kullan — ikincil (ghost) ───────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/guest-camera'),
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: Text(
                      'Hesapsız Dene',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 720.ms, duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ── Nasıl Çalışır? ────────────────────────────────────────
                TextButton(
                  onPressed: () => context.push('/onboarding'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.50),
                  ),
                  child: const Text(
                    'Nasıl çalışır?',
                    style: TextStyle(fontSize: 13),
                  ),
                ).animate().fadeIn(delay: 840.ms, duration: 400.ms),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Küçük özellik etiketi ─────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.80)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}
