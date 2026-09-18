import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

abstract class AcademicHolidaysRepository {
  Future<Either<Failure, List<AcademicHoliday>>> getHolidays({
    required String academicYearId,
    String? type,
  });

  Future<Either<Failure, AcademicHoliday>> createHoliday({
    required String academicYearId,
    required AcademicHoliday holiday,
  });

  Future<Either<Failure, AcademicHoliday>> updateHoliday({
    required String id,
    required AcademicHoliday holiday,
  });

  Future<Either<Failure, void>> deleteHoliday({
    required String id,
    required String pin,
  });
}
