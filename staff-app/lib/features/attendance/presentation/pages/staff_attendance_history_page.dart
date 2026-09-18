import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/attendance/data/datasources/staff_attendance_datasource.dart';
import 'package:staff_app/features/attendance/domain/models/staff_attendance_record.dart';
import 'package:staff_app/features/staff/presentation/pages/apply_leave_page.dart';

/// Screen Orchestrator for Staff Personal Attendance & Punch History (< 280 lines).
class StaffAttendanceHistoryPage extends StatefulWidget {
  const StaffAttendanceHistoryPage({super.key});

  @override
  State<StaffAttendanceHistoryPage> createState() => _StaffAttendanceHistoryPageState();
}

class _StaffAttendanceHistoryPageState extends State<StaffAttendanceHistoryPage> {
  final StaffAttendanceDatasource _datasource = const StaffAttendanceDatasource();
  late int _selectedMonth;
  late int _selectedYear;
  String _selectedFilter = 'ALL';

  List<StaffAttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _records = _datasource.getMonthlyRecords(
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  void _loadRecords() {
    setState(() {
      _records = _datasource.getMonthlyRecords(
        year: _selectedYear,
        month: _selectedMonth,
      );
    });
  }

  List<StaffAttendanceRecord> get _filteredRecords {
    if (_selectedFilter == 'PRESENT') {
      return _records.where((r) => r.status == StaffAttendanceStatus.present).toList();
    } else if (_selectedFilter == 'LEAVE') {
      return _records.where((r) => r.status == StaffAttendanceStatus.leave).toList();
    } else if (_selectedFilter == 'ABSENT') {
      return _records.where((r) => r.status == StaffAttendanceStatus.absent).toList();
    }
    return _records;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredRecords;

    final presentCount = _records.where((r) => r.status == StaffAttendanceStatus.present).length;
    final leaveCount = _records.where((r) => r.status == StaffAttendanceStatus.leave).length;
    final absentCount = _records.where((r) => r.status == StaffAttendanceStatus.absent).length;
    final totalWorking = presentCount + leaveCount + absentCount;
    final rateStr = totalWorking > 0
        ? '${((presentCount / totalWorking) * 100).toStringAsFixed(1)}%'
        : '0%';

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Polished Executive Header with "Apply Leave" Action
              ExecutiveTopHeader(
                icon: Icons.event_available_rounded,
                title: context.tr('history_top_title'),
                subtitle: context.tr('history_top_subtitle'),
                onIconTap: () => Navigator.of(context).maybePop(),
                trailing: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ApplyLeavePage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('action_apply_leave'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Month Selector Strip
              _buildMonthSelector(context, isDark),

              // Scrollable Content
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                  children: [
                    // Monthly KPI Summary Card
                    _buildKpiCard(
                      context: context,
                      isDark: isDark,
                      present: presentCount,
                      leaves: leaveCount,
                      absent: absentCount,
                      rate: rateStr,
                    ),

                    const SizedBox(height: 14),

                    // Filter Chips (All / Present / Leave / Absent)
                    _buildFilterChips(context, isDark),

                    const SizedBox(height: 12),

                    // Log Items or Empty State
                    if (filtered.isEmpty)
                      _buildEmptyState(context, isDark)
                    else
                      ...filtered.map((record) => _buildRecordCard(context, record, isDark)),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableMonths(BuildContext context) {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final d = DateTime(now.year, now.month - index, 1);
      final monthName = context.tr('month_${d.month}');
      return {
        'name': '$monthName ${d.year}',
        'month': d.month,
        'year': d.year,
      };
    });
  }

  Widget _buildMonthSelector(BuildContext context, bool isDark) {
    final months = _getAvailableMonths(context);

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = months[index];
          final isSelected = item['month'] == _selectedMonth && item['year'] == _selectedYear;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedMonth = item['month'] as int;
                _selectedYear = item['year'] as int;
              });
              _loadRecords();
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.goldPrimary
                    : (isDark ? const Color(0x2B1E293B) : const Color(0x52F1F5F9)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.goldChampagne
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 0.9,
                ),
              ),
              child: Center(
                child: Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required bool isDark,
    required int present,
    required int leaves,
    required int absent,
    required String rate,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      Colors.white.withValues(alpha: 0.60),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.goldPrimary.withValues(alpha: 0.35)
                  : AppColors.goldPrimary.withValues(alpha: 0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppColors.goldPrimary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.5),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          size: 13,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        context.tr('history_monthly_summary'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      '$_selectedMonth/$_selectedYear',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _kpiTile(
                      label: context.tr('teacher_attendance_present'),
                      value: '$present',
                      color: AppColors.statusPresent,
                      icon: Icons.check_circle_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _kpiTile(
                      label: context.tr('teacher_attendance_leaves'),
                      value: '$leaves',
                      color: AppColors.statusLeave,
                      icon: Icons.beach_access_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _kpiTile(
                      label: context.tr('teacher_attendance_absent'),
                      value: '$absent',
                      color: AppColors.statusAbsent,
                      icon: Icons.cancel_outlined,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _kpiTile(
                      label: context.tr('history_stat_ratio'),
                      value: rate,
                      color: AppColors.goldPrimary,
                      icon: Icons.pie_chart_outline_rounded,
                      isDark: isDark,
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

  Widget _kpiTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.08) : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    final filters = [
      ('ALL', context.tr('filter_all')),
      ('PRESENT', context.tr('filter_present')),
      ('LEAVE', context.tr('filter_leave')),
      ('ABSENT', context.tr('filter_absent')),
    ];

    return Row(
      children: filters.map((f) {
        final isSelected = _selectedFilter == f.$1;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = f.$1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.goldDark : AppColors.goldPrimary)
                      : (isDark ? const Color(0x1F1E293B) : const Color(0x33E2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.goldPrimary : Colors.transparent,
                    width: 0.9,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordCard(BuildContext context, StaffAttendanceRecord record, bool isDark) {
    final dayNum = record.date.day.toString().padLeft(2, '0');
    final dayName = context.tr('day_${record.date.weekday}');
    final statusColor = _getStatusColor(record.status);
    final statusLabel = _getStatusLabel(context, record.status, record.leaveType);
    final totalHoursLabel = record.workingHours != null
        ? context.tr('history_total_hours').replaceAll('{hours}', record.workingHours!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          // Date Badge Medallion
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x40000000) : const Color(0x0F000000),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Main Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Pill Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    if (totalHoursLabel != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          totalHoursLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                // In & Out Timestamps or Notes
                if (record.status == StaffAttendanceStatus.present) ...[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login_rounded, size: 13, color: AppColors.statusPresent),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('history_in_prefix').replaceAll('{time}', record.inTime ?? '--'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.logout_rounded, size: 13, color: AppColors.statusAbsent),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('history_out_prefix').replaceAll('{time}', record.outTime ?? '--'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    _getLocalizedNotes(context, record.notes),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StaffAttendanceStatus status) {
    switch (status) {
      case StaffAttendanceStatus.present:
        return AppColors.statusPresent;
      case StaffAttendanceStatus.leave:
        return AppColors.statusLeave;
      case StaffAttendanceStatus.absent:
        return AppColors.statusAbsent;
      case StaffAttendanceStatus.holiday:
        return const Color(0xFF64748B);
    }
  }

  String _getStatusLabel(BuildContext context, StaffAttendanceStatus status, String? leaveType) {
    switch (status) {
      case StaffAttendanceStatus.present:
        return context.tr('attendance_stat_present');
      case StaffAttendanceStatus.leave:
        if (leaveType != null && leaveType.toLowerCase().contains('casual')) {
          return context.tr('status_casual_leave');
        } else if (leaveType != null && leaveType.toLowerCase().contains('medical')) {
          return context.tr('status_medical_leave');
        }
        return context.tr('attendance_stat_leave');
      case StaffAttendanceStatus.absent:
        return context.tr('attendance_stat_absent');
      case StaffAttendanceStatus.holiday:
        return context.tr('status_holiday');
    }
  }

  String _getLocalizedNotes(BuildContext context, String? notes) {
    if (notes == null) return context.tr('history_status_recorded');
    if (notes.contains('Holiday')) return context.tr('history_weekly_holiday');
    if (notes.contains('Approved')) return context.tr('history_admin_approved');
    if (notes.contains('Unannounced') || notes.contains('Absence')) {
      return context.tr('history_unannounced_absence');
    }
    return notes;
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 40,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('history_no_records'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
