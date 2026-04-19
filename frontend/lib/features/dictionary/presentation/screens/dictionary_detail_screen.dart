import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sign_entry.dart';
import '../providers/dictionary_provider.dart';

class DictionaryDetailScreen extends ConsumerStatefulWidget {
  final int wordId;

  const DictionaryDetailScreen({super.key, required this.wordId});

  @override
  ConsumerState<DictionaryDetailScreen> createState() =>
      _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState
    extends ConsumerState<DictionaryDetailScreen> {
  VideoPlayerController? _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Şimdilik asset'ten video oynatmaya çalışalım
    // Not: Asset dosyası yoksa hata verecektir, bunu handle edeceğiz.
    _controller =
        VideoPlayerController.asset('assets/videos/sign_${widget.wordId}.mp4')
          ..initialize()
              .then((_) {
                setState(() {});
                _controller?.setLooping(true);
                _controller?.play();
              })
              .catchError((e) {
                debugPrint("Video yükleme hatası: $e");
                setState(() => _isError = true);
              });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dict = ref.watch(dictionaryProvider);

    // Kelimeyi bul
    final entry = dict.allSigns.firstWhere(
      (s) => s.id == widget.wordId,
      orElse: () => const SignEntry(id: -1, label: 'Bilinmeyen'),
    );

    if (entry.id == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Kelime bulunamadı.')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.softGrey,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildVideoSection(isDark),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppTheme.primaryBlue,
          ),

          // ── İçerik ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _categoryBadge(entry.category),
                      const Spacer(),
                      IconButton(
                        onPressed: () {}, // Favori eklenebilir
                        icon: const Icon(Icons.favorite_border_rounded),
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.label,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nasıl Yapılır?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.description ??
                        'Bu işaretin nasıl yapıldığına dair henüz bir açıklama eklenmemiş.',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white70 : AppTheme.midGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // İpuçları Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBlue.withValues(
                        alpha: isDark ? 0.05 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          color: AppTheme.secondaryBlue,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'İpucu: İşareti yaparken yüz ifadeleriniz ve vücut diliniz de anlamı güçlendirir.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(bool isDark) {
    if (_isError) {
      return Container(
        color: AppTheme.darkSurface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video şu an kullanılamıyor',
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              'sign_${widget.wordId}.mp4 bulunamadı',
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        // Overlay - Gradyan
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryStatusGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryStatusGreen,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
