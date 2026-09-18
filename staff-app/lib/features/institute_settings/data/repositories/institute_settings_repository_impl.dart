import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/institute_settings/data/datasources/institute_settings_local_datasource.dart';
import 'package:staff_app/features/institute_settings/data/datasources/institute_settings_remote_datasource.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';

class InstituteSettingsRepositoryImpl implements InstituteSettingsRepository {
  InstituteSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final InstituteSettingsRemoteDataSource remoteDataSource;
  final InstituteSettingsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, InstituteSettingsEntity>> getSettings({CancelToken? cancelToken}) async {
    try {
      final remoteSettings = await remoteDataSource.getSettings(cancelToken: cancelToken);
      await localDataSource.cacheSettings(remoteSettings);
      return Right(remoteSettings);
    } on NetworkException catch (_) {
      // Offline fallback from local encrypted Hive cache
      final cached = await localDataSource.getLastCachedSettings();
      if (cached != null) {
        return Right(cached);
      }
      return const Right(InstituteSettingsUiModel());
    } on ServerException catch (e) {
      final cached = await localDataSource.getLastCachedSettings();
      if (cached != null) {
        AppLogger.warn('Server error on settings fetch, using encrypted local cache fallback: ${e.message}');
        return Right(cached);
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode, code: e.code));
    } catch (e) {
      final cached = await localDataSource.getLastCachedSettings();
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure('Failed to load institute settings: $e'));
    }
  }

  @override
  Future<Either<Failure, InstituteSettingsEntity>> updateSettings(
    InstituteSettingsEntity settings, {
    CancelToken? cancelToken,
  }) async {
    final uiModel = InstituteSettingsUiModel.fromEntity(settings);

    try {
      final updated = await remoteDataSource.updateSettings(
        uiModel,
        cancelToken: cancelToken,
      );
      await localDataSource.cacheSettings(updated);
      return Right(updated);
    } on NetworkException catch (_) {
      // Network offline: enqueue for background sync and update local cache
      await localDataSource.queueSettingsUpdate(uiModel);
      return Right(uiModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update institute settings: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadBrandingAsset({
    required File file,
    required String type,
    CancelToken? cancelToken,
  }) async {
    try {
      final url = await remoteDataSource.uploadBrandingAsset(
        file: file,
        type: type,
        cancelToken: cancelToken,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to upload branding asset: $e'));
    }
  }
}
