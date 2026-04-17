import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

// Settings ekranı şu an profil ekranında (profile_screen.dart) yer alıyor.
// Bu ekran ileride bağımsız bir rota (/settings) olarak genişletilecek.

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ayarlar'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Kapsamlı ayarlar yapım aşamasında',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white38 : AppTheme.midGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mevcut ayarlar Profil sekmesinde',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
