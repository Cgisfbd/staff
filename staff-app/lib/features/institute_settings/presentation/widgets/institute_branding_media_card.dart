import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/branding/institute_banner_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/branding/institute_logo_card.dart';

class InstituteBrandingMediaCard extends StatelessWidget {
  const InstituteBrandingMediaCard({
    super.key,
    required this.model,
    required this.onPickLogo,
    required this.onPickBanner,
    this.localLogoPath,
    this.localBannerPath,
    this.isUploadingLogo = false,
    this.isUploadingBanner = false,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<File> onPickLogo;
  final ValueChanged<File> onPickBanner;
  final String? localLogoPath;
  final String? localBannerPath;
  final bool isUploadingLogo;
  final bool isUploadingBanner;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.palette_outlined, size: 16, color: AppColors.goldPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Media & Crest Branding',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        InstituteLogoCard(
          model: model,
          localLogoPath: localLogoPath,
          isUploadingLogo: isUploadingLogo,
          onPickLogo: onPickLogo,
        ),
        const SizedBox(height: 12),
        InstituteBannerCard(
          model: model,
          localBannerPath: localBannerPath,
          isUploadingBanner: isUploadingBanner,
          onPickBanner: onPickBanner,
        ),
      ],
    );
  }
}
