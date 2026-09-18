import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';

/// Top Brand Area of Login Screen (< 80 lines).
/// Pure Liquid Crystal Glass Emblem with TaleemOne Amber Gold Accent.
class LoginTopHeader extends StatelessWidget {
  const LoginTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Zero Network UI Lag: Read strictly from Hive AES-256 encrypted cache
    final rawSettings = sl<HiveService>().cacheBox.get('institute_settings_cache');
    InstituteSettingsUiModel? settings;
    if (rawSettings is Map) {
      settings = InstituteSettingsUiModel.fromJson(Map<String, dynamic>.from(rawSettings));
    }
    
    final appName = settings?.nameEn.isNotEmpty == true ? settings!.nameEn : context.tr('app_name');
    final logoUrl = settings?.logoUrl;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pure Liquid Crystal Glass Logo Sphere
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x33FFFFFF) : const Color(0x59FFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.20),
                      blurRadius: 28,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm + 2),

              // App Name (Dynamic)
              Text(
                appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 5),

              // Subtitle Badge: Staff Portal in TaleemOne Amber Gold Accent
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.40),
                    width: 1,
                  ),
                ),
                child: Text(
                  context.tr('staff_portal'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.goldLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
