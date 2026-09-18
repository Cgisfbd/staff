import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/splash/domain/usecases/init_app_usecase.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_state.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/get_institute_settings_usecase.dart';
import 'package:staff_app/core/utils/app_logger.dart';

/// Cubit managing splash bootstrap and initialization lifecycle.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required InitAppUseCase initAppUseCase,
    required GetInstituteSettingsUseCase getInstituteSettingsUseCase,
  })  : _initAppUseCase = initAppUseCase,
        _getInstituteSettingsUseCase = getInstituteSettingsUseCase,
        super(const SplashInitial());

  final InitAppUseCase _initAppUseCase;
  final GetInstituteSettingsUseCase _getInstituteSettingsUseCase;

  Future<void> initialize() async {
    emit(const SplashLoading());

    // Small delay to allow luxury mesh gradient and branding badge to present smoothly
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final result = await _initAppUseCase();
    
    // Concurrently fetch dynamic institute settings for branding
    // The repository implementation will automatically cache it to Hive via AES-256
    final settingsResult = await _getInstituteSettingsUseCase();
    settingsResult.fold(
      (failure) => AppLogger.warn('Failed to fetch institute settings: ${failure.message}'),
      (entity) => AppLogger.info('Institute settings fetched and cached successfully.'),
    );

    result.fold(
      (failure) => emit(SplashFailure(failure.message)),
      (entity) => emit(SplashSuccess(entity)),
    );
  }
}
