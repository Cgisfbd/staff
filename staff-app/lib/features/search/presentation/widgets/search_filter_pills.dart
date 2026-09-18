import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/search/domain/models/search_result_item.dart';

/// Interactive Horizontal Filter Pills for Search Categories (< 100 lines).
class SearchFilterPills extends StatelessWidget {
  const SearchFilterPills({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final SearchCategory? selectedCategory;
  final ValueChanged<SearchCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      (null, context.tr('search_all'), Icons.auto_awesome_rounded),
      (SearchCategory.student, context.tr('search_students'), Icons.school_outlined),
      (SearchCategory.action, context.tr('search_actions'), Icons.bolt_rounded),
      (SearchCategory.notice, context.tr('search_notices'), Icons.campaign_outlined),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (cat, label, icon) = categories[index];
          final isSelected = selectedCategory == cat;

          return InkWell(
            onTap: () => onCategorySelected(cat),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.goldPrimary
                    : (isDark ? const Color(0x380F172A) : Colors.white.withValues(alpha: 0.85)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.goldLight
                      : (isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000)),
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.goldLight : AppColors.goldPrimary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
