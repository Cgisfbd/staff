import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';

class PolicySummaryPill extends StatelessWidget {
  const PolicySummaryPill({
    super.key,
    required this.policy,
    required this.weeklyOffShort,
  });

  final AttendancePolicy policy;
  final String weeklyOffShort;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(
              'Off: $weeklyOffShort',
              AppColors.rosePrimary,
            ),
            _buildDot(isDark),
            _buildItem(
              '${policy.minimumAttendancePercent}% Req',
              AppColors.goldPrimary,
            ),
            _buildDot(isDark),
            _buildItem(
              '${policy.annualStudentLeaveQuota}d Std',
              const Color(0xFFEA580C),
            ),
            _buildDot(isDark),
            _buildItem(
              '${policy.annualStaffLeaveQuota}d Staff',
              const Color(0xFF9333EA),
            ),
            _buildDot(isDark),
            _buildItem(
              '${policy.consecutiveAbsentDropoutDays}d Drop',
              AppColors.rosePrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _buildDot(bool isDark) {
    return Container(
      width: 3.5,
      height: 3.5,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.black26,
        shape: BoxShape.circle,
      ),
    );
  }
}
