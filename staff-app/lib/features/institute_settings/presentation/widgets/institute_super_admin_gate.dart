import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';

class InstituteSuperAdminGate extends StatelessWidget {
  const InstituteSuperAdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ExecutiveTopHeader(
                icon: Icons.arrow_back_rounded,
                title: 'Institute Settings',
                subtitle: 'Super Admin Authority Required',
                onIconTap: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.rosePrimary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.rosePrimary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 40,
                              color: AppColors.rosePrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Super Admin Authority Required',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Institute branding, profile details, and media assets can strictly only be managed by the Super Admin (Muhtamim / Principal).',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
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
