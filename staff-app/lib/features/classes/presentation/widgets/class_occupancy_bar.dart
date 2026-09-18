import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class ClassOccupancyBar extends StatelessWidget {
  const ClassOccupancyBar({
    super.key,
    required this.studentCount,
    required this.capacity,
  });

  final int studentCount;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final occupancy = capacity > 0 ? ((studentCount / capacity) * 100).clamp(0, 100).toInt() : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color statusColor = occupancy > 90
        ? AppColors.rosePrimary
        : (occupancy > 60 ? AppColors.goldPrimary : AppColors.emeraldLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.6),
        borderRadius: BorderRadius.circular(10),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.airline_seat_recline_normal_rounded, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CAPACITY OCCUPANCY',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$studentCount / $capacity ($occupancy%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 5,
              width: double.infinity,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: occupancy / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.7),
                        statusColor,
                      ],
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
