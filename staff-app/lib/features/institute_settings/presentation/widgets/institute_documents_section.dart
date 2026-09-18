import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/documents/institute_document_accordion_tile.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/documents/multilingual_paragraph_editor_sheet.dart';

class InstituteDocumentsSection extends StatelessWidget {
  const InstituteDocumentsSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<InstituteSettingsUiModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 18, color: Colors.indigoAccent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'INSTITUTIONAL DOCUMENTS & RULES',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InstituteDocumentAccordionTile(
            title: 'About Us',
            description: 'Core institutional overview and objectives.',
            icon: Icons.history_edu_rounded,
            paragraphs: model.aboutUs,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'About Us',
              paragraphs: model.aboutUs,
              onSave: (list) => onChanged(model.copyWith(aboutUs: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: 'Institute Introduction',
            description: 'Campus facilities and historical background.',
            icon: Icons.domain_rounded,
            paragraphs: model.instituteIntroduction,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'Institute Introduction',
              paragraphs: model.instituteIntroduction,
              onSave: (list) => onChanged(model.copyWith(instituteIntroduction: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: "Founder's Message",
            description: 'Official welcome message from the Principal.',
            icon: Icons.format_quote_rounded,
            paragraphs: model.founderMessage,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: "Founder's Message",
              paragraphs: model.founderMessage,
              onSave: (list) => onChanged(model.copyWith(founderMessage: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: 'Student Code of Conduct',
            description: 'Rules regarding campus discipline and dress code.',
            icon: Icons.school_rounded,
            paragraphs: model.studentRules,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'Student Code of Conduct',
              paragraphs: model.studentRules,
              onSave: (list) => onChanged(model.copyWith(studentRules: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: 'Parent Guidelines',
            description: 'Policies on visiting hours and student progress.',
            icon: Icons.family_restroom_rounded,
            paragraphs: model.parentRules,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'Parent Guidelines',
              paragraphs: model.parentRules,
              onSave: (list) => onChanged(model.copyWith(parentRules: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: 'Staff Regulations',
            description: 'Faculty responsibilities and code of ethics.',
            icon: Icons.badge_rounded,
            paragraphs: model.staffRules,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'Staff Regulations',
              paragraphs: model.staffRules,
              onSave: (list) => onChanged(model.copyWith(staffRules: list)),
            ),
          ),
          InstituteDocumentAccordionTile(
            title: 'Privacy Policy',
            description: 'Data protection and portal terms of use.',
            icon: Icons.security_rounded,
            paragraphs: model.privacyPolicy,
            onEditParagraphs: () => MultilingualParagraphEditorSheet.show(
              context,
              title: 'Privacy Policy',
              paragraphs: model.privacyPolicy,
              onSave: (list) => onChanged(model.copyWith(privacyPolicy: list)),
            ),
          ),
        ],
      ),
    );
  }
}
