import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/period_duration_dialog.dart';

class PeriodsGrid extends StatelessWidget {
  const PeriodsGrid({
    super.key,
    required this.computation,
    required this.onPeriodDurationChanged,
  });

  final ScheduleComputationResult computation;
  final void Function(int index, int duration) onPeriodDurationChanged;

  void _showDurationDialog(BuildContext context, CalculatedPeriod period, int index) {
    showDialog<void>(
      context: context,
      builder: (_) => PeriodDurationDialog(
        periodLabel: period.label,
        currentDuration: period.durationMinutes,
        onDurationSaved: (newDuration) => onPeriodDurationChanged(index, newDuration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.view_timeline_rounded,
                  size: 15,
                  color: AppColors.goldPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PERIOD SCHEDULE & INSTRUCTION SLOTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${computation.periods.length} Slots',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white70 : AppColors.textLightSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of Periods with dynamic lunch insertion
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: computation.periods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final period = computation.periods[index];
            final isLunchAfterThis = computation.isLunchEnabled &&
                computation.lunchAfterPeriod == period.slot;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Period Card
                _buildPeriodCard(
                  context,
                  period: period,
                  index: index,
                  isDark: isDark,
                ),

                // Injected Lunch Break Banner if lunch is after this period
                if (isLunchAfterThis) ...[
                  const SizedBox(height: 8),
                  _buildLunchBreakBanner(context, isDark: isDark),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPeriodCard(
    BuildContext context, {
    required CalculatedPeriod period,
    required int index,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _showDurationDialog(context, period, index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
            alpha: isDark ? 0.40 : 0.85,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.goldPrimary.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Slot Circle Avatar with Haute Horlogerie Gold Gradient
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${period.slot}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Period Label + Formatted Interval
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    period.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    period.timeFormatted,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Duration Pill Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.goldPrimary.withValues(alpha: 0.12)
                    : AppColors.goldPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                  width: 0.9,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 13,
                    color: AppColors.goldPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${period.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLunchBreakBanner(BuildContext context, {required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.35 : 0.85,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 16,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lunch Break & Recess',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${ScheduleCalculator.formatTimeTo12Hour(computation.lunchStart)} – ${ScheduleCalculator.formatTimeTo12Hour(computation.lunchEnd)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${computation.lunchDurationMinutes} min',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: Color(0xFFD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
