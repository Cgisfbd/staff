import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

/// Zero-Swipe Responsive KPI Deck for Duty Allocation
class DutySummaryDeck extends StatelessWidget {
  const DutySummaryDeck({
    super.key,
    required this.stats,
  });

  final StaffDutyStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. Total Faculty
          Expanded(
            child: _buildMetricCard(
              title: 'Total Staff',
              count: stats.totalStaff,
              badge: 'Faculty',
              icon: Icons.groups_rounded,
              color: AppColors.goldDark,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Classes Covered
          Expanded(
            child: _buildMetricCard(
              title: 'Classes',
              count: stats.totalClassesCovered,
              badge: 'Assigned',
              icon: Icons.class_rounded,
              color: const Color(0xFF059669),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Books Allocated
          Expanded(
            child: _buildMetricCard(
              title: 'Kitabs',
              count: stats.totalBooksAllocated,
              badge: 'Allocated',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFFD97706),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required String badge,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.38 : 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.25),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, size: 13, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
