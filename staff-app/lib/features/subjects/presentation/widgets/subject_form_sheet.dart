import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_event.dart';

class SubjectFormSheet extends StatefulWidget {
  const SubjectFormSheet({
    super.key,
    required this.classes,
    this.existingSubject,
    this.boundClassId,
  });

  final List<ClassEntity> classes;
  final SubjectEntity? existingSubject;
  final String? boundClassId;

  static Future<void> show(
    BuildContext context, {
    required List<ClassEntity> classes,
    SubjectEntity? existingSubject,
    String? boundClassId,
  }) {
    final bloc = context.read<SubjectBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SubjectFormSheet(
          classes: classes,
          existingSubject: existingSubject,
          boundClassId: boundClassId,
        ),
      ),
    );
  }

  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameUrController;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    final sub = widget.existingSubject;
    _nameEnController = TextEditingController(text: sub?.nameEnglish ?? '');
    _nameUrController = TextEditingController(text: sub?.nameUrdu ?? '');

    if (sub != null) {
      _selectedClassId = sub.classId;
    } else if (widget.boundClassId != null &&
        widget.classes.any((c) => c.id == widget.boundClassId)) {
      _selectedClassId = widget.boundClassId;
    } else if (widget.classes.isNotEmpty) {
      _selectedClassId = widget.classes.first.id;
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) return;

    final bloc = context.read<SubjectBloc>();
    final isEdit = widget.existingSubject != null;

    if (isEdit) {
      bloc.add(UpdateSubjectEvent(
        id: widget.existingSubject!.id,
        classId: _selectedClassId!,
        nameEnglish: _nameEnController.text.trim(),
        nameUrdu: _nameUrController.text.trim(),
      ));
    } else {
      bloc.add(CreateSubjectEvent(
        classId: _selectedClassId!,
        nameEnglish: _nameEnController.text.trim(),
        nameUrdu: _nameUrController.text.trim(),
      ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingSubject != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.goldPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Edit Subject' : 'New Academic Subject',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          Text(
                            isEdit
                                ? 'Update subject details and assigned class'
                                : 'Define subject name in English & Urdu script',
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

                // Class Selector Dropdown
                Text(
                  'Assigned Class *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
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
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      hint: const Text('Select a class'),
                      items: widget.classes.map((cls) {
                        return DropdownMenuItem<String>(
                          value: cls.id,
                          child: Text(
                            cls.nameEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedClassId = val);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subject Name English
                Text(
                  'Subject Name (English) *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameEnController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Fiqh, Nahw, Islamic History',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.goldPrimary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'English name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Subject Name Urdu
                Text(
                  'Subject Name (Urdu Script) *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameUrController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'مثلاً: فقہ اسلامی، نحو و اعراب',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.goldPrimary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldPrimary : const Color(0xFF92400E),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Urdu name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.goldDark,
                            AppColors.goldPrimary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isEdit ? 'Save Changes' : 'Create Subject',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
