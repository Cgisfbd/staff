import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_state.dart';

class InstituteSaveBottomBar extends StatelessWidget {
  const InstituteSaveBottomBar({
    super.key,
    required this.status,
    required this.isDirty,
    required this.onReset,
    required this.onSave,
  });

  final InstituteSettingsStatus status;
  final bool isDirty;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaving = status == InstituteSettingsStatus.saving;
    final isSaved = status == InstituteSettingsStatus.saved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset Button
          OutlinedButton.icon(
            onPressed: (isSaving || !isDirty) ? null : onReset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              side: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.restart_alt_rounded,
              size: 16,
              color: isDirty
                  ? (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)
                  : (isDark ? Colors.white24 : Colors.black26),
            ),
            label: Text(
              'Reset',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDirty
                    ? (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Save Changes CTA
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSaving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else if (isSaved)
                    const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white)
                  else
                    const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isSaving
                          ? 'Saving Changes...'
                          : isSaved
                              ? 'Profile Saved'
                              : 'Save Institute Profile',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
