import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/camera_lifecycle_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../recognition/presentation/screens/recognition_screen.dart';
import '../../../text_to_sign/presentation/screens/translator_screen.dart';

/// Çeviri merkezi — İşaret Oku ve İşaret Anlat modlarını içerir.
///
/// İşaret Oku (index 0): Tam ekran kamera, işaret tanıma
/// İşaret Anlat (index 1): Metin → işaret çevirisi
class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncCamera(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _syncCamera(_tabController.index);
    }
  }

  /// Sekme 0 = İşaret Oku → kamera açık, Sekme 1 = İşaret Anlat → kamera kapalı
  void _syncCamera(int index) {
    ref.read(cameraActiveProvider.notifier).setActive(active: index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Mod Seçici ──────────────────────────────────────────────
            _ModeSelector(controller: _tabController),

            // ── İçerik ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
// Mod seçici — minimal pill tasarımı
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final index = controller.index;
          return Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _ModeTab(
                  icon: Icons.videocam_rounded,
                  label: 'İşaret Oku',
                  isSelected: index == 0,
                  onTap: () => controller.animateTo(0),
                ),
                _ModeTab(
                  icon: Icons.sign_language_rounded,
                  label: 'İşaret Anlat',
                  isSelected: index == 1,
                  onTap: () => controller.animateTo(1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
