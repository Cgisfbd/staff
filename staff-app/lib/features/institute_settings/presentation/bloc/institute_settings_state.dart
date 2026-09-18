import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';

enum InstituteSettingsStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class InstituteSettingsState {
  const InstituteSettingsState({
    this.status = InstituteSettingsStatus.initial,
    this.model = const InstituteSettingsUiModel(),
    this.initialModel = const InstituteSettingsUiModel(),
    this.isDirty = false,
    this.localLogoPath,
    this.localBannerPath,
    this.isUploadingLogo = false,
    this.isUploadingBanner = false,
    this.statusMessage,
    this.errorMessage,
  });

  final InstituteSettingsStatus status;
  final InstituteSettingsUiModel model;
  final InstituteSettingsUiModel initialModel;
  final bool isDirty;
  final String? localLogoPath;
  final String? localBannerPath;
  final bool isUploadingLogo;
  final bool isUploadingBanner;
  final String? statusMessage;
  final String? errorMessage;

  InstituteSettingsState copyWith({
    InstituteSettingsStatus? status,
    InstituteSettingsUiModel? model,
    InstituteSettingsUiModel? initialModel,
    bool? isDirty,
    String? localLogoPath,
    String? localBannerPath,
    bool? isUploadingLogo,
    bool? isUploadingBanner,
    String? statusMessage,
    String? errorMessage,
  }) {
    return InstituteSettingsState(
      status: status ?? this.status,
      model: model ?? this.model,
      initialModel: initialModel ?? this.initialModel,
      isDirty: isDirty ?? this.isDirty,
      localLogoPath: localLogoPath ?? this.localLogoPath,
      localBannerPath: localBannerPath ?? this.localBannerPath,
      isUploadingLogo: isUploadingLogo ?? this.isUploadingLogo,
      isUploadingBanner: isUploadingBanner ?? this.isUploadingBanner,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
    );
  }
}
