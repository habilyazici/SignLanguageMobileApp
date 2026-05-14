import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String body;
  final List<String> tips;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.tips,
  });
}

const _pages = [
  _OnboardingPage(
    icon: Icons.videocam_rounded,
    iconColor: AppTheme.secondaryBlue,
    title: 'İşaretten Çeviri',
    subtitle: 'Kamera · Gerçek Zamanlı',
    body:
        'Ellerinizi kameraya gösterin — uygulama işareti anında tanıyıp metne çevirir. İşaret dili bilmeyenlerle iletişim artık çok daha kolay.',
    tips: [
      'İyi aydınlatılmış bir ortamda daha doğru sonuç alırsınız.',
      'Ellerinizi kamera çerçevesi içinde tutun.',
      'Solak mısınız? Ayarlardan solak modunu açın.',
    ],
  ),
  _OnboardingPage(
    icon: Icons.sign_language_rounded,
    iconColor: AppTheme.primaryBlue,
    title: 'Sesten Çeviri',
    subtitle: 'Ses veya Metin → İşaret',
    body:
        'Söyleyin ya da yazın; karşılık gelen işaret videoları sırayla oynatılır. İstediğiniz kelimeye atlayabilir, dilediğiniz yerden devam edebilirsiniz.',
    tips: [
      'Mikrofon butonuyla sesli komut verebilirsiniz.',
      'Token şeridine dokunarak istediğiniz kelimeye atlayın.',
      'Öğrendiğiniz çeviriler geçmiş sayfasına kaydedilir.',
    ],
  ),
  _OnboardingPage(
    icon: Icons.menu_book_rounded,
    iconColor: AppTheme.statusPurple,
    title: 'Sözlük & Favoriler',
    subtitle: '1500+ işaret · İnternet Gerekmez',
    body:
        'Tüm işaretleri çevrimiçi bağlantı olmadan keşfedin. Sık kullandığınız kelimeleri favorilerinize ekleyin, istediğinizde anında bulun.',
    tips: [
      'Kelimeyi favorilere ekleyip hızla ulaşın.',
      'Geçmiş sayfasında öğrendiğiniz işaretleri tekrar edin.',
      'Tüm veriler cihazınızda güvenle saklanır.',
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAndNavigate();
    }
  }

  void _skip() => _completeAndNavigate();

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeAndNavigate() async {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _pages.length - 1;
    final pageColor = _pages[_currentPage].iconColor;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        color: isDark
            ? Color.lerp(AppTheme.darkBg, AppTheme.primaryBlue, 0.07)!
            : Color.lerp(AppTheme.softGrey, AppTheme.primaryBlue, 0.07)!,
        child: SafeArea(
          child: Column(
            children: [
              // ── Üst bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sayfa göstergesi (noktalar)
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? pageColor
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    // Atla
                    FilledButton(
                      onPressed: _skip,
                      style: FilledButton.styleFrom(
                        backgroundColor: pageColor.withValues(alpha: 0.12),
                        foregroundColor: pageColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Atla',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sayfa içeriği ─────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) =>
                      _PageContent(page: _pages[index], isDark: isDark),
                ),
              ),

              // ── Alt navigasyon ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Geri ok — ilk sayfada soluk
                    AnimatedOpacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: _currentPage == 0,
                        child: GestureDetector(
                          onTap: _back,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pageColor.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              color: pageColor.withValues(alpha: 0.08),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: pageColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // İleri ok / Başla
                    if (isLast)
                      FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: pageColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Başla',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pageColor,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page, required this.isDark});

  final _OnboardingPage page;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.iconColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: page.iconColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(page.icon, size: 64, color: page.iconColor),
              )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 36),

          Text(
                page.title,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : page.iconColor,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.1),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: page.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              page.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: page.iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

          const SizedBox(height: 20),

          Text(
            page.body,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white60 : AppTheme.midGrey,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // İpuçları — doğrudan görünür, expand gerektirmez
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: page.iconColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: page.iconColor.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: page.tips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: page.iconColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? Colors.white70 : AppTheme.midGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 420.ms, duration: 400.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
