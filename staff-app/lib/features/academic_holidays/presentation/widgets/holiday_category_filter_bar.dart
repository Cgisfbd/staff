import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class HolidayCategoryFilterBar extends StatelessWidget {
  const HolidayCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.allCount,
    required this.religiousCount,
    required this.nationalCount,
    required this.institutionalCount,
    required this.onSelectCategory,
  });

  final String selectedCategory;
  final int allCount;
  final int religiousCount;
  final int nationalCount;
  final int institutionalCount;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {'id': 'ALL', 'label': 'All', 'count': allCount},
      {'id': 'RELIGIOUS', 'label': 'Religious', 'count': religiousCount},
      {'id': 'NATIONAL', 'label': 'National', 'count': nationalCount},
      {'id': 'INSTITUTIONAL', 'label': 'Madrasa', 'count': institutionalCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final id = cat['id'] as String;
          final label = cat['label'] as String;
          final count = cat['count'] as int;
          final isSelected = selectedCategory == id;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectCategory(id),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.goldPrimary
                          : (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ).boxShadow!.first,
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.25)
                              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
