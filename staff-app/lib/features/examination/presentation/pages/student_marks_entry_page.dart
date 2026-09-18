import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/examination/data/datasources/examination_datasource.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';
import 'package:staff_app/features/examination/domain/models/student_marks_entry_model.dart';
import 'package:staff_app/features/examination/presentation/widgets/cascading_academic_selector.dart';

/// Ultra-Luxury Glassmorphic Student Marks Evaluation & Entry Screen
/// Features:
/// - 4-Tier Cascading Selector (Course ➔ Class ➔ Subject ➔ Book)
/// - Auto Roster Retrieval upon Book Selection
/// - Absentee Lock Shield (Absent students strictly locked from marks entry)
/// - Max Marks Ceiling Enforcement
/// - Atomic Batch Save mapped strictly to Selected Book (< 550 lines)
class StudentMarksEntryPage extends StatefulWidget {
  const StudentMarksEntryPage({super.key});

  @override
  State<StudentMarksEntryPage> createState() => _StudentMarksEntryPageState();
}

class _StudentMarksEntryPageState extends State<StudentMarksEntryPage> {
  final ExaminationDatasource _datasource = const ExaminationDatasource();

  CourseEntity? _selectedCourse;
  ClassEntity? _selectedClass;
  SubjectEntity? _selectedSubject;
  BookEntity? _selectedBook;

  List<StudentMarksRow> _students = [];
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onHierarchyChanged({
    CourseEntity? course,
    ClassEntity? classEntity,
    SubjectEntity? subject,
    BookEntity? book,
  }) {
    setState(() {
      _selectedCourse = course;
      _selectedClass = classEntity;
      _selectedSubject = subject;
      _selectedBook = book;

      if (classEntity != null && book != null) {
        _students = _datasource.getStudentRoster(
          classEntity.id,
          maxMarks: book.maxMarks,
        );
        _initControllers();
      } else {
        _students = [];
      }
    });
  }

  void _initControllers() {
    for (final s in _students) {
      if (!_controllers.containsKey(s.studentId)) {
        _controllers[s.studentId] = TextEditingController(
          text: s.obtainedMarks != null ? s.obtainedMarks.toString() : '',
        );
      } else {
        _controllers[s.studentId]!.text =
            s.obtainedMarks != null ? s.obtainedMarks.toString() : '';
      }
    }
  }

