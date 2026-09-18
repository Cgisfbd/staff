import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

/// Ultra-Luxury KPI Summary Deck for Staff Leaves Hub.
/// Displays Pending Approvals, Faculty on Leave Today, and Approved This Month.
class LeaveSummaryDeck extends StatelessWidget {
  const LeaveSummaryDeck({
    super.key,
    required this.stats,
  });

  final StaffLeaveStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. Pending Approvals
          Expanded(
            child: _buildMetricCard(
              context,
              isDark: isDark,
              icon: Icons.hourglass_top_rounded,
              accentColor: const Color(0xFFD97706),
              value: stats.pendingCount.toString(),
              label: 'Pending',
              subtitle: 'Needs Review',
            ),
          ),
          const SizedBox(width: 8),

          // 2. On Leave Today
          Expanded(
            child: _buildMetricCard(
              context,
              isDark: isDark,
              icon: Icons.event_busy_rounded,
              accentColor: const Color(0xFFE11D48),
              value: stats.approvedTodayCount.toString(),
              label: 'On Leave',
              subtitle: 'Today Absent',
            ),
          ),
          const SizedBox(width: 8),

          // 3. Approved This Month
          Expanded(
            child: _buildMetricCard(
              context,
              isDark: isDark,
              icon: Icons.check_circle_rounded,
              accentColor: const Color(0xFF059669),
              value: stats.totalThisMonth.toString(),
              label: 'Approved',
              subtitle: 'This Month',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color accentColor,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.38 : 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 14, color: accentColor),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
