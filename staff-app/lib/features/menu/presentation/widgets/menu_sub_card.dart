import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';

/// Amazon-Style Icon-Over-Text Clean Action Tile.
class MenuSubCard extends StatelessWidget {
  const MenuSubCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MenuSubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top: Circular Icon Medallion
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF2A3447),
                            const Color(0xFF131A26),
                          ]
                        : [
                            const Color(0xFFFFFDF9),
                            const Color(0xFFEDE5D5),
                          ],
                  ),
                  border: Border.all(
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 21,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                    if (item.badgeText != null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.statusPresent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF131A26) : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Bottom: Text Underneath
              Text(
                item.localizedTitle(context),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
