import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class StatusSummary extends StatelessWidget {
  const StatusSummary({
    super.key,
    required this.settings,
    required this.isDark,
  });

  final AppSettings settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final chips = <(IconData, String, Color)>[
      if (settings.ttsEnabled)
        (Icons.volume_up_rounded, 'TTS Açık', Colors.deepOrangeAccent),
      if (settings.devMode)
        (Icons.developer_mode_rounded, 'Dev Modu', Colors.cyanAccent),
      if (settings.fpsLimitEnabled)
        (Icons.speed_rounded, '15 FPS', Colors.orangeAccent),
      if (settings.zeroDataMode)
        (Icons.visibility_off_rounded, 'Sıfır-Veri', Colors.grey),
      if (!settings.hapticEnabled)
        (Icons.vibration_rounded, 'Titreşim Kapalı', Colors.red),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((c) {
          final (icon, label, color) = c;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
