import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_section_card.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_text_field.dart';

class StaffDocumentItem {
  const StaffDocumentItem({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;
}

const List<StaffDocumentItem> kStandardStaffDocs = [
  StaffDocumentItem(
    id: 'aadharCopy',
    title: 'Aadhaar Card Copy',
    icon: Icons.badge_outlined,
  ),
  StaffDocumentItem(
    id: 'sanadDegree',
    title: 'Sanad / Degree Copy',
    icon: Icons.school_outlined,
  ),
  StaffDocumentItem(
    id: 'bankPassbook',
    title: 'Bank Passbook Copy',
    icon: Icons.account_balance_outlined,
  ),
  StaffDocumentItem(
    id: 'expCertificate',
    title: 'Experience Certificate',
    icon: Icons.verified_outlined,
  ),
  StaffDocumentItem(
    id: 'passportPhotos',
    title: '4 Passport Photos',
    icon: Icons.photo_library_outlined,
  ),
  StaffDocumentItem(
    id: 'otherDoc',
    title: 'Other Document',
    icon: Icons.note_add_outlined,
  ),
];

/// Luxury Verification Checklist Section for Staff Submitted Documents (< 160 lines).
/// Perfectly harmonized with the Champagne Gold & Velvet Obsidian design system.
class StaffDocumentsSection extends StatelessWidget {
  const StaffDocumentsSection({
    super.key,
    required this.selectedDocIds,
    required this.onToggleDoc,
    required this.otherDocController,
    this.sectionNumber = '5',
  });

  final Set<String> selectedDocIds;
  final ValueChanged<String> onToggleDoc;
  final TextEditingController otherDocController;
  final String sectionNumber;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCount = kStandardStaffDocs.length;
    final selectedCount = selectedDocIds.length;

    return AdmissionSectionCard(
      icon: Icons.fact_check_rounded,
      title: '$sectionNumber. Submitted Documents',
      subtitle: 'Office registration verification & compliance checklist',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Completion Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document Deposit Checklist *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 11,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$selectedCount of $totalCount Verified',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Grid of 6 Standard Documents
          for (int i = 0; i < 6; i += 2) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDocChip(
                    doc: kStandardStaffDocs[i],
                    isChecked: selectedDocIds.contains(kStandardStaffDocs[i].id),
                    isDark: isDark,
                    onTap: () => onToggleDoc(kStandardStaffDocs[i].id),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDocChip(
                    doc: kStandardStaffDocs[i + 1],
                    isChecked: selectedDocIds.contains(kStandardStaffDocs[i + 1].id),
                    isDark: isDark,
                    onTap: () => onToggleDoc(kStandardStaffDocs[i + 1].id),
                  ),
                ),
              ],
            ),
            if (i < 4) const SizedBox(height: 8),
          ],

          // Other Document Name Input (Shows only when otherDoc is checked)
          if (selectedDocIds.contains('otherDoc')) ...[
            const SizedBox(height: 10),
            AdmissionTextField(
              label: 'Specify Other Document Name',
              controller: otherDocController,
              hint: 'e.g. PAN Card, Character Certificate, Appointment Order...',
              suffixIcon: const Icon(
                Icons.description_rounded,
                size: 16,
                color: AppColors.goldPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocChip({
    required StaffDocumentItem doc,
    required bool isChecked,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.goldPrimary
              : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isChecked
                ? AppColors.goldChampagne
                : (isDark ? Colors.white12 : Colors.black12),
            width: 0.9,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Luxury Checkbox Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: isChecked ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked
                      ? Colors.white
                      : (isDark ? Colors.white24 : Colors.black26),
                  width: 1.1,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.goldDark,
                    )
                  : null,
            ),
            const SizedBox(width: 7),

            // Icon
            Icon(
              doc.icon,
              size: 15,
              color: isChecked
                  ? Colors.white
                  : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
            ),
            const SizedBox(width: 6),

            // Document Title
            Expanded(
              child: Text(
                doc.title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                  color: isChecked
                      ? Colors.white
                      : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