  Future<void> _saveMarksToServer() async {
    if (_selectedBook == null) {
      AppSnackBar.showError(context, 'Please select a Book first');
      return;
    }

    if (_students.isEmpty) {
      AppSnackBar.showError(context, 'No students in roster to save');
      return;
    }

    setState(() => _isSaving = true);

    // Collect updated rows from controllers
    final maxMarks = _selectedBook!.maxMarks;
    final updatedList = <StudentMarksRow>[];

    for (final s in _students) {
      if (s.isAbsent) {
        // Strict preservation of absent state
        updatedList.add(s.copyWith(obtainedMarks: null));
      } else {
        final text = _controllers[s.studentId]?.text.trim() ?? '';
        final entered = int.tryParse(text);
        if (entered != null && entered > maxMarks) {
          setState(() => _isSaving = false);
          AppSnackBar.showError(
            context,
            'Roll #${s.rollNo}: Marks cannot exceed $maxMarks',
          );
          return;
        }
        updatedList.add(s.copyWith(obtainedMarks: entered));
      }
    }

    await _datasource.saveStudentMarksBatch(
      bookId: _selectedBook!.id,
      rows: updatedList,
    );

    if (!mounted) return;
    unawaited(HapticFeedback.heavyImpact());

    setState(() {
      _isSaving = false;
      _students = updatedList;
    });

    final evaluatedCount = updatedList.where((s) => s.isEvaluated).length;

    AppSnackBar.showSuccess(
      context,
      context.tr(
        'exam_save_marks_success',
        params: {
          'count': evaluatedCount.toString(),
          'book': _selectedBook!.localizedName(context.isRtl),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    final totalCount = _students.length;
    final absentCount = _students.where((s) => s.isAbsent).length;
    final presentCount = totalCount - absentCount;
    final evaluatedCount = _students.where((s) => s.isEvaluated).length;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, isDark, isRtl),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // 1. Cascading 4-Tier Hierarchy Selector
                        CascadingAcademicSelector(
                          datasource: _datasource,
                          onSelectionChanged: _onHierarchyChanged,
                        ),
                        const SizedBox(height: 14),

                        // 2. Max Marks & Book Evaluation Ceiling Card
                        if (_selectedBook != null) ...[
                          _buildMaxMarksBanner(isDark, isRtl),
                          const SizedBox(height: 14),
                        ],

                        // 3. Evaluation Status HUD
                        if (_students.isNotEmpty) ...[
                          _buildEvaluationHud(
                            isDark: isDark,
                            total: totalCount,
                            present: presentCount,
                            absent: absentCount,
                            evaluated: evaluatedCount,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 4. Student Marks Roster (With Strict Absentee Lock)
                        _buildStudentRosterCard(isDark, isRtl),
                        const SizedBox(height: 20),

                        // 5. Submit Marks to Server Action Button
                        if (_students.isNotEmpty) ...[
                          _buildSaveButton(isDark),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Bar
  // ---------------------------------------------------------------------------
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
                  context.tr('action_marks_entry'),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedCourse != null
                      ? '${_selectedCourse!.code} • ${_selectedClass?.localizedName(isRtl) ?? ""} • ${_selectedSubject?.code ?? ""}'
                      : context.tr('action_marks_entry_sub'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.50 : 0.35),
                width: 1.0,
              ),
            ),
            child: Text(
              '2025-26',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Max Marks & Book Evaluation Ceiling Banner
  // ---------------------------------------------------------------------------
  Widget _buildMaxMarksBanner(bool isDark, bool isRtl) {
    final book = _selectedBook!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.goldPrimary.withValues(alpha: 0.18),
                      const Color(0x1F1E293B),
                    ]
                  : [
                      const Color(0xFFFFF9EE),
                      Colors.white,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: AppColors.goldPrimary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.localizedName(isRtl),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 3,
                      softWrap: true,
                    ),
                    Text(
                      '${context.tr('exam_pass_marks_label', params: {'pass': book.passMarks.toString()})} • ${book.term}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'MAX: ${book.maxMarks}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Evaluation Stats HUD
  // ---------------------------------------------------------------------------
  Widget _buildEvaluationHud({
    required bool isDark,
    required int total,
    required int present,
    required int absent,
    required int evaluated,
  }) {
    return Row(
      children: [
        _buildHudTile('Total', total.toString(), isDark, AppColors.goldPrimary),
        const SizedBox(width: 8),
        _buildHudTile('Present', present.toString(), isDark, AppColors.emeraldPrimary),
        const SizedBox(width: 8),
        _buildHudTile('Absent', absent.toString(), isDark, AppColors.statusAbsent),
        const SizedBox(width: 8),
        _buildHudTile('Marked', evaluated.toString(), isDark, AppColors.goldLight),
      ],
    );
  }

  Widget _buildHudTile(String label, String value, bool isDark, Color accent) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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

  // ---------------------------------------------------------------------------
  // Student Marks Roster Card (Strict Absentee Lock)
  // ---------------------------------------------------------------------------
  Widget _buildStudentRosterCard(bool isDark, bool isRtl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          size: 16, color: AppColors.goldPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Class Evaluation Roster',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                          if (_selectedClass != null)
                            Text(
                              '${_selectedClass!.localizedName(isRtl)} • ${_selectedSubject?.localizedName(isRtl) ?? ""}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${_students.length} Students',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDarkMuted
                            : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),

              if (_students.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_late_outlined,
                            size: 38, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 10),
                        Text(
                          'Select Course, Class, Subject & Book above to load students',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (context, index) {
                    final s = _students[index];
                    return _buildStudentMarksRow(s, isDark);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentMarksRow(StudentMarksRow s, bool isDark) {
    final controller = _controllers[s.studentId];
    final maxMarks = _selectedBook?.maxMarks ?? 100;

    return Container(
      color: s.isAbsent
          ? (isDark
              ? Colors.black.withValues(alpha: 0.25)
              : const Color(0xFFF9F9F9))
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Roll Number Badge (Clean, subtle background, zero golden border)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: s.isAbsent
                  ? Colors.red.withValues(alpha: 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${s.rollNo}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: s.isAbsent
                    ? Colors.redAccent
                    : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: s.isAbsent
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  s.isAbsent
                      ? (s.statusRemarks ?? 'Marked Absent in Session')
                      : s.admissionNo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: s.isAbsent ? FontWeight.w700 : FontWeight.w500,
                    color: s.isAbsent
                        ? AppColors.statusAbsent
                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // STRICT ATTENDANCE-BASED MARKS BOX OR ABSENT LOCK SHIELD
          if (s.isAbsent)
            Container(
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.statusAbsent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: AppColors.statusAbsent.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 10, color: AppColors.statusAbsent),
                    SizedBox(width: 2),
                    Text(
                      'ABSENT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: AppColors.statusAbsent,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.40) : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isDark
                      ? AppColors.goldPrimary.withValues(alpha: 0.35)
                      : AppColors.goldPrimary.withValues(alpha: 0.45),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: AppColors.goldPrimary,
                      cursorWidth: 1.5,
                      cursorRadius: const Radius.circular(2),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                        color: isDark ? AppColors.goldChampagne : AppColors.charcoalDark,
                      ),
                      onChanged: (val) {
                        final num = int.tryParse(val);
                        if (num != null && num > maxMarks) {
                          controller?.text = maxMarks.toString();
                          controller?.selection =
                              TextSelection.collapsed(offset: controller.text.length);
                          AppSnackBar.showError(context, 'Max marks: $maxMarks');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    '/$maxMarks',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save Marks to Server Action Button
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveMarksToServer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldPrimary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('exam_save_marks_btn'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
