import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Ultra-Luxury Student Photo Picker Card matching ERP Web interface.
class AdmissionPhotoCard extends StatelessWidget {
  const AdmissionPhotoCard({
    super.key,
    required this.photoPath,
    required this.onPhotoSelected,
    required this.onPhotoRemoved,
  });

  final String? photoPath;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onPhotoRemoved;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked != null) {
        onPhotoSelected(picked.path);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo Frame Medallion
          Stack(
            children: [
              Container(
                width: 105,
                height: 125,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x330F172A)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasPhoto
                        ? AppColors.goldPrimary
                        : AppColors.goldPrimary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: hasPhoto
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          width: 105,
                          height: 125,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 28,
                                color: isDark
                                    ? AppColors.goldChampagne
                                    : AppColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.tr('admission_field_photo'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Delete button if photo exists
              if (hasPhoto)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: onPhotoRemoved,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statusAbsent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Action Buttons: Camera & Upload
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera Button
              InkWell(
                onTap: () => _pickImage(context, ImageSource.camera),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 13,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('admission_field_take_photo'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Gallery Upload Button
              InkWell(
                onTap: () => _pickImage(context, ImageSource.gallery),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2BFFFFFF) : const Color(0x0F000000),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        size: 13,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('admission_field_upload_photo'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
