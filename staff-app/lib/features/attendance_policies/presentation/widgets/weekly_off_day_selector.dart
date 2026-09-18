import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class WeeklyOffDaySelector extends StatelessWidget {
  const WeeklyOffDaySelector({
    super.key,
    required this.selectedDay,
    required this.onSelectDay,
  });

  final String selectedDay;
  final ValueChanged<String> onSelectDay;

  static const List<Map<String, String>> daysOfWeek = [
    {'id': 'MONDAY', 'short': 'Mon', 'urdu': 'پیر'},
    {'id': 'TUESDAY', 'short': 'Tue', 'urdu': 'منگل'},
    {'id': 'WEDNESDAY', 'short': 'Wed', 'urdu': 'بدھ'},
    {'id': 'THURSDAY', 'short': 'Thu', 'urdu': 'جمعرات'},
    {'id': 'FRIDAY', 'short': 'Fri', 'urdu': 'جمعہ'},
    {'id': 'SATURDAY', 'short': 'Sat', 'urdu': 'ہفتہ'},
    {'id': 'SUNDAY', 'short': 'Sun', 'urdu': 'اتوار'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDayInfo = daysOfWeek.firstWhere(
      (d) => d['id'] == selectedDay.toUpperCase(),
      orElse: () => daysOfWeek[4], // Friday default
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.rosePrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event_busy_rounded,
                        size: 16,
                        color: AppColors.rosePrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Weekly Off Day',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.charcoalDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.rosePrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ہفتہ وار تعطیل',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.rosePrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Official institutional rest day',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rosePrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.rosePrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Off: ${currentDayInfo['short']}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.rosePrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 7-Day Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: daysOfWeek.map((day) {
                  final isSelected = selectedDay.toUpperCase() == day['id'];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelectDay(day['id']!),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [AppColors.goldPrimary, AppColors.goldDark],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.goldPrimary
                                    : (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    day['short']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    day['urdu']!,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white70
                                          : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
