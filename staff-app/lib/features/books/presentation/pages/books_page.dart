import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:staff_app/features/books/presentation/bloc/book_event.dart';
import 'package:staff_app/features/books/presentation/bloc/book_state.dart';
import 'package:staff_app/features/books/presentation/widgets/book_card.dart';
import 'package:staff_app/features/books/presentation/widgets/book_form_sheet.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({super.key, this.initialSubjectId});

  final String? initialSubjectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookBloc>()..add(LoadBooksEvent(subjectId: initialSubjectId)),
      child: _BooksView(initialSubjectId: initialSubjectId),
    );
  }
}

class _BooksView extends StatefulWidget {
  const _BooksView({this.initialSubjectId});

  final String? initialSubjectId;

  @override
  State<_BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<_BooksView> {
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
            // Executive Top Header
            BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                final subjects = state is BookLoaded ? state.subjects : null;
                final selectedSubjectId = state is BookLoaded ? state.selectedSubjectId : null;

                return ExecutiveTopHeader(
                  icon: Icons.collections_bookmark_rounded,
                  title: 'Books',
                  subtitle: 'Institute text library & marks allocation',
                  onIconTap: () => context.pop(),
                  trailing: _isAdmin && subjects != null && subjects.isNotEmpty
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => BookFormSheet.show(
                              context,
                              subjects: subjects,
                              boundSubjectId: selectedSubjectId,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.emeraldDark, AppColors.emeraldPrimary],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
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
                                    'Add Book',
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

            // Main Content Area
            Expanded(
              child: BlocConsumer<BookBloc, BookState>(
                listener: (context, state) {
                  if (state is BookLoaded) {
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
                  if (state is BookLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary),
                    );
                  }

                  if (state is BookError) {
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
                                context.read<BookBloc>().add(const LoadBooksEvent()),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldPrimary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BookLoaded) {
                    final books = state.filteredBooks;
                    final deeniCount = books.where((b) => b.category == 'DEENI').length;
                    final asriCount = books.where((b) => b.category == 'ASRI').length;

                    return RefreshIndicator(
                      color: AppColors.goldPrimary,
                      onRefresh: () async {
                        context.read<BookBloc>().add(LoadBooksEvent(
                              subjectId: state.selectedSubjectId,
                              term: state.selectedTerm,
                              category: state.selectedCategory,
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
                                      onChanged: (val) =>
                                          context.read<BookBloc>().add(SearchBooksEvent(val)),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : AppColors.charcoalDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search books by title, kitab name...',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          size: 18,
                                          color: AppColors.emeraldPrimary,
                                        ),
                                        suffixIcon: _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear_rounded, size: 16),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  context
                                                      .read<BookBloc>()
                                                      .add(const SearchBooksEvent(''));
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

                                  // Subject Filter Pills
                                  if (state.subjects.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          _Pill(
                                            label: 'All Subjects',
                                            isSelected: state.selectedSubjectId == null,
                                            onTap: () => context
                                                .read<BookBloc>()
                                                .add(const FilterSubjectSelectedEvent('ALL')),
                                          ),
                                          ...state.subjects.map((sub) {
                                            final isSelected =
                                                state.selectedSubjectId == sub.id;
                                            return _Pill(
                                              label: sub.nameEnglish,
                                              isSelected: isSelected,
                                              onTap: () => context
                                                  .read<BookBloc>()
                                                  .add(FilterSubjectSelectedEvent(sub.id)),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 6),

                                  // Category & Term Filter Row
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        // Category Pills
                                        _Pill(
                                          label: 'All Categories',
                                          isSelected: state.selectedCategory == 'ALL',
                                          isSub: true,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterCategorySelectedEvent('ALL')),
                                        ),
                                        _Pill(
                                          label: 'دینی Deeni',
                                          isSelected: state.selectedCategory == 'DEENI',
                                          isSub: true,
                                          activeColor: AppColors.emeraldPrimary,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterCategorySelectedEvent('DEENI')),
                                        ),
                                        _Pill(
                                          label: 'عصری Asri',
                                          isSelected: state.selectedCategory == 'ASRI',
                                          isSub: true,
                                          activeColor: AppColors.goldDark,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterCategorySelectedEvent('ASRI')),
                                        ),

                                        const SizedBox(width: 8),
                                        Container(
                                          width: 1,
                                          height: 18,
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        const SizedBox(width: 8),

                                        // Term Pills
                                        // Session / Semester Pills
                                        _Pill(
                                          label: 'All Sessions',
                                          isSelected: state.selectedTerm == 'ALL',
                                          isSub: true,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterTermSelectedEvent('ALL')),
                                        ),
                                        _Pill(
                                          label: 'Full Session',
                                          isSelected: state.selectedTerm == 'FULL_YEAR',
                                          isSub: true,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterTermSelectedEvent('FULL_YEAR')),
                                        ),
                                        _Pill(
                                          label: 'First Semester',
                                          isSelected: state.selectedTerm == 'TERM_1',
                                          isSub: true,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterTermSelectedEvent('TERM_1')),
                                        ),
                                        _Pill(
                                          label: 'Second Semester',
                                          isSelected: state.selectedTerm == 'TERM_2',
                                          isSub: true,
                                          onTap: () => context
                                              .read<BookBloc>()
                                              .add(const FilterTermSelectedEvent('TERM_2')),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Summary Stat Row
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
                                        _StatMetric(
                                          label: 'Total Books',
                                          value: '${books.length}',
                                          color: AppColors.goldPrimary,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        _StatMetric(
                                          label: 'Deeni (دینی)',
                                          value: '$deeniCount',
                                          color: AppColors.emeraldPrimary,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        _StatMetric(
                                          label: 'Asri (عصری)',
                                          value: '$asriCount',
                                          color: AppColors.goldDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Books List or Empty State
                          if (books.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.collections_bookmark_outlined,
                                      size: 52,
                                      color: isDark ? Colors.white24 : Colors.black26,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No books found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try selecting a different subject or term filter',
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
                                    final book = books[index];
                                    return BookCard(
                                      book: book,
                                      subjects: state.subjects,
                                      isAdmin: _isAdmin,
                                    );
                                  },
                                  childCount: books.length,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSub = false,
    this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSub;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = activeColor ?? AppColors.goldPrimary;

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
              horizontal: isSub ? 10 : 12,
              vertical: isSub ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [primary.withValues(alpha: 0.85), primary],
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
                    ? primary
                    : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSub ? 11 : 12,
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

class _StatMetric extends StatelessWidget {
  const _StatMetric({
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
