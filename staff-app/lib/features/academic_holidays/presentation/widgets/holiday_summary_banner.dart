import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class HolidaySummaryBanner extends StatelessWidget {
  const HolidaySummaryBanner({
    super.key,
    required this.filteredCount,
    required this.totalCount,
    required this.totalDaysOff,
  });

  final int filteredCount;
  final int totalCount;
  final int totalDaysOff;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                children: [
                  const TextSpan(text: 'Listed: '),
                  TextSpan(
                    text: '$filteredCount',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  if (filteredCount != totalCount)
                    TextSpan(
                      text: ' of $totalCount total',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: 13,
                      color: AppColors.goldPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalDaysOff Total Days Off',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
