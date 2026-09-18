import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

/// Ultra-Luxury Glassmorphic Salary KPI Row strictly complying with:
/// FRONTEND_RULES.md (Liquid Crystal Glassmorphism & Zero Solid Cards)
/// AppColors ZERO BLUE FAMILY LAW (100% purged blues).
class SalaryKpiCards extends StatelessWidget {
  const SalaryKpiCards({super.key, required this.stats});

  final InstitutionalSalaryStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          // 1. Total Annual Budget (11M) -> Champagne Gold
          _buildCard(
            title: 'Total Budget',
            badge: '11-Months Target',
            value: '₹${stats.totalAnnualBudget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            icon: Icons.trending_up_rounded,
            accentColor: AppColors.goldPrimary,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // 2. Total Disbursed (Paid) -> Emerald
          _buildCard(
            title: 'Total Disbursed',
            badge: '${stats.completionRate}% Cleared',
            value: '₹${stats.totalPaidAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            icon: Icons.check_circle_rounded,
            accentColor: AppColors.statusPresent,
            showPulse: true,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // 3. Pending Dues -> Rose Crimson
          _buildCard(
            title: 'Pending Dues',
            badge: '${stats.totalDueTeachers} Due',
            value: '₹${stats.totalDueAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            icon: Icons.error_outline_rounded,
            accentColor: AppColors.rosePrimary,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // 4. Total Deductions -> Warm Amber Gold (Zero Purple)
          _buildCard(
            title: 'Total Deductions',
            badge: 'Leaves & Cuts',
            value: '₹${stats.totalDeductions.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            icon: Icons.trending_down_rounded,
            accentColor: AppColors.statusLeave,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // 5. Faculty Members -> Antique Champagne
          _buildCard(
            title: 'Faculty Members',
            badge: 'Total Staff',
            value: '${stats.totalStaff}',
            icon: Icons.groups_rounded,
            accentColor: AppColors.goldChampagne,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // 6. Session Balance -> Deep Bronze Gold
          _buildCard(
            title: 'Session Balance',
            badge: 'Remaining Dues',
            value: '₹${stats.totalRemaining.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            icon: Icons.account_balance_wallet_rounded,
            accentColor: AppColors.goldDark,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String badge,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    bool showPulse = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.40 : 0.70),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.38 : 0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? accentColor.withValues(alpha: 0.95) : accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.25),
                          accentColor.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(icon, size: 12, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showPulse) ...[
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: isDark ? 0.30 : 0.20),
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
