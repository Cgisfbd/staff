import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_bloc.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_event.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

class ClassFormSheet extends StatefulWidget {
  const ClassFormSheet({
    super.key,
    required this.courses,
    this.initialClass,
    this.boundCourseId,
  });

  final List<CourseEntity> courses;
  final ClassEntity? initialClass;
  final String? boundCourseId;

  static Future<void> show(
    BuildContext context, {
    required List<CourseEntity> courses,
    ClassEntity? initialClass,
    String? boundCourseId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ClassBloc>(),
        child: ClassFormSheet(
          courses: courses,
          initialClass: initialClass,
          boundCourseId: boundCourseId,
        ),
      ),
    );
  }

  @override
  State<ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends State<ClassFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCourseId;
  late TextEditingController _nameEnController;
  late TextEditingController _nameUrController;
  late TextEditingController _capacityController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialClass != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedCourseId = widget.initialClass!.courseId;
    } else if (widget.boundCourseId != null &&
        widget.boundCourseId != 'ALL' &&
        widget.courses.any((c) => c.id == widget.boundCourseId)) {
      _selectedCourseId = widget.boundCourseId!;
    } else if (widget.courses.isNotEmpty) {
      _selectedCourseId = widget.courses.first.id;
    } else {
      _selectedCourseId = '';
    }

    _nameEnController = TextEditingController(text: widget.initialClass?.nameEnglish ?? '');
    _nameUrController = TextEditingController(text: widget.initialClass?.nameUrdu ?? '');
    _capacityController = TextEditingController(text: '${widget.initialClass?.capacity ?? 50}');
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an affiliated Course / Department first'),
          backgroundColor: AppColors.rosePrimary,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final nameEn = _nameEnController.text.trim();
    final nameUr = _nameUrController.text.trim();
    final cap = int.tryParse(_capacityController.text.trim()) ?? 50;

    if (_isEditing) {
      context.read<ClassBloc>().add(
            UpdateClassEvent(
              id: widget.initialClass!.id,
              courseId: _selectedCourseId,
              nameEnglish: nameEn,
              nameUrdu: nameUr.isNotEmpty ? nameUr : null,
              capacity: cap,
            ),
          );
    } else {
      context.read<ClassBloc>().add(
            CreateClassEvent(
              courseId: _selectedCourseId,
              nameEnglish: nameEn,
              nameUrdu: nameUr.isNotEmpty ? nameUr : null,
              capacity: cap,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final Map<String, CourseEntity> uniqueCourses = {};
    for (final c in widget.courses) {
      uniqueCourses[c.id] = c;
    }
    if (widget.initialClass != null &&
        widget.initialClass!.courseId.isNotEmpty &&
        !uniqueCourses.containsKey(widget.initialClass!.courseId)) {
      uniqueCourses[widget.initialClass!.courseId] = CourseEntity(
        id: widget.initialClass!.courseId,
        simpleId: 1,
        nameEnglish: widget.initialClass!.courseName,
      );
    }
    final coursesList = uniqueCourses.values.toList();
    final String? effectiveValue = uniqueCourses.containsKey(_selectedCourseId)
        ? _selectedCourseId
        : (coursesList.isNotEmpty ? coursesList.first.id : null);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldDark, AppColors.goldPrimary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isEditing ? Icons.edit_note_rounded : Icons.domain_add_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing ? 'Edit Class & Section' : 'Add New Class Section',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              _isEditing
                                  ? 'Update class naming, capacity, or assigned department'
                                  : 'Assign a new classroom section to a course curriculum',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 1. Parent Course / Department Selector
                  const Text(
                    'PARENT COURSE / DEPARTMENT *',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: effectiveValue,
                        hint: const Text('Select affiliated course', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.goldPrimary),
                        dropdownColor: isDark ? AppColors.charcoalDark : Colors.white,
                        items: coursesList.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(
                              c.nameEnglish,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCourseId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Class Name (English)
                  const Text(
                    'CLASS NAME (ENGLISH) *',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameEnController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Darja Awwal (1st Year), Section A',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.class_outlined, size: 18, color: AppColors.goldPrimary),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter English class name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 3. Class Name (Urdu) - Optional
                  const Text(
                    'CLASS NAME (URDU) - اختیاری',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameUrController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'مثلاً: درجہ اول، شعبہ حفظ الف',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.translate_rounded, size: 18, color: AppColors.goldPrimary),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Seating Capacity
                  const Text(
                    'MAXIMUM STUDENT SEATING CAPACITY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Standard class capacity (e.g. 50)',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.airline_seat_recline_normal_rounded, size: 18, color: AppColors.goldPrimary),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter capacity';
                      }
                      final num = int.tryParse(value.trim());
                      if (num == null || num <= 0) {
                        return 'Capacity must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditing ? 'Save Class Changes' : 'Create Class Section',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
