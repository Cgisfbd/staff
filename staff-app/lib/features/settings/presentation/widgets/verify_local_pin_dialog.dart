import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/widgets/pin_numpad_widget.dart';

/// Ultra-Luxury Tactile Dialog to verify existing 6-digit In-App PIN (< 180 lines).
/// Returns true if verified, false if cancelled or dismissed.
class VerifyLocalPinDialog extends StatefulWidget {
  const VerifyLocalPinDialog({
    super.key,
    this.title = 'Verify In-App PIN',
    this.subtitle = 'Enter your 6-digit PIN to proceed',
  });

  final String title;
  final String subtitle;

  static Future<bool> show(
    BuildContext context, {
    String title = 'Verify In-App PIN',
    String subtitle = 'Enter your 6-digit PIN to proceed',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => BlocProvider.value(
        value: context.read<AppLockCubit>(),
        child: VerifyLocalPinDialog(title: title, subtitle: subtitle),
      ),
    );
    return result ?? false;
  }

  @override
  State<VerifyLocalPinDialog> createState() => _VerifyLocalPinDialogState();
}

class _VerifyLocalPinDialogState extends State<VerifyLocalPinDialog> {
  static const int _pinLength = 6;
  String _enteredPin = '';
  bool _isError = false;
  String? _errorMessage;
  bool _isVerifying = false;

  Future<void> _handleDigit(String digit) async {
    if (_isVerifying || _isError || _enteredPin.length >= _pinLength) return;

    final updated = _enteredPin + digit;
    setState(() {
      _enteredPin = updated;
      _errorMessage = null;
      _isError = false;
    });

    if (updated.length == _pinLength) {
      setState(() => _isVerifying = true);
      final cubit = context.read<AppLockCubit>();
      final match = await cubit.checkLocalPin(updated);
      if (!mounted) return;

      if (match) {
        unawaited(HapticFeedback.lightImpact());
        Navigator.of(context).pop(true);
      } else {
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _isError = true;
          _isVerifying = false;
          _errorMessage = 'Incorrect PIN. Please try again.';
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
                      child: const Icon(Icons.lock_outline_rounded, color: AppColors.goldPrimary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.title,
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
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Subtitle
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _isError
                        ? AppColors.statusAbsent
                        : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. Strictly 6 Dots
                _buildPinDots(_enteredPin.length, isError: _isError),
                const SizedBox(height: 6),

                // Error message
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.statusAbsent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ] else
                  const SizedBox(height: 22),

                // 4. Tactile NumPad
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

  Widget _buildPinDots(int length, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isFilled ? 13 : 11,
          height: isFilled ? 13 : 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? AppColors.statusAbsent
                : (isFilled ? AppColors.goldPrimary : Colors.transparent),
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
                      color: AppColors.goldPrimary.withValues(alpha: 0.45),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (isError
                    ? [
                        BoxShadow(
                          color: AppColors.statusAbsent.withValues(alpha: 0.40),
                          blurRadius: 7,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
        );
      }),
    );
  }
}
