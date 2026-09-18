import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';

class GetInstituteSettingsUseCase {
  const GetInstituteSettingsUseCase(this._repository);

  final InstituteSettingsRepository _repository;

  Future<Either<Failure, InstituteSettingsEntity>> call({CancelToken? cancelToken}) {
    return _repository.getSettings(cancelToken: cancelToken);
  }
}
