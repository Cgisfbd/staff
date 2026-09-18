import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';
import 'package:staff_app/features/salary_counter/domain/repositories/salary_counter_repository.dart';

class GetInstitutionalSalaryStatsUseCase {
  final SalaryCounterRepository repository;
  GetInstitutionalSalaryStatsUseCase(this.repository);

  Future<Either<Failure, InstitutionalSalaryStatsEntity>> call() =>
      repository.getInstitutionalStats();
}

class GetFacultySalaryListUseCase {
  final SalaryCounterRepository repository;
  GetFacultySalaryListUseCase(this.repository);

  Future<Either<Failure, List<FacultySalaryRecordEntity>>> call() =>
      repository.getFacultyList();
}

class GetPaymentHistoryForFacultyUseCase {
  final SalaryCounterRepository repository;
  GetPaymentHistoryForFacultyUseCase(this.repository);

  Future<Either<Failure, List<SalaryReceiptEntity>>> call(String teacherId) =>
      repository.getPaymentHistoryForFaculty(teacherId);
}

class DisburseSalaryUseCase {
  final SalaryCounterRepository repository;
  DisburseSalaryUseCase(this.repository);

  Future<Either<Failure, SalaryReceiptEntity>> call({
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
  }) =>
      repository.disburseSalary(
        teacherId: teacherId,
        academicYear: academicYear,
        months: months,
        amountPerMonth: amountPerMonth,
        deductions: deductions,
        totalAmount: totalAmount,
        paymentDate: paymentDate,
        paymentMode: paymentMode,
        transactionRef: transactionRef,
        idempotencyKey: idempotencyKey,
      );
}
