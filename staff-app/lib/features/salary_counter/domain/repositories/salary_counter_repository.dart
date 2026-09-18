import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

abstract class SalaryCounterRepository {
  Future<Either<Failure, InstitutionalSalaryStatsEntity>> getInstitutionalStats();
  Future<Either<Failure, List<FacultySalaryRecordEntity>>> getFacultyList();
  Future<Either<Failure, List<SalaryReceiptEntity>>> getPaymentHistoryForFaculty(String teacherId);
  Future<Either<Failure, SalaryReceiptEntity>> disburseSalary({
    required String teacherId,
    required String academicYear,
    required List<String> months,
    required double amountPerMonth,
    required List<SalaryDeductionEntity> deductions,
    required double totalAmount,
    required String paymentDate,
    required String paymentMode,
    String? transactionRef,
    String? idempotencyKey,
  });
}
