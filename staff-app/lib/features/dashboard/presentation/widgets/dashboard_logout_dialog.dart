import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';

/// Glassmorphic confirmation dialog for session logout (< 120 lines).
class DashboardLogoutDialog extends StatefulWidget {
  const DashboardLogoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => const DashboardLogoutDialog(),
    );
  }

  @override
  State<DashboardLogoutDialog> createState() => _DashboardLogoutDialogState();
}

class _DashboardLogoutDialogState extends State<DashboardLogoutDialog> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppSpacing.roundedLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.statusAbsent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.statusAbsent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.tr('sign_out_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.tr('sign_out_confirm'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoggingOut ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        context.tr('cancel'),
                        style: TextStyle(
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusAbsent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                      onPressed: _isLoggingOut
                          ? null
                          : () async {
                              setState(() => _isLoggingOut = true);
                              final navigator = Navigator.of(context);
                              final router = GoRouter.of(context);
                              // 1. Invalidate session on backend & wipe local auth tokens
                              await sl<AuthRepository>().logout();
                              // 2. Ensure AppLock does not overlay the login screen
                              sl<AppLockCubit>().unlock();
                              navigator.pop();
                              router.go(RouteNames.login);
                            },
                      child: _isLoggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(context.tr('sign_out_action')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
