import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Başlık ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryStatusRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppTheme.primaryStatusRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acil Durum',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Hızlı mesajlar ve sağlık kartı',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : AppTheme.midGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 28),

              // ── Acil hızlı butonlar ────────────────────────────────────
              Text(
                'HIZLI MESAJLAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.midGrey,
                  letterSpacing: 1.4,
                ),
              ).animate().fadeIn(delay: 80.ms),

              const SizedBox(height: 12),

              ...([
                ('Ağrım Var', Icons.medical_services_rounded, AppTheme.primaryStatusRed),
                ('Alerjim Var', Icons.warning_rounded, Colors.deepOrangeAccent),
                ('Yardım Lazım', Icons.pan_tool_rounded, AppTheme.secondaryBlue),
                ('Kan Grubum: ?', Icons.bloodtype_rounded, Colors.pinkAccent),
              ]
                  .asMap()
                  .entries
                  .map((entry) {
                final (label, icon, color) = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(icon, color: color, size: 22),
                      label: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color.withValues(alpha: 0.4)),
                        backgroundColor: color.withValues(alpha: 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 120 + entry.key * 60)).slideX(begin: -0.08),
                );
              })),

              const SizedBox(height: 8),

              // ── Sağlık kartı ────────────────────────────────────────────
              Text(
                'SAĞLIK KARTI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.midGrey,
                  letterSpacing: 1.4,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_rounded,
                      color: isDark ? Colors.white38 : AppTheme.midGrey,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sağlık kartı henüz oluşturulmadı',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Profil → Sağlık Kartı bölümünden ekle',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : AppTheme.midGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
