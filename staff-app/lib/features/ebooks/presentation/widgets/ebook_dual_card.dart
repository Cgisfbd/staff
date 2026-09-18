import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';
import 'package:staff_app/features/ebooks/data/datasources/ebooks_datasource.dart';
import 'package:staff_app/features/ebooks/domain/models/ebook_bundle_model.dart';
import 'package:staff_app/features/ebooks/presentation/widgets/pdf_first_page_cover.dart';

/// Ultra-Luxury Dual-Book Card matching the app's signature card design (< 220 lines).
/// Renders authentic first-page PDF document covers side-by-side
/// with full book titles and PDF reader actions positioned underneath.
class EbookDualCard extends StatelessWidget {
  const EbookDualCard({
    super.key,
    required this.bundle,
  });

  final EBookBundleModel bundle;

  void _openPdf({
    required BuildContext context,
    required String title,
    required String author,
    required String editionBadge,
    required String language,
    required int totalPages,
    required bool isTranslation,
  }) {
    final sanitizedFileName =
        '${title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')}.pdf';

    GlobalPdfViewer.open<void>(
      context,
      title: title,
      fileName: sanitizedFileName,
      subtitle: language,
      pdfBytesFuture: () => EbooksDatasource.generateBookPdf(
        title: title,
        author: author,
        subject: bundle.subjectName,
        editionBadge: editionBadge,
        language: language,
        totalPages: totalPages,
        isTranslation: isTranslation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(12),
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
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Card Header: Subject Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      bundle.localizedSubject(isRtl, context.currentLanguageCode, context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hairline separator
              Container(
                height: 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Main Row: 2 Authentic PDF First-Page Previews Side-by-Side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Book: Main Original PDF (اصل متن)
                  Expanded(
                    child: _buildBookColumn(
                      context: context,
                      isDark: isDark,
                      isRtl: isRtl,
                      accentColor: const Color(0xFFB45309), // Amber-Gold
                      cacheKey: '${bundle.id}_main',
                      pdfBytesFuture: () => EbooksDatasource.generateBookPdf(
                        title: bundle.mainBookTitle,
                        author: bundle.mainBookAuthor,
                        subject: bundle.subjectName,
                        editionBadge: bundle.mainBookBadge,
                        language: bundle.mainBookLanguage,
                        totalPages: bundle.mainBookPages,
                        isTranslation: false,
                      ),
                      bookTitle: bundle.localizedMainTitle(isRtl, context.currentLanguageCode, context),
                      onTap: () => _openPdf(
                        context: context,
                        title: bundle.mainBookTitle,
                        author: bundle.mainBookAuthor,
                        editionBadge: bundle.mainBookBadge,
                        language: bundle.mainBookLanguage,
                        totalPages: bundle.mainBookPages,
                        isTranslation: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Right Book: Translation & Sharh PDF (ترجمہ و تشریح)
                  Expanded(
                    child: _buildBookColumn(
                      context: context,
                      isDark: isDark,
                      isRtl: isRtl,
                      accentColor: const Color(0xFF059669), // Emerald
                      cacheKey: '${bundle.id}_trans',
                      pdfBytesFuture: () => EbooksDatasource.generateBookPdf(
                        title: bundle.transBookTitle,
                        author: bundle.transBookAuthor,
                        subject: bundle.subjectName,
                        editionBadge: bundle.transBookBadge,
                        language: bundle.transBookLanguage,
                        totalPages: bundle.transBookPages,
                        isTranslation: true,
                      ),
                      bookTitle: bundle.localizedTransTitle(isRtl, context.currentLanguageCode, context),
                      onTap: () => _openPdf(
                        context: context,
                        title: bundle.transBookTitle,
                        author: bundle.transBookAuthor,
                        editionBadge: bundle.transBookBadge,
                        language: bundle.transBookLanguage,
                        totalPages: bundle.transBookPages,
                        isTranslation: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookColumn({
    required BuildContext context,
    required bool isDark,
    required bool isRtl,
    required Color accentColor,
    required String cacheKey,
    required Future<Uint8List> Function() pdfBytesFuture,
    required String bookTitle,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Exact PDF First-Page Cover Preview
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: PdfFirstPageCover(
              cacheKey: cacheKey,
              pdfBytesFuture: pdfBytesFuture,
              accentColor: accentColor,
              width: 124,
              height: 174,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 2. Text Content Positioned Underneath PDF First-Page Preview
        Text(
          bookTitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.25,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),

        // Action Button: Open PDF
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.20),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.40),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 13, color: accentColor),
                  const SizedBox(width: 5),
                  Text(
                    context.tr('read_pdf_action'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
