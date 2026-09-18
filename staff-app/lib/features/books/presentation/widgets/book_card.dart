import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/books/presentation/widgets/book_form_sheet.dart';
import 'package:staff_app/features/books/presentation/widgets/delete_book_dialog.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.subjects,
    required this.isAdmin,
  });

  final BookEntity book;
  final List<SubjectEntity> subjects;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDeeni = book.category == 'DEENI';

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
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Names + Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Icon Sphere
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isDeeni
                              ? [AppColors.emeraldDark, AppColors.emeraldPrimary]
                              : [AppColors.goldDark, AppColors.goldPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDeeni ? AppColors.emeraldPrimary : AppColors.goldPrimary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.collections_bookmark_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title Column (Shielded with Expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Urdu Kitab Title
                          if (book.nameUrdu.isNotEmpty)
                            Text(
                              book.nameUrdu,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.goldPrimary : const Color(0xFF92400E),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 2),

                          // English Book Title
                          Text(
                            book.nameEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => BookFormSheet.show(
                          context,
                          subjects: subjects,
                          existingBook: book,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.rosePrimary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => DeleteBookDialog.show(
                          context,
                          bookId: book.id,
                          bookName: book.nameEnglish,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Middle Row: Subject Pill + Category Badge + Term Pill
                Row(
                  children: [
                    // Subject Pill (Flexible with Ellipsis)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 12,
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                book.subjectName ?? 'Subject',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Category Badge (Deeni vs Asri)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

