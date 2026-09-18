import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class _NavItem {
  const _NavItem({required this.icon, required this.labelKey});
  final IconData icon;
  final String labelKey;
}

/// Amazon-Style Docked Liquid Crystal Glass Bottom Navigation Bar (< 130 lines).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.dashboard_rounded, labelKey: 'nav_home'),
    _NavItem(icon: Icons.fact_check_rounded, labelKey: 'nav_attendance'),
    _NavItem(icon: Icons.menu_book_rounded, labelKey: 'nav_ebooks'),
    _NavItem(icon: Icons.menu_rounded, labelKey: 'nav_menu'),
    _NavItem(icon: Icons.tune_rounded, labelKey: 'nav_settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xD90F172A) : const Color(0xEBFFFFFF),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0xB3FFFFFF),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 58,
              child: Row(
                children: List.generate(_items.length, (index) {
                  final isSelected = currentIndex == index;
                  final item = _items[index];

                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(index),
                      splashColor: AppColors.goldPrimary.withValues(alpha: 0.12),
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Amazon-Style Active Top Indicator Accent Line
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            height: 3.5,
                            width: isSelected ? 40 : 0,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.goldPrimary : Colors.transparent,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const Spacer(flex: 1),
                          Icon(
                            item.icon,
                            size: isSelected ? 23 : 21,
                            color: isSelected
                                ? AppColors.goldPrimary
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                context.tr(item.labelKey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.goldPrimary
                                      : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
