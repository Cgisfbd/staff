import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_holidays/data/datasources/academic_holidays_remote_datasource.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';
import 'package:staff_app/features/academic_holidays/domain/repositories/academic_holidays_repository.dart';

class AcademicHolidaysRepositoryImpl implements AcademicHolidaysRepository {
  AcademicHolidaysRepositoryImpl({required this.remoteDataSource});

  final AcademicHolidaysRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<AcademicHoliday>>> getHolidays({
    required String academicYearId,
    String? type,
  }) async {
    try {
      final list = await remoteDataSource.getHolidays(
        academicYearId: academicYearId,
        type: type,
      );
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcademicHoliday>> createHoliday({
    required String academicYearId,
    required AcademicHoliday holiday,
  }) async {
    try {
      final created = await remoteDataSource.createHoliday(
        academicYearId: academicYearId,
        holiday: holiday,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcademicHoliday>> updateHoliday({
    required String id,
    required AcademicHoliday holiday,
  }) async {
    try {
      final updated = await remoteDataSource.updateHoliday(
        id: id,
        holiday: holiday,
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHoliday({
    required String id,
    required String pin,
  }) async {
    try {
      await remoteDataSource.deleteHoliday(id: id, pin: pin);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
