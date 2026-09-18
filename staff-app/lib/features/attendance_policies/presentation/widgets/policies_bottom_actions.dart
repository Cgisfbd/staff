import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_state.dart';

class PoliciesBottomActions extends StatelessWidget {
  const PoliciesBottomActions({
    super.key,
    required this.status,
    required this.onResetDefaults,
    required this.onSave,
  });

  final AttendancePoliciesStatus status;
  final VoidCallback onResetDefaults;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaving = status == AttendancePoliciesStatus.saving;
    final isSaved = status == AttendancePoliciesStatus.saved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          // Reset Button
          OutlinedButton.icon(
            onPressed: isSaving ? null : onResetDefaults,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
            label: Text(
              'Reset Defaults',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Save Button CTA
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
                          ? 'Saving Rules...'
                          : isSaved
                              ? 'Rules Saved'
                              : 'Save Rules & Thresholds',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
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
