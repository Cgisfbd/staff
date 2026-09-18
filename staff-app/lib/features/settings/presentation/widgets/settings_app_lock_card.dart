import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_state.dart';
import 'package:staff_app/features/settings/presentation/widgets/set_local_pin_dialog.dart';
import 'package:staff_app/features/settings/presentation/widgets/verify_local_pin_dialog.dart';

/// Ultra-Luxury Glassmorphic Institutional Security Card (< 200 lines).
/// Strictly allows exactly ONE lock method (Phone Screen Lock vs Local In-App PIN).
/// Exactly one lock method is mandatory and always active.
class SettingsAppLockCard extends StatelessWidget {
  const SettingsAppLockCard({super.key});

  Future<void> _selectPhoneLock(BuildContext context, AppLockState state) async {
    if (state.lockMode == AppLockMode.phoneLock) {
      // Already active, test verify
      final ok = await context.read<AppLockCubit>().authenticateDevice();
      if (context.mounted) {
        if (ok) {
          AppSnackBar.showSuccess(context, 'Phone screen lock verified successfully');
        } else {
          AppSnackBar.showError(context, 'Verification cancelled or failed');
        }
      }
      return;
    }

    // 1. Switching from Local PIN to Phone Lock:
    // MUST verify active Local PIN first!
    if (state.lockMode == AppLockMode.localPin) {
      final pinVerified = await VerifyLocalPinDialog.show(
        context,
        title: context.tr('settings_verify_inapp_pin'),
        subtitle: context.tr('settings_verify_inapp_pin_sub'),
      );
      if (!context.mounted || !pinVerified) {
        return; // Cancelled or incorrect PIN
      }
    }

    // 2. Switch from Local PIN to Phone Lock (verifies device auth)
    final ok = await context.read<AppLockCubit>().switchToPhoneLock();
    if (context.mounted) {
      if (ok) {
        AppSnackBar.showSuccess(context, 'Switched to Phone Screen Lock (Fingerprint/PIN)');
      } else {
        AppSnackBar.showError(context, 'Phone lock verification required');
      }
    }
  }

  Future<void> _selectLocalPin(BuildContext context, AppLockState state) async {
    if (state.lockMode == AppLockMode.phoneLock) {
      // 1. Switching from Phone Lock to Local PIN:
      // MUST authenticate with Phone Screen Lock (biometric / screen lock) first!
      final ok = await context.read<AppLockCubit>().authenticateDevice();
      if (!context.mounted) return;
      if (!ok) {
        AppSnackBar.showError(context, 'Phone screen lock verification required to switch');
        return;
      }

      // 2. Verified! Now switch or set up
      if (state.hasLocalPin) {
        await context.read<AppLockCubit>().selectExistingLocalPin();
        if (context.mounted) {
          AppSnackBar.showSuccess(context, 'Switched to 6-digit In-App PIN');
        }
      } else {
        await SetLocalPinDialog.show(context, isChangingExisting: false);
      }
      return;
    }

    // Local PIN is already active: User tapped it to CHANGE their PIN!
    // SetLocalPinDialog will strictly verify Current PIN (Step 1) before allowing New PIN (Step 2) & Confirm (Step 3)!
    await SetLocalPinDialog.show(context, isChangingExisting: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        final isPhoneLockActive = state.lockMode == AppLockMode.phoneLock;
        final isLocalPinActive = state.lockMode == AppLockMode.localPin;

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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('settings_security_section'),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          context.tr('settings_security_mandatory_sub'),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.goldPrimary.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: AppSpacing.md),

              // 1. Option A: Phone Screen Lock (Fingerprint, PIN, Pattern, Password)
              OutlinedButton(
                onPressed: () => _selectPhoneLock(context, state),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isPhoneLockActive
                      ? (isDark ? const Color(0xFF0D281E).withValues(alpha: 0.65) : const Color(0xFFF0FDF4))
                      : (isDark ? const Color(0xFF1C2433).withValues(alpha: 0.65) : const Color(0xFFFAF7F2)),
                  foregroundColor: isPhoneLockActive ? AppColors.statusPresent : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                  side: BorderSide(
                    color: isPhoneLockActive
                        ? AppColors.statusPresent.withValues(alpha: 0.65)
                        : AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: isPhoneLockActive ? 1.5 : 1.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 20,
                      color: isPhoneLockActive
                          ? AppColors.statusPresent
                          : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('settings_lock_phone'),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isPhoneLockActive
                                ? context.tr('settings_lock_phone_active')
                                : context.tr('settings_lock_phone_inactive'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isPhoneLockActive
                                   ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                                   : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isPhoneLockActive
                            ? AppColors.statusPresent.withValues(alpha: 0.18)
                            : AppColors.goldPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPhoneLockActive
                              ? AppColors.statusPresent.withValues(alpha: 0.55)
                              : AppColors.goldPrimary.withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isPhoneLockActive ? context.tr('status_active') : context.tr('status_select'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isPhoneLockActive
                              ? AppColors.statusPresent
                              : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isPhoneLockActive ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                      size: 16,
                      color: isPhoneLockActive ? AppColors.statusPresent : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 2. Option B: Local In-App PIN
              OutlinedButton(
                onPressed: () => _selectLocalPin(context, state),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isLocalPinActive
                      ? (isDark ? const Color(0xFF0D281E).withValues(alpha: 0.65) : const Color(0xFFF0FDF4))
                      : (isDark ? const Color(0xFF1C2433).withValues(alpha: 0.65) : const Color(0xFFFAF7F2)),
                  foregroundColor: isLocalPinActive ? AppColors.statusPresent : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                  side: BorderSide(
                    color: isLocalPinActive
                        ? AppColors.statusPresent.withValues(alpha: 0.65)
                        : AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: isLocalPinActive ? 1.5 : 1.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dialpad_rounded,
                      size: 18,
                      color: isLocalPinActive
                          ? AppColors.statusPresent
                          : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('settings_lock_pin'),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isLocalPinActive
                                ? context.tr('settings_lock_pin_active')
                                : (state.hasLocalPin
                                    ? context.tr('settings_lock_pin_saved')
                                    : context.tr('settings_lock_pin_setup')),
                            style: TextStyle(
                              fontSize: 10,
                              color: isLocalPinActive
                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                                  : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isLocalPinActive
                            ? AppColors.statusPresent.withValues(alpha: 0.18)
                            : AppColors.goldPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLocalPinActive
                              ? AppColors.statusPresent.withValues(alpha: 0.55)
                              : AppColors.goldPrimary.withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isLocalPinActive
                            ? context.tr('status_active')
                            : (state.hasLocalPin ? context.tr('status_ready') : context.tr('status_setup')),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isLocalPinActive
                              ? AppColors.statusPresent
                              : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isLocalPinActive ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                      size: 16,
                      color: isLocalPinActive ? AppColors.statusPresent : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
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
