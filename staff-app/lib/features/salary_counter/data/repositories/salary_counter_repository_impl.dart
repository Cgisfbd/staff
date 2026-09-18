import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/salary_counter/data/datasources/salary_counter_remote_datasource.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';
import 'package:staff_app/features/salary_counter/domain/repositories/salary_counter_repository.dart';

class SalaryCounterRepositoryImpl implements SalaryCounterRepository {
  final SalaryCounterRemoteDataSource remoteDataSource;

  SalaryCounterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InstitutionalSalaryStatsEntity>> getInstitutionalStats() async {
    try {
      final res = await remoteDataSource.getInstitutionalStats();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FacultySalaryRecordEntity>>> getFacultyList() async {
    try {
      final res = await remoteDataSource.getFacultyList();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalaryReceiptEntity>>> getPaymentHistoryForFaculty(String teacherId) async {
    try {
      final res = await remoteDataSource.getPaymentHistoryForFaculty(teacherId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final res = await remoteDataSource.disburseSalary(
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
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
