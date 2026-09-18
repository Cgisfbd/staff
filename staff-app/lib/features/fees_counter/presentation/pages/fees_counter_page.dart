import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_bloc.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_event.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_state.dart';
import 'package:staff_app/features/fees_counter/presentation/widgets/admin_pin_dialog.dart';
import 'package:staff_app/features/fees_counter/presentation/widgets/fee_receipt_voucher_dialog.dart';
import 'package:staff_app/features/fees_counter/presentation/widgets/fees_kpi_cards.dart';
import 'package:staff_app/features/fees_counter/presentation/widgets/fees_month_matrix_grid.dart';

class FeesCounterPage extends StatelessWidget {
  const FeesCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeesCounterBloc>()..add(const LoadFeesInitialEvent()),
      child: const _FeesCounterView(),
    );
  }
}

class _FeesCounterView extends StatelessWidget {
  const _FeesCounterView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<FeesCounterBloc, FeesCounterState>(
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
        if (state.generatedReceipt != null && state.selectedStudent != null) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => FeeReceiptVoucherDialog(
              receipt: state.generatedReceipt!,
              student: state.selectedStudent!,
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<FeesCounterBloc>().add(const DismissReceiptVoucherEvent());
            }
          });
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.currentLevel == FeesCounterLevel.courses,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
            }
          },
          child: Scaffold(
            body: AppBackground(
              useSafeArea: false,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(context, state),
                    _buildBreadcrumbs(context, state, isDark),
                    Expanded(
                      child: state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.goldPrimary),
                            )
                          : _buildActiveLevelBody(context, state, isDark),
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

  Widget _buildHeader(BuildContext context, FeesCounterState state) {
    String title = 'Fees Counter';
    String subtitle = 'Class-wise student collections & live cash counter';

    switch (state.currentLevel) {
      case FeesCounterLevel.courses:
        title = 'Fees Counter';
        subtitle = 'Select course to manage class fee collections';
        break;
      case FeesCounterLevel.classes:
        title = state.selectedCourse?.nameEnglish ?? 'Classes';
        subtitle = 'Select class to view student fee status';
        break;
      case FeesCounterLevel.students:
        title = state.selectedClass?.nameEnglish ?? 'Students';
        subtitle = '10-Month Fee Ledger & Student Directory';
        break;
      case FeesCounterLevel.studentProfile:
        title = state.selectedStudent?.fullNameEn ?? 'Fee Profile';
        subtitle = 'Live Cash Counter & Instant Receipt Voucher';
        break;
    }

    return ExecutiveTopHeader(
      icon: state.currentLevel != FeesCounterLevel.courses
          ? Icons.arrow_back_ios_new_rounded
          : Icons.point_of_sale_rounded,
      title: title,
      subtitle: subtitle,
      onIconTap: () {
        if (state.currentLevel != FeesCounterLevel.courses) {
          context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
        } else {
          Navigator.of(context).maybePop();
        }
      },
      trailing: state.currentLevel != FeesCounterLevel.courses
          ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
              },
            )
          : null,
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, FeesCounterState state, bool isDark) {
    if (state.currentLevel == FeesCounterLevel.courses) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.45 : 0.70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.32 : 0.22),
          width: 0.9,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCrumbChip('Courses', () {
              context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
              if (state.currentLevel == FeesCounterLevel.students || state.currentLevel == FeesCounterLevel.studentProfile) {
                context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
              }
              if (state.currentLevel == FeesCounterLevel.studentProfile) {
                context.read<FeesCounterBloc>().add(const NavigateBackLevelEvent());
              }
            }, false, isDark),
            if (state.selectedCourse != null) ...[
              const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.goldPrimary),
              _buildCrumbChip(state.selectedCourse!.nameEnglish, () {
                if (state.currentLevel == FeesCounterLevel.students || state.currentLevel == FeesCounterLevel.studentProfile) {
                  context.read<FeesCounterBloc>().add(SelectCourseEvent(state.selectedCourse!));
                }
              }, state.currentLevel == FeesCounterLevel.classes, isDark),
            ],
            if (state.selectedClass != null && state.currentLevel != FeesCounterLevel.classes) ...[
              const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.goldPrimary),
              _buildCrumbChip(state.selectedClass!.nameEnglish, () {
                if (state.currentLevel == FeesCounterLevel.studentProfile) {
                  context.read<FeesCounterBloc>().add(SelectClassEvent(state.selectedClass!));
                }
              }, state.currentLevel == FeesCounterLevel.students, isDark),
            ],
            if (state.selectedStudent != null && state.currentLevel == FeesCounterLevel.studentProfile) ...[
              const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.goldPrimary),
              _buildCrumbChip(state.selectedStudent!.fullNameEn, null, true, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCrumbChip(String label, VoidCallback? onTap, bool isCurrent, bool isDark) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
            color: isCurrent
                ? AppColors.goldPrimary
                : (isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLevelBody(
    BuildContext context,
    FeesCounterState state,
    bool isDark,
  ) {
    switch (state.currentLevel) {
      case FeesCounterLevel.courses:
        return _buildLevel1Courses(context, state, isDark);
      case FeesCounterLevel.classes:
        return _buildLevel2Classes(context, state, isDark);
      case FeesCounterLevel.students:
        return _buildLevel3Students(context, state, isDark);
      case FeesCounterLevel.studentProfile:
        return _buildLevel4StudentProfile(context, state, isDark);
    }
  }

  // ===========================================================================
  // LEVEL 1: COURSES & 6 KPI CARDS (Matching Web ERP CourseOverviewTab.tsx)
  // ===========================================================================
  Widget _buildLevel1Courses(
    BuildContext context,
    FeesCounterState state,
    bool isDark,
  ) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
      children: [
        if (state.kpi != null) ...[
          FeesKpiCards(kpi: state.kpi!),
          const SizedBox(height: 14),
        ],

        // Search Bar
        _buildSearchBar(
          context,
          hint: 'Search courses by name or code...',
          query: state.searchQuery,
          onChanged: (val) =>
              context.read<FeesCounterBloc>().add(SearchQueryChangedEvent(val)),
        ),
        const SizedBox(height: 14),

        // Section Title
        Row(
          children: [
            const Icon(Icons.school_rounded, size: 16, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            Text(
              'Select Academic Course (${state.filteredCourses.length})',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.goldPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...state.filteredCourses.map((course) {
          final collectionRate = course.totalExpected > 0
              ? (course.totalCollected / course.totalExpected) * 100
              : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<FeesCounterBloc>().add(SelectCourseEvent(course));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0x331E293B) : Colors.white)
                            .withValues(alpha: isDark ? 0.38 : 0.88),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.22),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.goldPrimary, AppColors.goldDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.school_rounded, size: 22, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        course.nameEnglish,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (course.nameUrdu != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        course.nameUrdu!,
                                        style: const TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.goldPrimary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${course.classesCount} Classes • ${course.studentsCount} Students Enrolled',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (collectionRate / 100).clamp(0.0, 1.0),
                                          minHeight: 5,
                                          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusPresent),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${collectionRate.toInt()}% Paid',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.statusPresent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.goldPrimary),
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

  // ===========================================================================
  // LEVEL 2: CLASSES UNDER SELECTED COURSE (Matching ClassDirectoryTable.tsx)
  // ===========================================================================
  Widget _buildLevel2Classes(
    BuildContext context,
    FeesCounterState state,
    bool isDark,
  ) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
      children: [
        // Course Banner
        if (state.selectedCourse != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0x331E293B) : Colors.white)
                      .withValues(alpha: isDark ? 0.40 : 0.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.goldPrimary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedCourse!.nameEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${state.classes.length} Academic Sections • Tap class to open directory',
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
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),

        // Classes List
        Row(
          children: [
            const Icon(Icons.groups_rounded, size: 16, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            const Text(
              'Select Academic Class / Section',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...state.classes.map((cls) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<FeesCounterBloc>().add(SelectClassEvent(cls));
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0x331E293B) : Colors.white)
                            .withValues(alpha: isDark ? 0.38 : 0.88),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.22),
                          width: 1.0,
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
                                  cls.nameEnglish,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.statusPresent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cls.collectionRate}% Paid',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.statusPresent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Students: ${cls.studentCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                              Text(
                                'Tuition: ₹${cls.tuitionFee.toInt()}/mo',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldPrimary),
                              ),
                              if (cls.hostelFee > 0)
                                Text(
                                  '• Hostel: ₹${cls.hostelFee.toInt()}/mo',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldDark),
                                ),
                            ],
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

  // ===========================================================================
  // LEVEL 3: STUDENTS 10-MONTH MATRIX (Matching StudentFinanceDirectoryTable.tsx)
  // ===========================================================================
  Widget _buildLevel3Students(
    BuildContext context,
    FeesCounterState state,
    bool isDark,
  ) {
    final students = state.filteredStudents;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
      children: [
        // Class Header & Metrics Banner
        if (state.selectedClass != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0x331E293B) : Colors.white)
                      .withValues(alpha: isDark ? 0.40 : 0.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
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
                            '${state.selectedClass!.nameEnglish} Directory',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${students.length} Students Listed • 10 Academic Months Ledger',
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${state.selectedClass!.collectionRate}% Cleared',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        // Search Bar
        _buildSearchBar(
          context,
          hint: 'Search student by name, roll no, mobile...',
          query: state.searchQuery,
          onChanged: (val) =>
              context.read<FeesCounterBloc>().add(SearchQueryChangedEvent(val)),
        ),
        const SizedBox(height: 12),

        ...students.map((student) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<FeesCounterBloc>().add(SelectStudentEvent(student));
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0x331E293B) : Colors.white)
                            .withValues(alpha: isDark ? 0.38 : 0.88),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.22),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    student.fullNameEn.isNotEmpty ? student.fullNameEn[0] : 'S',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
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
                                            student.fullNameEn,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (student.nameUrdu != null) ...[
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              student.nameUrdu!,
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
                                      'Roll #${student.rollNo.toString().padLeft(2, '0')} • ${student.fatherNameEn != null ? "S/O ${student.fatherNameEn}" : student.mobile}',
                                      style: TextStyle(
                                        fontSize: 10.5,
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
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: student.isHostel
                                      ? AppColors.goldPrimary.withValues(alpha: 0.15)
                                      : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: student.isHostel
                                        ? AppColors.goldPrimary.withValues(alpha: 0.4)
                                        : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.12)),
                                  ),
                                ),
                                child: Text(
                                  student.isHostel ? 'Hostel' : 'Day Scholar',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: student.isHostel
                                        ? AppColors.goldPrimary
                                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 10-Month Status Pills
                          StudentMonthPillsRow(monthStatusMap: student.monthStatusMap),
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

  // ===========================================================================
  // LEVEL 4: STUDENT FEE PROFILE & CASH COUNTER (Matching StudentFeeProfileView)
  // ===========================================================================
  Widget _buildLevel4StudentProfile(
    BuildContext context,
    FeesCounterState state,
    bool isDark,
  ) {
    final student = state.selectedStudent!;
    final monthlyRate = student.monthlyRate;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
      children: [
        // 1. Bio Identity Card
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0x331E293B) : Colors.white)
                    .withValues(alpha: isDark ? 0.40 : 0.85),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.38 : 0.28), width: 1.2),
              ),
              child: Column(
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
                            student.fullNameEn.isNotEmpty ? student.fullNameEn[0] : 'S',
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
                              student.fullNameEn,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${student.courseName} • ${student.className} • Roll #${student.rollNo.toString().padLeft(2, '0')}',
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
                          color: student.isHostel
                              ? AppColors.goldPrimary.withValues(alpha: 0.15)
                              : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: student.isHostel
                                ? AppColors.goldPrimary.withValues(alpha: 0.4)
                                : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.12)),
                          ),
                        ),
                        child: Text(
                          student.isHostel ? 'Hostel' : 'Day Scholar',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: student.isHostel
                                ? AppColors.goldPrimary
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatSnippet(context, 'Tuition Rate', '₹${student.tuitionFee.toInt()}/mo', isDark),
                      _buildStatSnippet(context, 'Hostel Rate', '₹${student.hostelFee.toInt()}/mo', isDark),
                      _buildStatSnippet(context, 'Total Rate', '₹${monthlyRate.toInt()}/mo', isDark, isGold: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. 10-Month Selection Header & Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Academic Months (Jan – Oct)',
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
                    context.read<FeesCounterBloc>().add(const SelectAllPendingMonthsEvent());
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Select Due', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldPrimary)),
                ),
                if (state.selectedMonths.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<FeesCounterBloc>().add(const ClearMonthSelectionEvent());
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

        // 3. Interactive Month Grid
        InteractiveMonthSelectorGrid(
          monthStatusMap: student.monthStatusMap,
          selectedMonths: state.selectedMonths,
          onToggleMonth: (m) {
            HapticFeedback.selectionClick();
            context.read<FeesCounterBloc>().add(ToggleMonthSelectionEvent(m));
          },
          monthlyRate: monthlyRate,
        ),
        const SizedBox(height: 16),

        // 4. Concession & Live Amount Panel
        if (state.selectedMonths.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0x331E293B) : Colors.white)
                      .withValues(alpha: isDark ? 0.45 : 0.90),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.40 : 0.30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gross Amount (${state.selectedMonths.length} Months):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        Text(
                          '₹${state.currentGrossAmount.toInt()} /-',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Concession row + Quick percent buttons
                    Row(
                      children: [
                        Text(
                          'Concession (Riyayat):',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          height: 36,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                              ),
                            ),
                            onChanged: (val) {
                              final amt = double.tryParse(val) ?? 0.0;
                              context.read<FeesCounterBloc>().add(SetConcessionAmountEvent(amt));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick percentage chips
                    Row(
                      children: [10, 25, 50, 100].map((pct) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.read<FeesCounterBloc>().add(ApplyPercentConcessionEvent(pct));
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                '$pct%',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Net Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusPresent.withValues(alpha: isDark ? 0.16 : 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.statusPresent.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Payable Amount:',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.statusPresent),
                          ),
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

                    // CTA Buttons: Deposit or Waive
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) => AdminPinDialog(
                                        onPinVerified: (pin) {
                                          context.read<FeesCounterBloc>().add(ConfirmWaiveOffEvent(pin));
                                        },
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                            label: const Text('Waive Off', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.statusLeave,
                              side: BorderSide(color: AppColors.statusLeave.withValues(alpha: 0.8), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    context.read<FeesCounterBloc>().add(const ConfirmDepositEvent());
                                  },
                            icon: state.isSubmitting
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.point_of_sale_rounded, size: 16),
                            label: const Text('Confirm Deposit', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 5. Payment Receipts History for this Student
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 16, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Past Receipts & Settlement Ledger',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.goldPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (state.studentPaymentsHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'No past receipts recorded for this student.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
            ),
          )
        else
          ...state.studentPaymentsHistory.map((payment) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0x331E293B) : Colors.white)
                        .withValues(alpha: isDark ? 0.38 : 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.10) : AppColors.goldPrimary.withValues(alpha: 0.20),
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
                              payment.receiptNo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${payment.monthsPaid.join(", ")} • ${payment.feeType}',
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
                            '₹${payment.amountPaid.toInt()}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              color: payment.isWaived ? AppColors.statusLeave : AppColors.statusPresent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.print_rounded, size: 18, color: AppColors.goldPrimary),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => FeeReceiptVoucherDialog(
                                  receipt: payment,
                                  student: student,
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

  Widget _buildStatSnippet(BuildContext context, String title, String value, bool isDark, {bool isGold = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            color: isGold
                ? AppColors.goldPrimary
                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context, {
    required String hint,
    required String query,
    required ValueChanged<String> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 18, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: query)..selection = TextSelection.collapsed(offset: query.length),
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.goldPrimary),
                  onPressed: () => onChanged(''),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
