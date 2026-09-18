import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/ebooks/data/datasources/ebooks_datasource.dart';
import 'package:staff_app/features/ebooks/domain/models/ebook_bundle_model.dart';
import 'package:staff_app/features/ebooks/presentation/widgets/ebook_dual_card.dart';
import 'package:staff_app/features/ebooks/presentation/widgets/ebook_filter_card.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Ultra-Luxury E-Books & Dual-Reader Hub Page (< 150 lines).
/// Strictly styled with Liquid Crystal Glassmorphism, cascading dropdowns,
/// and paired original/translation textbook cards.
class EbooksPage extends StatefulWidget {
  const EbooksPage({super.key});

  @override
  State<EbooksPage> createState() => _EbooksPageState();
}

class _EbooksPageState extends State<EbooksPage> {
  final List<CourseEntity> _courses = EbooksDatasource.courses;
  late CourseEntity _selectedCourse;
  late List<ClassEntity> _currentClasses;
  ClassEntity? _selectedClass;

  @override
  void initState() {
    super.initState();
    _selectedCourse = _courses.first;
    _currentClasses = EbooksDatasource.getClassesForCourse(_selectedCourse.id);
    _selectedClass = _currentClasses.isNotEmpty ? _currentClasses.first : null;
  }

  void _onCourseChanged(CourseEntity? newCourse) {
    if (newCourse == null || newCourse == _selectedCourse) return;
    setState(() {
      _selectedCourse = newCourse;
      _currentClasses = EbooksDatasource.getClassesForCourse(newCourse.id);
      _selectedClass = _currentClasses.isNotEmpty ? _currentClasses.first : null;
    });
  }

  void _onClassChanged(ClassEntity? newClass) {
    if (newClass == null || newClass == _selectedClass) return;
    setState(() {
      _selectedClass = newClass;
    });
  }

  List<EBookBundleModel> get _filteredBooks {
    if (_selectedClass == null) return const [];
    return EbooksDatasource.getBooksForClass(_selectedCourse.id, _selectedClass!.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = _filteredBooks;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Executive Top Header
              ExecutiveTopHeader(
                icon: Icons.menu_book_rounded,
                title: context.tr('ebooks_header_title'),
                subtitle: context.tr('ebooks_header_subtitle'),
              ),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    // Cascading Filter Card
                    EbookFilterCard(
                      courses: _courses,
                      classes: _currentClasses,
                      selectedCourse: _selectedCourse,
                      selectedClass: _selectedClass,
                      totalBooksCount: books.length,
                      onCourseChanged: _onCourseChanged,
                      onClassChanged: _onClassChanged,
                    ),
                    const SizedBox(height: 14),

                    // Books List or Empty State
                    if (books.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ...books.map(
                        (bundle) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EbookDualCard(bundle: bundle),
                        ),
                      ),

                    const SizedBox(height: 96), // Bottom nav bar clearance
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x3D1E293B),
                      const Color(0x240F172A),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFFBF8F3).withValues(alpha: 0.88),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.goldPrimary.withValues(alpha: 0.38)
                  : AppColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: AppColors.goldPrimary.withValues(alpha: 0.55),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.tr('ebooks_empty_title'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('ebooks_empty_subtitle'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
