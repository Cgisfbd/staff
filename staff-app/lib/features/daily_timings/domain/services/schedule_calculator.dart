import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';

/// Pure computation engine mirroring ERP's `useMemo` schedule calculator
class ScheduleCalculator {
  const ScheduleCalculator._();

  static const List<int> defaultPeriodDurations = [40, 40, 40, 40, 40, 40, 40, 35];

  /// Converts "HH:mm" (24-hour) string to minutes from midnight
  static int timeToMinutes(String timeStr) {
    if (timeStr.isEmpty) return 0;
    final parts = timeStr.split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return (h * 60) + m;
  }

  /// Converts minutes from midnight into 24-hour "HH:mm" format
  static String minutesToTimeString(int minutes) {
    var normalized = minutes % (24 * 60);
    if (normalized < 0) normalized += 24 * 60;
    final h = (normalized ~/ 60).toString().padLeft(2, '0');
    final m = (normalized % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formats 24-hour "HH:mm" into executive 12-hour AM/PM string (e.g. "07:45 AM")
  static String formatTimeTo12Hour(String timeStr) {
    if (timeStr.isEmpty) return '--:--';
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = (h % 12 == 0) ? 12 : h % 12;
    final hStr = hour12.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    return '$hStr:$mStr $period';
  }

  /// Live 2-way schedule calculator dynamically injecting lunch break
  static ScheduleComputationResult computeSchedule({
    required String startTime,
    required List<int> periodDurations,
    required int lunchDurationMinutes,
    required int lunchAfterPeriod,
  }) {
    final startMins = timeToMinutes(startTime);
    final List<CalculatedPeriod> periods = [];
    final lDur = lunchDurationMinutes > 0 ? lunchDurationMinutes : 15;

    var current = startMins;
    int? lunchStartMins;
    int? lunchEndMins;

    for (int i = 1; i <= 8; i++) {
      final defaultSlotDur = i == 8 ? 35 : 40;
      final dur = (i - 1 < periodDurations.length && periodDurations[i - 1] > 0)
          ? periodDurations[i - 1]
          : defaultSlotDur;

      final sStr = minutesToTimeString(current);
      final end = current + dur;
      final eStr = minutesToTimeString(end);

      periods.add(
        CalculatedPeriod(
          slot: i,
          label: 'Period $i',
          startTime: sStr,
          endTime: eStr,
          durationMinutes: dur,
          timeFormatted: '${formatTimeTo12Hour(sStr)} – ${formatTimeTo12Hour(eStr)}',
        ),
      );

      current = end;

      // If lunch is configured to happen after this period (1..7)
      if (lunchAfterPeriod > 0 && i == lunchAfterPeriod) {
        lunchStartMins = current;
        lunchEndMins = lunchStartMins + lDur;
        current = lunchEndMins; // Subsequent period starts from lunch end
      }
    }

    final lunchStartStr = lunchStartMins != null ? minutesToTimeString(lunchStartMins) : '';
    final lunchEndStr = lunchEndMins != null ? minutesToTimeString(lunchEndMins) : '';
    final endTimeStr = minutesToTimeString(current);

    final totalTeachingMins = periods.fold<int>(0, (acc, p) => acc + p.durationMinutes);
    final hours = totalTeachingMins ~/ 60;
    final mins = totalTeachingMins % 60;
    final instructionText = hours > 0 && mins > 0
        ? '${hours}h ${mins}m Classes'
        : (hours > 0 ? '${hours}h Classes' : '${mins}m Classes');

    return ScheduleComputationResult(
      periods: periods,
      lunchAfterPeriod: lunchAfterPeriod,
      isLunchEnabled: lunchAfterPeriod > 0,
      lunchStart: lunchStartStr,
      lunchEnd: lunchEndStr,
      lunchDurationMinutes: lDur,
      endTime: endTimeStr,
      totalTeachingMins: totalTeachingMins,
      instructionText: instructionText,
    );
  }
}
