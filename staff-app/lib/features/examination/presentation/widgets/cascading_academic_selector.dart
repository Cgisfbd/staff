import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/examination/data/datasources/examination_datasource.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Reusable Liquid Crystal Glassmorphic Selector for 4-tier Academic Hierarchy:
/// 1. Course ➔ 2. Class ➔ 3. Subject ➔ 4. Book
class CascadingAcademicSelector extends StatefulWidget {
  const CascadingAcademicSelector({
    super.key,
    required this.datasource,
    required this.onSelectionChanged,
    this.initialCourse,
    this.initialClass,
    this.initialSubject,
    this.initialBook,
  });

  final ExaminationDatasource datasource;
  final void Function({
    CourseEntity? course,
    ClassEntity? classEntity,
    SubjectEntity? subject,
    BookEntity? book,
  }) onSelectionChanged;

  final CourseEntity? initialCourse;
  final ClassEntity? initialClass;
  final SubjectEntity? initialSubject;
  final BookEntity? initialBook;

  @override
  State<CascadingAcademicSelector> createState() =>
      _CascadingAcademicSelectorState();
}

class _CascadingAcademicSelectorState extends State<CascadingAcademicSelector> {
  CourseEntity? _selectedCourse;
  ClassEntity? _selectedClass;
  SubjectEntity? _selectedSubject;
  BookEntity? _selectedBook;

  List<CourseEntity> _courses = [];
  List<ClassEntity> _classes = [];
  List<SubjectEntity> _subjects = [];
  List<BookEntity> _books = [];

  @override
  void initState() {
    super.initState();
    _courses = widget.datasource.getCourses();

    // Progressive selection: only populate initial values if explicitly provided
    if (widget.initialCourse != null) {
      _selectedCourse = widget.initialCourse;
      _classes = widget.datasource.getClasses(_selectedCourse!.id);

      if (widget.initialClass != null) {
        _selectedClass = widget.initialClass;
        _subjects = widget.datasource.getSubjects(_selectedClass!.id);

        if (widget.initialSubject != null) {
          _selectedSubject = widget.initialSubject;
          _books = widget.datasource.getBooks(_selectedSubject!.id);

          if (widget.initialBook != null) {
            _selectedBook = widget.initialBook;
          }
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyParent();
      });
    }
  }

  void _notifyParent() {
    widget.onSelectionChanged(
      course: _selectedCourse,
      classEntity: _selectedClass,
      subject: _selectedSubject,
      book: _selectedBook,
    );
  }

  void _onCourseChanged(CourseEntity? newCourse) {
    if (newCourse == _selectedCourse) return;
    setState(() {
      _selectedCourse = newCourse;
      _classes = newCourse != null ? widget.datasource.getClasses(newCourse.id) : [];
      _selectedClass = _classes.isNotEmpty ? _classes.first : null;
      _subjects = _selectedClass != null ? widget.datasource.getSubjects(_selectedClass!.id) : [];
      _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
      _books = _selectedSubject != null ? widget.datasource.getBooks(_selectedSubject!.id) : [];
      _selectedBook = _books.isNotEmpty ? _books.first : null;
    });
    _notifyParent();
  }

  void _onClassChanged(ClassEntity? newClass) {
    if (newClass == _selectedClass) return;
    setState(() {
      _selectedClass = newClass;
      _subjects = newClass != null ? widget.datasource.getSubjects(newClass.id) : [];
      _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
      _books = _selectedSubject != null ? widget.datasource.getBooks(_selectedSubject!.id) : [];
      _selectedBook = _books.isNotEmpty ? _books.first : null;
    });
    _notifyParent();
  }

  void _onSubjectChanged(SubjectEntity? newSubject) {
    if (newSubject == _selectedSubject) return;
    setState(() {
      _selectedSubject = newSubject;
      _books = newSubject != null ? widget.datasource.getBooks(newSubject.id) : [];
      _selectedBook = _books.isNotEmpty ? _books.first : null;
    });
    _notifyParent();
  }

  void _onBookChanged(BookEntity? newBook) {
    if (newBook == _selectedBook) return;
    setState(() {
      _selectedBook = newBook;
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;
    final isFullySelected = _selectedBook != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFullySelected
                  ? AppColors.goldPrimary.withValues(alpha: 0.45)
                  : (isDark ? Colors.white24 : Colors.black12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isFullySelected
                    ? AppColors.goldPrimary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Active State Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 17,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.tr('exam_card_hierarchy_title'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.tr('exam_card_hierarchy_sub'),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textDarkMuted
                                  : AppColors.textLightMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFullySelected
                          ? AppColors.emeraldPrimary.withValues(alpha: 0.18)
                          : AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFullySelected
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.4)
                            : AppColors.goldPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFullySelected
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          size: 12,
                          color: isFullySelected
                              ? AppColors.emeraldPrimary
                              : AppColors.goldPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFullySelected ? '4/4 BOOK READY' : 'SELECTING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: isFullySelected
                                ? AppColors.emeraldPrimary
                                : AppColors.goldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. Course Dropdown
              _buildDropdownField<CourseEntity>(
                label: context.tr('exam_sel_course'),
                icon: Icons.school_rounded,
                value: _selectedCourse,
                items: _courses,
                itemLabel: (c) => c.localizedName(isRtl),
                onChanged: _onCourseChanged,
                hintText: context.tr('exam_sel_course_hint'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // 2. Class Dropdown
              _buildDropdownField<ClassEntity>(
                label: context.tr('exam_sel_class'),
                icon: Icons.meeting_room_rounded,
                value: _selectedClass,
                items: _classes,
                itemLabel: (cls) => cls.localizedName(isRtl),
                onChanged: _classes.isNotEmpty ? _onClassChanged : null,
                hintText: context.tr('exam_sel_class_hint'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // 3. Subject Dropdown
              _buildDropdownField<SubjectEntity>(
                label: context.tr('exam_sel_subject'),
                icon: Icons.menu_book_rounded,
                value: _selectedSubject,
                items: _subjects,
                itemLabel: (s) => s.localizedName(isRtl),
                onChanged: _subjects.isNotEmpty ? _onSubjectChanged : null,
                hintText: context.tr('exam_sel_subject_hint'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // 4. Book Dropdown (Key Destination!)
              _buildDropdownField<BookEntity>(
                label: context.tr('exam_sel_book'),
                icon: Icons.library_books_rounded,
                value: _selectedBook,
                items: _books,
                itemLabel: (b) => '${b.localizedName(isRtl)} • (${b.maxMarks} Marks)',
                onChanged: _books.isNotEmpty ? _onBookChanged : null,
                hintText: context.tr('exam_sel_book_hint'),
                isDark: isDark,
                isHighlighted: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T extends Object>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?)? onChanged,
    required String hintText,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    final isEnabled = onChanged != null && items.isNotEmpty;
    final T? resolvedValue = (value != null && items.contains(value)) ? value : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (isHighlighted
                ? AppColors.goldPrimary.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.28))
            : (isHighlighted
                ? AppColors.goldPrimary.withValues(alpha: 0.08)
                : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? AppColors.goldPrimary.withValues(alpha: 0.45)
              : (isDark ? Colors.white12 : Colors.black12),
          width: isHighlighted ? 1.3 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? AppColors.goldPrimary
                : (isEnabled
                    ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                    : (isDark ? Colors.white24 : Colors.black26)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: resolvedValue,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF161F2E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
                hint: Text(
                  hintText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemLabel(item),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                      maxLines: 3,
                      softWrap: true,
                    ),
                  );
                }).toList(),
                onChanged: isEnabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
