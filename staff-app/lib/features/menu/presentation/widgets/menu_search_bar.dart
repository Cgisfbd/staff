import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Ultra-Premium Frosted Search Bar for the Mega Menu Hub.
class MenuSearchBar extends StatelessWidget {
  const MenuSearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.searchQuery = '',
    this.totalModulesCount = 10,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String searchQuery;
  final int totalModulesCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2EFFFFFF) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppColors.goldPrimary.withValues(alpha: 0.30)
              : AppColors.goldPrimary.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.goldChampagne : AppColors.goldPrimary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: AppColors.goldPrimary,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.tr('menu_search_hint'),
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                isDense: true,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              color: isDark ? AppColors.goldChampagne : AppColors.textLightMuted,
              onPressed: onClear,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
