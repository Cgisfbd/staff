import 'package:flutter/material.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Luxury Glassmorphic Bottom Sheets for Privacy Policy, About Us, and Contact Desk (< 175 lines).
class LegalInfoSheets {
  LegalInfoSheets._();

  static void showPrivacyPolicy(BuildContext context) {
    _showSheet(
      context,
      title: context.tr('settings_privacy_modal_title'),
      icon: Icons.privacy_tip_rounded,
      content: const [
        _InfoSection(
          title: '1. Single-Institute Dedicated VPS Model',
          body:
              'TaleemOne ERP is deployed strictly on a dedicated institutional server. Student and staff records are physically isolated with zero shared multi-tenant database overhead.',
        ),
        _InfoSection(
          title: '2. Hardware AES-256 Enclave Encryption',
          body:
              'All cached offline records, tokens, and biometric descriptors are encrypted using hardware-backed Android Keystore and iOS Keychain enclaves.',
        ),
        _InfoSection(
          title: '3. Zero Data Sharing or Commercial Monetization',
          body:
              'Student, parent, financial, and attendance records are 100% confidential and owned entirely by the institution. No data is shared with third-party advertising networks.',
        ),
        _InfoSection(
          title: '4. Institutional Access Governance',
          body:
              'Access is governed by 3 internal roles (Super Admin, Admin, Staff) with audited change trails and cryptographic HMAC verification.',
        ),
      ],
    );
  }

  static void showAboutUs(BuildContext context) {
    _showSheet(
      context,
      title: context.tr('settings_about_modal_title'),
      icon: Icons.info_rounded,
      content: [
        const _InfoSection(
          title: '${AppConfig.appName} — ${AppConfig.appSubTitle}',
          body:
              'An enterprise-grade, high-performance academic management ecosystem engineered specifically for modern universities, schools, and madarsas.',
        ),
        _InfoSection(
          title: context.tr('settings_engineering_title'),
          body:
              '${AppConfig.platformAuthority}\nBuilt with FAANG-grade Clean Architecture, Feature-Sliced Design, and hardware-accelerated Liquid Crystal Glassmorphism.',
        ),
        _InfoSection(
          title: context.tr('settings_platform_version'),
          body: 'Client: v1.0.0+1 (Enclave Shielded)\nRuntime: Flutter 3.29+ / BLoC 8.1.6\nSecurity: Keystore Tier-9 Armor',
        ),
      ],
    );
  }

  static void showContactUs(BuildContext context) {
    _showSheet(
      context,
      title: context.tr('settings_contact_modal_title'),
      icon: Icons.support_agent_rounded,
      content: [
        _InfoSection(
          title: context.tr('settings_institutional_helpline'),
          body: '📞 +91 98765 43210\nAvailable Mon-Sat, 9:00 AM - 5:00 PM IST',
        ),
        _InfoSection(
          title: context.tr('settings_whatsapp_support'),
          body: '💬 +91 98765 43210\nInstant operational support & ticket resolution',
        ),
        _InfoSection(
          title: context.tr('settings_support_email'),
          body: '✉️ support@barkattech.com\nFor bug reports, server diagnostics & escalations',
        ),
        _InfoSection(
          title: context.tr('settings_campus_it'),
          body: '🏛️ Central Administrative Office, Main Campus\nContact your Super Admin for credential resets.',
        ),
      ],
    );
  }

  static void _showSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_InfoSection> content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(icon, color: AppColors.goldPrimary, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
