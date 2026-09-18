import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:staff_app/features/books/presentation/bloc/book_event.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

class BookFormSheet extends StatefulWidget {
  const BookFormSheet({
    super.key,
    required this.subjects,
    this.existingBook,
    this.boundSubjectId,
  });

  final List<SubjectEntity> subjects;
  final BookEntity? existingBook;
  final String? boundSubjectId;

  static Future<void> show(
    BuildContext context, {
    required List<SubjectEntity> subjects,
    BookEntity? existingBook,
    String? boundSubjectId,
  }) {
    final bloc = context.read<BookBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BookFormSheet(
          subjects: subjects,
          existingBook: existingBook,
          boundSubjectId: boundSubjectId,
        ),
      ),
    );
  }

  @override
  State<BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameUrController;

  String? _selectedSubjectId;
  String _category = 'DEENI';

  @override
  void initState() {
    super.initState();
    final b = widget.existingBook;
    _nameEnController = TextEditingController(text: b?.nameEnglish ?? '');
    _nameUrController = TextEditingController(text: b?.nameUrdu ?? '');

    if (b != null) {
      _selectedSubjectId = b.subjectId;
      _category = b.category;
    } else if (widget.boundSubjectId != null &&
        widget.subjects.any((s) => s.id == widget.boundSubjectId)) {
      _selectedSubjectId = widget.boundSubjectId;
    } else if (widget.subjects.isNotEmpty) {
      _selectedSubjectId = widget.subjects.first.id;
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
    if (_selectedSubjectId == null) return;

    final bloc = context.read<BookBloc>();
    final isEdit = widget.existingBook != null;

    if (isEdit) {
      bloc.add(UpdateBookEvent(
        id: widget.existingBook!.id,
        subjectId: _selectedSubjectId!,
        nameEnglish: _nameEnController.text.trim(),
        nameUrdu: _nameUrController.text.trim(),
        category: _category,
        term: 'FULL_YEAR',
        maxMarks: 100,
        passMarks: 33,
        theoryMarks: 100,
        practicalMarks: 0,
      ));
    } else {
      bloc.add(CreateBookEvent(
        subjectId: _selectedSubjectId!,
        nameEnglish: _nameEnController.text.trim(),
        nameUrdu: _nameUrController.text.trim(),
        category: _category,
        term: 'FULL_YEAR',
        maxMarks: 100,
        passMarks: 33,
        theoryMarks: 100,
        practicalMarks: 0,
      ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingBook != null;
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
                        color: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.collections_bookmark_rounded,
                        color: AppColors.emeraldPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Edit Book' : 'Add New Book',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          Text(
                            isEdit
                                ? 'Update textbook details under parent subject'
                                : 'Define book name and curriculum category',
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

                // 1. Parent Subject Selector Dropdown
                Text(
                  'Parent Subject *',
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
                      value: _selectedSubjectId,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      hint: const Text('Select a subject'),
                      items: widget.subjects.map((sub) {
                        return DropdownMenuItem<String>(
                          value: sub.id,
                          child: Text(
                            '${sub.nameEnglish} (${sub.className})',
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
                          setState(() => _selectedSubjectId = val);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Book Name English
                Text(
                  'Book Name (English) *',
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
                    hintText: 'e.g. Mukhtasar al-Quduri, Hidayat un-Nahw',
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

                // 3. Book Name Urdu
                Text(
                  'Book Name (Urdu / Arabic Script) *',
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
                    hintText: 'مثلاً: مختصر القدوری، ہدایۃ النحو',
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
                      return 'Urdu title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 4. Category Selector (Deeni vs Asri)
                Text(
                  'Curriculum Category *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceTile(
                        label: 'دینی Deeni Book',
                        isSelected: _category == 'DEENI',
                        activeColor: AppColors.emeraldPrimary,
                        onTap: () => setState(() => _category = 'DEENI'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChoiceTile(
                        label: 'عصری Asri Book',
                        isSelected: _category == 'ASRI',
                        activeColor: AppColors.goldDark,
                        onTap: () => setState(() => _category = 'ASRI'),
                      ),
                    ),
                  ],
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
                            AppColors.emeraldDark,
                            AppColors.emeraldPrimary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emeraldPrimary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Book',
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

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white70 : AppColors.charcoalDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
