import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_bloc.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_event.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_state.dart';
import 'package:staff_app/features/salary_counter/presentation/widgets/salary_kpi_cards.dart';
import 'package:staff_app/features/salary_counter/presentation/widgets/salary_receipt_voucher_dialog.dart';

class SalaryCounterPage extends StatelessWidget {
  const SalaryCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SalaryCounterBloc>()..add(const LoadSalaryInitialEvent()),
      child: const _SalaryCounterView(),
    );
  }
}

class _SalaryCounterView extends StatelessWidget {
  const _SalaryCounterView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SalaryCounterBloc, SalaryCounterState>(
      listenWhen: (prev, current) =>
          prev.errorMessage != current.errorMessage ||
          prev.successMessage != current.successMessage ||
          prev.generatedReceipt != current.generatedReceipt,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.rosePrimary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.statusPresent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.generatedReceipt != null && state.selectedTeacher != null) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => SalaryReceiptVoucherDialog(
              receipt: state.generatedReceipt!,
              teacher: state.selectedTeacher!,
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<SalaryCounterBloc>().add(const DismissSalaryVoucherEvent());
            }
          });
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !state.isDetailMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.read<SalaryCounterBloc>().add(const DeselectTeacherEvent());
            }
          },
          child: Scaffold(
            body: AppBackground(
              useSafeArea: false,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    ExecutiveTopHeader(
                      icon: state.isDetailMode
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.payments_rounded,
                      title: state.isDetailMode
                          ? (state.selectedTeacher?.name ?? 'Faculty Salary')
                          : 'Salary Counter',
                      subtitle: state.isDetailMode
                          ? 'Live Disbursement Counter & Dual Salary Slip'
                          : 'Institutional Faculty Payroll & Disbursement Hub',
                      onIconTap: () {
                        if (state.isDetailMode) {
                          context.read<SalaryCounterBloc>().add(const DeselectTeacherEvent());
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      trailing: state.isDetailMode
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                context.read<SalaryCounterBloc>().add(const DeselectTeacherEvent());
                              },
                            )
                          : null,
                    ),
                    if (state.isDetailMode && state.selectedTeacher != null)
                      _buildBreadcrumbs(context, state.selectedTeacher!.name, isDark),
                    Expanded(
                      child: state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.goldPrimary),
                            )
                          : state.isDetailMode
                              ? _buildFacultyDetailWorkspace(context, state, isDark)
                              : _buildAllFacultyOverview(context, state, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, String teacherName, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.38 : 0.88),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : AppColors.goldPrimary.withValues(alpha: 0.22),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => context.read<SalaryCounterBloc>().add(const DeselectTeacherEvent()),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Faculty Directory',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.goldPrimary),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      teacherName,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.goldPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CASE A: ALL-FACULTY OVERVIEW MODE (Level 1)
  // ===========================================================================
  Widget _buildAllFacultyOverview(
    BuildContext context,
    SalaryCounterState state,
    bool isDark,
  ) {
    final facultyList = state.filteredFacultyList;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
      children: [
        // 1. 6 Multi-Color Glass KPI Cards
        if (state.stats != null) ...[
          SalaryKpiCards(stats: state.stats!),
          const SizedBox(height: 14),
        ],

        // 2. Search Bar + Residence Filters
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.40 : 0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : AppColors.goldPrimary.withValues(alpha: 0.22),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: AppColors.goldPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) =>
                          context.read<SalaryCounterBloc>().add(SearchFacultyEvent(val)),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search faculty by name, title, phone...',
                        hintStyle: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(context, 'All Faculty', 'ALL', state.residenceFilter, isDark),
              const SizedBox(width: 6),
              _buildFilterChip(context, 'Hostel Residents', 'HOSTEL', state.residenceFilter, isDark),
              const SizedBox(width: 6),
              _buildFilterChip(context, 'Day Scholars', 'DAY_SCHOLAR', state.residenceFilter, isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Master Faculty Directory Cards
        ...facultyList.map((teacher) {
          final info = state.getTeacherDuesInfo(teacher, state.teacherReceipts);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<SalaryCounterBloc>().add(SelectTeacherEvent(teacher));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.38 : 0.88),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.22),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bio Row
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [AppColors.goldPrimary, AppColors.goldDark]),
                                ),
                                child: Center(
                                  child: Text(
                                    teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            teacher.name,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (teacher.nameUrdu != null) ...[
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              teacher.nameUrdu!,
                                              style: const TextStyle(fontFamily: 'serif', fontSize: 12, color: AppColors.goldPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${teacher.designation} • ${teacher.phone}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusPresent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.statusPresent.withValues(alpha: 0.35)),
                                ),
                                child: Text(
                                  '₹${teacher.monthlySalary.toInt()}/mo',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.statusPresent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Dues Summary Strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Disbursed: ₹${info.paidAmount.toInt()} (${info.paidMonthsCount}/11M)',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Row(
                                  children: [
                                    Text(
                                      info.dueCount > 0 ? '${info.dueCount} M Due' : 'Cleared',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: info.dueCount > 0 ? AppColors.rosePrimary : AppColors.statusPresent,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.goldPrimary),
                                  ],
                                ),
                              ],
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
        }),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value, String current, bool isDark) {
    final isSelected = current == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<SalaryCounterBloc>().add(FilterResidenceEvent(value));
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.38 : 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldLight
                  : (isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.2)),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CASE B: SPECIFIC TEACHER PROFILE & DISBURSEMENT WORKSPACE (Level 2)
  // ===========================================================================
  Widget _buildFacultyDetailWorkspace(
    BuildContext context,
    SalaryCounterState state,
    bool isDark,
  ) {
    final teacher = state.selectedTeacher!;
    final baseSalary = teacher.monthlySalary;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
      children: [
        // 1. Bank & Bio Details Card
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.40 : 0.90),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.16) : AppColors.goldPrimary.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.goldPrimary, AppColors.goldDark]),
                        ),
                        child: Center(
                          child: Text(
                            teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${teacher.designation} • ${teacher.phone}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusPresent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.statusPresent.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '₹${baseSalary.toInt()}/mo',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.statusPresent),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Bank: ${teacher.bankName ?? "SBI"}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A/C: ${teacher.accountNumber ?? "—"}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. 11-Month Timeline Header & Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                '11-Month Timeline (April – Feb)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.goldPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<SalaryCounterBloc>().add(const SelectAllDueMonthsEvent());
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Select Due', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                if (state.selectedMonths.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<SalaryCounterBloc>().add(const ResetSalaryMonthSelectionEvent());
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 11-Month Tiles Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.05,
          ),
          itemCount: kAcademicMonths.length,
          itemBuilder: (context, index) {
            final month = kAcademicMonths[index];
            final isPaid = state.paidMonthsSet.contains(month);
            final isSelected = state.selectedMonths.contains(month);
            final isDue = index <= 4 && !isPaid; // April to August

            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isPaid
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            context.read<SalaryCounterBloc>().add(ToggleSalaryMonthEvent(month));
                          },
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
                        color: isSelected
                            ? null
                            : isPaid
                                ? const Color(0x2E059669)
                                : isDue
                                    ? const Color(0x2EE11D48)
                                    : (isDark ? const Color(0x331E293B).withValues(alpha: 0.30) : Colors.white).withValues(alpha: isDark ? 0.30 : 0.70),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.goldLight
                              : isPaid
                                  ? const Color(0x80059669)
                                  : isDue
                                      ? const Color(0x80E11D48)
                                      : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08)),
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
                          Text(
                            '#0${index + 1}',
                            style: TextStyle(
                              fontSize: 8,
                              fontFamily: 'monospace',
                              color: isSelected
                                  ? Colors.white70
                                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                            ),
                          ),
                          Text(
                            month,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : AppColors.textLightPrimary),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isPaid
                                ? 'PAID'
                                : isSelected
                                    ? 'SELECTED'
                                    : isDue
                                        ? 'DUE'
                                        : 'FUTURE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : isPaid
                                      ? AppColors.statusPresent
                                      : isDue
                                          ? AppColors.rosePrimary
                                          : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
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
        ),
        const SizedBox(height: 16),

        // 3. Live Salary Disbursement Panel
        if (state.selectedMonths.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.45 : 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.16) : AppColors.goldPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Gross Salary (${state.selectedMonths.length} Months):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${state.currentGrossAmount.toInt()} /-',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Deductions Manager per Month
                    Text(
                      'Deductions / Leave Adjustments:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    ...state.selectedMonths.map((m) {
                      final deduction = state.deductionsMap[m];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : AppColors.textLightSecondary,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 32,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                                ),
                                decoration: InputDecoration(
                                  prefixText: '₹',
                                  prefixStyle: const TextStyle(fontSize: 11, color: AppColors.goldPrimary, fontWeight: FontWeight.bold),
                                  hintText: '0',
                                  hintStyle: TextStyle(fontSize: 11, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                  isDense: true,
                                  filled: true,
                                  fillColor: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.85),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
                                  ),
                                ),
                                onChanged: (val) {
                                  final amt = double.tryParse(val) ?? 0.0;
                                  context.read<SalaryCounterBloc>().add(
                                        SetDeductionEvent(month: m, amount: amt, reason: deduction?.reason ?? 'Leave deduction'),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Reason (e.g. Leave)',
                                    hintStyle: TextStyle(fontSize: 11, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                    isDense: true,
                                    filled: true,
                                    fillColor: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.85),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    context.read<SalaryCounterBloc>().add(
                                          SetDeductionEvent(month: m, amount: deduction?.amount ?? 0.0, reason: val),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // Payment Mode Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.30 : 0.70),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Mode:',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                            ),
                          ),
                          DropdownButton<String>(
                            value: state.paymentMode,
                            isDense: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.goldPrimary),
                            dropdownColor: isDark ? AppColors.darkModalSurface : Colors.white,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer (NEFT)')),
                              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'UPI', child: Text('UPI / Online')),
                              DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                context.read<SalaryCounterBloc>().add(UpdatePaymentModeEvent(val));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Net Disbursed Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusPresent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.statusPresent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Net Disbursable Amount:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.statusPresent),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${state.currentNetPayable.toInt()} /-',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              color: AppColors.statusPresent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.isSubmitting
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context.read<SalaryCounterBloc>().add(const ExecuteSalaryDisbursementEvent());
                              },
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.payments_rounded, size: 16),
                        label: const Text('Confirm & Disburse Salary',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 4. Past Salary Receipts Table
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 16, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Past Salary Vouchers & Receipts',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.goldPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (state.teacherReceipts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'No past salary vouchers recorded for this faculty member.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
            ),
          )
        else
          ...state.teacherReceipts.map((receipt) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.38 : 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.receiptNo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${receipt.months.join(", ")} • ${receipt.paymentMode}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            '₹${receipt.totalAmount.toInt()}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              color: AppColors.statusPresent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.print_rounded, size: 18, color: AppColors.goldPrimary),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => SalaryReceiptVoucherDialog(
                                  receipt: receipt,
                                  teacher: teacher,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
