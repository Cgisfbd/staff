import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';
import 'package:staff_app/features/fees_counter/domain/repositories/fees_counter_repository.dart';

class GetFeesKpiUseCase {
  final FeesCounterRepository repository;
  GetFeesKpiUseCase(this.repository);

  Future<Either<Failure, FeesKpiEntity>> call() => repository.getFeesKpi();
}

class GetCoursesSummaryUseCase {
  final FeesCounterRepository repository;
  GetCoursesSummaryUseCase(this.repository);

  Future<Either<Failure, List<FeesCourseSummaryEntity>>> call() => repository.getCoursesSummary();
}

class GetClassesForCourseUseCase {
  final FeesCounterRepository repository;
  GetClassesForCourseUseCase(this.repository);

  Future<Either<Failure, List<FeesClassSummaryEntity>>> call(String courseId) =>
      repository.getClassesForCourse(courseId);
}

class GetStudentsForClassUseCase {
  final FeesCounterRepository repository;
  GetStudentsForClassUseCase(this.repository);

  Future<Either<Failure, List<StudentFeeRecordEntity>>> call({
    required String courseId,
    required String classId,
  }) =>
      repository.getStudentsForClass(courseId: courseId, classId: classId);
}

class GetPaymentHistoryForStudentUseCase {
  final FeesCounterRepository repository;
  GetPaymentHistoryForStudentUseCase(this.repository);

  Future<Either<Failure, List<FeePaymentRecordEntity>>> call(String studentId) =>
      repository.getPaymentHistoryForStudent(studentId);
}

class DepositFeeUseCase {
  final FeesCounterRepository repository;
  DepositFeeUseCase(this.repository);

  Future<Either<Failure, FeePaymentRecordEntity>> call({
    required String studentId,
    required List<String> months,
    required double grossAmount,
    required double concessionAmount,
    required double amountPaid,
    required String feeType,
    required String collector,
    String? idempotencyKey,
  }) =>
      repository.depositFee(
        studentId: studentId,
        months: months,
        grossAmount: grossAmount,
        concessionAmount: concessionAmount,
        amountPaid: amountPaid,
        feeType: feeType,
        collector: collector,
        idempotencyKey: idempotencyKey,
      );
}

class WaiveFeeUseCase {
  final FeesCounterRepository repository;
  WaiveFeeUseCase(this.repository);

  Future<Either<Failure, FeePaymentRecordEntity>> call({
    required String studentId,
    required List<String> months,
    required double waivedAmount,
    required String adminPin,
    required String collector,
    String? idempotencyKey,
  }) =>
      repository.waiveFee(
        studentId: studentId,
        months: months,
        waivedAmount: waivedAmount,
        adminPin: adminPin,
        collector: collector,
        idempotencyKey: idempotencyKey,
      );
}
