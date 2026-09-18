import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/attendance/presentation/pages/staff_attendance_history_page.dart';

/// Glassmorphic Dashboard Summary Card for Teacher's Personal Attendance (< 175 lines).
class TeacherAttendanceCard extends StatelessWidget {
  const TeacherAttendanceCard({
    super.key,
    this.presentDays = 21,
    this.absentDays = 1,
    this.leaveDays = 2,
    this.attendanceRate = '91.3%',
  });

  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final String attendanceRate;

  void _openHistory(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const StaffAttendanceHistoryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openHistory(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0x3D1E293B),
                          const Color(0x240F172A),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.95),
                          const Color(0xFFFBF8F3).withValues(alpha: 0.88),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppColors.goldPrimary.withValues(alpha: 0.38)
                      : AppColors.goldPrimary.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                        .withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openHistory(context),
                  borderRadius: BorderRadius.circular(18),
                  splashColor: AppColors.goldPrimary.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Header Row: Title + "View History" Action Pill
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.goldPrimary.withValues(alpha: 0.25),
                                  AppColors.goldPrimary.withValues(alpha: 0.12),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.45),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.goldPrimary,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('teacher_attendance_title'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  context.tr('teacher_attendance_subtitle'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // View History Action Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x33000000) : const Color(0x12C5A059),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.40),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr('teacher_attendance_history'),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 4-Column KPI Stats Deck
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              label: context.tr('teacher_attendance_present'),
                              value: '$presentDays',
                              color: AppColors.statusPresent,
                              isDark: isDark,
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              label: context.tr('teacher_attendance_leaves'),
                              value: '$leaveDays',
                              color: AppColors.statusLeave,
                              isDark: isDark,
                              icon: Icons.timelapse_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              label: context.tr('teacher_attendance_absent'),
                              value: '$absentDays',
                              color: AppColors.statusAbsent,
                              isDark: isDark,
                              icon: Icons.cancel_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              label: context.tr('teacher_attendance_rate'),
                              value: attendanceRate,
                              color: AppColors.goldPrimary,
                              isDark: isDark,
                              icon: Icons.pie_chart_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2B1E293B) : const Color(0x52F1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
          width: 0.9,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
