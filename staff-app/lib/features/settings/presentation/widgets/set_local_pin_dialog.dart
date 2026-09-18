import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/widgets/pin_numpad_widget.dart';

/// Ultra-Luxury NumPad Dialog for setting strictly 6-digit In-App PIN (< 210 lines).
/// Features:
/// - Strictly 6 digits (min & max = 6).
/// - Zero Badges / Zero Pills.
/// - Zero Outer Border (uses MaterialType.transparency).
/// - 100% Tactile NumPad (Zero System Keyboard).
/// - Instant Auto-Transition & Auto-Verification (Zero OK button).
/// - Red pulse alert on mismatch with smooth clean reset.
class SetLocalPinDialog extends StatefulWidget {
  const SetLocalPinDialog({
    super.key,
    this.isChangingExisting = false,
  });

  final bool isChangingExisting;

  static Future<bool?> show(BuildContext context, {bool? isChangingExisting}) {
    final hasPin = context.read<AppLockCubit>().state.hasLocalPin;
    final changing = isChangingExisting ?? hasPin;

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => BlocProvider.value(
        value: context.read<AppLockCubit>(),
        child: SetLocalPinDialog(isChangingExisting: changing),
      ),
    );
  }

  @override
  State<SetLocalPinDialog> createState() => _SetLocalPinDialogState();
}

class _SetLocalPinDialogState extends State<SetLocalPinDialog> {
  static const int _pinLength = 6;
  late int _step; // If changing: 1=Current, 2=New, 3=Confirm. If new: 1=New, 2=Confirm.
  String _newPinDraft = '';
  String _enteredPin = '';
  bool _isError = false;
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _step = 1;
  }

  String _getStepSubtitle() {
    if (widget.isChangingExisting) {
      switch (_step) {
        case 1:
          return 'Step 1: Enter Current 6-digit PIN';
        case 2:
          return 'Step 2: Enter New 6-digit PIN';
        case 3:
          return 'Step 3: Re-enter New 6-digit PIN to confirm';
        default:
          return '';
      }
    } else {
      return _step == 1 ? 'Step 1: Enter 6-digit PIN' : 'Step 2: Re-enter 6-digit PIN to confirm';
    }
  }

  Future<void> _handleDigit(String digit) async {
    if (_isVerifying || _isError || _enteredPin.length >= _pinLength) return;

    final updated = _enteredPin + digit;
    setState(() {
      _enteredPin = updated;
      _errorMessage = null;
      _isError = false;
    });

    if (updated.length == _pinLength) {
      final cubit = context.read<AppLockCubit>();

      if (widget.isChangingExisting) {
        // --- 3-STEP FLOW (CHANGING EXISTING PIN) ---
        if (_step == 1) {
          // Verify Current PIN
          setState(() => _isVerifying = true);
          final match = await cubit.checkLocalPin(updated);
          if (!mounted) return;

          if (match) {
            unawaited(HapticFeedback.selectionClick());
            setState(() {
              _isVerifying = false;
              _enteredPin = '';
              _step = 2;
            });
          } else {
            unawaited(HapticFeedback.heavyImpact());
            setState(() {
              _isError = true;
              _isVerifying = false;
              _errorMessage = 'Current PIN is incorrect. Try again.';
            });
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                _enteredPin = '';
                _isError = false;
                _errorMessage = null;
              });
            }
          }
        } else if (_step == 2) {
          // Enter New PIN Draft
          unawaited(HapticFeedback.selectionClick());
          setState(() {
            _newPinDraft = updated;
            _enteredPin = '';
            _step = 3;
          });
        } else {
          // Confirm New PIN
          if (updated == _newPinDraft) {
            unawaited(HapticFeedback.lightImpact());
            await cubit.setLocalPin(updated);
            if (!mounted) return;
            Navigator.of(context).pop(true);
            AppSnackBar.showSuccess(context, '6-digit In-App PIN changed successfully');
          } else {
            unawaited(HapticFeedback.heavyImpact());
            setState(() {
              _isError = true;
              _errorMessage = 'New PINs do not match. Please try again.';
            });
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                _step = 2;
                _enteredPin = '';
                _newPinDraft = '';
                _isError = false;
                _errorMessage = null;
              });
            }
          }
        }
      } else {
        // --- 2-STEP FLOW (CREATING NEW PIN) ---
        if (_step == 1) {
          unawaited(HapticFeedback.selectionClick());
          setState(() {
            _newPinDraft = updated;
            _enteredPin = '';
            _step = 2;
          });
        } else {
          if (updated == _newPinDraft) {
            unawaited(HapticFeedback.lightImpact());
            await cubit.setLocalPin(updated);
            if (!mounted) return;
            Navigator.of(context).pop(true);
            AppSnackBar.showSuccess(context, '6-digit In-App PIN activated');
          } else {
            unawaited(HapticFeedback.heavyImpact());
            setState(() {
              _isError = true;
              _errorMessage = 'PINs do not match. Please try again.';
            });
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                _step = 1;
                _enteredPin = '';
                _newPinDraft = '';
                _isError = false;
                _errorMessage = null;
              });
            }
          }
        }
      }
    }
  }

  void _handleBackspace() {
    if (_isVerifying || _enteredPin.isEmpty || _isError) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _isError = false;
      _errorMessage = null;
    });
  }

  void _handleClear() {
    if (_isVerifying || _isError) return;
    setState(() {
      _enteredPin = '';
      _isError = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A26) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header with Close Button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.dialpad_rounded, color: AppColors.goldPrimary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.isChangingExisting ? 'Change In-App PIN' : context.tr('settings_set_local_pin'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Step Subtitle
                Text(
                  _getStepSubtitle(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isError
                        ? AppColors.statusAbsent
                        : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. Strictly 6 Dots Indicator
                _buildPinDots(_enteredPin.length, _pinLength, isError: _isError),
                const SizedBox(height: 6),

                // Error message or spacing
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.statusAbsent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const SizedBox(height: 14),

                // 4. Tactical NumPad
                PinNumpadWidget(
                  onDigit: _handleDigit,
                  onBackspace: _handleBackspace,
                  onClear: _handleClear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(int length, int targetCount, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(targetCount, (index) {
        final isFilled = index < length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isFilled ? 13 : 11,
          height: isFilled ? 13 : 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? AppColors.statusAbsent
                : (isFilled
                    ? AppColors.goldPrimary
                    : Colors.transparent),
            border: Border.all(
              color: isError
                  ? AppColors.statusAbsent
                  : (isFilled
                      ? AppColors.goldChampagne
                      : AppColors.goldPrimary.withValues(alpha: 0.35)),
              width: 1.5,
            ),
            boxShadow: isFilled && !isError
                ? [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
