import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_bloc.dart';
import 'package:staff_app/features/exam_settings/presentation/pages/book_exam_setup_page.dart';

class BookExamSettingCard extends StatelessWidget {
  const BookExamSettingCard({
    super.key,
    required this.book,
  });

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDeeni = book.category == 'DEENI';
    final hasPractical = (book.practicalMarks) > 0;

    void navigateToSetup() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<ExamSettingsBloc>(),
            child: BookExamSetupPage(book: book),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: navigateToSetup,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title, Urdu, Category, & Setup Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Icon Sphere
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.goldDark, AppColors.goldPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Book Title Column (Shielded with Expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (book.nameUrdu.isNotEmpty)
                            Text(
                              book.nameUrdu,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.goldPrimary : const Color(0xFF92400E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            book.nameEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // "Setup" Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: navigateToSetup,
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
                              Icon(Icons.tune_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Setup',
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
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Middle Row: Term Badge, Category Badge, Practical Tag (Zero-Overflow Wrap)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Term Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.goldPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            book.term == 'FULL_YEAR'
                                ? 'Full Session'
                                : (book.term == 'TERM_1' ? 'First Semester' : 'Second Semester'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isDeeni
                                ? AppColors.emeraldPrimary.withValues(alpha: 0.12)
                                : AppColors.goldPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDeeni
                                  ? AppColors.emeraldPrimary.withValues(alpha: 0.3)
                                  : AppColors.goldPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isDeeni ? 'دینی Deeni' : 'عصری Asri',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDeeni ? AppColors.emeraldPrimary : AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Practical indicator tag
                    if (hasPractical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${book.practicalMarks} Practical',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      )
                    else
                      Text(
                        'No Practical',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Metrics Strip: Max, Pass, Theory
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricItem(
                          label: 'Total Marks',
                          value: '${book.maxMarks}',
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                      _Divider(isDark: isDark),
                      Expanded(
                        child: _MetricItem(
                          label: 'Passing',
                          value: '${book.passMarks}',
                          color: AppColors.emeraldPrimary,
                        ),
                      ),
                      _Divider(isDark: isDark),
                      Expanded(
                        child: _MetricItem(
                          label: 'Theory',
                          value: '${book.theoryMarks}',
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      _Divider(isDark: isDark),
                      Expanded(
                        child: _MetricItem(
                          label: 'Practical',
                          value: hasPractical ? '${book.practicalMarks}' : '0',
                          color: hasPractical ? Colors.amber : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                    ],
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

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
