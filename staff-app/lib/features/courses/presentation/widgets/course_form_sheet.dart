import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/presentation/bloc/course_bloc.dart';
import 'package:staff_app/features/courses/presentation/bloc/course_event.dart';

class CourseFormSheet extends StatefulWidget {
  const CourseFormSheet({
    super.key,
    this.initialCourse,
  });

  final CourseEntity? initialCourse;

  static Future<void> show(BuildContext context, {CourseEntity? initialCourse}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CourseBloc>(),
        child: CourseFormSheet(initialCourse: initialCourse),
      ),
    );
  }

  @override
  State<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<CourseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameUrController;
  late TextEditingController _descController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialCourse != null;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.initialCourse?.nameEnglish ?? '');
    _nameUrController = TextEditingController(text: widget.initialCourse?.nameUrdu ?? '');
    _descController = TextEditingController(text: widget.initialCourse?.description ?? '');
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final nameEn = _nameEnController.text.trim();
    final nameUr = _nameUrController.text.trim();
    final desc = _descController.text.trim();

    if (_isEditing) {
      context.read<CourseBloc>().add(
            UpdateCourseEvent(
              id: widget.initialCourse!.id,
              nameEnglish: nameEn,
              nameUrdu: nameUr.isNotEmpty ? nameUr : null,
              description: desc.isNotEmpty ? desc : null,
            ),
          );
    } else {
      context.read<CourseBloc>().add(
            CreateCourseEvent(
              nameEnglish: nameEn,
              nameUrdu: nameUr.isNotEmpty ? nameUr : null,
              description: desc.isNotEmpty ? desc : null,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                          _isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
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
                              _isEditing ? 'Edit Course Details' : 'Create New Course',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              _isEditing
                                  ? 'Update department syllabus and naming'
                                  : 'Define a new curriculum stream or department',
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

                  // English Course Name
                  const Text(
                    'COURSE NAME (ENGLISH) *',
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
                      hintText: 'e.g. Dars-e-Nizami, Hifz-ul-Quran',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.school_outlined, size: 18, color: AppColors.goldPrimary),
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
                        return 'Please enter English course name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Urdu Course Name with RTL
                  const Text(
                    'COURSE NAME (URDU) - اختیاری',
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
                      hintText: 'مثلاً: درس نظامی (عالمیت)، حفظ القرآن',
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

                  // Description Textarea
                  Text(
                    'DEPARTMENT DESCRIPTION',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe curriculum scope, target age, or specializations...',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                  _isEditing ? 'Save Course Changes' : 'Create Course',
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
