import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';
import 'package:staff_app/features/staff/domain/models/staff_academic_catalog.dart';

/// Ultra-Luxury Academic Duty Allocation Setup Screen for Faculty.
/// Implements:
/// 1. Course Dropdown for Class Allocation (assign all course classes or individual classes).
/// 2. 4-Tier Cascading Filter for Book Allocation (Course ➔ Class ➔ Subject ➔ Books).
/// 3. Multi-Select Book Assignment ("jitni chahein utni kitaben").
class AssignDutyPage extends StatefulWidget {
  const AssignDutyPage({
    super.key,
    required this.duty,
    required this.onSave,
  });

  final StaffDutyEntity duty;
  final Future<void> Function({
    required List<String> assignedClasses,
    required List<TeachingBookItem> assignedBooks,
  }) onSave;

  @override
  State<AssignDutyPage> createState() => _AssignDutyPageState();
}

class _AssignDutyPageState extends State<AssignDutyPage> {
  late final List<String> _selectedClasses;
  late final List<TeachingBookItem> _assignedBooks;
  bool _isSaving = false;

  // --- SECTION 1: Class Allocation State ---
  late CatalogCourse _selectedCourseForClass;

  // --- SECTION 2: 4-Tier Cascading Books Filter State ---
  late CatalogCourse _bookFilterCourse;
  late CatalogClass _bookFilterClass;
  late CatalogSubject _bookFilterSubject;
  final Set<String> _checkedBooks = <String>{};

  // Custom Book state
  bool _isCustomBookMode = false;
  final TextEditingController _customBookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClasses = List.from(widget.duty.assignedClasses);
    _assignedBooks = List.from(widget.duty.assignedBooks);

    // Initialize Class Course Selector
    _selectedCourseForClass = StaffAcademicCatalog.courses.first;
    if (_selectedClasses.isNotEmpty) {
      final matchedClass = StaffAcademicCatalog.findClassByName(_selectedClasses.first);
      if (matchedClass != null) {
        final matchedCourse = StaffAcademicCatalog.findCourse(matchedClass.courseId);
        if (matchedCourse != null) {
          _selectedCourseForClass = matchedCourse;
        }
      }
    }

