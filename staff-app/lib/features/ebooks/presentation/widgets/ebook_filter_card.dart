import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Compact, Low-Profile Cascading Filter Bar (< 160 lines).
/// Renders Course & Class dropdowns side-by-side in a single row
/// with full text visibility (zero "...." truncation) via adaptive scaling and multi-line wrapping.
class EbookFilterCard extends StatelessWidget {
  const EbookFilterCard({
    super.key,
    required this.courses,
    required this.classes,
    required this.selectedCourse,
    required this.selectedClass,
    required this.totalBooksCount,
    required this.onCourseChanged,
    required this.onClassChanged,
  });

  final List<CourseEntity> courses;
  final List<ClassEntity> classes;
  final CourseEntity? selectedCourse;
  final ClassEntity? selectedClass;
  final int totalBooksCount;
  final ValueChanged<CourseEntity?> onCourseChanged;
  final ValueChanged<ClassEntity?> onClassChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            borderRadius: BorderRadius.circular(16),
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
          child: Row(
            children: [
              // 1. Course Dropdown (Side-by-Side Left with Full Text Display)
              Expanded(
                child: _buildCompactDropdown<CourseEntity>(
                  context: context,
                  isDark: isDark,
                  icon: Icons.school_rounded,
                  label: context.tr('exam_sel_course'),
                  value: selectedCourse,
                  items: courses,
                  itemLabel: (c) => c.localizedName(isRtl),
                  onChanged: onCourseChanged,
                ),
              ),
              const SizedBox(width: 8),

              // 2. Class Dropdown (Side-by-Side Right with Full Text Display)
              Expanded(
                child: _buildCompactDropdown<ClassEntity>(
                  context: context,
                  isDark: isDark,
                  icon: Icons.class_rounded,
                  label: context.tr('exam_sel_class'),
                  value: selectedClass,
                  items: classes,
                  itemLabel: (c) => c.localizedName(isRtl),
                  onChanged: onClassChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDropdown<T>({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.30)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
          ),
          dropdownColor: isDark ? const Color(0xFF161F2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          hint: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.goldPrimary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          // Custom Selected Item Builder: Wraps full text with zero "...." truncation!
          selectedItemBuilder: (BuildContext ctx) {
            return items.map((T item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(icon, size: 13, color: AppColors.goldPrimary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          itemLabel(item),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          // Dropdown Popup Menu Items: Full multi-line text display
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: AppColors.goldPrimary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        itemLabel(item),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
