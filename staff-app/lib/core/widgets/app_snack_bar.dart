import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Ultra-Premium Floating SnackBar Architecture (< 100 lines).
/// Placed consistently at the bottom with high-end glass aesthetics and icons.
class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        backgroundColor: isDark ? const Color(0xF012281E) : const Color(0xF5F0FDF4),
        elevation: 8,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.60 : 0.45), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 19),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final isOffline = message.toLowerCase().contains('server') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connect') ||
        message.toLowerCase().contains('reach') ||
        message.toLowerCase().contains('timed out');

    final accentColor = isOffline
        ? (isDark ? AppColors.goldPrimary : AppColors.goldDark)
        : AppColors.statusAbsent;
    final title = context.tr(isOffline ? 'alert_server_title' : 'alert_auth_title');

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        backgroundColor: isDark ? const Color(0xF0201414) : const Color(0xF5FFF5F5),
        elevation: 8,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withValues(alpha: isDark ? 0.60 : 0.45), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.lock_outline_rounded,
                color: accentColor,
                size: 19,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
