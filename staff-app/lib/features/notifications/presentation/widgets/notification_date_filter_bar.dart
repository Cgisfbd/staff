import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/utils/formatters.dart';

/// Interactive Date Filter Bar with Quick Chips & Calendar Picker (< 130 lines).
class NotificationDateFilterBar extends StatelessWidget {
  const NotificationDateFilterBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final isTodaySelected = _isSameDay(selectedDate, today);
    final isYesterdaySelected = _isSameDay(selectedDate, yesterday);
    final isCustomDateSelected = !isTodaySelected && !isYesterdaySelected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Today Chip
            _buildChip(
              context: context,
              label: context.tr('filter_today'),
              isSelected: isTodaySelected,
              isDark: isDark,
              onTap: () => onDateSelected(today),
            ),
            const SizedBox(width: 8),

            // Yesterday Chip
            _buildChip(
              context: context,
              label: context.tr('filter_yesterday'),
              isSelected: isYesterdaySelected,
              isDark: isDark,
              onTap: () => onDateSelected(yesterday),
            ),
            const SizedBox(width: 8),

            // Calendar Picker Chip
            _buildChip(
              context: context,
              label: isCustomDateSelected
                  ? AppFormatters.formatDate(selectedDate)
                  : context.tr('filter_pick_date'),
              icon: Icons.calendar_month_rounded,
              isSelected: isCustomDateSelected,
              isDark: isDark,
              onTap: () => _showDatePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldPrimary
              : (isDark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.goldPrimary
                : (isDark ? const Color(0x26FFFFFF) : const Color(0x80FFFFFF)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.goldPrimary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }
}
