import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/attendance/domain/models/student_attendance_model.dart';

/// Luxury Student Attendance Row (< 180 lines).
/// Features Student Avatar, Full Multi-Line Name with Zero Truncation,
/// Roll Number, and Present / Absent / Leave (P / A / L) marking selectors.
class StudentAttendanceRow extends StatelessWidget {
  const StudentAttendanceRow({
    super.key,
    required this.student,
    required this.onStatusChanged,
  });

  final StudentAttendanceItem student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final displayName = student.localizedName(isRtl, context.currentLanguageCode, context);

    // Dynamic accent color based on marked status
    final Color statusAccent = switch (student.status) {
      AttendanceStatus.present => const Color(0xFF10B981),
      AttendanceStatus.absent => const Color(0xFFEF4444),
      AttendanceStatus.leave => const Color(0xFFF59E0B),
    };

    return Container(
      color: switch (student.status) {
        AttendanceStatus.present => Colors.transparent,
        AttendanceStatus.absent => const Color(0xFFEF4444).withValues(alpha: isDark ? 0.08 : 0.04),
        AttendanceStatus.leave => const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.08 : 0.04),
      },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          // 1. Student Avatar with Dynamic Status Ring
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  statusAccent.withValues(alpha: 0.85),
                  statusAccent.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: statusAccent, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: statusAccent.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(displayName, isRtl: isRtl),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Student Name & Roll No (Full Multi-Line Wrap - Zero "...." Truncation)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: isRtl ? 14 : 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('roll_no_prefix', params: {'roll': student.rollNo}),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSharpHistoryPill(isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Present / Absent / Leave (P / A / L) Marking Controls
          _buildPalSelector(isDark),
        ],
      ),
    );
  }

  /// Sharp-Cornered Pill displaying last 3 days history (P / A / L)
  Widget _buildSharpHistoryPill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1.5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(2.5), // Strict sharp corner mandate
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: student.lastThreeDays.map((history) {
          final Color chipColor = switch (history) {
            HistoryDayStatus.present => const Color(0xFF10B981),
            HistoryDayStatus.absent => const Color(0xFFEF4444),
            HistoryDayStatus.leave => const Color(0xFFF59E0B),
          };
          final String chipText = switch (history) {
            HistoryDayStatus.present => 'P',
            HistoryDayStatus.absent => 'A',
            HistoryDayStatus.leave => 'L',
          };

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 0.8),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(1.5), // Sharp inner corner
              border: Border.all(color: chipColor.withValues(alpha: 0.75), width: 0.6),
            ),
            child: Text(
              chipText,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: chipColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Compact 3-State Segmented Toggle for Present, Absent, and Leave
  Widget _buildPalSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.70)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // P - Present
          _buildActionButton(
            label: 'P',
            isActive: student.status == AttendanceStatus.present,
            activeColor: const Color(0xFF10B981),
            isDark: isDark,
            onTap: () => onStatusChanged(AttendanceStatus.present),
          ),
          const SizedBox(width: 3),

          // A - Absent
          _buildActionButton(
            label: 'A',
            isActive: student.status == AttendanceStatus.absent,
            activeColor: const Color(0xFFEF4444),
            isDark: isDark,
            onTap: () => onStatusChanged(AttendanceStatus.absent),
          ),
          const SizedBox(width: 3),

          // L - Leave
          _buildActionButton(
            label: 'L',
            isActive: student.status == AttendanceStatus.leave,
            activeColor: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => onStatusChanged(AttendanceStatus.leave),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
              width: isActive ? 1.0 : 0.7,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isActive
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name, {required bool isRtl}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return isRtl ? 'ط' : 'S';
    if (isRtl) {
      return trimmed.characters.first;
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
