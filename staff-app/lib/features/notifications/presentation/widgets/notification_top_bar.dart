import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Docked Liquid Crystal Glass Top Bar for Notifications Screen (< 110 lines).
class NotificationTopBar extends StatelessWidget {
  const NotificationTopBar({
    super.key,
    required this.unreadCount,
    this.onMarkAllRead,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final headerBgColor = isDark ? const Color(0xD90F172A) : const Color(0xEBFFFFFF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerBgColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0x33FFFFFF) : const Color(0x260F172A),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: statusBarHeight > 0 ? statusBarHeight + 6 : 14,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Back Button
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0x26FFFFFF) : const Color(0x80FFFFFF),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Unread Badge
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.tr('notifications'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Mark all as read icon button
                if (unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded, size: 20),
                    color: AppColors.goldPrimary,
                    tooltip: context.tr('mark_all_read'),
                    onPressed: onMarkAllRead,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
