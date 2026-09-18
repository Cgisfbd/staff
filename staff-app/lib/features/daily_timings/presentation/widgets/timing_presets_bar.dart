import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class TimingPresetItem {
  const TimingPresetItem({
    required this.name,
    required this.assembly,
    required this.start,
  });

  final String name;
  final String assembly;
  final String start;
}

class TimingPresetsBar extends StatelessWidget {
  const TimingPresetsBar({
    super.key,
    required this.currentAssembly,
    required this.currentStart,
    required this.onApplyPreset,
  });

  final String currentAssembly;
  final String currentStart;
  final ValueChanged<TimingPresetItem> onApplyPreset;

  static const List<TimingPresetItem> presets = [
    TimingPresetItem(name: '6:00 AM', assembly: '05:45', start: '06:00'),
    TimingPresetItem(name: '6:30 AM', assembly: '06:15', start: '06:30'),
    TimingPresetItem(name: '7:00 AM', assembly: '06:45', start: '07:00'),
    TimingPresetItem(name: '7:30 AM', assembly: '07:15', start: '07:30'),
    TimingPresetItem(name: '8:00 AM', assembly: '07:45', start: '08:00'),
    TimingPresetItem(name: '8:30 AM', assembly: '08:15', start: '08:30'),
    TimingPresetItem(name: '9:00 AM', assembly: '08:45', start: '09:00'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Zap Icon + Label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'PRESETS:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Preset Chips
          ...presets.map((p) {
            final isActive = currentStart == p.start && currentAssembly == p.assembly;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onApplyPreset(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? AppColors.goldPrimary
                          : (isDark ? Colors.white10 : Colors.black12),
                    ),
                  ),
                  child: Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive
                          ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                          : (isDark ? Colors.white70 : AppColors.textLightSecondary),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
