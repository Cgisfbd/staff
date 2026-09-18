import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/presentation/widgets/course_form_sheet.dart';
import 'package:staff_app/features/courses/presentation/widgets/course_stats_grid.dart';
import 'package:staff_app/features/courses/presentation/widgets/delete_course_dialog.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.isExpanded,
    required this.onTap,
    required this.isAdmin,
  });

  final CourseEntity course;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? (isExpanded ? 0.50 : 0.38) : (isExpanded ? 0.95 : 0.88)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isExpanded
                    ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.55 : 0.45)
                    : (isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.20)),
                width: isExpanded ? 1.2 : 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: isExpanded
                      ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.12)
                      : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: isExpanded ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.goldDark, AppColors.goldPrimary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.school_rounded, size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 10),

                          // English & Urdu Titles (Natural multi-line wrapping, zero dots)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.nameEnglish,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (course.nameUrdu != null && course.nameUrdu!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    course.nameUrdu!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Admin Actions (Edit & Delete)
                          if (isAdmin) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.3 : 0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.25),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => CourseFormSheet.show(context, initialCourse: course),
                                    icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.goldPrimary),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                  Container(width: 1, height: 16, color: AppColors.goldPrimary.withValues(alpha: 0.2)),
                                  IconButton(
                                    onPressed: () => DeleteCourseDialog.show(context, course: course),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.rosePrimary),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],

                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark ? Colors.white54 : Colors.black45,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Collapsed quick preview (Natural wrap, no dots)
                      if (!isExpanded && course.description != null && course.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          course.description!,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],

                      // Expanded Body
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.goldPrimary.withValues(alpha: 0.2),
                        ),
                        if (course.description != null && course.description!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              course.description!,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // 4 Analytics Grids
                        CourseStatsGrid(course: course),
                        const SizedBox(height: 12),

                        // Footer Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.goldPrimary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Curriculum stream active',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Classes linked',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 13,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
