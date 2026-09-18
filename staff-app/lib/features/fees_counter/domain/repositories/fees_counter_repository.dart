import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

abstract class FeesCounterRepository {
  Future<Either<Failure, FeesKpiEntity>> getFeesKpi();
  Future<Either<Failure, List<FeesCourseSummaryEntity>>> getCoursesSummary();
  Future<Either<Failure, List<FeesClassSummaryEntity>>> getClassesForCourse(String courseId);
  Future<Either<Failure, List<StudentFeeRecordEntity>>> getStudentsForClass({
    required String courseId,
    required String classId,
  });
  Future<Either<Failure, List<FeePaymentRecordEntity>>> getPaymentHistoryForStudent(String studentId);
  Future<Either<Failure, FeePaymentRecordEntity>> depositFee({
    required String studentId,
    required List<String> months,
    required double grossAmount,
    required double concessionAmount,
    required double amountPaid,
    required String feeType,
    required String collector,
    String? idempotencyKey,
  });
  Future<Either<Failure, FeePaymentRecordEntity>> waiveFee({
    required String studentId,
    required List<String> months,
    required double waivedAmount,
    required String adminPin,
    required String collector,
    String? idempotencyKey,
  });
}
