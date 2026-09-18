import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';
import 'package:staff_app/features/fee_structure/presentation/pages/fee_structure_setup_page.dart';

class CourseClassSelectorSheet extends StatefulWidget {
  const CourseClassSelectorSheet({
    super.key,
    required this.courses,
    required this.classes,
    required this.fees,
    this.initialCourseId,
    this.initialClassId,
  });

  final List<CourseEntity> courses;
  final List<ClassEntity> classes;
  final List<FeeStructureEntity> fees;
  final String? initialCourseId;
  final String? initialClassId;

  static Future<void> show(
    BuildContext context, {
    required List<CourseEntity> courses,
    required List<ClassEntity> classes,
    required List<FeeStructureEntity> fees,
    String? initialCourseId,
    String? initialClassId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CourseClassSelectorSheet(
        courses: courses,
        classes: classes,
        fees: fees,
        initialCourseId: initialCourseId,
        initialClassId: initialClassId,
      ),
    );
  }

  @override
  State<CourseClassSelectorSheet> createState() =>
      _CourseClassSelectorSheetState();
}

class _CourseClassSelectorSheetState extends State<CourseClassSelectorSheet> {
  String? _selectedCourseId;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    if (widget.courses.isNotEmpty) {
      _selectedCourseId = widget.initialCourseId ?? widget.courses.first.id;
    }
    final courseClasses = _getClassesForCourse(_selectedCourseId);
    if (courseClasses.isNotEmpty) {
      _selectedClassId = widget.initialClassId ?? courseClasses.first.id;
    }
  }

  List<ClassEntity> _getClassesForCourse(String? courseId) {
    if (courseId == null) return [];
    return widget.classes.where((c) => c.courseId == courseId).toList();
  }

  FeeStructureEntity? _getFeeForClass(String? classId) {
    if (classId == null) return null;
    try {
      return widget.fees.firstWhere((f) => f.classId == classId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseClasses = _getClassesForCourse(_selectedCourseId);
    final selectedClass = widget.classes
        .where((c) => c.id == _selectedClassId)
        .firstOrNull;
    final selectedCourse = widget.courses
        .where((c) => c.id == _selectedCourseId)
        .firstOrNull;
    final existingFee = _getFeeForClass(_selectedClassId);
    final hasExistingFee = existingFee != null &&
        (existingFee.tuitionFee > 0 ||
            existingFee.hostelFee > 0 ||
            existingFee.admissionFeeHostel > 0);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldPrimary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Structure Setup',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select Course & Class to configure fees',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Step 1: Course Selection
          Text(
            'STEP 1: SELECT COURSE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? AppColors.goldPrimary : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourseId,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: widget.courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course.id,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 16,
                          color: AppColors.emeraldPrimary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            course.nameEnglish,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCourseId = val;
                    final classesInCourse = _getClassesForCourse(val);
                    _selectedClassId = classesInCourse.isNotEmpty
                        ? classesInCourse.first.id
                        : null;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Step 2: Class Selection
          Text(
            'STEP 2: SELECT CLASS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? AppColors.goldPrimary : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 8),
          if (courseClasses.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No classes found under this course. Please create classes first.',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClassId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: courseClasses.map((clazz) {
                    final fee = _getFeeForClass(clazz.id);
                    final isSet = fee != null &&
                        (fee.tuitionFee > 0 ||
                            fee.hostelFee > 0 ||
                            fee.admissionFeeHostel > 0);

                    return DropdownMenuItem<String>(
                      value: clazz.id,
                      child: Row(
                        children: [
                          Icon(
                            isSet
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isSet
                                ? AppColors.emeraldPrimary
                                : Colors.amber,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              clazz.nameEnglish,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.charcoalDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSet
                                  ? AppColors.emeraldPrimary
                                      .withValues(alpha: 0.12)
                                  : Colors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isSet ? 'Configured' : 'Needs Setup',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSet
                                    ? AppColors.emeraldPrimary
                                    : Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClassId = val;
                    });
                  },
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Action Button: Proceed to Configure
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: selectedClass == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (ctx) => FeeStructureSetupPage(
                            clazz: selectedClass,
                            course: selectedCourse,
                            fee: existingFee,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasExistingFee
                            ? Icons.edit_note_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          hasExistingFee
                              ? 'Edit Fee Structure (${selectedClass?.nameEnglish ?? ''})'
                              : 'Configure Fees (${selectedClass?.nameEnglish ?? ''})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
