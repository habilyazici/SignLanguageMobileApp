import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            isDark,
            Icons.info_outline_rounded,
            AppTheme.midGrey,
            'Sürüm',
            'v1.0.0',
          ),
          _divider(isDark),
          _row(
            isDark,
            Icons.school_rounded,
            Colors.amber,
            'Veri Seti',
            '1500+ işaret',
          ),
          _divider(isDark),
          _row(
            isDark,
            Icons.accessibility_new_rounded,
            AppTheme.primaryBlue,
            'Amaç',
            'Engelsiz İletişim',
          ),
        ],
      ),
    );
  }

  Widget _row(
    bool isDark,
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppTheme.midGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
    height: 1,
    indent: 58,
    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
  );
}
