import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';

/// Ultra-Luxury Sculpted Navigation Rail for Mega Menu Hub.
class MenuLeftRail extends StatelessWidget {
  const MenuLeftRail({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<MenuCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 82,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0x33131A26),
                  const Color(0x1F0F1117),
                ]
              : [
                  Colors.white.withValues(alpha: 0.90),
                  const Color(0xFFFBF8F3).withValues(alpha: 0.80),
                ],
        ),
        border: BorderDirectional(
          end: BorderSide(
            color: isDark
                ? AppColors.goldPrimary.withValues(alpha: 0.25)
                : AppColors.goldPrimary.withValues(alpha: 0.28),
            width: 1.0,
          ),
        ),
      ),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          0,
          6,
          0,
          MediaQuery.of(context).padding.bottom + 85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCategorySelected(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.goldPrimary.withValues(alpha: 0.16)
                          : Colors.white)
                      : Colors.transparent,
                  border: BorderDirectional(
                    start: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                          : Colors.transparent,
                      width: 3.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Soft Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.goldPrimary.withValues(alpha: 0.22)
                                : AppColors.goldPrimary.withValues(alpha: 0.14))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: isSelected ? 21 : 19,
                          color: isSelected
                              ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Category Short Label
                    Text(
                      cat.localizedShortLabel(context),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                            : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                        letterSpacing: isSelected ? 0.2 : 0.0,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
