import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Real-time HUD stats bar for Staff Manual Attendance (< 160 lines).
class StaffAttendanceHudCard extends StatelessWidget {
  const StaffAttendanceHudCard({
    super.key,
    required this.totalCount,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.onMarkAllPresent,
  });

  final int totalCount;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final VoidCallback onMarkAllPresent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x330F172A)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : const Color(0x80FFFFFF),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Stat metrics
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        label: context.tr('attendance_stat_total'),
                        value: '$totalCount',
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMetric(
                        label: context.tr('attendance_stat_present'),
                        value: '$presentCount',
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMetric(
                        label: context.tr('attendance_stat_absent'),
                        value: '$absentCount',
                        color: const Color(0xFFEF4444),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMetric(
                        label: context.tr('attendance_stat_leave'),
                        value: '$leaveCount',
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Mark All Present Action Button
                InkWell(
                  onTap: onMarkAllPresent,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.tr('staff_att_mark_all_present'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 22,
      color: isDark ? const Color(0x26FFFFFF) : const Color(0x26000000),
    );
  }
}
