import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'package:staff_app/features/settings/presentation/widgets/legal_info_sheets.dart';

/// Ultra-Premium Glassmorphic Legal & Institutional Information Card (< 180 lines).
class SettingsLegalCard extends StatelessWidget {
  const SettingsLegalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      customFillColor: isDark
          ? const Color(0xFF131A26).withValues(alpha: 0.78)
          : Colors.white.withValues(alpha: 0.88),
      customBorderColor: AppColors.goldPrimary.withValues(alpha: isDark ? 0.32 : 0.25),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Section Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.tr('settings_legal_section'),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.goldPrimary.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Privacy Policy
          _buildActionTile(
            context,
            icon: Icons.privacy_tip_rounded,
            title: context.tr('settings_privacy_policy'),
            subtitle: context.tr('settings_privacy_subtitle'),
            onTap: () => LegalInfoSheets.showPrivacyPolicy(context),
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),

          // About Us
          _buildActionTile(
            context,
            icon: Icons.info_outline_rounded,
            title: context.tr('settings_about_us'),
            subtitle: context.tr('settings_about_subtitle'),
            onTap: () => LegalInfoSheets.showAboutUs(context),
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Contact Us
          _buildActionTile(
            context,
            icon: Icons.headset_mic_rounded,
            title: context.tr('settings_contact_us'),
            subtitle: context.tr('settings_contact_subtitle'),
            onTap: () => LegalInfoSheets.showContactUs(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C2433).withValues(alpha: 0.65)
              : const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.20),
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.3,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                    maxLines: 2,
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
