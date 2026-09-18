import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

class SessionStudentStatsGrid extends StatelessWidget {
  const SessionStudentStatsGrid({
    super.key,
    required this.stats,
  });

  final SessionStudentStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'STUDENT ENROLLMENT & ATTRITION',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: 'Total',
                value: '${stats.total}',
                icon: Icons.people_alt_rounded,
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: 'Active',
                value: '${stats.active}',
                icon: Icons.person_add_rounded,
                color: AppColors.emeraldLight,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: 'Graduated',
                value: '${stats.graduated}',
                icon: Icons.school_rounded,
                color: AppColors.goldChampagne,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: 'Dropouts',
                value: '-${stats.dropout}',
                icon: Icons.person_remove_rounded,
                color: AppColors.rosePrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 10, color: color),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
