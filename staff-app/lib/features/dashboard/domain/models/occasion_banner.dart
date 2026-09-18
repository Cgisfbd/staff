import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';

/// Data Model representing an Occasion, Celebration or Urgent Announcement Banner.
class OccasionBanner {
  const OccasionBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.badge = 'SPECIAL OCCASION',
    this.badgeColor,
    this.actionLabel,
    this.onActionTap,
    this.isDismissible = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imagePath;
  final String badge;
  final Color? badgeColor;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool isDismissible;

  String localizedTitle(BuildContext context) {
    final trKey = '${id}_title';
    final val = context.tr(trKey);
    return val != trKey ? val : title;
  }

  String? localizedSubtitle(BuildContext context) {
    if (subtitle == null) return null;
    final trKey = '${id}_sub';
    final val = context.tr(trKey);
    return val != trKey ? val : subtitle;
  }

  String localizedBadge(BuildContext context) {
    final trKey = '${id}_badge';
    final val = context.tr(trKey);
    return val != trKey ? val : badge;
  }
}
