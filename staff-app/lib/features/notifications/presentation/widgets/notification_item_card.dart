import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/features/notifications/domain/models/app_notification.dart';

/// Liquid Crystal Glass Notification Item Card (< 140 lines).
class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = notification.categoryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isDark
                    ? (notification.isRead ? const Color(0x330F172A) : const Color(0x4D0F172A))
                    : (notification.isRead ? const Color(0x66FFFFFF) : const Color(0x99FFFFFF)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: notification.isRead
                      ? (isDark ? const Color(0x26FFFFFF) : const Color(0x80FFFFFF))
                      : AppColors.goldPrimary.withValues(alpha: 0.5),
                  width: notification.isRead ? 1.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      notification.icon,
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row: Category Badge & Time
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  context.tr(notification.categoryStringKey).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: categoryColor,
                                    letterSpacing: 0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppFormatters.formatTime(notification.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!notification.isRead) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.goldPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Title
                        Text(
                          notification.localizedTitle(context.currentLanguageCode),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),

                        // Message Body
                        Text(
                          notification.localizedMessage(context.currentLanguageCode),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
