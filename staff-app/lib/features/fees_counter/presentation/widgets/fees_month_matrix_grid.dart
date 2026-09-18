import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

/// Mini horizontal 10-month status row used inside student list tiles.
/// 100% Zero Blue compliant, uses Emerald (Paid), Rose (Due), and Warm Amber (Waived).
class StudentMonthPillsRow extends StatelessWidget {
  const StudentMonthPillsRow({super.key, required this.monthStatusMap});

  final Map<String, MonthStatusType> monthStatusMap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3.5,
      runSpacing: 3.5,
      children: kCalendarMonths.map((m) {
        final status = monthStatusMap[m.shortEn] ?? MonthStatusType.upcoming;
        return _buildMiniPill(m.shortEn, status);
      }).toList(),
    );
  }

  Widget _buildMiniPill(String shortName, MonthStatusType status) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case MonthStatusType.paid:
        bg = const Color(0x2E059669);
        fg = AppColors.statusPresent;
        border = const Color(0x66059669);
        break;
      case MonthStatusType.waived:
        bg = const Color(0x2ED97706);
        fg = AppColors.statusLeave;
        border = const Color(0x66D97706);
        break;
      case MonthStatusType.pending:
        bg = const Color(0x2EE11D48);
        fg = AppColors.rosePrimary;
        border = const Color(0x66E11D48);
        break;
      case MonthStatusType.upcoming:
        bg = const Color(0x1A94A3B8);
        fg = const Color(0xFF64748B);
        border = const Color(0x2E94A3B8);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        shortName,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// Interactive 10-Month Selection Grid for the Live Cash Counter (Level 4).
/// Features Liquid Crystal Glassmorphism, Champagne Gold selection, and tactile feedback.
class InteractiveMonthSelectorGrid extends StatelessWidget {
  const InteractiveMonthSelectorGrid({
    super.key,
    required this.monthStatusMap,
    required this.selectedMonths,
    required this.onToggleMonth,
    required this.monthlyRate,
  });

  final Map<String, MonthStatusType> monthStatusMap;
  final List<String> selectedMonths;
  final ValueChanged<String> onToggleMonth;
  final double monthlyRate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.92,
      ),
      itemCount: kCalendarMonths.length,
      itemBuilder: (context, index) {
        final month = kCalendarMonths[index];
        final status = monthStatusMap[month.shortEn] ?? MonthStatusType.upcoming;
        final isSelected = selectedMonths.contains(month.shortEn);
        final isSettled = status == MonthStatusType.paid || status == MonthStatusType.waived;

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSettled ? null : () => onToggleMonth(month.shortEn),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : _getBgColor(status, isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.goldLight
                          : _getBorderColor(status, isDark),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.40),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#0${month.order}',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                          _buildStatusIcon(status, isSelected),
                        ],
                      ),
                      Text(
                        month.shortEn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textLightPrimary),
                        ),
                      ),
                      Text(
                        _getStatusLabel(status, isSelected),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.95)
                              : _getTextColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBgColor(MonthStatusType status, bool isDark) {
    switch (status) {
      case MonthStatusType.paid:
        return isDark ? const Color(0x2E059669) : const Color(0x22059669);
      case MonthStatusType.waived:
        return isDark ? const Color(0x2ED97706) : const Color(0x22D97706);
      case MonthStatusType.pending:
        return isDark ? const Color(0x2EE11D48) : const Color(0x22E11D48);
      case MonthStatusType.upcoming:
        return isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03);
    }
  }

  Color _getBorderColor(MonthStatusType status, bool isDark) {
    switch (status) {
      case MonthStatusType.paid:
        return const Color(0x80059669);
      case MonthStatusType.waived:
        return const Color(0x80D97706);
      case MonthStatusType.pending:
        return const Color(0x80E11D48);
      case MonthStatusType.upcoming:
        return isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.18);
    }
  }

  Color _getTextColor(MonthStatusType status) {
    switch (status) {
      case MonthStatusType.paid:
        return AppColors.statusPresent;
      case MonthStatusType.waived:
        return AppColors.statusLeave;
      case MonthStatusType.pending:
        return AppColors.rosePrimary;
      case MonthStatusType.upcoming:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildStatusIcon(MonthStatusType status, bool isSelected) {
    if (isSelected) {
      return const Icon(Icons.check_circle_rounded, size: 10, color: Colors.white);
    }
    switch (status) {
      case MonthStatusType.paid:
        return const Icon(Icons.check_rounded, size: 10, color: AppColors.statusPresent);
      case MonthStatusType.waived:
        return const Icon(Icons.auto_awesome_rounded, size: 9, color: AppColors.statusLeave);
      case MonthStatusType.pending:
        return Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.rosePrimary,
            shape: BoxShape.circle,
          ),
        );
      case MonthStatusType.upcoming:
        return Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
        );
    }
  }

  String _getStatusLabel(MonthStatusType status, bool isSelected) {
    if (isSelected) return 'SELECTED';
    switch (status) {
      case MonthStatusType.paid:
        return 'PAID';
      case MonthStatusType.waived:
        return 'WAIVED';
      case MonthStatusType.pending:
        return 'DUE';
      case MonthStatusType.upcoming:
        return 'FUTURE';
    }
  }
}
