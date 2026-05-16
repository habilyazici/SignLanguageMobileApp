import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/camera_lifecycle_provider.dart';
import '../../../../../core/providers/translation_tab_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../recognition/presentation/screens/recognition_screen.dart';
import '../../../text_to_sign/presentation/screens/translator_screen.dart';

/// Çeviri merkezi — İşaret Oku ve İşaret Anlat modlarını içerir.
///
/// Tab geçişleri hem _ModeSelector butonlarıyla hem de ScaffoldWithNav'ın
/// swipe sistemiyle (translationTabProvider üzerinden) tetiklenebilir.
class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTab.clamp(0, 1);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initial);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Route'tan gelen initialTab'ı provider ile senkronize et.
      ref.read(translationTabProvider.notifier).setTab(initial);
      _syncCamera(initial);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Animasyon süresinde birden fazla tetiklenmeyi önle.
    if (_tabController.indexIsChanging) return;
    final newTab = _tabController.index;
    _syncCamera(newTab);
    // Provider'ı güncelle ki _SwipeNavWrapper sanal indeksi doğru hesaplasın.
    if (ref.read(translationTabProvider) != newTab) {
      ref.read(translationTabProvider.notifier).setTab(newTab);
    }
  }

  /// Sekme 0 = İşaret Oku → kamera açık; Sekme 1 = İşaret Anlat → kamera kapalı.
  void _syncCamera(int index) {
    ref.read(cameraActiveProvider.notifier).setActive(active: index == 0);
  }

  @override
  Widget build(BuildContext context) {
    // Swipe navigasyonundan gelen dış tab değişikliklerini dinle.
    ref.listen(translationTabProvider, (_, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
        // _syncCamera, animasyon bitince _onTabChanged tarafından çağrılır.
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Mod Seçici ──────────────────────────────────────────────
            _ModeSelector(controller: _tabController),

            // ── İçerik ─────────────────────────────────────────────────
            // NeverScrollableScrollPhysics: yatay swipe'lar _SwipeNavWrapper
            // tarafından yakalanır; bu sayede tab geçişi ve ekran geçişi
            // aynı gesture sistemiyle tutarlı biçimde çalışır.
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: const [
                  RecognitionScreen(),
                  TranslatorScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mod seçici — iki ayrı buton
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Yatay padding'i artırarak (32) alt kutudan daha dar ve ortalı yaptık
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 6),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final index = controller.index;
          return Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: 'İşaretten Çeviri',
                  sublabel: 'Kamera ile tanıma',
                  isSelected: index == 0,
                  alignment: CrossAxisAlignment.end, // Yazılar sağa yaslı
                  onTap: () => controller.animateTo(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  label: 'Sesten Çeviri',
                  sublabel: 'Ses veya metin',
                  isSelected: index == 1,
                  alignment: CrossAxisAlignment.start, // Yazılar sola yaslı
                  onTap: () => controller.animateTo(1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
    required this.alignment,
  });

  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveBg = isDark ? AppTheme.darkSurface : Colors.white;
    final inactiveBorder = isDark ? Colors.white12 : AppTheme.borderColor;
    final inactiveText = isDark ? Colors.white70 : AppTheme.textPrimary;
    final inactiveSub = isDark ? Colors.white38 : AppTheme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : inactiveBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : inactiveBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: [
            Text(
              label,
              textAlign: alignment == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.left,
              style: TextStyle(
                fontSize: 14, // Biraz küçülterek daha zarif yaptık
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : inactiveText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              textAlign: alignment == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.left,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.75)
                    : inactiveSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
