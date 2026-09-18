import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/branding/image_source_picker_sheet.dart';

class InstituteBannerCard extends StatelessWidget {
  const InstituteBannerCard({
    super.key,
    required this.model,
    required this.onPickBanner,
    this.localBannerPath,
    this.isUploadingBanner = false,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<File> onPickBanner;
  final String? localBannerPath;
  final bool isUploadingBanner;

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
                    const Icon(Icons.panorama_rounded, size: 16, color: Color(0xFFC084FC)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Campus Hero Banner',
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
                  color: const Color(0xFFC084FC).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '16:9 Wide',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFC084FC)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Atmospheric header backdrop on App home & Portal prospectus.',
            style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: isUploadingBanner ? null : () => ImageSourcePickerSheet.show(context, onPickBanner),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.35)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildBannerPreview()),
                    Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isUploadingBanner)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          else
                            const Icon(Icons.add_photo_alternate_rounded, size: 26, color: Colors.white),
                          const SizedBox(height: 4),
                          Text(
                            isUploadingBanner ? 'Uploading Banner...' : 'Change Campus Hero Banner',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const Text(
                            'Recommended 1920×640 or 16:9',
                            style: TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPreview() {
    if (localBannerPath != null && localBannerPath!.isNotEmpty) {
      final file = File(localBannerPath!);
      if (file.existsSync()) return Image.file(file, fit: BoxFit.cover);
    }
    if (model.bannerUrl.isNotEmpty && !model.bannerUrl.contains('default')) {
      return Image.network(
        model.bannerUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B1812)),
      );
    }
    return Container(color: const Color(0xFF1B1812));
  }
}
