import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/attendance/data/datasources/exam_qr_datasource.dart';
import 'package:staff_app/features/attendance/domain/models/exam_qr_attendance_model.dart';
import 'package:staff_app/features/settings/presentation/widgets/pin_numpad_widget.dart';

/// Ultra-Luxury Tactile Dialog to authorize manual roll entry
/// strictly against institutional Staff Server Security PIN (Argon2 verified).
class VerifyServerPinDialog extends StatefulWidget {
  const VerifyServerPinDialog({
    super.key,
    required this.student,
    required this.datasource,
  });

  final StudentExamEntity student;
  final ExamQrDatasource datasource;

  static Future<bool> show(
    BuildContext context, {
    required StudentExamEntity student,
    required ExamQrDatasource datasource,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      barrierDismissible: false,
      builder: (_) => VerifyServerPinDialog(
        student: student,
        datasource: datasource,
      ),
    );
    return result ?? false;
  }

  @override
  State<VerifyServerPinDialog> createState() => _VerifyServerPinDialogState();
}

class _VerifyServerPinDialogState extends State<VerifyServerPinDialog> {
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

      final isMatch = await widget.datasource.verifyServerStaffPin(updated);
      if (!mounted) return;

      if (isMatch) {
        unawaited(HapticFeedback.lightImpact());
        Navigator.of(context).pop(true);
      } else {
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _isError = true;
          _isVerifying = false;
          _errorMessage = context.tr('qr_server_pin_error');
        });
        await Future<void>.delayed(const Duration(milliseconds: 700));
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
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A26) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header with Shield & Close Button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: AppColors.goldPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.tr('qr_server_pin_title'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Student Badge (Shows Roll Number & Student Name Being Authorized)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${widget.student.rollNo}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.student.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.student.registeredClass,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Subtitle / Instruction
                Text(
                  context.tr('qr_server_pin_sub'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isError
                        ? AppColors.statusAbsent
                        : (isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),

                // 4. Strictly 6 Dots
                _buildPinDots(_enteredPin.length, isError: _isError),
                const SizedBox(height: 8),

                // 5. Verification status / Error message
                if (_isVerifying) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else if (_errorMessage != null) ...[
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
                  const SizedBox(height: 18),

                // 6. Tactile NumPad
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
          margin: const EdgeInsets.symmetric(horizontal: 6),
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
