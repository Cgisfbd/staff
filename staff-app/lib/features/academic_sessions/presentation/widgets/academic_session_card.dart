import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/lock_session_sheet.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/session_finance_grid.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/session_hierarchy_grid.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/session_progress_bar.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/session_student_stats_grid.dart';

class AcademicSessionCard extends StatelessWidget {
  const AcademicSessionCard({
    super.key,
    required this.session,
    required this.isExpanded,
    required this.onTap,
    required this.isAdmin,
  });

  final AcademicSessionEntity session;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startStr = DateFormat('dd MMM yyyy').format(session.startDate);
    final endStr = session.endDate != null ? DateFormat('dd MMM yyyy').format(session.endDate!) : 'Present (Active)';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? (isExpanded ? 0.50 : 0.38) : (isExpanded ? 0.95 : 0.88)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: session.isActive
                    ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.55 : 0.45)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : AppColors.goldPrimary.withValues(alpha: 0.20)),
                width: session.isActive ? 1.2 : 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: session.isActive
                      ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.12)
                      : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: session.isActive ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Status Icon Badge
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: session.isActive
                                    ? const [AppColors.goldDark, AppColors.goldPrimary]
                                    : (session.isLocked
                                        ? const [Color(0xFF881337), AppColors.rosePrimary]
                                        : const [AppColors.charcoalDark, AppColors.charcoalMedium]),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: session.isActive
                                      ? AppColors.goldPrimary.withValues(alpha: 0.35)
                                      : (session.isLocked
                                          ? AppColors.rosePrimary.withValues(alpha: 0.3)
                                          : Colors.black.withValues(alpha: 0.2)),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              session.isActive
                                  ? Icons.bolt_rounded
                                  : (session.isLocked ? Icons.lock_rounded : Icons.access_time_rounded),
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Session Title & Dates
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.yearName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$startStr ➔ $endStr',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Live Badge or Locked Badge
                          if (session.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldLight.withValues(alpha: isDark ? 0.2 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.emeraldLight.withValues(alpha: 0.45),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fiber_manual_record_rounded, size: 7, color: AppColors.emeraldLight),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: AppColors.emeraldLight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (session.isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.rosePrimary.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.rosePrimary.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 10, color: AppColors.rosePrimary),
                                  SizedBox(width: 4),
                                  Text(
                                    'LOCKED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: AppColors.rosePrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // Collapsed Mini Progress Indicator
                      if (!isExpanded) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 4,
                            width: double.infinity,
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: session.progress.clamp(0, 100) / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: session.isActive
                                        ? const [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldChampagne]
                                        : const [AppColors.charcoalDark, AppColors.charcoalMedium],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Expanded Body
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.goldPrimary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),

                        // Progress Bar
                        SessionProgressBar(progress: session.progress),
                        const SizedBox(height: 12),

                        // 1. Student Stats
                        SessionStudentStatsGrid(stats: session.studentStats),
                        const SizedBox(height: 12),

                        // 2. Hierarchy Stats
                        SessionHierarchyGrid(stats: session.hierarchyStats),
                        const SizedBox(height: 12),

                        // 3. Finance Stats
                        SessionFinanceGrid(stats: session.financeStats),
                        const SizedBox(height: 14),

                        // Action Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (session.isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldLight.withValues(alpha: isDark ? 0.15 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.emeraldLight.withValues(alpha: 0.3),
                                    width: 0.7,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.history_edu_rounded, size: 13, color: AppColors.emeraldLight),
                                    SizedBox(width: 5),
                                    Text(
                                      'Historical Archive (Read-Only)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emeraldLight,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (isAdmin)
                              InkWell(
                                onTap: () => LockSessionSheet.show(context, session: session),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.rosePrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.rosePrimary.withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield_outlined, size: 13, color: AppColors.rosePrimary),
                                      SizedBox(width: 5),
                                      Text(
                                        'Lock Session',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.rosePrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
