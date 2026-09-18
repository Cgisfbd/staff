import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

class CourseStatsGrid extends StatelessWidget {
  const CourseStatsGrid({
    super.key,
    required this.course,
  });

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTile(
            context,
            title: 'Students',
            value: '${course.studentCount}',
            icon: Icons.people_alt_rounded,
            color: AppColors.emeraldLight,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Classes',
            value: '${course.classCount}',
            icon: Icons.domain_rounded,
            color: AppColors.goldPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Subjects',
            value: '${course.subjectCount}',
            icon: Icons.book_outlined,
            color: AppColors.goldChampagne,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTile(
            context,
            title: 'Books',
            value: '${course.bookCount}',
            icon: Icons.library_books_outlined,
            color: AppColors.amberDark,
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
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
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
