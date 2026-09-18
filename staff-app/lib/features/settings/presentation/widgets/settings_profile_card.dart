import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:staff_app/features/settings/presentation/widgets/change_password_sheet.dart';
import 'package:staff_app/features/settings/presentation/widgets/change_pin_sheet.dart';
import 'package:staff_app/features/settings/presentation/widgets/circular_photo_crop_dialog.dart';
import 'package:staff_app/features/settings/presentation/widgets/photo_picker_sheet.dart';
import 'package:staff_app/features/settings/presentation/widgets/two_factor_disable_dialog.dart';
import 'package:staff_app/features/settings/presentation/widgets/two_factor_setup_sheet.dart';

/// Luxury Glassmorphic Staff Profile & Credentials Card (< 200 lines).
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key});

  Future<void> _handleAvatarTap(BuildContext context) async {
    final source = await PhotoPickerSheet.show(context);
    if (source == null || !context.mounted) return;

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 98,
      );

      if (file == null || !context.mounted) return;

      final bytes = await file.readAsBytes();
      if (!context.mounted) return;

      final Uint8List? croppedBytes = await CircularPhotoCropDialog.show(
        context,
        imageBytes: bytes,
      );

      if (croppedBytes != null && context.mounted) {
        final success = await context.read<ProfileCubit>().updateAvatar(
              bytes: croppedBytes,
              fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
            );

        if (context.mounted) {
          if (success) {
            AppSnackBar.showSuccess(
              context,
              context.tr('settings_avatar_updated'),
            );
          } else {
            final error = context.read<ProfileCubit>().state.errorMessage;
            AppSnackBar.showError(
              context,
              error ?? 'Failed to update profile photo',
            );
          }
        }
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Permission or device error: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Error selecting image: $e');
      }
    }
  }

  Widget _buildAvatarImage(ProfileState state, String name) {
    if (state.localAvatarBytes != null && state.localAvatarBytes!.isNotEmpty) {
      return Image.memory(
        Uint8List.fromList(state.localAvatarBytes!),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    }
    final avatarUrl = state.profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _buildInitials(name),
      );
    }
    return _buildInitials(name);
  }

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final name = profile?.fullName ?? 'Staff Member';
        final username = profile?.username.isNotEmpty == true ? '@${profile!.username}' : '@staff';
        final role = profile?.role ?? 'STAFF';

        return GlassCard(
          customFillColor: isDark
              ? const Color(0xFF131A26).withValues(alpha: 0.78)
              : Colors.white.withValues(alpha: 0.88),
          customBorderColor: AppColors.goldPrimary.withValues(alpha: isDark ? 0.32 : 0.25),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.badge_outlined, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.tr('settings_profile_section'),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.goldPrimary.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: AppSpacing.md),

              // Staff Avatar & Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    key: const ValueKey('avatar_picker_trigger'),
                    onTap: () => _handleAvatarTap(context),
                    child: Stack(
                      children: [
                        Builder(
                          builder: (context) {
                            final hasPhoto = (state.localAvatarBytes != null && state.localAvatarBytes!.isNotEmpty) ||
                                (state.profile?.avatarUrl?.isNotEmpty == true);
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasPhoto ? (isDark ? const Color(0xFF131A26) : Colors.white) : null,
                                gradient: hasPhoto
                                    ? null
                                    : const LinearGradient(
                                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                border: Border.all(
                                  color: hasPhoto
                                      ? (isDark ? Colors.white70 : Colors.black26)
                                      : AppColors.goldChampagne,
                                  width: hasPhoto ? 1.5 : 2.0,
                                ),
                                boxShadow: hasPhoto
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: AppColors.goldPrimary.withValues(alpha: 0.30),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: ClipOval(
                                child: _buildAvatarImage(state, name),
                              ),
                            );
                          },
                        ),
                        if (state.isActionLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.goldChampagne,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4.5),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF131A26) : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.goldPrimary.withValues(alpha: 0.45),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            role == 'SUPER_ADMIN'
                                ? context.tr('role_super_admin')
                                : (role == 'ADMIN' ? context.tr('role_admin') : context.tr('role_staff')),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ChangePasswordSheet.show(context),
                      icon: const Icon(Icons.lock_outline_rounded, size: 14),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr('settings_change_password'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                            : const Color(0xFFFAF7F2),
                        foregroundColor: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.30)),
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ChangePinSheet.show(context),
                      icon: const Icon(Icons.dialpad_rounded, size: 14),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr('settings_change_pin'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                            : const Color(0xFFFAF7F2),
                        foregroundColor: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.30)),
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Two-Factor Authentication (2FA) Button
              OutlinedButton(
                onPressed: () {
                  if (profile?.isTwoFactorEnabled == true) {
                    TwoFactorDisableDialog.show(context);
                  } else {
                    TwoFactorSetupSheet.show(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                      : const Color(0xFFFAF7F2),
                  foregroundColor: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  side: BorderSide(
                    color: (profile?.isTwoFactorEnabled == true)
                        ? AppColors.statusPresent.withValues(alpha: 0.45)
                        : AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phonelink_lock_rounded,
                      size: 16,
                      color: (profile?.isTwoFactorEnabled == true)
                          ? AppColors.statusPresent
                          : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.tr('settings_two_factor'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (profile?.isTwoFactorEnabled == true)
                            ? AppColors.statusPresent.withValues(alpha: 0.15)
                            : AppColors.goldPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (profile?.isTwoFactorEnabled == true)
                              ? AppColors.statusPresent.withValues(alpha: 0.45)
                              : AppColors.goldPrimary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        (profile?.isTwoFactorEnabled == true)
                            ? context.tr('settings_two_factor_enabled')
                            : context.tr('settings_two_factor_setup'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: (profile?.isTwoFactorEnabled == true)
                              ? AppColors.statusPresent
                              : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
