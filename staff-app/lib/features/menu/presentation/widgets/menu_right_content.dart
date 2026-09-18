import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';
import 'package:staff_app/features/menu/presentation/widgets/menu_sub_card.dart';

/// Amazon-Style Clean Icon Grid Viewport with Compact ERP-Grade Sub-Categories.
class MenuRightContent extends StatefulWidget {
  const MenuRightContent({
    super.key,
    required this.category,
    required this.onSubItemTap,
  });

  final MenuCategory category;
  final ValueChanged<MenuSubItem> onSubItemTap;

  @override
  State<MenuRightContent> createState() => _MenuRightContentState();
}

class _MenuRightContentState extends State<MenuRightContent> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.category;
    final hasSections = category.sections != null && category.sections!.isNotEmpty;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).padding.bottom + 85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Department Header: Title + Subtitle + Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.localizedTitle(context),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        category.localizedSubtitle(context),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.goldPrimary.withValues(alpha: 0.16)
                        : AppColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.goldChampagne.withValues(alpha: 0.5)
                          : AppColors.goldDark.withValues(alpha: 0.45),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${category.items.length}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Hairline Divider
          Container(
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Grid Content (Grouped by Sub-Category or Flat)
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final crossAxisCount = availableWidth > 420
                  ? 4
                  : (availableWidth > 210 ? 3 : 2);
              const double spacing = 6.0;
              final double itemWidth =
                  ((availableWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount).floorToDouble();

              if (hasSections) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: category.sections!.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compact Section Header Banner
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.16),
                                        AppColors.goldDark.withValues(alpha: isDark ? 0.14 : 0.08),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.goldChampagne.withValues(alpha: 0.45)
                                          : AppColors.goldDark.withValues(alpha: 0.35),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Icon(
                                    section.icon,
                                    size: 12,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textDarkPrimary
                                          : AppColors.textLightPrimary,
                                      letterSpacing: -0.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0x22131A26)
                                        : const Color(0x12C5A059),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.goldChampagne.withValues(alpha: 0.35)
                                          : AppColors.goldDark.withValues(alpha: 0.3),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    '${section.items.length}',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.goldChampagne
                                          : AppColors.goldDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Section Subtle Hairline Divider
                          Container(
                            height: 0.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Clean Wrap Layout - ZERO DEAD SPACE
                          Wrap(
                            spacing: spacing,
                            runSpacing: 6,
                            children: section.items.map((item) {
                              return SizedBox(
                                width: itemWidth,
                                child: MenuSubCard(
                                  item: item,
                                  onTap: () => widget.onSubItemTap(item),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }

              // Flat Wrap fallback when category has no sections
              return Wrap(
                spacing: spacing,
                runSpacing: 6,
                children: category.items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: MenuSubCard(
                      item: item,
                      onTap: () => widget.onSubItemTap(item),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
