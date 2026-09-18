import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Live Attendance Metrics HUD Bar with counts for Total, Present, Absent, and Leave
class AttendanceHudBar extends StatelessWidget {
  const AttendanceHudBar({
    super.key,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.onMarkAllPresent,
  });

  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final VoidCallback onMarkAllPresent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x381E293B)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                ? AppColors.goldPrimary.withValues(alpha: 0.28)
                : AppColors.goldPrimary.withValues(alpha: 0.22),
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              // 1. All 4 Stat Chips shielded with Auto-Scale Protection
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total Pill
                      _buildStatChip(
                        label: context.tr('attendance_stat_total'),
                        count: totalStudents,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        bgColor: isDark ? const Color(0x3364748B) : const Color(0xFFF1F5F9),
                        borderColor: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 5),

                      // Present Pill (Green)
                      _buildStatChip(
                        label: context.tr('attendance_stat_present'),
                        count: presentCount,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFF10B981).withValues(alpha: 0.14),
                        borderColor: const Color(0xFF10B981).withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 5),

                      // Absent Pill (Red)
                      _buildStatChip(
                        label: context.tr('attendance_stat_absent'),
                        count: absentCount,
                        color: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFEF4444).withValues(alpha: 0.14),
                        borderColor: const Color(0xFFEF4444).withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 5),

                      // Leave Pill (Amber)
                      _buildStatChip(
                        label: context.tr('attendance_stat_leave'),
                        count: leaveCount,
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 2. Quick Action: Mark All Present shielded with scale-down
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMarkAllPresent,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.done_all_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('attendance_all_present_btn'),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
