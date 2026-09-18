import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';

class ClassStatsGrid extends StatelessWidget {
  const ClassStatsGrid({
    super.key,
    required this.classEntity,
  });

  final ClassEntity classEntity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTile(
            context,
            title: 'Enrolled',
            value: '${classEntity.studentCount}',
            icon: Icons.people_alt_rounded,
            color: AppColors.emeraldLight,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Subjects',
            value: '${classEntity.subjectCount}',
            icon: Icons.book_outlined,
            color: AppColors.goldPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Books',
            value: '${classEntity.bookCount}',
            icon: Icons.library_books_outlined,
            color: AppColors.goldChampagne,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Fees',
            value: classEntity.hasFeeStructure ? 'Configured' : 'Pending',
            icon: Icons.receipt_long_rounded,
            color: classEntity.hasFeeStructure ? AppColors.emeraldLight : AppColors.statusLeave,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 10, color: color),
              ),
              const SizedBox(width: 3),
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
                fontSize: 12,
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
