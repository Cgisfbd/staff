import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_bloc.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_event.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_state.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_branding_media_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_contact_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_documents_section.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_hero_preview_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_identity_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_save_bottom_bar.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/institute_super_admin_gate.dart';

class InstituteSettingsPage extends StatelessWidget {
  const InstituteSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstituteSettingsBloc>(
      create: (_) => sl<InstituteSettingsBloc>()..add(const LoadInstituteSettingsEvent()),
      child: const _InstituteSettingsView(),
    );
  }
}

class _InstituteSettingsView extends StatefulWidget {
  const _InstituteSettingsView();

  @override
  State<_InstituteSettingsView> createState() => _InstituteSettingsViewState();
}

class _InstituteSettingsViewState extends State<_InstituteSettingsView> {
  String _userRole = 'SUPER_ADMIN';
  bool _roleLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final profileStr = await sl<SecureStorageService>().getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _userRole = data['role']?.toString() ?? 'STAFF';
            _roleLoaded = true;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _roleLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_roleLoaded && _userRole != 'SUPER_ADMIN') {
      return const InstituteSuperAdminGate();
    }

    return BlocConsumer<InstituteSettingsBloc, InstituteSettingsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.statusMessage != current.statusMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == InstituteSettingsStatus.saved && state.statusMessage != null) {
          AppSnackBar.showSuccess(context, state.statusMessage!);
        } else if (state.status == InstituteSettingsStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final bloc = context.read<InstituteSettingsBloc>();

        return Scaffold(
          body: AppBackground(
            useSafeArea: false,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExecutiveTopHeader(
                    icon: Icons.arrow_back_rounded,
                    title: 'Institute Settings',
                    subtitle: 'Branding, Urdu logo, banner & contacts',
                    onIconTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InstituteHeroPreviewCard(
                            model: state.model,
                            localLogoPath: state.localLogoPath,
                            localBannerPath: state.localBannerPath,
                          ),
                          const SizedBox(height: 14),
                          InstituteBrandingMediaCard(
                            model: state.model,
                            localLogoPath: state.localLogoPath,
                            localBannerPath: state.localBannerPath,
                            isUploadingLogo: state.isUploadingLogo,
                            isUploadingBanner: state.isUploadingBanner,
                            onPickLogo: (file) => bloc.add(UploadLogoEvent(file)),
                            onPickBanner: (file) => bloc.add(UploadBannerEvent(file)),
                          ),
                          const SizedBox(height: 14),
                          InstituteIdentityCard(
                            model: state.model,
                            onChanged: (updated) => bloc.add(UpdateInstituteModelEvent(updated)),
                          ),
                          const SizedBox(height: 14),
                          InstituteContactCard(
                            model: state.model,
                            onChanged: (updated) => bloc.add(UpdateInstituteModelEvent(updated)),
                          ),
                          const SizedBox(height: 14),
                          InstituteDocumentsSection(
                            model: state.model,
                            onChanged: (updated) => bloc.add(UpdateInstituteModelEvent(updated)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  InstituteSaveBottomBar(
                    status: state.status,
                    isDirty: state.isDirty,
                    onReset: () => bloc.add(const ResetInstituteSettingsEvent()),
                    onSave: () => bloc.add(const SaveInstituteSettingsEvent()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
