import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/presentation/widgets/class_form_sheet.dart';
import 'package:staff_app/features/classes/presentation/widgets/class_occupancy_bar.dart';
import 'package:staff_app/features/classes/presentation/widgets/class_stats_grid.dart';
import 'package:staff_app/features/classes/presentation/widgets/delete_class_dialog.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.classEntity,
    required this.courses,
    required this.isExpanded,
    required this.onTap,
    required this.isAdmin,
  });

  final ClassEntity classEntity;
  final List<CourseEntity> courses;
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
                            child: const Icon(Icons.domain_rounded, size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 10),

                          // English & Urdu Titles and Department
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classEntity.nameEnglish,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (classEntity.nameUrdu != null && classEntity.nameUrdu!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    classEntity.nameUrdu!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.3 : 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Text(
                                      classEntity.courseName,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                      ),
                                    ),
                                  ),
                                ),
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
                                    onPressed: () => ClassFormSheet.show(
                                      context,
                                      courses: courses,
                                      initialClass: classEntity,
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.goldPrimary),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                  Container(width: 1, height: 16, color: AppColors.goldPrimary.withValues(alpha: 0.2)),
                                  IconButton(
                                    onPressed: () => DeleteClassDialog.show(context, classEntity: classEntity),
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

                      // Collapsed Mini Occupancy Preview
                      if (!isExpanded) ...[
                        const SizedBox(height: 10),
                        ClassOccupancyBar(
                          studentCount: classEntity.studentCount,
                          capacity: classEntity.capacity,
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
                        const SizedBox(height: 12),

                        // 1. Detailed Occupancy Gauge
                        ClassOccupancyBar(
                          studentCount: classEntity.studentCount,
                          capacity: classEntity.capacity,
                        ),
                        const SizedBox(height: 12),

                        // 2. Class Stats (Enrolled, Subjects, Books, Fees)
                        ClassStatsGrid(classEntity: classEntity),
                        const SizedBox(height: 12),

                        // 3. Footer Stream Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded, size: 12, color: AppColors.emeraldLight),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Active Section Registered',
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
                                    'Manage Subjects',
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
