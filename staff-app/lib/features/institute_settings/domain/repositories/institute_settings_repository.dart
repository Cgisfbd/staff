import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';

/// Pure domain repository contract for institutional settings (STAFF_RULES §1.1).
abstract class InstituteSettingsRepository {
  Future<Either<Failure, InstituteSettingsEntity>> getSettings({CancelToken? cancelToken});

  Future<Either<Failure, InstituteSettingsEntity>> updateSettings(
    InstituteSettingsEntity settings, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, String>> uploadBrandingAsset({
    required File file,
    required String type,
    CancelToken? cancelToken,
  });
}
