import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({
    super.key,
    required this.progress,
  });

  final int progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0, 100);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: clamped > 80
                        ? AppColors.emeraldLight
                        : (clamped > 40 ? AppColors.goldPrimary : AppColors.goldDark),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'SESSION COMPLETION PROGRESS',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ],
              ),
              Text(
                '$clamped%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 6,
              width: double.infinity,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clamped / 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.emeraldLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
