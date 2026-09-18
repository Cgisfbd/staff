import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_event.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_state.dart';
import 'package:staff_app/features/subjects/presentation/widgets/subject_card.dart';
import 'package:staff_app/features/subjects/presentation/widgets/subject_form_sheet.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubjectBloc>()..add(const LoadSubjectsEvent()),
      child: const _SubjectsView(),
    );
  }
}

class _SubjectsView extends StatefulWidget {
  const _SubjectsView();

  @override
  State<_SubjectsView> createState() => _SubjectsViewState();
}

class _SubjectsViewState extends State<_SubjectsView> {
  final TextEditingController _searchController = TextEditingController();
  String _userRole = 'STAFF';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    try {
      final profileStr = await sl<SecureStorageService>().getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _userRole = data['role']?.toString() ?? 'STAFF';
          });
        }
      }
    } catch (_) {}
  }

  bool get _isAdmin => _userRole == 'SUPER_ADMIN' || _userRole == 'ADMIN';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Executive Header with NEW SUBJECT action
            BlocBuilder<SubjectBloc, SubjectState>(
              builder: (context, state) {
                final classes = state is SubjectLoaded ? state.classes : null;
                final selectedClassId = state is SubjectLoaded ? state.selectedClassId : null;

                return ExecutiveTopHeader(
                  icon: Icons.menu_book_rounded,
                  title: 'Subjects',
                  subtitle: 'Curriculum definition, syllabus & weightage',
                  onIconTap: () => context.pop(),
                  trailing: _isAdmin && classes != null && classes.isNotEmpty
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => SubjectFormSheet.show(
                              context,
                              classes: classes,
                              boundClassId: selectedClassId,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.goldDark, AppColors.goldPrimary],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'New Subject',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),

            // Content Area
            Expanded(
              child: BlocConsumer<SubjectBloc, SubjectState>(
                listener: (context, state) {
                  if (state is SubjectLoaded) {
                    if (state.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.successMessage!),
                          backgroundColor: AppColors.emeraldPrimary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: AppColors.rosePrimary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is SubjectLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary),
                    );
                  }

                  if (state is SubjectError) {
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
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.read<SubjectBloc>().add(const LoadSubjectsEvent()),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldPrimary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SubjectLoaded) {
                    final subjects = state.filteredSubjects;
                    final totalBooks = subjects.fold<int>(0, (sum, s) => sum + s.bookCount);

                    return RefreshIndicator(
                      color: AppColors.goldPrimary,
                      onRefresh: () async {
                        context.read<SubjectBloc>().add(LoadSubjectsEvent(
                              courseId: state.selectedCourseId,
                              classId: state.selectedClassId,
                            ));
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // Search & Filter Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Search Field
                                  Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkGlassSurface
                                          : AppColors.lightGlassSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkGlassBorder
                                            : AppColors.lightGlassBorder,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) => context
                                          .read<SubjectBloc>()
                                          .add(SearchSubjectsEvent(val)),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : AppColors.charcoalDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search subjects (English or Urdu)...',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                        ),
                                        prefixIcon: const Icon(Icons.search_rounded,
                                            size: 18, color: AppColors.goldPrimary),
                                        suffixIcon: _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear_rounded, size: 16),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  context
                                                      .read<SubjectBloc>()
                                                      .add(const SearchSubjectsEvent(''));
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Course Filter Pills (Horizontal Scroll)
                                  if (state.courses.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          _FilterChip(
                                            label: 'All Courses',
                                            isSelected: state.selectedCourseId == null,
                                            onTap: () => context
                                                .read<SubjectBloc>()
                                                .add(const FilterCourseSelectedEvent('ALL')),
                                          ),
                                          ...state.courses.map((course) {
                                            final isSelected =
                                                state.selectedCourseId == course.id;
                                            return _FilterChip(
                                              label: course.nameEnglish,
                                              isSelected: isSelected,
                                              onTap: () => context
                                                  .read<SubjectBloc>()
                                                  .add(FilterCourseSelectedEvent(course.id)),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 6),

                                  // Class Filter Pills (Filtered by selected course)
                                  if (state.classes.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          _FilterChip(
                                            label: 'All Classes',
                                            isSelected: state.selectedClassId == null,
                                            isSubFilter: true,
                                            onTap: () => context
                                                .read<SubjectBloc>()
                                                .add(const FilterClassSelectedEvent('ALL')),
                                          ),
                                          ...state.classes
                                              .where((c) =>
                                                  state.selectedCourseId == null ||
                                                  c.courseId == state.selectedCourseId)
                                              .map((cls) {
                                            final isSelected =
                                                state.selectedClassId == cls.id;
                                            return _FilterChip(
                                              label: cls.nameEnglish,
                                              isSelected: isSelected,
                                              isSubFilter: true,
                                              onTap: () => context
                                                  .read<SubjectBloc>()
                                                  .add(FilterClassSelectedEvent(cls.id)),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 12),

                                  // Summary Stat Row (Liquid Crystal)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkGlassSurface
                                          : AppColors.lightGlassSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkGlassBorder
                                            : AppColors.lightGlassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _StatItem(
                                          label: 'Subjects',
                                          value: '${subjects.length}',
                                          color: AppColors.goldPrimary,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        _StatItem(
                                          label: 'Books Linked',
                                          value: '$totalBooks',
                                          color: AppColors.goldLight,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        _StatItem(
                                          label: 'Classes',
                                          value: '${state.classes.length}',
                                          color: AppColors.emeraldPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Subjects List or Empty State
                          if (subjects.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 52,
                                      color: isDark ? Colors.white24 : Colors.black26,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No subjects found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try adjusting your search or course/class filter',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final sub = subjects[index];
                                    return SubjectCard(
                                      subject: sub,
                                      classes: state.classes,
                                      isAdmin: _isAdmin,
                                      onTap: () {
                                        // Open Books page filtered for this subject
                                        context.push(
                                          '${RouteNames.books}?subjectId=${sub.id}',
                                        );
                                      },
                                    );
                                  },
                                  childCount: subjects.length,
                                ),
                              ),
                            ),
                        ],
                      ),
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSubFilter = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSubFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSubFilter ? 10 : 12,
              vertical: isSubFilter ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.goldPrimary],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.goldPrimary
                    : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSubFilter ? 11 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
