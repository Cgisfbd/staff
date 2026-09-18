import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';

class TimingSequenceBanner extends StatelessWidget {
  const TimingSequenceBanner({
    super.key,
    required this.timings,
    required this.computation,
  });

  final ScheduleTimingsEntity timings;
  final ScheduleComputationResult computation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Assembly Time
            _buildTimePill(
              context,
              label: 'Assembly',
              time: ScheduleCalculator.formatTimeTo12Hour(timings.assemblyTime),
              color: AppColors.goldPrimary,
              isDark: isDark,
            ),

            _buildArrow(isDark),

            // Classes Start
            _buildTimePill(
              context,
              label: 'Start',
              time: ScheduleCalculator.formatTimeTo12Hour(timings.startTime),
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),

            if (computation.isLunchEnabled) ...[
              _buildArrow(isDark),
              // Lunch Break
              _buildTimePill(
                context,
                label: 'Lunch (P${computation.lunchAfterPeriod})',
                time:
                    '${ScheduleCalculator.formatTimeTo12Hour(computation.lunchStart)} – ${ScheduleCalculator.formatTimeTo12Hour(computation.lunchEnd)}',
                color: const Color(0xFFD97706),
                isDark: isDark,
              ),
            ],

            _buildArrow(isDark),

            // Dismissal
            _buildTimePill(
              context,
              label: 'Dismissal',
              time: ScheduleCalculator.formatTimeTo12Hour(computation.endTime),
              color: AppColors.goldDark,
              isDark: isDark,
            ),

            const SizedBox(width: 8),

            // Instruction Duration Badge (Haute Horlogerie Champagne Gold)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                computation.instructionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(
    BuildContext context, {
    required String label,
    required String time,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textLightSecondary,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '→',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }
}
