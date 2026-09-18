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
import 'package:staff_app/features/examination/domain/models/question_paper_model.dart';
import 'package:staff_app/features/examination/presentation/widgets/cascading_academic_selector.dart';

/// Ultra-Luxury Glassmorphic Question Paper Upload & Management Screen
/// Features:
/// - 4-Tier Cascading Selector (Course ➔ Class ➔ Subject ➔ Book)
/// - Conditional Activation (Locked until Book selected)
/// - Multi-lingual Question Text Input (Urdu / English / Hindi)
/// - Strict Preset Marks (Strictly 10, 15, or 20 only)
/// - Book Reference Page Number (Strict Max 1000)
/// - Staged Question Bank Roster (< 550 lines)
class QuestionUploadPage extends StatefulWidget {
  const QuestionUploadPage({super.key});

  @override
  State<QuestionUploadPage> createState() => _QuestionUploadPageState();
}

class _QuestionUploadPageState extends State<QuestionUploadPage> {
  final ExaminationDatasource _datasource = const ExaminationDatasource();

  CourseEntity? _selectedCourse;
  ClassEntity? _selectedClass;
  SubjectEntity? _selectedSubject;
  BookEntity? _selectedBook;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _pageNoController = TextEditingController();
  final FocusNode _questionFocus = FocusNode();
  final FocusNode _pageFocus = FocusNode();

  int _selectedMarks = 10; // Default preset (strictly 10, 15, or 20)
  bool _isUploading = false;
  List<QuestionPaperItem> _bookQuestions = [];

  @override
  void dispose() {
    _questionController.dispose();
    _pageNoController.dispose();
    _questionFocus.dispose();
    _pageFocus.dispose();
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
      if (book != null) {
        _bookQuestions = _datasource.getQuestionsForBook(book.id);
      } else {
        _bookQuestions = [];
      }
    });
  }

  Future<void> _submitQuestion() async {
    if (_selectedBook == null) {
      AppSnackBar.showError(context, 'Please select a Book first');
      return;
    }

    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) {
      AppSnackBar.showError(context, 'Please enter question text');
      _questionFocus.requestFocus();
      return;
    }

    final pageStr = _pageNoController.text.trim();
    final pageNo = int.tryParse(pageStr);
    if (pageNo == null || pageNo < 1 || pageNo > 1000) {
      AppSnackBar.showError(context, context.tr('exam_page_no_error'));
      _pageFocus.requestFocus();
      return;
    }

    final isRtl = context.isRtl;
    final book = _selectedBook!;
    final successMsg = context.tr(
      'exam_question_added_success',
      params: {'book': book.localizedName(isRtl)},
    );

    setState(() => _isUploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final newItem = QuestionPaperItem(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      bookId: book.id,
      bookName: book.localizedName(isRtl),
      questionText: questionText,
      marks: _selectedMarks,
      pageNo: pageNo,
      createdAt: DateTime.now(),
    );

    _datasource.uploadQuestion(newItem);

    if (!mounted) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _isUploading = false;
      _bookQuestions = _datasource.getQuestionsForBook(book.id);
      _questionController.clear();
      _pageNoController.clear();
    });

    AppSnackBar.showSuccess(context, successMsg);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;
    final isFormEnabled = _selectedBook != null;

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

                        // 1. Cascading 4-Tier Selector Card
                        CascadingAcademicSelector(
                          datasource: _datasource,
                          onSelectionChanged: _onHierarchyChanged,
                        ),
                        const SizedBox(height: 16),

                        // 2. Conditional Question Editor Card (Locked or Enabled)
                        _buildQuestionFormCard(isDark, isRtl, isFormEnabled),
                        const SizedBox(height: 16),

                        // 3. Questions Bank Staging Roster
                        _buildStagedQuestionsCard(isDark, isRtl),
                        const SizedBox(height: 40),
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
  // Top Navigation Bar
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
                  context.tr('action_upload_questions'),
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
                      : context.tr('action_upload_questions_sub'),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.quiz_rounded, color: AppColors.goldPrimary, size: 14),
                const SizedBox(width: 5),
                Text(
                  '${_bookQuestions.length} Qs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
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
  // Question Entry Form Card (With Conditional Locked Overlay)
  // ---------------------------------------------------------------------------
  Widget _buildQuestionFormCard(bool isDark, bool isRtl, bool isEnabled) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? AppColors.goldPrimary.withValues(alpha: 0.40)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Form Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            size: 18, color: AppColors.goldPrimary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                          child: Text(
                            context.tr('exam_question_box_title'),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Multi-lingual Question Text Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.goldPrimary.withValues(alpha: 0.25)
                            : AppColors.goldPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: _questionController,
                      focusNode: _questionFocus,
                      minLines: 3,
                      maxLines: 5,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: context.tr('exam_question_hint'),
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Strict Preset Marks Selection (Strictly 10, 15, or 20)
                  Text(
                    context.tr('exam_marks_fixed_title'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMarksPresetChip(10, context.tr('exam_marks_chip_10'), isDark),
                      const SizedBox(width: 10),
                      _buildMarksPresetChip(15, context.tr('exam_marks_chip_15'), isDark),
                      const SizedBox(width: 10),
                      _buildMarksPresetChip(20, context.tr('exam_marks_chip_20'), isDark),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Reference Page Number (Max limit 1000)
                  Text(
                    context.tr('exam_page_no_title'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.goldPrimary.withValues(alpha: 0.30)
                            : AppColors.goldPrimary.withValues(alpha: 0.40),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_border_rounded,
                            size: 18, color: AppColors.goldPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _pageNoController,
                            focusNode: _pageFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              hintText: context.tr('exam_page_no_hint'),
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                            onChanged: (val) {
                              final num = int.tryParse(val);
                              if (num != null && num > 1000) {
                                _pageNoController.text = '1000';
                                _pageNoController.selection =
                                    const TextSelection.collapsed(offset: 4);
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'MAX 1000',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
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
                                  const Icon(Icons.cloud_upload_rounded,
                                      size: 19, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('exam_upload_btn'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              // Locked Overlay when Book not selected
              if (!isEnabled)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.50),
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: AppColors.goldPrimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.tr('exam_locked_card_prompt'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildMarksPresetChip(int value, String label, bool isDark) {
    final isSelected = _selectedMarks == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedMarks = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
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
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldChampagne
                  : (isDark ? Colors.white12 : Colors.black12),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
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
  // Staged Question Bank Roster Card
  // ---------------------------------------------------------------------------
  Widget _buildStagedQuestionsCard(bool isDark, bool isRtl) {
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storage_rounded,
                          size: 16, color: AppColors.emeraldPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('exam_staged_questions_title'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_bookQuestions.length} Questions',
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

              if (_bookQuestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.feed_outlined,
                            size: 36, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('exam_staged_empty'),
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
                  itemCount: _bookQuestions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (context, index) {
                    final q = _bookQuestions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${q.marks} Marks',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Page #${q.pageNo}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textDarkSecondary
                                        : AppColors.textLightSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white30 : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.questionText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
