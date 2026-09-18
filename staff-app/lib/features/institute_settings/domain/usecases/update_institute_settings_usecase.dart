import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';

class UpdateInstituteSettingsUseCase {
  const UpdateInstituteSettingsUseCase(this._repository);

  final InstituteSettingsRepository _repository;

  Future<Either<Failure, InstituteSettingsEntity>> call(
    InstituteSettingsEntity settings, {
    CancelToken? cancelToken,
  }) {
    return _repository.updateSettings(settings, cancelToken: cancelToken);
  }
}
