import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_bloc.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_event.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_state.dart';
import 'package:staff_app/features/fee_structure/presentation/pages/fee_structure_setup_page.dart';
import 'package:staff_app/features/fee_structure/presentation/widgets/delete_fee_dialog.dart';
import 'package:staff_app/features/fee_structure/presentation/widgets/fee_structure_card.dart';

/// Ultra-Premium Fee Structure Management Screen.
/// Displays ALL configured fee cards without restrictive filtering as commanded by the user,
/// with a 2-step Course + Class Selector required to open the setup form.
class FeeStructurePage extends StatelessWidget {
  const FeeStructurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeeStructureBloc>()..add(const LoadFeeStructuresEvent()),
      child: const _FeeStructureView(),
    );
  }
}

class _FeeStructureView extends StatefulWidget {
  const _FeeStructureView();

  @override
  State<_FeeStructureView> createState() => _FeeStructureViewState();
}

class _FeeStructureViewState extends State<_FeeStructureView> {
  String? _selectedCourseId;
  String? _selectedClassId;
  String? _expandedFeeId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Master Top Header
            BlocBuilder<FeeStructureBloc, FeeStructureState>(
              builder: (context, state) {
                final totalCount = state is FeeStructureLoaded ? state.fees.length : 0;

                return ExecutiveTopHeader(
                  icon: Icons.arrow_back_rounded,
                  title: 'Fee Structure',
                  subtitle: 'Institutional tuition, hostel & admission matrices',
                  onIconTap: () => context.pop(),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Total: $totalCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Content Area
            Expanded(
              child: BlocConsumer<FeeStructureBloc, FeeStructureState>(
                listener: (context, state) {
                  if (state is FeeStructureLoaded && state.statusMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.statusMessage!),
                        backgroundColor: AppColors.emeraldPrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is FeeStructureLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldPrimary,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (state is FeeStructureError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 44,
                              color: AppColors.rosePrimary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<FeeStructureBloc>()
                                  .add(const LoadFeeStructuresEvent()),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldPrimary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is FeeStructureLoaded) {
                    final courses = state.courses;
                    final classes = state.classes;
                    // BINA FILTER KE: Display ALL configured fees directly
                    final displayFees = state.fees;

                    // Initialize course selection if not set
                    if (_selectedCourseId == null && courses.isNotEmpty) {
                      _selectedCourseId = courses.first.id;
                    }

                    // Filter classes for the selected course
                    final courseClasses = classes
                        .where((c) => c.courseId == _selectedCourseId)
                        .toList();

                    // Initialize class selection if not set or invalid
                    if (_selectedClassId == null ||
                        !courseClasses.any((c) => c.id == _selectedClassId)) {
                      _selectedClassId = courseClasses.isNotEmpty ? courseClasses.first.id : null;
                    }

                    final selectedClass = classes
                        .where((c) => c.id == _selectedClassId)
                        .firstOrNull;
                    final selectedCourse = courses
                        .where((c) => c.id == _selectedCourseId)
                        .firstOrNull;

                    final isSelectedConfigured = selectedClass != null &&
                        state.fees.any((f) => f.classId == selectedClass.id);

                    return RefreshIndicator(
                      color: AppColors.goldPrimary,
                      onRefresh: () async {
                        context
                            .read<FeeStructureBloc>()
                            .add(const LoadFeeStructuresEvent());
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                        children: [
                          // 1. Mandatory Course & Class Selection Setup Card
                          _buildCourseAndClassSetupBar(
                            context: context,
                            state: state,
                            isDark: isDark,
                            courses: courses,
                            courseClasses: courseClasses,
                            selectedClass: selectedClass,
                            selectedCourse: selectedCourse,
                            isSelectedConfigured: isSelectedConfigured,
                          ),

                          const SizedBox(height: 16),

                          // 2. Section Header: All Configured Fee Matrices (Bina Filter Ke)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'CONFIGURED FEE MATRICES (ALL)',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: isDark
                                        ? AppColors.goldChampagne
                                        : AppColors.goldDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldLight.withValues(alpha: isDark ? 0.2 : 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.emeraldLight.withValues(alpha: 0.4),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  '${displayFees.length} Configured Classes',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.emeraldLight,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 3. Configured Fee Structure Cards List (Rendered without any filter)
                          if (displayFees.isEmpty)
                            _buildEmptyState(
                              isDark: isDark,
                              onConfigureTap: selectedClass != null && selectedCourse != null
                                  ? () => _openCreateFormForClass(state, selectedClass, selectedCourse)
                                  : null,
                            )
                          else
                            ...displayFees.map((fee) {
                              final clazz = classes
                                      .where((c) => c.id == fee.classId)
                                      .firstOrNull ??
                                  ClassEntity(
                                    id: fee.classId,
                                    simpleId: fee.simpleId,
                                    nameEnglish: fee.className,
                                    courseId: fee.courseId ?? '',
                                    courseName: fee.courseName ?? '',
                                    capacity: 0,
                                    hasFeeStructure: true,
                                  );

                              final course = courses
                                  .where((c) => c.id == clazz.courseId)
                                  .firstOrNull;
                              final isExpanded = _expandedFeeId == fee.id;

                              return FeeStructureCard(
                                fee: fee,
                                clazz: clazz,
                                course: course,
                                isExpanded: isExpanded,
                                onTap: () {
                                  setState(() {
                                    _expandedFeeId = isExpanded ? null : fee.id;
                                  });
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (ctx) => FeeStructureSetupPage(
                                        clazz: clazz,
                                        fee: fee,
                                        course: course,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  DeleteFeeDialog.show(
                                    context,
                                    className: clazz.nameEnglish,
                                    onConfirm: () {
                                      context.read<FeeStructureBloc>().add(
                                            DeleteFeeStructureEvent(fee.id),
                                          );
                                    },
                                  );
                                },
                              );
                            }),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mandatory 2-step Selector: Course + Class required before opening setup form
  Widget _buildCourseAndClassSetupBar({
    required BuildContext context,
    required FeeStructureLoaded state,
    required bool isDark,
    required List<CourseEntity> courses,
    required List<ClassEntity> courseClasses,
    required ClassEntity? selectedClass,
    required CourseEntity? selectedCourse,
    required bool isSelectedConfigured,
  }) {
    final canOpenForm = selectedCourse != null && selectedClass != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.45 : 0.94,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.38 : 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.14 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldPrimary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FEE STRUCTURE SETUP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                      ),
                    ),
                    Text(
                      'Select both Course & Class to configure or modify fees',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
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

          const SizedBox(height: 12),

          // Step 1: Course Dropdown
          Text(
            '1. SELECT COURSE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourseId,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                items: courses.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(
                      c.nameEnglish,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCourseId = val;
                      final cl = state.classes.where((c) => c.courseId == val).toList();
                      _selectedClassId = cl.isNotEmpty ? cl.first.id : null;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Step 2: Class Dropdown (Under selected course)
          Text(
            '2. SELECT CLASS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: courseClasses.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No classes found under this course',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClassId,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                      ),
                      items: courseClasses.map((c) {
                        final isConfigured = state.fees.any((f) => f.classId == c.id);

                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  c.nameEnglish,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isConfigured
                                      ? AppColors.emeraldLight.withValues(alpha: 0.2)
                                      : AppColors.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isConfigured ? '✓ Configured' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: isConfigured
                                        ? AppColors.emeraldLight
                                        : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedClassId = val;
                          });
                        }
                      },
                    ),
                  ),
          ),

          const SizedBox(height: 14),

          // Step 3: Open Setup Form Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: canOpenForm
                  ? () => _openCreateFormForClass(state, selectedClass, selectedCourse)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? Colors.white10 : Colors.black12,
                disabledForegroundColor: isDark ? Colors.white30 : Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelectedConfigured ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSelectedConfigured ? 'Edit Fee Structure ➔' : 'Set Fee Structure ➔',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateFormForClass(
    FeeStructureLoaded state,
    ClassEntity selectedClass,
    CourseEntity selectedCourse,
  ) {
    final existingFee = state.fees
        .where((f) => f.classId == selectedClass.id)
        .firstOrNull;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => FeeStructureSetupPage(
          clazz: selectedClass,
          fee: existingFee,
          course: selectedCourse,
        ),
      ),
    );
  }

  // Clean Empty State
  Widget _buildEmptyState({
    required bool isDark,
    VoidCallback? onConfigureTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.35 : 0.85,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 36,
              color: AppColors.goldPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Fee Structures Configured',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select Course and Class in the setup box above and tap Set Fee Structure to configure institutional fees.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              height: 1.4,
            ),
          ),
          if (onConfigureTap != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onConfigureTap,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Set Fee Structure Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
