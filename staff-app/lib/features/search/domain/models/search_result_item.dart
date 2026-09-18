import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Categories for institutional search.
enum SearchCategory {
  student,
  action,
  notice;

  String get displayName {
    switch (this) {
      case SearchCategory.student:
        return 'Students';
      case SearchCategory.action:
        return 'Quick Actions';
      case SearchCategory.notice:
        return 'Notices';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.student:
        return Icons.school_outlined;
      case SearchCategory.action:
        return Icons.bolt_rounded;
      case SearchCategory.notice:
        return Icons.campaign_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SearchCategory.student:
        return AppColors.goldPrimary;
      case SearchCategory.action:
        return AppColors.statusPresent;
      case SearchCategory.notice:
        return AppColors.statusLeave;
    }
  }
}

/// Strongly typed search result item with metadata (< 120 lines).
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.badgeText,
    this.route,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String? badgeText;
  final String? route;
  final Map<String, String> metadata;

  static const List<SearchResultItem> mockData = [];

  static List<SearchResultItem> search(String query, [SearchCategory? filterCategory]) {
    final cleanQuery = query.trim().toLowerCase();
    return mockData.where((item) {
      if (filterCategory != null && item.category != filterCategory) {
        return false;
      }
      if (cleanQuery.isEmpty) {
        return true;
      }
      final titleMatch = item.title.toLowerCase().contains(cleanQuery);
      final subtitleMatch = item.subtitle.toLowerCase().contains(cleanQuery);
      final badgeMatch = item.badgeText?.toLowerCase().contains(cleanQuery) ?? false;
      final rollMatch = item.metadata['rollNo']?.toLowerCase().contains(cleanQuery) ?? false;
      final admMatch = item.metadata['admissionNo']?.toLowerCase().contains(cleanQuery) ?? false;

      return titleMatch || subtitleMatch || badgeMatch || rollMatch || admMatch;
    }).toList();
  }
}
