import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/branding/image_source_picker_sheet.dart';

class InstituteLogoCard extends StatelessWidget {
  const InstituteLogoCard({
    super.key,
    required this.model,
    required this.onPickLogo,
    this.localLogoPath,
    this.isUploadingLogo = false,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<File> onPickLogo;
  final String? localLogoPath;
  final bool isUploadingLogo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.image_rounded, size: 16, color: AppColors.goldPrimary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Official Institute Logo',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'High-Res',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.goldPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Used for fee receipts, admit cards, marksheets & portal header.',
            style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: isUploadingLogo ? null : () => ImageSourcePickerSheet.show(context, onPickLogo),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF262C36) : Colors.white,
                      border: Border.all(color: AppColors.goldPrimary),
                    ),
                    child: ClipOval(child: _buildLogoPreview()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isUploadingLogo)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldPrimary),
                              )
                            else
                              const Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.goldPrimary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isUploadingLogo ? 'Uploading Logo...' : 'Upload Official Logo',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Supports PNG, JPG, WEBP (Max 5MB)',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 10, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.goldPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPreview() {
    if (localLogoPath != null && localLogoPath!.isNotEmpty) {
      final file = File(localLogoPath!);
      if (file.existsSync()) return Image.file(file, fit: BoxFit.contain);
    }
    if (model.logoUrl.isNotEmpty && !model.logoUrl.contains('default')) {
      return Image.network(
        model.logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: AppColors.goldPrimary),
      );
    }
    return const Icon(Icons.account_balance, color: AppColors.goldPrimary);
  }
}
