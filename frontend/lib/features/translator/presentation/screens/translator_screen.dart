import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({super.key});

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final _controller = TextEditingController();

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video çevirisi yakında kullanıma girecek'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sttEnabled = ref.watch(settingsProvider).sttEnabled;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Başlık ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      color: AppTheme.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metin → İşaret',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Yazı veya ses ile işaret videosu',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : AppTheme.midGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

            const SizedBox(height: 20),

            // ── Video önizleme alanı ─────────────────────────────────────
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 56,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Video oynatıcı yapım aşamasında',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : AppTheme.midGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),

            const SizedBox(height: 16),

            // ── Metin giriş alanı ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Çevrilecek metni girin...',
                        filled: true,
                        fillColor: isDark
                            ? AppTheme.darkSurface
                            : Colors.black.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // STT mikrofon butonu
                  GestureDetector(
                    onTap: sttEnabled
                        ? () => _showComingSoon(context)
                        : null,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: sttEnabled
                            ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: sttEnabled ? AppTheme.primaryBlue : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

            const SizedBox(height: 16),

            // ── Çevir butonu ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _showComingSoon(context),
                  icon: const Icon(Icons.translate_rounded),
                  label: const Text('Çevir'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
