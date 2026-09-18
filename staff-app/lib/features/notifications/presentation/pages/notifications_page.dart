import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/notifications/domain/models/app_notification.dart';
import 'package:staff_app/features/notifications/presentation/widgets/notification_date_filter_bar.dart';
import 'package:staff_app/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:staff_app/features/notifications/presentation/widgets/notification_top_bar.dart';

/// Screen Orchestrator for Notifications Hub with Date-Based Filtering (< 145 lines).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  DateTime _selectedDate = DateTime.now();
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = AppNotification.getMockNotifications();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _toggleNotificationRead(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            category: n.category,
            createdAt: n.createdAt,
            isRead: true,
            priority: n.priority,
          );
        }
        return n;
      }).toList();
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          category: n.category,
          createdAt: n.createdAt,
          isRead: true,
          priority: n.priority,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _notifications.where((n) {
      return n.createdAt.year == _selectedDate.year &&
          n.createdAt.month == _selectedDate.month &&
          n.createdAt.day == _selectedDate.day;
    }).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: Column(
          children: [
            NotificationTopBar(
              unreadCount: unreadCount,
              onMarkAllRead: _markAllAsRead,
            ),
            NotificationDateFilterBar(
              selectedDate: _selectedDate,
              onDateSelected: _onDateChanged,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return NotificationItemCard(
                          notification: item,
                          onTap: () => _toggleNotificationRead(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x4DFFFFFF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0x26FFFFFF) : const Color(0x80FFFFFF),
                  width: 1.0,
                ),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('no_notifications'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
