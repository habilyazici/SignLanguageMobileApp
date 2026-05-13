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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ──────────────────────────────────────────────────
                Image.asset(
                  'assets/images/logo.png',
                  height: 72,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
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

                const SizedBox(height: 12),

                // ── Açıklama ──────────────────────────────────────────────
                Text(
                  'İşaret dili çevirisi ve iletişim aracınız.\nHer an, her yerde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.65,
                  ),
                ).animate().fadeIn(delay: 380.ms, duration: 500.ms),

                const Spacer(flex: 3),

                // ── Giriş Yap / Kayıt Ol ──────────────────────────────────
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
                    .fadeIn(delay: 550.ms, duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 12),

                // ── Çeviriyi Hemen Kullan ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/guest-camera'),
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: Text(
                      'Çeviriyi Hemen Kullan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 680.ms, duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 28),

                // ── Nasıl Çalışır? ────────────────────────────────────────
                TextButton(
                  onPressed: () => context.push('/onboarding'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.45),
                  ),
                  child: const Text(
                    'Nasıl Çalışır?',
                    style: TextStyle(fontSize: 13),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
