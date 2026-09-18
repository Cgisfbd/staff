import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/data/datasources/academic_session_remote_datasource.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class AcademicSessionRepositoryImpl implements AcademicSessionRepository {
  AcademicSessionRepositoryImpl({required this.remoteDataSource});

  final AcademicSessionRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<AcademicSessionEntity>>> getAcademicSessions() async {
    try {
      final sessions = await remoteDataSource.getAcademicSessions();
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure('Failed to load academic sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, NextSessionInfoEntity>> getNextSessionInfo() async {
    try {
      final info = await remoteDataSource.getNextSessionInfo();
      return Right(info);
    } catch (e) {
      return Left(ServerFailure('Failed to check next session status: $e'));
    }
  }

  @override
  Future<Either<Failure, AcademicSessionEntity>> createAcademicSession({
    required String yearName,
    required String startDate,
  }) async {
    try {
      final created = await remoteDataSource.createAcademicSession(
        yearName: yearName,
        startDate: startDate,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize new session: $e'));
    }
  }

  @override
  Future<Either<Failure, AcademicSessionEntity>> lockAcademicSession({
    required String id,
    required String endDate,
    required String pin,
  }) async {
    try {
      final locked = await remoteDataSource.lockAcademicSession(
        id: id,
        endDate: endDate,
        pin: pin,
      );
      return Right(locked);
    } catch (e) {
      return Left(ServerFailure('Failed to seal and lock session: $e'));
    }
  }

  @override
  Future<Either<Failure, AcademicSessionEntity>> setActiveSession(String id) async {
    try {
      final activated = await remoteDataSource.setActiveSession(id);
      return Right(activated);
    } catch (e) {
      return Left(ServerFailure('Failed to activate session: $e'));
    }
  }
}
