import 'dart:io';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';

abstract class InstituteSettingsEvent {
  const InstituteSettingsEvent();
}

class LoadInstituteSettingsEvent extends InstituteSettingsEvent {
  const LoadInstituteSettingsEvent();
}

class UpdateInstituteModelEvent extends InstituteSettingsEvent {
  const UpdateInstituteModelEvent(this.model);
  final InstituteSettingsUiModel model;
}

class UploadLogoEvent extends InstituteSettingsEvent {
  const UploadLogoEvent(this.imageFile);
  final File imageFile;
}

class UploadBannerEvent extends InstituteSettingsEvent {
  const UploadBannerEvent(this.imageFile);
  final File imageFile;
}

class SaveInstituteSettingsEvent extends InstituteSettingsEvent {
  const SaveInstituteSettingsEvent();
}

class ResetInstituteSettingsEvent extends InstituteSettingsEvent {
  const ResetInstituteSettingsEvent();
}
