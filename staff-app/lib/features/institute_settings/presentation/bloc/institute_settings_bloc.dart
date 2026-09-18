import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/get_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/update_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/upload_branding_asset_usecase.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_event.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_state.dart';

class InstituteSettingsBloc extends Bloc<InstituteSettingsEvent, InstituteSettingsState> {
  InstituteSettingsBloc({
    required this.getInstituteSettingsUseCase,
    required this.updateInstituteSettingsUseCase,
    required this.uploadBrandingAssetUseCase,
  }) : super(const InstituteSettingsState()) {
    on<LoadInstituteSettingsEvent>(_onLoad);
    on<UpdateInstituteModelEvent>(_onUpdateModel);
    on<UploadLogoEvent>(_onUploadLogo);
    on<UploadBannerEvent>(_onUploadBanner);
    on<SaveInstituteSettingsEvent>(_onSave);
    on<ResetInstituteSettingsEvent>(_onReset);
  }

  final GetInstituteSettingsUseCase getInstituteSettingsUseCase;
  final UpdateInstituteSettingsUseCase updateInstituteSettingsUseCase;
  final UploadBrandingAssetUseCase uploadBrandingAssetUseCase;

  CancelToken? _cancelToken;

  @override
  Future<void> close() {
    _cancelToken?.cancel('InstituteSettingsBloc closed');
    return super.close();
  }

  Future<void> _onLoad(
    LoadInstituteSettingsEvent event,
    Emitter<InstituteSettingsState> emit,
  ) async {
    emit(state.copyWith(status: InstituteSettingsStatus.loading));
    _cancelToken?.cancel('New load request');
    _cancelToken = CancelToken();

    final result = await getInstituteSettingsUseCase(cancelToken: _cancelToken);

    result.fold(
      (failure) => emit(state.copyWith(
        status: InstituteSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (entity) {
        final uiModel = InstituteSettingsUiModel.fromEntity(entity);
        emit(state.copyWith(
          status: InstituteSettingsStatus.loaded,
          model: uiModel,
          initialModel: uiModel,
          isDirty: false,
        ));
      },
    );
  }

  void _onUpdateModel(
    UpdateInstituteModelEvent event,
    Emitter<InstituteSettingsState> emit,
  ) {
    emit(state.copyWith(
      model: event.model,
      isDirty: true,
    ));
  }

  Future<void> _onUploadLogo(
    UploadLogoEvent event,
    Emitter<InstituteSettingsState> emit,
  ) async {
    emit(state.copyWith(
      localLogoPath: event.imageFile.path,
      isUploadingLogo: true,
      isDirty: true,
    ));

    final result = await uploadBrandingAssetUseCase(
      file: event.imageFile,
      type: 'logo',
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUploadingLogo: false,
        errorMessage: failure.message,
      )),
      (remoteUrl) {
        final updatedModel = state.model.copyWith(logoUrl: remoteUrl);
        emit(state.copyWith(
          model: updatedModel,
          isUploadingLogo: false,
          statusMessage: 'Official logo uploaded successfully',
        ));
      },
    );
  }

  Future<void> _onUploadBanner(
    UploadBannerEvent event,
    Emitter<InstituteSettingsState> emit,
  ) async {
    emit(state.copyWith(
      localBannerPath: event.imageFile.path,
      isUploadingBanner: true,
      isDirty: true,
    ));

    final result = await uploadBrandingAssetUseCase(
      file: event.imageFile,
      type: 'banner',
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUploadingBanner: false,
        errorMessage: failure.message,
      )),
      (remoteUrl) {
        final updatedModel = state.model.copyWith(bannerUrl: remoteUrl);
        emit(state.copyWith(
          model: updatedModel,
          isUploadingBanner: false,
          statusMessage: 'Campus hero banner updated successfully',
        ));
      },
    );
  }

  Future<void> _onSave(
    SaveInstituteSettingsEvent event,
    Emitter<InstituteSettingsState> emit,
  ) async {
    emit(state.copyWith(status: InstituteSettingsStatus.saving));
    _cancelToken?.cancel('New save request');
    _cancelToken = CancelToken();

    final result = await updateInstituteSettingsUseCase(
      state.model,
      cancelToken: _cancelToken,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: InstituteSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (updatedEntity) {
        final updatedModel = InstituteSettingsUiModel.fromEntity(updatedEntity);
        emit(state.copyWith(
          status: InstituteSettingsStatus.saved,
          model: updatedModel,
          initialModel: updatedModel,
          isDirty: false,
          statusMessage: 'Institute profile updated successfully',
        ));
      },
    );
  }

  void _onReset(
    ResetInstituteSettingsEvent event,
    Emitter<InstituteSettingsState> emit,
  ) {
    emit(state.copyWith(
      model: state.initialModel,
      isDirty: false,
      localLogoPath: null,
      localBannerPath: null,
    ));
  }
}
