import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/attendance/presentation/pages/qr_attendance_page.dart';
import 'package:staff_app/features/examination/presentation/pages/examination_results_page.dart';
import 'package:staff_app/features/examination/presentation/pages/question_upload_page.dart';
import 'package:staff_app/features/examination/presentation/pages/student_marks_entry_page.dart';
import 'package:staff_app/features/salary/presentation/pages/staff_salary_page.dart';
import 'package:staff_app/features/visitors/presentation/pages/visitor_scanner_page.dart';

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.accentColor,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color accentColor;
}

/// Responsive Grid of Teacher and Staff Daily Actions (< 150 lines).
/// Styled with identical Liquid Crystal Gold-Frosted Glassmorphism as DashboardPunchCard.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  static const List<_ActionItem> _actions = [
    _ActionItem(
      icon: Icons.account_balance_wallet_rounded,
      titleKey: 'action_salary',
      subtitleKey: 'action_salary_sub',
      accentColor: AppColors.goldPrimary,
    ),
    _ActionItem(
      icon: Icons.qr_code_scanner_rounded,
      titleKey: 'action_qr_attendance',
      subtitleKey: 'action_qr_attendance_sub',
      accentColor: AppColors.goldPrimary,
    ),
    _ActionItem(
      icon: Icons.quiz_rounded,
      titleKey: 'action_upload_questions',
      subtitleKey: 'action_upload_questions_sub',
      accentColor: AppColors.goldPrimary,
    ),
    _ActionItem(
      icon: Icons.fact_check_rounded,
      titleKey: 'action_marks_entry',
      subtitleKey: 'action_marks_entry_sub',
      accentColor: AppColors.goldPrimary,
    ),
    _ActionItem(
      icon: Icons.badge_rounded,
      titleKey: 'action_visitor_pass',
      subtitleKey: 'action_visitor_pass_sub',
      accentColor: AppColors.goldPrimary,
    ),
    _ActionItem(
      icon: Icons.workspace_premium_rounded,
      titleKey: 'action_results',
      subtitleKey: 'action_results_sub',
      accentColor: AppColors.goldPrimary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCard(context, _actions[0], isDark)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildCard(context, _actions[1], isDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildCard(context, _actions[2], isDark)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildCard(context, _actions[3], isDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildCard(context, _actions[4], isDark)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildCard(context, _actions[5], isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _ActionItem item, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x3D1E293B),
                      const Color(0x240F172A),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFFBF8F3).withValues(alpha: 0.88),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.goldPrimary.withValues(alpha: 0.38)
                  : AppColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (item.titleKey == 'action_salary') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StaffSalaryPage(),
                    ),
                  );
                } else if (item.titleKey == 'action_qr_attendance') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QrAttendancePage(),
                    ),
                  );
                } else if (item.titleKey == 'action_upload_questions') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuestionUploadPage(),
                    ),
                  );
                } else if (item.titleKey == 'action_marks_entry') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StudentMarksEntryPage(),
                    ),
                  );
                } else if (item.titleKey == 'action_visitor_pass') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VisitorScannerPage(),
                    ),
                  );
                } else if (item.titleKey == 'action_results') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExaminationResultsPage(),
                    ),
                  );
                } else if (item.titleKey == 'action_students') {
                  context.go(RouteNames.students);
                } else {
                  AppSnackBar.showSuccess(context, '${context.tr(item.titleKey)} — Ready');
                }
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: AppColors.goldPrimary.withValues(alpha: 0.12),
              highlightColor: AppColors.goldPrimary.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.accentColor.withValues(alpha: 0.22),
                            item.accentColor.withValues(alpha: 0.10),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.accentColor.withValues(alpha: 0.38),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(item.icon, color: item.accentColor, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.tr(item.titleKey),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.tr(item.subtitleKey),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        maxLines: 1,
                      ),
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
}
