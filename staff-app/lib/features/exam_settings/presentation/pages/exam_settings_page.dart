import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_bloc.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_event.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_state.dart';
import 'package:staff_app/features/exam_settings/presentation/widgets/book_exam_setting_card.dart';

class ExamSettingsPage extends StatelessWidget {
  const ExamSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExamSettingsBloc>()..add(const LoadExamSettingsInitialEvent()),
      child: const _ExamSettingsView(),
    );
  }
}

class _ExamSettingsView extends StatelessWidget {
  const _ExamSettingsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Top Executive Header
            ExecutiveTopHeader(
              icon: Icons.tune_rounded,
              title: 'Exam Settings',
              subtitle: 'Book marking rules, terms & practical setup',
              onIconTap: () => context.pop(),
            ),

            // Main Body Area
            Expanded(
              child: BlocConsumer<ExamSettingsBloc, ExamSettingsState>(
                listener: (context, state) {
                  if (state is ExamSettingsLoaded && state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: AppColors.emeraldPrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is ExamSettingsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.rosePrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ExamSettingsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary),
                    );
                  }

                  if (state is ExamSettingsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: AppColors.rosePrimary),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ExamSettingsBloc>()
                                .add(const LoadExamSettingsInitialEvent()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ExamSettingsLoaded) {
                    return Column(
                      children: [
                        // Cascading Hierarchy Selector Strip
                        _HierarchyFilterCard(state: state),

                        // Books Roster or Guiding Instructions
                        Expanded(
                          child: _buildBooksContent(context, state, isDark),
                        ),
                      ],
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

  Widget _buildBooksContent(BuildContext context, ExamSettingsLoaded state, bool isDark) {
    if (state.isLoadingBooks) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.emeraldPrimary),
            SizedBox(height: 12),
            Text(
              'Loading textbooks for this subject...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty) {
      final hasSelectedSubject =
          state.selectedSubjectId != null && state.selectedSubjectId!.isNotEmpty;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasSelectedSubject
                      ? 'No Textbooks Found'
                      : 'Select Syllabus to Configure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasSelectedSubject
                      ? 'No books are configured under this subject yet.\nAdd books under "Books" tab or select another subject.'
                      : 'Choose Course ➔ Class ➔ Subject from the dropdowns above and tap "Load Books" to set up marking rules.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.books.length,
      itemBuilder: (context, index) {
        final book = state.books[index];
        return BookExamSettingCard(book: book);
      },
    );
  }
}

class _HierarchyFilterCard extends StatelessWidget {
  const _HierarchyFilterCard({required this.state});

  final ExamSettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<ExamSettingsBloc>();

    final courses = state.courses;
    final classes = state.filteredClasses;
    final subjects = state.filteredSubjects;

    final selectedCourseId = state.selectedCourseId;
    final selectedClassId = state.selectedClassId;
    final selectedSubjectId = state.selectedSubjectId;

    final canLoad = selectedSubjectId != null && selectedSubjectId.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Course Dropdown
          _DropdownRow(
            label: '1. Course',
            hint: 'Select Course',
            value: selectedCourseId,
            items: courses.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text(c.nameEnglish, maxLines: 1, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) {
              if (val != null) {
                bloc.add(SelectCourseEvent(val));
              }
            },
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // 2. Class Dropdown
          _DropdownRow(
            label: '2. Class',
            hint: selectedCourseId == null ? 'Select Course First' : 'Select Class',
            value: selectedClassId,
            items: classes.map((cl) => DropdownMenuItem(
              value: cl.id,
              child: Text(cl.nameEnglish, maxLines: 1, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: selectedCourseId == null
                ? null
                : (val) {
                    if (val != null) {
                      bloc.add(SelectClassEvent(val));
                    }
                  },
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // 3. Subject Dropdown
          _DropdownRow(
            label: '3. Subject',
            hint: selectedClassId == null ? 'Select Class First' : 'Select Subject',
            value: selectedSubjectId,
            items: subjects.map((sub) => DropdownMenuItem(
              value: sub.id,
              child: Text(
                '${sub.nameEnglish}${sub.nameUrdu.isNotEmpty ? " (${sub.nameUrdu})" : ""}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: selectedClassId == null
                ? null
                : (val) {
                    if (val != null) {
                      bloc.add(SelectSubjectEvent(val));
                    }
                  },
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // 4. "Load Books" Action Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: canLoad
                  ? () => bloc.add(LoadBooksForSubjectEvent(selectedSubjectId))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: canLoad
                      ? const LinearGradient(
                          colors: [AppColors.emeraldDark, AppColors.emeraldPrimary],
                        )
                      : null,
                  color: canLoad ? null : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: canLoad
                      ? [
                          BoxShadow(
                            color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_books_rounded,
                        size: 16,
                        color: canLoad ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.books.isNotEmpty ? 'Refresh Books' : 'Load Books',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canLoad ? Colors.white : Colors.grey,
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

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.charcoalDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.any((it) => it.value == value) ? value : null,
                hint: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
