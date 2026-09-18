import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/fees_counter/data/datasources/fees_counter_remote_datasource.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';
import 'package:staff_app/features/fees_counter/domain/repositories/fees_counter_repository.dart';

class FeesCounterRepositoryImpl implements FeesCounterRepository {
  final FeesCounterRemoteDataSource remoteDataSource;

  FeesCounterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FeesKpiEntity>> getFeesKpi() async {
    try {
      final res = await remoteDataSource.getFeesKpi();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeesCourseSummaryEntity>>> getCoursesSummary() async {
    try {
      final res = await remoteDataSource.getCoursesSummary();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeesClassSummaryEntity>>> getClassesForCourse(String courseId) async {
    try {
      final res = await remoteDataSource.getClassesForCourse(courseId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentFeeRecordEntity>>> getStudentsForClass({
    required String courseId,
    required String classId,
  }) async {
    try {
      final res = await remoteDataSource.getStudentsForClass(courseId: courseId, classId: classId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeePaymentRecordEntity>>> getPaymentHistoryForStudent(String studentId) async {
    try {
      final res = await remoteDataSource.getPaymentHistoryForStudent(studentId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FeePaymentRecordEntity>> depositFee({
    required String studentId,
    required List<String> months,
    required double grossAmount,
    required double concessionAmount,
    required double amountPaid,
    required String feeType,
    required String collector,
    String? idempotencyKey,
  }) async {
    try {
      final res = await remoteDataSource.depositFee(
        studentId: studentId,
        months: months,
        grossAmount: grossAmount,
        concessionAmount: concessionAmount,
        amountPaid: amountPaid,
        feeType: feeType,
        collector: collector,
        idempotencyKey: idempotencyKey,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FeePaymentRecordEntity>> waiveFee({
    required String studentId,
    required List<String> months,
    required double waivedAmount,
    required String adminPin,
    required String collector,
    String? idempotencyKey,
  }) async {
    try {
      final res = await remoteDataSource.waiveFee(
        studentId: studentId,
        months: months,
        waivedAmount: waivedAmount,
        adminPin: adminPin,
        collector: collector,
        idempotencyKey: idempotencyKey,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
