import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

class HolidayCard extends StatelessWidget {
  const HolidayCard({
    super.key,
    required this.holiday,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final AcademicHoliday holiday;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSingleDay = holiday.isSingleDay;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index Badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Main Holiday Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Badges Row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      holiday.titleEn.isNotEmpty ? holiday.titleEn : 'Academic Holiday',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    if (holiday.titleUr.isNotEmpty)
                      Text(
                        holiday.titleUr,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '${holiday.durationDays} ${holiday.durationDays == 1 ? "Day" : "Days"}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    // Applies To Badge
                    _buildAppliesToBadge(holiday.appliesTo),
                  ],
                ),

                const SizedBox(height: 6),

                // Date Range Row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 13,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isSingleDay
                            ? AppFormatters.formatDate(holiday.startDate)
                            : '${AppFormatters.formatDate(holiday.startDate)} → ${AppFormatters.formatDate(holiday.endDate)}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description Snippet (if available)
                if (holiday.descEn.isNotEmpty || holiday.descUr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    holiday.descEn.isNotEmpty ? holiday.descEn : holiday.descUr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                color: isDark ? AppColors.goldLight : AppColors.goldDark,
                visualDensity: VisualDensity.compact,
                tooltip: 'Edit Holiday',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                color: AppColors.rosePrimary,
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete Holiday',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliesToBadge(HolidayAppliesTo appliesTo) {
    switch (appliesTo) {
      case HolidayAppliesTo.studentsOnly:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 10, color: Color(0xFF0284C7)),
              SizedBox(width: 3),
              Text(
                'Students Only',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        );
      case HolidayAppliesTo.staffOnly:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF9333EA).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF9333EA).withValues(alpha: 0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline_rounded, size: 10, color: Color(0xFF9333EA)),
              SizedBox(width: 3),
              Text(
                'Staff Only',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9333EA),
                ),
              ),
            ],
          ),
        );
      case HolidayAppliesTo.all:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_alt_outlined, size: 10, color: AppColors.goldChampagne),
              SizedBox(width: 3),
              Text(
                'All',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldChampagne,
                ),
              ),
            ],
          ),
        );
    }
  }
}
