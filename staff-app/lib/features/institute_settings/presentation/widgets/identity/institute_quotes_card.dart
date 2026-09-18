import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstituteQuotesCard extends StatelessWidget {
  const InstituteQuotesCard({
    super.key,
    required this.quotesMainCtrl,
    required this.quotesTranslationCtrl,
    required this.onChanged,
  });

  final TextEditingController quotesMainCtrl;
  final TextEditingController quotesTranslationCtrl;
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
              const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.goldPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'INSTITUTE QUOTES',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: quotesMainCtrl,
            label: 'Main Quote (Type in Any Language) *',
            placeholder: 'Type quote in any language (Arabic, Urdu, English, Hindi)',
            icon: Icons.bookmark_rounded,
            iconColor: AppColors.goldPrimary,
            isDark: isDark,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: quotesTranslationCtrl,
            label: 'Translation / Meaning (Optional)',
            placeholder: 'Enter translation or leave blank',
            icon: Icons.translate_rounded,
            iconColor: Colors.cyan,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textDirection: textDirection,
                  textAlign: textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.charcoalDark),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.black26),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
