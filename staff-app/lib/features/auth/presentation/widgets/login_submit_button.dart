import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Ultra-Premium TaleemOne Golden Gradient Submit Button (< 80 lines).
/// Perfectly mirrors the staff-app signature button styling in both Light and Dark themes.
class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Both Light and Dark modes feature the iconic TaleemOne Golden Gradient
    const gradientColors = [AppColors.goldPrimary, AppColors.goldLight];
    final shadowColor = AppColors.goldPrimary.withValues(alpha: 0.35);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          context.tr('sign_in_button'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Transform.scale(
                        scaleX: context.isRtl ? -1.0 : 1.0,
                        child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
