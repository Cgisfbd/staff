import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/daily_timings/data/datasources/daily_timings_remote_datasource.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/repositories/daily_timings_repository.dart';

class DailyTimingsRepositoryImpl implements DailyTimingsRepository {
  DailyTimingsRepositoryImpl({required this.remoteDataSource});

  final DailyTimingsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ScheduleTimingsEntity>> getScheduleTimings({
    required String academicYearId,
  }) async {
    try {
      final model = await remoteDataSource.getScheduleTimings(
        academicYearId: academicYearId,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScheduleTimingsEntity>> upsertScheduleTimings({
    required String academicYearId,
    required ScheduleTimingsEntity timings,
  }) async {
    try {
      final model = await remoteDataSource.upsertScheduleTimings(
        academicYearId: academicYearId,
        timings: timings,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
