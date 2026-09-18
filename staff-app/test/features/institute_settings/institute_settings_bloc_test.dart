import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/get_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/update_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/upload_branding_asset_usecase.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_bloc.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_event.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_state.dart';

class MockInstituteSettingsRepository extends Mock implements InstituteSettingsRepository {}

void main() {
  late MockInstituteSettingsRepository mockRepository;
  late GetInstituteSettingsUseCase getUseCase;
  late UpdateInstituteSettingsUseCase updateUseCase;
  late UploadBrandingAssetUseCase uploadUseCase;
  late InstituteSettingsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const InstituteSettingsEntity());
  });

  setUp(() {
    mockRepository = MockInstituteSettingsRepository();
    getUseCase = GetInstituteSettingsUseCase(mockRepository);
    updateUseCase = UpdateInstituteSettingsUseCase(mockRepository);
    uploadUseCase = UploadBrandingAssetUseCase(mockRepository);

    bloc = InstituteSettingsBloc(
      getInstituteSettingsUseCase: getUseCase,
      updateInstituteSettingsUseCase: updateUseCase,
      uploadBrandingAssetUseCase: uploadUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('InstituteSettingsBloc Clean Architecture Tests', () {
    test('initial state has status initial', () {
      expect(bloc.state.status, equals(InstituteSettingsStatus.initial));
    });

    test('emits [loading, loaded] when LoadInstituteSettingsEvent succeeds', () async {
      const testEntity = InstituteSettingsEntity(
        nameEn: 'TaleemOne Model Institute',
        taglineEn: 'Pioneering Excellence',
      );

      when(() => mockRepository.getSettings(cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => const Right(testEntity));

      final expectedStates = [
        predicate<InstituteSettingsState>((s) => s.status == InstituteSettingsStatus.loading),
        predicate<InstituteSettingsState>((s) =>
            s.status == InstituteSettingsStatus.loaded &&
            s.model.nameEn == 'TaleemOne Model Institute'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadInstituteSettingsEvent());
    });

    test('emits [loading, error] when LoadInstituteSettingsEvent returns Failure', () async {
      when(() => mockRepository.getSettings(cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => const Left(ServerFailure('Connection refused by gateway')));

      final expectedStates = [
        predicate<InstituteSettingsState>((s) => s.status == InstituteSettingsStatus.loading),
        predicate<InstituteSettingsState>((s) =>
            s.status == InstituteSettingsStatus.error &&
            s.errorMessage == 'Connection refused by gateway'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadInstituteSettingsEvent());
    });
  });
}
