import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';

abstract class DailyTimingsRepository {
  Future<Either<Failure, ScheduleTimingsEntity>> getScheduleTimings({
    required String academicYearId,
  });

  Future<Either<Failure, ScheduleTimingsEntity>> upsertScheduleTimings({
    required String academicYearId,
    required ScheduleTimingsEntity timings,
  });
}
