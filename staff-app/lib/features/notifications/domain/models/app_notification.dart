import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

enum NotificationCategory {
  announcement,
  substitution,
  leave,
  task,
}

enum NotificationPriority {
  normal,
  high,
  urgent,
}

/// Immutable Domain Entity for Notifications (< 120 lines).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.titleUrdu,
    this.messageUrdu,
    this.titleHindi,
    this.messageHindi,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
  });

  final String id;
  final String title;
  final String message;
  final String? titleUrdu;
  final String? messageUrdu;
  final String? titleHindi;
  final String? messageHindi;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final NotificationPriority priority;

  String localizedTitle(String langCode) {
    if (langCode == 'ur' && titleUrdu != null) return titleUrdu!;
    if (langCode == 'hi' && titleHindi != null) return titleHindi!;
    return title;
  }

  String localizedMessage(String langCode) {
    if (langCode == 'ur' && messageUrdu != null) return messageUrdu!;
    if (langCode == 'hi' && messageHindi != null) return messageHindi!;
    return message;
  }

  IconData get icon {
    switch (category) {
      case NotificationCategory.announcement:
        return Icons.campaign_rounded;
      case NotificationCategory.substitution:
        return Icons.swap_horiz_rounded;
      case NotificationCategory.leave:
        return Icons.event_available_rounded;
      case NotificationCategory.task:
        return Icons.assignment_late_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case NotificationCategory.announcement:
        return AppColors.goldPrimary;
      case NotificationCategory.substitution:
        return AppColors.statusPresent;
      case NotificationCategory.leave:
        return AppColors.statusLeave;
      case NotificationCategory.task:
        return AppColors.statusAbsent;
    }
  }

  String get categoryStringKey {
    switch (category) {
      case NotificationCategory.announcement:
        return 'category_announcement';
      case NotificationCategory.substitution:
        return 'category_substitution';
      case NotificationCategory.leave:
        return 'category_leave';
      case NotificationCategory.task:
        return 'category_task';
    }
  }

  /// Sample mock notifications across dates for live demo & testing
  static List<AppNotification> getMockNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    return [
      AppNotification(
        id: 'notif-1',
        title: 'Emergency Circular: Monsoon Advisory',
        message: 'Classes will conclude at 1:30 PM today due to heavy monsoon rain advisory.',
        titleUrdu: 'ہنگامی سرکلر: شدید بارش کی پیش گوئی',
        messageUrdu: 'تیز بارش کی پیش گوئی کے سبب آج درجات کی تدریس 1:30 بجے اختتام پذیر ہوگی۔',
        titleHindi: 'आपातकालीन सूचना: मानसून परामर्श',
        messageHindi: 'भारी बारिश की चेतावनी के कारण आज कक्षाएं दोपहर 1:30 बजे समाप्त होंगी।',
        category: NotificationCategory.announcement,
        createdAt: DateTime(today.year, today.month, today.day, 10, 15),
        isRead: false,
        priority: NotificationPriority.urgent,
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Period Substitution Assigned',
        message: 'Please take Period 3 for Class 8B in Room 204 in place of Ustad Zaid.',
        titleUrdu: 'متبادل گھنٹہ کی تفویض',
        messageUrdu: 'استاذ زید صاحب کی جگہ درجہ ہشتم (8B) کا تیسرا گھنٹہ کمرہ نمبر 204 میں پڑھائیں۔',
        titleHindi: 'कक्षा प्रतिस्थापन का कार्य',
        messageHindi: 'उस्ताद ज़ैद के स्थान पर कमरा 204 में कक्षा 8B का तीसरा पीरियड लें।',
        category: NotificationCategory.substitution,
        createdAt: DateTime(today.year, today.month, today.day, 9, 30),
        isRead: false,
        priority: NotificationPriority.high,
      ),
      AppNotification(
        id: 'notif-3',
        title: 'Daily Attendance Pending',
        message: 'Attendance for Class 5A (Morning Session) is still pending submission.',
        titleUrdu: 'روزانہ حاضری زیر التواء',
        messageUrdu: 'درجہ پنجم (5A) کی صبح کی حاضری کا اندراج ابھی تک باقی ہے۔',
        titleHindi: 'दैनिक उपस्थिति शेष',
        messageHindi: 'कक्षा 5A (सुबह का सत्र) की उपस्थिति अभी तक दर्ज नहीं हुई है।',
        category: NotificationCategory.task,
        createdAt: DateTime(today.year, today.month, today.day, 8, 45),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
      AppNotification(
        id: 'notif-4',
        title: 'Leave Request Approved',
        message: 'Your casual leave request for upcoming Monday has been approved by Principal.',
        titleUrdu: 'درخواست رخصت منظور',
        messageUrdu: 'آئندہ پیر کے لیے آپ کی اتفاقیہ رخصت کی درخواست مہتمم صاحب نے منظور کر لی ہے۔',
        titleHindi: 'अवकाश स्वीकृत',
        messageHindi: 'आगामी सोमवार के लिए आपकी छुट्टी का आवेदन प्रधानाचार्य द्वारा स्वीकृत कर लिया गया है।',
        category: NotificationCategory.leave,
        createdAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 20),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
      AppNotification(
        id: 'notif-5',
        title: 'Monthly Staff Meeting Scheduled',
        message: 'Academic progress review meeting in Conference Hall at 3:30 PM.',
        titleUrdu: 'اساتذہ کا ماہانہ مشاورتی اجلاس',
        messageUrdu: 'تعلیمی پیش رفت کا جائزہ اجلاس کانفرنس ہال میں سہ پہر 3:30 بجے ہوگا۔',
        titleHindi: 'मासिक शिक्षक बैठक',
        messageHindi: 'कॉन्फ्रेंस हॉल में दोपहर 3:30 बजे शैक्षणिक प्रगति समीक्षा बैठक होगी।',
        category: NotificationCategory.announcement,
        createdAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 11, 0),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
      AppNotification(
        id: 'notif-6',
        title: 'Syllabus Coverage Audit Completed',
        message: 'Quarterly syllabus audit reports are now available on the faculty portal.',
        titleUrdu: 'نصابی تکمیل کی جانچ مکمل',
        messageUrdu: 'سہ ماہی نصابی رپورٹ اب اساتذہ کے پورٹل پر دستیاب ہے۔',
        titleHindi: 'पाठ्यक्रम समीक्षा पूर्ण',
        messageHindi: 'त्रैमासिक पाठ्यक्रम समीक्षा रिपोर्ट अब पोर्टल पर उपलब्ध है।',
        category: NotificationCategory.announcement,
        createdAt: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 14, 10),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
    ];
  }
}
