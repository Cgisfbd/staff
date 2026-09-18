import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class PolicyCardMinimumAttendance extends StatelessWidget {
  const PolicyCardMinimumAttendance({
    super.key,
    required this.percent,
    required this.onChanged,
  });

  final int percent;
  final ValueChanged<int> onChanged;

  static const List<int> presets = [65, 70, 75, 80, 85];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.percent_rounded,
                        size: 16,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minimum Attendance',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          Text(
                            'Exam Eligibility Threshold',
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
                  color: AppColors.goldPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.goldPrimary,
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
              thumbColor: AppColors.goldPrimary,
              overlayColor: AppColors.goldPrimary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: percent.toDouble().clamp(50, 95),
              min: 50,
              max: 95,
              divisions: 9,
              onChanged: (val) => onChanged(val.round()),
            ),
          ),

          // Segmented Presets
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: presets.map((p) {
                final isSelected = percent == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF262C36) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$p%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.goldPrimary
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Dynamic Policy Impact Note
          Row(
            children: [
              const Icon(Icons.info_outline, size: 12, color: AppColors.goldPrimary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Below $percent% flags student exam ineligibility in registers.',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
