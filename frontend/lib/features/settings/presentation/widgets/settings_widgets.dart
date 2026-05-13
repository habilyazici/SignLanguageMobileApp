import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_dialogs.dart';

// ── Bölüm Başlığı ────────────────────────────────────────────────────────────
class SettingsSection extends StatelessWidget {
  const SettingsSection(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.midGrey,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Ayar Kartı ───────────────────────────────────────────────────────────────
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children, required this.isDark});
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Ayırıcı (Divider) ────────────────────────────────────────────────────────
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }
}

// ── Switch Satırı ────────────────────────────────────────────────────────────
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.helpText,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? helpText;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: helpText != null
          ? () => SettingsDialogs.showHelpDialog(context, isDark, title, helpText!)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            settingsIconBox(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.midGrey),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppTheme.secondaryBlue,
              inactiveThumbColor: isDark ? Colors.white38 : Colors.white,
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aksiyon Satırı ───────────────────────────────────────────────────────────
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.labelColor,
    required this.onTap,
    this.helpText,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? helpText;
  final String label;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: helpText != null
          ? () => SettingsDialogs.showHelpDialog(context, isDark, title, helpText!)
          : null,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            settingsIconBox(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.midGrey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: labelColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segment Seçici — picker bottom sheet açar ────────────────────────────────
class SettingsSegmentButtons<T> extends StatelessWidget {
  const SettingsSegmentButtons({
    super.key,
    required this.items,
    required this.current,
    required this.onChanged,
    required this.isDark,
    this.sheetTitle,
  });

  final List<(T, String)> items;
  final T current;
  final ValueChanged<T> onChanged;
  final bool isDark;
  final String? sheetTitle;

  @override
  Widget build(BuildContext context) {
    final currentLabel = items
        .firstWhere(
          (item) => item.$1 == current,
          orElse: () => items.first,
        )
        .$2;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlueTint,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionPickerSheet<T>(
        title: sheetTitle,
        items: items,
        current: current,
        onChanged: (value) {
          Navigator.pop(context);
          onChanged(value);
        },
      ),
    );
  }
}

class _OptionPickerSheet<T> extends StatelessWidget {
  const _OptionPickerSheet({
    required this.items,
    required this.current,
    required this.onChanged,
    this.title,
  });

  final List<(T, String)> items;
  final T current;
  final ValueChanged<T> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutma çubuğu
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.borderColor),
          ],
          ...items.map((item) {
            final (value, label) = item;
            final isSelected = current == value;
            return InkWell(
              onTap: () => onChanged(value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.borderColor,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlueTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Seçili',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Landmark Legend (Dev Mode) ───────────────────────────────────────────────
class LandmarkLegend extends StatelessWidget {
  const LandmarkLegend({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamera üzerinde gösterilen noktalar:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppTheme.midGrey,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _dotLegend('Kırmızı', 'Sağ el', Colors.redAccent),
                _dotLegend('Mavi', 'Sol el', Colors.blueAccent),
                _dotLegend('Sarı', 'Pose noktaları', Colors.yellowAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotLegend(String label, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text('$label: $desc', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Yardımcı İkon Kutusu ─────────────────────────────────────────────────────
Widget settingsIconBox(IconData icon, Color color) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
