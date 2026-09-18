import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstituteTriadFieldCard extends StatelessWidget {
  const InstituteTriadFieldCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isRequired,
    required this.enCtrl,
    required this.enPlaceholder,
    required this.urCtrl,
    required this.urPlaceholder,
    required this.hiCtrl,
    required this.hiPlaceholder,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isRequired;
  final TextEditingController enCtrl;
  final String enPlaceholder;
  final TextEditingController urCtrl;
  final String urPlaceholder;
  final TextEditingController hiCtrl;
  final String hiPlaceholder;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title + (isRequired ? ' *' : ''),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLanguageRow(
            badge: 'EN',
            badgeColor: Colors.blueAccent,
            controller: enCtrl,
            placeholder: enPlaceholder,
            isDark: isDark,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 10),
          _buildLanguageRow(
            badge: 'UR',
            badgeColor: AppColors.emeraldPrimary,
            controller: urCtrl,
            placeholder: urPlaceholder,
            isDark: isDark,
            textDirection: TextDirection.rtl,
            extraBadge: 'Right to Left (RTL)',
          ),
          const SizedBox(height: 10),
          _buildLanguageRow(
            badge: 'HI',
            badgeColor: AppColors.goldPrimary,
            controller: hiCtrl,
            placeholder: hiPlaceholder,
            isDark: isDark,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow({
    required String badge,
    required Color badgeColor,
    required TextEditingController controller,
    required String placeholder,
    required bool isDark,
    required TextDirection textDirection,
    String? extraBadge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                badge,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeColor),
              ),
            ),
            if (extraBadge != null)
              Text(
                extraBadge,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.emeraldLight : AppColors.emeraldPrimary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: TextField(
            controller: controller,
            textDirection: textDirection,
            textAlign: textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.charcoalDark),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.black26),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              border: InputBorder.none,
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}
