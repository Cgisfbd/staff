import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';

/// Ultra-Luxury Glassmorphic Storage & Session Diagnostics Card (< 200 lines).
class SettingsDiagnosticsCard extends StatelessWidget {
  const SettingsDiagnosticsCard({super.key});

  Future<void> _handleClearCache(BuildContext context) async {
    try {
      final hive = sl<HiveService>();
      if (hive.isInitialized) {
        await hive.cacheBox.clear();
      }
      if (context.mounted) {
        AppSnackBar.showSuccess(context, context.tr('settings_cache_cleared'));
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Failed to clear cache: $e');
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isLoggingOut = false;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Center(
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A26) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.tr('sign_out_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.tr('sign_out_confirm'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoggingOut ? null : () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                              side: BorderSide(
                                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(context.tr('cancel')),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoggingOut
                                ? null
                                : () async {
                                    setDialogState(() => isLoggingOut = true);
                                    // 1. Invalidate session on backend & wipe local auth tokens
                                    await sl<AuthRepository>().logout();
                                    // 2. Ensure AppLock does not overlay the login screen
                                    sl<AppLockCubit>().unlock();
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                    if (context.mounted) {
                                      context.go(RouteNames.login);
                                      AppSnackBar.showSuccess(context, 'Signed out successfully');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoggingOut
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(context.tr('sign_out_action'), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: const Icon(Icons.terminal_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.tr('settings_diagnostics_section'),
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
          const SizedBox(height: AppSpacing.sm),

          // 1. Clear Cache Row
          InkWell(
            onTap: () => _handleClearCache(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                    : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.20),
                  width: 0.9,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cleaning_services_rounded,
                    size: 20,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('settings_clear_cache'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('settings_clear_cache_desc'),
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.3,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2. App Version Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                  : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.20),
                width: 0.9,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 20,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('settings_app_version'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Production Enterprise Build (FAANG Grade)',
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.3,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.45),
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      'v${AppConfig.appVersion}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Luxury Sign Out CTA
          InkWell(
            onTap: () => _showSignOutDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: isDark ? 0.20 : 0.14),
                    Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: isDark ? 0.45 : 0.35),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('sign_out_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.redAccent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
