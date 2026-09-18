import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_state.dart';

/// Minimal FAANG-Grade Footer with Powered by Barkat Tech verified signature.
/// Strictly compliant with TaleemOne ERP Constitution Section 5.2.
class MinimalSplashFooter extends StatelessWidget {
  const MinimalSplashFooter({
    super.key,
    required this.state,
  });

  final SplashState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 34.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thin subtle loader while bootstrap initializes
          if (state is SplashLoading || state is SplashInitial)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.goldLight : AppColors.goldPrimary,
                  ),
                ),
              ),
            ),

          // Verified Provider Attribution Signature (Powered by Barkat Tech)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const Text(
                'Barkat Tech',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.goldLight,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
