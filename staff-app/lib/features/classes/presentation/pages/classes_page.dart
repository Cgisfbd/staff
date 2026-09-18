import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_bloc.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_event.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_state.dart';
import 'package:staff_app/features/classes/presentation/widgets/class_card.dart';
import 'package:staff_app/features/classes/presentation/widgets/class_form_sheet.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassBloc>()..add(const LoadClassesEvent()),
      child: const _ClassesView(),
    );
  }
}

class _ClassesView extends StatefulWidget {
  const _ClassesView();

  @override
  State<_ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<_ClassesView> {
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
            // Executive Header with NEW CLASS action
            BlocBuilder<ClassBloc, ClassState>(
              builder: (context, state) {
                final courses = state is ClassLoaded ? state.courses : null;
                final selectedCourseId = state is ClassLoaded ? state.selectedCourseId : null;

                return ExecutiveTopHeader(
                  icon: Icons.domain_rounded,
                  title: 'Classes & Sections',
                  subtitle: 'Academic divisions, capacities & enrollment',
                  onIconTap: () => context.pop(),
                  trailing: _isAdmin && courses != null
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => ClassFormSheet.show(
                              context,
                              courses: courses,
                              boundCourseId: selectedCourseId,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.goldDark, AppColors.goldPrimary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'NEW CLASS',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
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
              child: BlocConsumer<ClassBloc, ClassState>(
                listener: (context, state) {
                  if (state is ClassLoaded && state.actionSuccessMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.actionSuccessMessage!),
                        backgroundColor: AppColors.emeraldPrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ClassLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2),
                    );
                  }

                  if (state is ClassError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 42, color: AppColors.rosePrimary),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.read<ClassBloc>().add(const LoadClassesEvent()),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldPrimary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ClassLoaded) {
                    final classes = state.filteredClasses;

                    return RefreshIndicator(
                      color: AppColors.goldPrimary,
                      onRefresh: () async {
                        context.read<ClassBloc>().add(LoadClassesEvent(
                              courseId: state.selectedCourseId,
                              searchQuery: _searchController.text,
                            ));
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                        children: [
                          // 1. Overview Metric Bar
                          _buildSummaryBar(context, state, isDark),
                          const SizedBox(height: 12),

                          // 2. Horizontal Course Filter Pills Scroller
                          _buildCourseFilterBar(context, state, isDark),
                          const SizedBox(height: 12),

                          // 3. Search Bar
                          _buildSearchBar(context, isDark),
                          const SizedBox(height: 14),

                          // 4. Classes List Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACTIVE SECTIONS (${classes.length})',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: AppColors.goldPrimary,
                                ),
                              ),
                              Text(
                                'Tap card to expand details',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 5. Classes List
                          if (classes.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded, size: 36, color: Colors.grey.withValues(alpha: 0.4)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No class sections found',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...classes.map((c) {
                              final isExpanded = state.expandedClassId == c.id;
                              return ClassCard(
                                key: ValueKey(c.id),
                                classEntity: c,
                                courses: state.courses,
                                isExpanded: isExpanded,
                                isAdmin: _isAdmin,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<ClassBloc>().add(ToggleExpandClassEvent(c.id));
                                },
                              );
                            }),
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

  Widget _buildSummaryBar(BuildContext context, ClassLoaded state, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.38 : 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.goldPrimary.withValues(alpha: 0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryPill(
                  label: 'Classes',
                  value: '${state.filteredClasses.length}',
                  icon: Icons.domain_rounded,
                  color: AppColors.goldPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: (isDark ? Colors.white : AppColors.goldPrimary).withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildSummaryPill(
                  label: 'Enrolled',
                  value: '${state.totalStudents}',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.emeraldLight,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: (isDark ? Colors.white : AppColors.goldPrimary).withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildSummaryPill(
                  label: 'Capacity',
                  value: '${state.totalCapacity}',
                  icon: Icons.airline_seat_recline_normal_rounded,
                  color: AppColors.goldChampagne,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseFilterBar(BuildContext context, ClassLoaded state, bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip(
            context,
            label: 'All Courses',
            isSelected: state.selectedCourseId == 'ALL',
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<ClassBloc>().add(const SelectCourseFilterEvent('ALL'));
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          ...state.courses.map((course) {
            final isSelected = state.selectedCourseId == course.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context,
                label: course.nameEnglish,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<ClassBloc>().add(SelectCourseFilterEvent(course.id));
                },
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.65),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldPrimary
                  : (isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.goldPrimary.withValues(alpha: 0.25)),
              width: 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLightPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white)
                .withValues(alpha: isDark ? 0.35 : 0.70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 11),
              const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    final bloc = context.read<ClassBloc>();
                    final currentState = bloc.state;
                    final courseId = currentState is ClassLoaded ? currentState.selectedCourseId : 'ALL';
                    bloc.add(LoadClassesEvent(courseId: courseId, searchQuery: val));
                  },
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search classes in English or Urdu...',
                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.goldPrimary),
                  onPressed: () {
                    _searchController.clear();
                    final bloc = context.read<ClassBloc>();
                    final currentState = bloc.state;
                    final courseId = currentState is ClassLoaded ? currentState.selectedCourseId : 'ALL';
                    bloc.add(LoadClassesEvent(courseId: courseId));
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
