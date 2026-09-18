import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';

class UploadBrandingAssetUseCase {
  const UploadBrandingAssetUseCase(this._repository);

  final InstituteSettingsRepository _repository;

  Future<Either<Failure, String>> call({
    required File file,
    required String type,
    CancelToken? cancelToken,
  }) {
    return _repository.uploadBrandingAsset(
      file: file,
      type: type,
      cancelToken: cancelToken,
    );
  }
}
