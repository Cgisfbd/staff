import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/lunch_slot_picker_sheet.dart';

class TimingStatCards extends StatelessWidget {
  const TimingStatCards({
    super.key,
    required this.timings,
    required this.computation,
    required this.onAssemblyTimeChanged,
    required this.onStartTimeChanged,
    required this.onLunchSlotChanged,
    required this.onLunchDurationChanged,
  });

  final ScheduleTimingsEntity timings;
  final ScheduleComputationResult computation;
  final ValueChanged<String> onAssemblyTimeChanged;
  final ValueChanged<String> onStartTimeChanged;
  final ValueChanged<int> onLunchSlotChanged;
  final ValueChanged<int> onLunchDurationChanged;

  Future<void> _pickTime({
    required BuildContext context,
    required String currentTimeStr,
    required ValueChanged<String> onSelected,
  }) async {
    final parts = currentTimeStr.split(':');
    final initialHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFC5A059),
                    onPrimary: Colors.black,
                    surface: Color(0xFF1E232F),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFC5A059),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      onSelected('$h:$m');
    }
  }

  void _openLunchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LunchSlotPickerSheet(
        currentSlot: timings.lunchAfterPeriod,
        currentDuration: timings.lunchDurationMinutes,
        onSlotSelected: onLunchSlotChanged,
        onDurationChanged: onLunchDurationChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Row 1: Assembly (01) & Classes Start (02)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                slotNumber: '01',
                title: 'Assembly & Prayer',
                subtitle: 'Morning Ingress',
                displayTime: ScheduleCalculator.formatTimeTo12Hour(timings.assemblyTime),
                accentColor: AppColors.goldPrimary,
                icon: Icons.wb_twilight_rounded,
                isDark: isDark,
                onTap: () => _pickTime(
                  context: context,
                  currentTimeStr: timings.assemblyTime,
                  onSelected: onAssemblyTimeChanged,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                context,
                slotNumber: '02',
                title: 'Classes Start',
                subtitle: 'P1 Begins',
                displayTime: ScheduleCalculator.formatTimeTo12Hour(timings.startTime),
                accentColor: const Color(0xFF10B981),
                icon: Icons.notifications_active_outlined,
                isDark: isDark,
                onTap: () => _pickTime(
                  context: context,
                  currentTimeStr: timings.startTime,
                  onSelected: onStartTimeChanged,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 2: Lunch Break (03) & Classes End (04)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                slotNumber: '03',
                title: 'Lunch Break',
                subtitle: timings.lunchAfterPeriod > 0
                    ? 'After Period ${timings.lunchAfterPeriod}'
                    : 'No Lunch Break',
                displayTime: computation.isLunchEnabled
                    ? '${ScheduleCalculator.formatTimeTo12Hour(computation.lunchStart)} – ${ScheduleCalculator.formatTimeTo12Hour(computation.lunchEnd)}'
                    : 'Disabled',
                accentColor: const Color(0xFF059669),
                icon: Icons.restaurant_rounded,
                isDark: isDark,
                durationBadge: computation.isLunchEnabled
                    ? '${timings.lunchDurationMinutes}m'
                    : null,
                onTap: () => _openLunchSheet(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                context,
                slotNumber: '04',
                title: 'Classes End',
                subtitle: 'Period 8 Dismissal',
                displayTime: ScheduleCalculator.formatTimeTo12Hour(computation.endTime),
                accentColor: const Color(0xFFD97706),
                icon: Icons.dark_mode_outlined,
                isDark: isDark,
                isReadOnly: true,
                onTap: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String slotNumber,
    required String title,
    required String subtitle,
    required String displayTime,
    required Color accentColor,
    required IconData icon,
    required bool isDark,
    String? durationBadge,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
            alpha: isDark ? 0.40 : 0.85,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.30 : 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.10 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon + Title + Slot#
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: accentColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black45,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Slot pill or duration badge
                if (durationBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      durationBadge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      slotNumber,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),

            // Middle Display Time
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                displayTime,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // Bottom Action Label / Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isReadOnly ? 'Auto-calculated' : 'Tap to adjust',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isReadOnly
                          ? (isDark ? Colors.white38 : Colors.black38)
                          : accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isReadOnly)
                  Icon(
                    Icons.edit_calendar_outlined,
                    size: 11,
                    color: accentColor,
                  )
                else
                  Icon(
                    Icons.lock_clock_outlined,
                    size: 11,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
