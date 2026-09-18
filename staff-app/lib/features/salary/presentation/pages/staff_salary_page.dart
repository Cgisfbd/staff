import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/salary/data/datasources/staff_salary_datasource.dart';
import 'package:staff_app/features/salary/domain/models/staff_salary_record.dart';

/// Screen Orchestrator for Teacher's Salary Statement (< 280 lines).
/// Fully Trilingual (EN, UR, HI) with RTL support, Visual Distribution Chart,
/// and simplified institutional deductions (Absent days, Late arrivals & Advance recovery).
class StaffSalaryPage extends StatefulWidget {
  const StaffSalaryPage({super.key});

  @override
  State<StaffSalaryPage> createState() => _StaffSalaryPageState();
}

class _StaffSalaryPageState extends State<StaffSalaryPage> {
  final StaffSalaryDatasource _datasource = const StaffSalaryDatasource();
  late SalaryOverview _overview;
  late List<StaffSalaryRecord> _records;
  final Set<String> _expandedRecordIds = {};

  @override
  void initState() {
    super.initState();
    _overview = _datasource.getOverview();
    _records = _datasource.getMonthlyHistory();
    if (_records.isNotEmpty) {
      _expandedRecordIds.add(_records.first.id);
    }
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedRecordIds.contains(id)) {
        _expandedRecordIds.remove(id);
      } else {
        _expandedRecordIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(context, isDark, isRtl),

              // Scrollable Single Page View
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                  children: [
                    // Top Overview Chart & Stats Deck Card
                    _buildOverviewChartCard(context, isDark),

                    const SizedBox(height: 18),

                    // Section Heading Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('salary_statements_title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('salary_months_count', params: {'count': '${_records.length}'}),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Expandable Monthly Cards
                    ..._records.map((record) => _buildExpandableMonthlyCard(context, record, isDark)),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.9,
                ),
              ),
              child: Icon(
                isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('salary_title'),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                ),
                Text(
                  context.tr('salary_subtitle'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewChartCard(BuildContext context, bool isDark) {
    final totalPool = _overview.totalPaid + _overview.totalPending + _overview.totalDeductions;
    final paidFraction = totalPool > 0 ? (_overview.totalPaid / totalPool).clamp(0.05, 0.90) : 0.70;
    final pendingFraction = totalPool > 0 ? (_overview.totalPending / totalPool).clamp(0.05, 0.40) : 0.18;
    final deductionsFraction = totalPool > 0 ? (_overview.totalDeductions / totalPool).clamp(0.02, 0.20) : 0.12;

    final paidPct = (paidFraction * 100).toInt();
    final pendingPct = (pendingFraction * 100).toInt();
    final deductionsPct = (deductionsFraction * 100).toInt();

    final totalDisbursedPool = _records.fold<double>(0.0, (sum, r) => sum + r.netSalary);
    final avgMonthlyPayout = _records.isNotEmpty ? totalDisbursedPool / _records.length : _overview.baseSalary;
    final chronologicalRecords = _records.reversed.toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x661E293B),
                      const Color(0x520F172A),
                      const Color(0x5C1E293B),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.96),
                      const Color(0xF7F8FAFC),
                      Colors.white.withValues(alpha: 0.94),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.45 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: Medallion + Annual Title + Fiscal Year Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('salary_annual_title'),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Fiscal Year Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      context.tr('salary_fiscal_year'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 2. HERO SPOTLIGHT: TOTAL ANNUAL PACKAGE (کل سالانہ تنخواہ)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x3D0F172A) : const Color(0x40F1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('salary_annual_package'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppFormatters.formatCurrency(_overview.annualSalary),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('salary_per_annum'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dual Sub-Pills: Monthly Base & YTD Disbursed
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 10.5, color: isDark ? AppColors.goldChampagne : AppColors.goldDark),
                                const SizedBox(width: 4),
                                Text(
                                  '${context.tr('salary_base_fixed')}: ${AppFormatters.formatCurrency(_overview.baseSalary)}${context.tr('salary_per_month')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.statusPresent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.statusPresent.withValues(alpha: 0.3),
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              context.tr('salary_ytd_disbursed_chip', params: {
                                'amount': AppFormatters.formatCurrency(_overview.totalPaid),
                              }),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.statusPresent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. 3-Column Floating Pods: Received | Pending | Upcoming Est.
              Row(
                children: [
                  Expanded(
                    child: _buildLuxuryPod(
                      label: context.tr('salary_received'),
                      amount: _overview.totalPaid,
                      accentColor: AppColors.statusPresent,
                      bgColor: AppColors.statusPresent.withValues(alpha: isDark ? 0.14 : 0.08),
                      icon: Icons.check_circle_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLuxuryPod(
                      label: context.tr('salary_pending'),
                      amount: _overview.totalPending,
                      accentColor: AppColors.statusLeave,
                      bgColor: AppColors.statusLeave.withValues(alpha: isDark ? 0.14 : 0.08),
                      icon: Icons.hourglass_top_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLuxuryPod(
                      label: context.tr('salary_upcoming'),
                      amount: _overview.upcomingEstimate,
                      accentColor: AppColors.goldPrimary,
                      bgColor: AppColors.goldPrimary.withValues(alpha: isDark ? 0.14 : 0.08),
                      icon: Icons.schedule_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 4. Visual 6-Month Monthly Payout Bar Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x330F172A) : const Color(0x3DF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chart Header Row: Title & Avg Pill
                    Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded, size: 15, color: AppColors.goldPrimary),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            context.tr('salary_chart_title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3), width: 0.7),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.tr('salary_chart_avg', params: {
                                  'amount': AppFormatters.formatCurrency(avgMonthlyPayout),
                                }),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 6-Month Vertical Bar Chart Deck
                    SizedBox(
                      height: 70,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chronologicalRecords.map((r) {
                          final isPaid = r.status == 'PAID';
                          final ratio = (r.netSalary / _overview.baseSalary).clamp(0.25, 1.0);
                          final barHeight = ratio * 36.0;
                          final monthShort = DateFormat('MMM').format(DateTime(r.year, r.month));
                          final kAmount = '${(r.netSalary / 1000).toStringAsFixed(1)}k';

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      kAmount,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: isPaid
                                            ? (isDark ? Colors.white70 : AppColors.textLightSecondary)
                                            : AppColors.statusLeave,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: isPaid
                                            ? [AppColors.statusPresent, const Color(0xFF047857)]
                                            : [AppColors.statusLeave, const Color(0xFFB45309)],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isPaid ? AppColors.statusPresent : AppColors.statusLeave)
                                              .withValues(alpha: 0.25),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      monthShort,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Horizontal Segmented Ratio Track (Summary)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('salary_chart_ratio'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('salary_disbursed_badge', params: {'percent': '$paidPct'}),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.statusPresent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              flex: (paidFraction * 100).toInt(),
                              child: Container(color: AppColors.statusPresent),
                            ),
                            const SizedBox(width: 1.5),
                            Flexible(
                              flex: (pendingFraction * 100).toInt(),
                              child: Container(color: AppColors.statusLeave),
                            ),
                            const SizedBox(width: 1.5),
                            Flexible(
                              flex: (deductionsFraction * 100).toInt(),
                              child: Container(color: AppColors.statusAbsent),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Chart Legend Strip
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _legendDot(AppColors.statusPresent, context.tr('salary_chart_paid', params: {'percent': '$paidPct'}), isDark),
                          const SizedBox(width: 12),
                          _legendDot(AppColors.statusLeave, context.tr('salary_chart_pending', params: {'percent': '$pendingPct'}), isDark),
                          const SizedBox(width: 12),
                          _legendDot(AppColors.statusAbsent, context.tr('salary_chart_deductions', params: {'percent': '$deductionsPct'}), isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Total Deductions & Attendance Impact Pill (Direct context for teacher)
              if (_overview.totalDeductions > 0 || _overview.totalLateDays > 0 || _overview.totalAbsentDays > 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.statusAbsent.withValues(alpha: isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.statusAbsent.withValues(alpha: isDark ? 0.30 : 0.20),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down_rounded, size: 14, color: AppColors.statusAbsent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${context.tr('salary_total_deductions')}: -${AppFormatters.formatCurrency(_overview.totalDeductions)} (${context.tr('salary_late_penalty_short', params: {'count': '${_overview.totalLateDays}'})} • ${context.tr('salary_absent_days_short', params: {'count': '${_overview.totalAbsentDays}'})})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFFDA4AF) : AppColors.statusAbsent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLuxuryPod({
    required String label,
    required double amount,
    required Color accentColor,
    required Color bgColor,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 0.9,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 15, color: accentColor),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppFormatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMonthlyCard(BuildContext context, StaffSalaryRecord record, bool isDark) {
    final isExpanded = _expandedRecordIds.contains(record.id);
    final isPaid = record.status == 'PAID';
    final statusColor = isPaid ? AppColors.statusPresent : AppColors.statusLeave;
    final statusKey = isPaid ? 'salary_status_paid' : (record.status == 'PENDING' ? 'salary_status_pending' : 'salary_status_upcoming');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.goldPrimary.withValues(alpha: 0.45)
              : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
          width: isExpanded ? 1.1 : 0.9,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleExpand(record.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapsed Summary Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Calendar Icon Medallion
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x33000000) : const Color(0x0F000000),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 19,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Month & Mode Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.monthName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.paymentMode} • ${record.paymentDate ?? '--'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Net Amount + Status Badge
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(record.netSalary),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.7),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.tr(statusKey),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ],
                ),

                // Expanded Section: Detailed Breakdown
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: isDark ? Colors.white12 : Colors.black12,
                    height: 1,
                    thickness: 0.8,
                  ),
                  const SizedBox(height: 12),

                  // Base Salary
                  _buildDetailRow(
                    label: context.tr('salary_base_fixed'),
                    value: AppFormatters.formatCurrency(record.baseSalary),
                    valueColor: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    isDark: isDark,
                  ),

                  // Absent Deduction
                  if (record.absentDays > 0)
                    _buildDetailRow(
                      label: context.tr(
                        record.absentDays > 1 ? 'salary_absent_deduction_plural' : 'salary_absent_deduction',
                        params: {'days': '${record.absentDays}'},
                      ),
                      value: '- ${AppFormatters.formatCurrency(record.absentDeduction)}',
                      valueColor: AppColors.statusAbsent,
                      isDark: isDark,
                    )
                  else
                    _buildDetailRow(
                      label: context.tr('salary_absent_deduction', params: {'days': '0'}),
                      value: context.tr('salary_nil'),
                      valueColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      isDark: isDark,
                    ),

                  // Late Arrival Penalty
                  if (record.lateDays > 0)
                    _buildDetailRow(
                      label: context.tr(
                        record.lateDays > 1 ? 'salary_late_deduction_plural' : 'salary_late_deduction',
                        params: {'days': '${record.lateDays}'},
                      ),
                      value: '- ${AppFormatters.formatCurrency(record.lateDeduction)}',
                      valueColor: AppColors.statusAbsent,
                      isDark: isDark,
                    )
                  else
                    _buildDetailRow(
                      label: context.tr('salary_late_deduction', params: {'days': '0'}),
                      value: context.tr('salary_nil'),
                      valueColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      isDark: isDark,
                    ),

                  // Advance Recovery
                  if (record.advanceDeduction > 0)
                    _buildDetailRow(
                      label: context.tr('salary_advance_recovery'),
                      value: '- ${AppFormatters.formatCurrency(record.advanceDeduction)}',
                      valueColor: AppColors.statusLeave,
                      isDark: isDark,
                    )
                  else
                    _buildDetailRow(
                      label: context.tr('salary_advance_recovery'),
                      value: context.tr('salary_nil'),
                      valueColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      isDark: isDark,
                    ),

                  Divider(
                    color: isDark ? Colors.white12 : Colors.black12,
                    height: 12,
                    thickness: 0.8,
                  ),

                  // Net Payable / Disbursed
                  _buildDetailRow(
                    label: isPaid ? context.tr('salary_net_disbursed') : context.tr('salary_net_payable'),
                    value: AppFormatters.formatCurrency(record.netSalary),
                    valueColor: AppColors.statusPresent,
                    isBold: true,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 8),

                  // Notes / Disbursement Details Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2B1E293B) : const Color(0x40F1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record.paidBy != null)
                          Text(
                            context.tr('salary_disbursed_by', params: {'name': record.paidBy!}),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                          ),
                        if (record.receiptNo != null)
                          Text(
                            context.tr('salary_receipt_no', params: {'number': record.receiptNo!}),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                        if (record.notes != null)
                          Text(
                            context.tr('salary_remarks', params: {'notes': record.notes!}),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Button: Download Receipt / Voucher
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('salary_receipt_downloaded', params: {'month': record.monthName})),
                          backgroundColor: AppColors.statusPresent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x33C5A059) : const Color(0x1FC5A059),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4),
                          width: 0.9,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_rounded, size: 14, color: AppColors.goldPrimary),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('salary_download_receipt'),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: isBold
                    ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
