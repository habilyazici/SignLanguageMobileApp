import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

// Türkçe alfabe — harf chip'leri için
const _kTurkishAlphabet = [
  'A',
  'B',
  'C',
  'Ç',
  'D',
  'E',
  'F',
  'G',
  'Ğ',
  'H',
  'I',
  'İ',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'Ö',
  'P',
  'R',
  'S',
  'Ş',
  'T',
  'U',
  'Ü',
  'V',
  'Y',
  'Z',
];

// Türkçe büyük/küçük harf dönüşümü (I/İ ayrımı)
String _trLower(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<Map<String, String>> _allSigns = [];
  List<Map<String, String>> _filteredSigns = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _letterScrollController = ScrollController();

  // null = Tümü
  String? _selectedLetter;

  @override
  void initState() {
    super.initState();
    _loadLabels();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _letterScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLabels() async {
    try {
      final String csvData = await rootBundle.loadString(
        'assets/models/labels.csv',
      );
      // Hem \r\n hem \n destekli bölme
      final lines = csvData.split(RegExp(r'\r?\n'));
      final loaded = <Map<String, String>>[];

      debugPrint('📖 Sözlük: ${lines.length} satır okundu (başlık dahil)');

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(',');
        if (parts.length >= 3) {
          loaded.add({
            'id': parts[0].trim(),
            'en': parts[1].trim(),
            'tr': parts[2].trim(),
          });
        }
      }

      debugPrint('✅ Sözlük: ${loaded.length} kelime başarıyla yüklendi');

      // Türkçe alfabetik sırala
      loaded.sort((a, b) => _trLower(a['tr']!).compareTo(_trLower(b['tr']!)));

      setState(() {
        _allSigns = loaded;
        _filteredSigns = loaded;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Sözlük Yükleme Hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sözlük yüklenemedi: $e')));
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        // Arama aktifken harf filtresi devre dışı (arama öncelikli)
        _filteredSigns = _allSigns.where((s) {
          return s['tr']!.toLowerCase().contains(query) ||
              s['en']!.toLowerCase().contains(query);
        }).toList();
      } else if (_selectedLetter != null) {
        _filteredSigns = _allSigns.where((s) {
          if (s['tr']!.isEmpty) return false;
          return _trLower(s['tr']![0]) == _trLower(_selectedLetter!);
        }).toList();
      } else {
        _filteredSigns = _allSigns;
      }
    });
  }

  void _selectLetter(String? letter) {
    _searchController.clear(); // harfe basınca arama temizlenir
    setState(() => _selectedLetter = letter);
    _applyFilters();
  }

  bool get _isFiltered =>
      _selectedLetter != null || _searchController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Başlık ───────────────────────────────────────────────────
            _Header(
              totalCount: _allSigns.length,
              filteredCount: _filteredSigns.length,
              isFiltered: _isFiltered,
            ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1),

            // ── Arama çubuğu ─────────────────────────────────────────────
            _SearchBar(
              controller: _searchController,
              isDark: isDark,
            ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

            // ── Harf filtre şeridi ────────────────────────────────────────
            _LetterStrip(
              scrollController: _letterScrollController,
              selected: _selectedLetter,
              onSelect: _selectLetter,
              isDark: isDark,
            ).animate().fadeIn(delay: 140.ms, duration: 300.ms),

            // ── Sonuç listesi ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSigns.isEmpty
                  ? _EmptyState(isDark: isDark)
                  : _SignList(signs: _filteredSigns, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Başlık + kelime sayacı
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.totalCount,
    required this.filteredCount,
    required this.isFiltered,
  });

  final int totalCount;
  final int filteredCount;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final label = isFiltered
        ? '$filteredCount / $totalCount'
        : '$totalCount Kelime';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Text(
            'İşaret Sözlüğü',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(label),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFiltered
                    ? AppTheme.secondaryBlue.withValues(alpha: 0.15)
                    : AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isFiltered
                      ? AppTheme.secondaryBlue
                      : AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arama çubuğu
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.isDark});

  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Kelime ara (TR / EN)...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (_, _) => controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 18,
                    ),
                    onPressed: controller.clear,
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: isDark
              ? AppTheme.darkSurface
              : Colors.black.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yatay kaydırmalı harf şeridi
// ─────────────────────────────────────────────────────────────────────────────

class _LetterStrip extends StatelessWidget {
  const _LetterStrip({
    required this.scrollController,
    required this.selected,
    required this.onSelect,
    required this.isDark,
  });

  final ScrollController scrollController;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          // "Tümü" chip'i
          _LetterChip(
            label: 'Tümü',
            isSelected: selected == null,
            isDark: isDark,
            onTap: () => onSelect(null),
            isAll: true,
          ),
          const SizedBox(width: 6),
          // A–Z harf chip'leri
          for (final letter in _kTurkishAlphabet) ...[
            _LetterChip(
              label: letter,
              isSelected: selected == letter,
              isDark: isDark,
              onTap: () => onSelect(letter),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.isAll = false,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final bool isAll;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.secondaryBlue;
    final bg = isSelected
        ? activeColor
        : (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: isAll ? 14 : 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isAll ? 12 : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kelime listesi — animasyon sadece ilk yüklemede
// ─────────────────────────────────────────────────────────────────────────────

class _SignList extends StatelessWidget {
  const _SignList({required this.signs, required this.isDark});

  final List<Map<String, String>> signs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      itemCount: signs.length,
      itemBuilder: (context, index) {
        final sign = signs[index];
        return _SignCard(sign: sign, isDark: isDark);
      },
    );
  }
}

class _SignCard extends StatelessWidget {
  const _SignCard({required this.sign, required this.isDark});

  final Map<String, String> sign;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              sign['tr']!.isEmpty ? '?' : sign['tr']![0].toUpperCase(),
              style: TextStyle(
                color: AppTheme.secondaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          sign['tr']!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          sign['en']!.toUpperCase(),
          style: TextStyle(
            color: AppTheme.midGrey,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppTheme.midGrey.withValues(alpha: 0.4),
        ),
        onTap: () {
          // Gelecekte: video detay sayfası
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Boş durum
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white38 : AppTheme.midGrey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