    // Initialize 4-Tier Book Filters
    _bookFilterCourse = _selectedCourseForClass;
    _bookFilterClass = _bookFilterCourse.classes.first;
    _bookFilterSubject = _bookFilterClass.subjects.first;
  }

  @override
  void dispose() {
    _customBookController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SECTION 1 LOGIC: Classes Allocation
  // ===========================================================================
  void _onCourseForClassChanged(CatalogCourse course) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCourseForClass = course;
    });
  }

  void _toggleIndividualClass(String className) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedClasses.contains(className)) {
        _selectedClasses.remove(className);
        // Automatically remove books allocated for this class
        _assignedBooks.removeWhere((b) => b.className == className);
      } else {
        _selectedClasses.add(className);
      }
    });
  }

  void _selectAllCourseClasses(CatalogCourse course) {
    HapticFeedback.lightImpact();
    setState(() {
      for (final cls in course.classes) {
        if (!_selectedClasses.contains(cls.nameEn)) {
          _selectedClasses.add(cls.nameEn);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All classes under ${course.nameEn} assigned.'),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deselectAllCourseClasses(CatalogCourse course) {
    HapticFeedback.lightImpact();
    setState(() {
      for (final cls in course.classes) {
        _selectedClasses.remove(cls.nameEn);
        _assignedBooks.removeWhere((b) => b.className == cls.nameEn);
      }
    });
  }

  void _removeAssignedClass(String className) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedClasses.remove(className);
      _assignedBooks.removeWhere((b) => b.className == className);
    });
  }

  void _clearAllClasses() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedClasses.clear();
      _assignedBooks.clear();
    });
  }

  // ===========================================================================
  // SECTION 2 LOGIC: 4-Tier Cascading Filter for Books
  // ===========================================================================
  void _onBookFilterCourseChanged(CatalogCourse course) {
    HapticFeedback.selectionClick();
    setState(() {
      _bookFilterCourse = course;
      _bookFilterClass = course.classes.first;
      _bookFilterSubject = _bookFilterClass.subjects.first;
      _checkedBooks.clear();
    });
  }

  void _onBookFilterClassChanged(CatalogClass cls) {
    HapticFeedback.selectionClick();
    setState(() {
      _bookFilterClass = cls;
      _bookFilterSubject = cls.subjects.first;
      _checkedBooks.clear();
    });
  }

  void _onBookFilterSubjectChanged(CatalogSubject sub) {
    HapticFeedback.selectionClick();
    setState(() {
      _bookFilterSubject = sub;
      _checkedBooks.clear();
    });
  }

  void _toggleBookCheck(String book) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_checkedBooks.contains(book)) {
        _checkedBooks.remove(book);
      } else {
        _checkedBooks.add(book);
      }
    });
  }

  void _selectAllAvailableBooks() {
    HapticFeedback.selectionClick();
    setState(() {
      _checkedBooks.addAll(_bookFilterSubject.books);
    });
  }

  void _deselectAllAvailableBooks() {
    HapticFeedback.selectionClick();
    setState(() {
      _checkedBooks.clear();
    });
  }

  void _assignSelectedBooks() {
    if (_checkedBooks.isEmpty) return;

    // Auto-ensure the class is in assigned classes
    if (!_selectedClasses.contains(_bookFilterClass.nameEn)) {
      _selectedClasses.add(_bookFilterClass.nameEn);
    }

    int addedCount = 0;
    for (final book in _checkedBooks) {
      final exists = _assignedBooks.any(
        (b) => b.className == _bookFilterClass.nameEn && b.bookName.toLowerCase() == book.toLowerCase(),
      );
      if (!exists) {
        _assignedBooks.add(TeachingBookItem(
          courseName: _bookFilterCourse.nameEn,
          className: _bookFilterClass.nameEn,
          bookName: book,
        ));
        addedCount++;
      }
    }

    HapticFeedback.lightImpact();
    setState(() {
      _checkedBooks.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addedCount > 0
              ? 'Successfully assigned $addedCount kitabs for ${_bookFilterClass.nameEn}!'
              : 'Selected kitabs were already assigned.',
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addCustomBook() {
    final bookName = _customBookController.text.trim();
    if (bookName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter custom kitab name.')),
      );
      return;
    }

    // Auto-ensure class is assigned
    if (!_selectedClasses.contains(_bookFilterClass.nameEn)) {
      _selectedClasses.add(_bookFilterClass.nameEn);
    }

    final exists = _assignedBooks.any(
      (b) => b.className == _bookFilterClass.nameEn && b.bookName.toLowerCase() == bookName.toLowerCase(),
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$bookName" is already allocated for ${_bookFilterClass.nameEn}.')),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _assignedBooks.add(TeachingBookItem(
        courseName: _bookFilterCourse.nameEn,
        className: _bookFilterClass.nameEn,
        bookName: bookName,
      ));
      _customBookController.clear();
      _isCustomBookMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added custom kitab "$bookName" for ${_bookFilterClass.nameEn}.'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeAllocatedBook(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _assignedBooks.removeAt(index);
    });
  }

  void _clearAllAllocatedBooks() {
    HapticFeedback.mediumImpact();
    setState(() {
      _assignedBooks.clear();
    });
  }

  // ===========================================================================
  // SAVE HANDLER
  // ===========================================================================
  Future<void> _handleSave() async {
    if (_selectedClasses.isEmpty && _assignedBooks.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Clear All Duties?'),
          content: const Text(
            'You have not selected any classes or kitabs. This will set this faculty member to Unassigned status.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        assignedClasses: _selectedClasses,
        assignedBooks: _assignedBooks,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.statusAbsent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Executive Top Header
              ExecutiveTopHeader(
                icon: Icons.assignment_ind_rounded,
                title: 'Assign Classes & Books',
                subtitle: 'Faculty Code: ${widget.duty.staffCode}',
                onIconTap: () => Navigator.of(context).maybePop(),
              ),

              // 2. Main Scrollable Deck
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6, bottom: 24),
                  children: [
                    // Teacher Bio Bar Card
                    _buildTeacherBioCard(isDark),
                    const SizedBox(height: 12),

                    // SECTION 1: Class Allocation (Course Dropdown + Select All / Individual)
                    _buildSection1Classes(isDark),
                    const SizedBox(height: 14),

                    // SECTION 2: Kitab Allocation (4-Tier Filter: Course ➔ Class ➔ Subject ➔ Books)
                    _buildSection2Books(isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 3. Sticky Bottom Command Bar
              _buildBottomCommandBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TEACHER BIO CARD
  // ===========================================================================
  Widget _buildTeacherBioCard(bool isDark) {
    final hasPhoto = widget.duty.avatar.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.38 : 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                  backgroundImage: hasPhoto ? NetworkImage(widget.duty.avatar) : null,
                  child: !hasPhoto
                      ? Text(
                          widget.duty.fullNameEn.isNotEmpty ? widget.duty.fullNameEn[0].toUpperCase() : 'F',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.goldDark),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.duty.fullNameEn,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'ID: ${widget.duty.staffCode}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.goldDark,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.duty.designation} • ${widget.duty.department}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
    );
  }

  // ===========================================================================
  // SECTION 1: ASSIGN CLASSES (WITH COURSE DROPDOWN)
  // ===========================================================================
  Widget _buildSection1Classes(bool isDark) {
    final allCourseClassesSelected = _selectedCourseForClass.classes.isNotEmpty &&
        _selectedCourseForClass.classes.every((cls) => _selectedClasses.contains(cls.nameEn));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.38 : 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.goldPrimary.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 16, color: AppColors.goldPrimary),
                        const SizedBox(width: 6),
                        Text(
                          '1. ASSIGN CLASSES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Text(
                        '${_selectedClasses.length} Selected',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select course from dropdown to assign all or individual classes:',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Course Dropdown Selector
                Text(
                  'SELECT COURSE (شعبہ):',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.4),
                      width: 0.9,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CatalogCourse>(
                      value: _selectedCourseForClass,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      items: StaffAcademicCatalog.courses.map((course) {
                        return DropdownMenuItem<CatalogCourse>(
                          value: course,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.nameEn,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                course.nameUr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'JameelNoori',
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (c) {
                        if (c != null) _onCourseForClassChanged(c);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Course Classes Controls Header (Select All / Deselect All)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CLASSES IN ${_selectedCourseForClass.code} (${_selectedCourseForClass.classes.length}):',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (allCourseClassesSelected) {
                          _deselectAllCourseClasses(_selectedCourseForClass);
                        } else {
                          _selectAllCourseClasses(_selectedCourseForClass);
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: allCourseClassesSelected
                              ? const Color(0xFFE11D48).withValues(alpha: 0.1)
                              : const Color(0xFF059669).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: allCourseClassesSelected
                                ? const Color(0xFFE11D48).withValues(alpha: 0.3)
                                : const Color(0xFF059669).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              allCourseClassesSelected ? Icons.remove_done_rounded : Icons.done_all_rounded,
                              size: 11,
                              color: allCourseClassesSelected ? const Color(0xFFE11D48) : const Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              allCourseClassesSelected ? 'Deselect All Course' : 'Select All in Course',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: allCourseClassesSelected ? const Color(0xFFE11D48) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 4. Interactive Class Chips under selected course
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedCourseForClass.classes.map((cls) {
                    final isSelected = _selectedClasses.contains(cls.nameEn);
                    return InkWell(
                      onTap: () => _toggleIndividualClass(cls.nameEn),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.goldPrimary
                              : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.goldPrimary
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: 0.9,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                            ),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cls.nameEn,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                                  ),
                                ),
                                if (cls.nameUr.isNotEmpty)
                                  Text(
                                    cls.nameUr,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontFamily: 'JameelNoori',
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 5. Currently Assigned Classes Across All Courses Deck
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.2 : 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ASSIGNED CLASSES SUMMARY (${_selectedClasses.length}):',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                          if (_selectedClasses.isNotEmpty)
                            InkWell(
                              onTap: _clearAllClasses,
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_selectedClasses.isEmpty)
                        Text(
                          'No classes assigned yet. Pick a course above and select classes.',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _selectedClasses.map((cName) {
                            return Container(
                              padding: const EdgeInsets.only(left: 8, right: 3, top: 3, bottom: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  InkWell(
                                    onTap: () => _removeAssignedClass(cName),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Icon(Icons.close_rounded, size: 12, color: Color(0xFF0284C7)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
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
  // SECTION 2: ALLOCATE BOOKS (4-TIER CASCADING FILTERS + MULTI-SELECT)
  // ===========================================================================
  Widget _buildSection2Books(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.38 : 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.goldPrimary.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Text(
                          '2. ALLOCATE BOOKS (4-TIER FILTER)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Text(
                        '${_assignedBooks.length} Kitabs',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select Course ➔ Class ➔ Subject ➔ Kitabs and assign as many as needed:',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. 4-Tier Filter Container Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.3 : 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      width: 0.9,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FILTER 1: Course Dropdown ---
                      _buildFilterLabel('FILTER 1: COURSE (شعبہ)', isDark),
                      const SizedBox(height: 3),
                      _buildDropdownWrapper(
                        isDark: isDark,
                        child: DropdownButton<CatalogCourse>(
                          value: _bookFilterCourse,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: StaffAcademicCatalog.courses.map((course) {
                            return DropdownMenuItem<CatalogCourse>(
                              value: course,
                              child: Text(
                                course.nameEn,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (c) {
                            if (c != null) _onBookFilterCourseChanged(c);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- FILTER 2: Class Dropdown ---
                      _buildFilterLabel('FILTER 2: CLASS (جماعت)', isDark),
                      const SizedBox(height: 3),
                      _buildDropdownWrapper(
                        isDark: isDark,
                        child: DropdownButton<CatalogClass>(
                          value: _bookFilterClass,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: _bookFilterCourse.classes.map((cls) {
                            return DropdownMenuItem<CatalogClass>(
                              value: cls,
                              child: Text(
                                cls.nameEn,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (cls) {
                            if (cls != null) _onBookFilterClassChanged(cls);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- FILTER 3: Subject Dropdown ---
                      _buildFilterLabel('FILTER 3: SUBJECT (مضمون / فن)', isDark),
                      const SizedBox(height: 3),
                      _buildDropdownWrapper(
                        isDark: isDark,
                        child: DropdownButton<CatalogSubject>(
                          value: _bookFilterSubject,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: _bookFilterClass.subjects.map((sub) {
                            return DropdownMenuItem<CatalogSubject>(
                              value: sub,
                              child: Text(
                                sub.nameEn,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (sub) {
                            if (sub != null) _onBookFilterSubjectChanged(sub);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- FILTER 4 / RESULTS: Books Selection ("jitni chahein utni") ---
                      if (!_isCustomBookMode) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterLabel(
                              'FILTER 4: SELECT BOOKS (${_bookFilterSubject.books.length} AVAILABLE)',
                              isDark,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: _selectAllAvailableBooks,
                                  child: const Text(
                                    'Select All',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                                const Text(' • ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                InkWell(
                                  onTap: _deselectAllAvailableBooks,
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFE11D48),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Books List with Checkboxes
                        Container(
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                              width: 0.8,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _bookFilterSubject.books.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              thickness: 0.6,
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                            itemBuilder: (context, idx) {
                              final book = _bookFilterSubject.books[idx];
                              final isChecked = _checkedBooks.contains(book);
                              final isAlreadyAssigned = _assignedBooks.any(
                                (b) => b.className == _bookFilterClass.nameEn &&
                                       b.bookName.toLowerCase() == book.toLowerCase(),
                              );

                              return InkWell(
                                onTap: () => _toggleBookCheck(book),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        size: 16,
                                        color: isChecked ? AppColors.goldPrimary : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          book,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isAlreadyAssigned)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF059669).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Assigned',
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action Button: Assign Selected Books
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _isCustomBookMode = true),
                              child: const Text(
                                '+ Add custom kitab name',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldDark,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _checkedBooks.isEmpty ? null : _assignSelectedBooks,
                              icon: const Icon(Icons.add_task_rounded, size: 14),
                              label: Text(
                                _checkedBooks.isEmpty
                                    ? 'Select Kitabs Above'
                                    : 'Assign ${_checkedBooks.length} Kitabs',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Custom Kitab Input Mode
                        TextField(
                          controller: _customBookController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Enter Custom Kitab Name for ${_bookFilterClass.nameEn}',
                            hintText: 'e.g. Qasas-un-Nabiyyeen Part 2',
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _isCustomBookMode = false),
                              child: const Text(
                                '➔ Back to preset list',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldDark,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addCustomBook,
                              icon: const Icon(Icons.add_rounded, size: 14),
                              label: const Text('Add Custom Kitab'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Currently Allocated Books Roster Deck
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENTLY ALLOCATED BOOKS (${_assignedBooks.length}):',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    if (_assignedBooks.isNotEmpty)
                      InkWell(
                        onTap: _clearAllAllocatedBooks,
                        child: const Text(
                          'Clear All Kitabs',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_assignedBooks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Center(
                      child: Text(
                        'No kitabs allocated yet.\nUse the 4 filters above to select and assign kitabs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _assignedBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = _assignedBooks[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0x221E293B) : Colors.white).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.goldPrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.bookName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.courseName} ➔ ${item.className}',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.statusAbsent),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              onPressed: () => _removeAllocatedBook(index),
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
      ),
    );
  }

  // --- Helper: Filter Label ---
  Widget _buildFilterLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.4,
        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
      ),
    );
  }

  // --- Helper: Dropdown Wrapper ---
  Widget _buildDropdownWrapper({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  // ===========================================================================
  // BOTTOM COMMAND BAR
  // ===========================================================================
  Widget _buildBottomCommandBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),

          // Save Button (Champagne Gold Gradient)
          InkWell(
            onTap: _isSaving ? null : _handleSave,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.save_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _isSaving ? 'Saving...' : 'Save Allocation',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
}
