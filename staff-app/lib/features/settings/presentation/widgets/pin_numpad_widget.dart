import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Ultra-Luxury Glassmorphic Numeric Keypad for Enclave PIN Entry (< 175 lines).
/// Renders sleek circular tactile buttons (0-9, Backspace, Submit/Clear)
/// with subtle gold reflections and haptic micro-feedback.
class PinNumpadWidget extends StatelessWidget {
  const PinNumpadWidget({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onClear,
    this.onSubmit,
    this.canSubmit = false,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;
  final VoidCallback? onSubmit;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(['1', '2', '3'], isDark),
            const SizedBox(height: 14),
            _buildRow(['4', '5', '6'], isDark),
            const SizedBox(height: 14),
            _buildRow(['7', '8', '9'], isDark),
            const SizedBox(height: 14),
            _buildBottomRow(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d, isDark)).toList(),
    );
  }

  Widget _buildDigitButton(String digit, bool isDark) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onDigit(digit);
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.goldPrimary.withValues(alpha: 0.25),
        highlightColor: AppColors.goldPrimary.withValues(alpha: 0.12),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.22),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left Button: Submit Checkmark if ready, otherwise Clear 'C'
        if (canSubmit && onSubmit != null)
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                onSubmit!();
              },
              customBorder: const CircleBorder(),
              splashColor: AppColors.goldPrimary.withValues(alpha: 0.35),
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.goldChampagne, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
              ),
            ),
          )
        else
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClear != null
                  ? () {
                      HapticFeedback.selectionClick();
                      onClear!();
                    }
                  : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 66,
                height: 66,
                child: Center(
                  child: Text(
                    onClear != null ? 'C' : '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Center Button: 0
        _buildDigitButton('0', isDark),

        // Right Button: Backspace
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onBackspace();
            },
            onLongPress: onClear != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onClear!();
                  }
                : null,
            customBorder: const CircleBorder(),
            splashColor: AppColors.goldPrimary.withValues(alpha: 0.25),
            child: Container(
              width: 66,
              height: 66,
              alignment: Alignment.center,
              child: Icon(
                Icons.backspace_outlined,
                size: 22,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
