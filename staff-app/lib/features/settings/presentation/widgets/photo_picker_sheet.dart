import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Ultra-Luxury Bottom Sheet for selecting photo source (Camera or Gallery) (< 160 lines).
/// Returns the selected [ImageSource] to the caller so the caller's mounted context
/// handles the subsequent crop dialog and upload seamlessly.
class PhotoPickerSheet extends StatelessWidget {
  const PhotoPickerSheet({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (_) => const PhotoPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = math.max(MediaQuery.of(context).viewPadding.bottom, 16.0);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldPrimary, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 17),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.tr('settings_change_photo'),
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Select source to capture or choose a new profile photo',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Option 1: Camera
            _buildSourceTile(
              context,
              icon: Icons.camera_alt_rounded,
              title: context.tr('settings_take_photo'),
              subtitle: context.tr('settings_take_photo_sub'),
              colors: const [AppColors.goldPrimary, AppColors.goldDark],
              borderColor: AppColors.goldChampagne,
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Option 2: Gallery
            _buildSourceTile(
              context,
              icon: Icons.photo_library_rounded,
              title: context.tr('settings_choose_gallery'),
              subtitle: context.tr('settings_choose_gallery_sub'),
              colors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              borderColor: const Color(0xFF60A5FA),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  context.tr('cancel'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required Color borderColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C2433).withValues(alpha: 0.75)
              : const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.22),
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 19, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ],
        ),
      ),
    );
  }
}
