import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/core/widgets/glass_card.dart';

/// Ultra-Luxury Glassmorphic Preferences Card (< 220 lines).
/// Features rich interactive Language & Theme selection cards with gold jewel accents.
class SettingsPreferencesCard extends StatelessWidget {
  const SettingsPreferencesCard({super.key});

  static const _languages = [
    {'code': 'en', 'label': 'English', 'sub': 'English', 'native': 'EN'},
    {'code': 'ur', 'label': 'اردو', 'sub': 'Urdu (RTL)', 'native': 'اردو'},
    {'code': 'hi', 'label': 'हिन्दी', 'sub': 'Hindi', 'native': 'हिन्दी'},
  ];

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
          // Section Header
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
                child: const Icon(Icons.palette_outlined, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.tr('settings_preferences_section'),
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
          const SizedBox(height: AppSpacing.md),

          // 1. Language Section Header
          Text(
            context.tr('settings_language'),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr('settings_lang_subtitle'),
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),

          // 3-Language Segmented Interactive Cards with Jewel UX
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return Row(
                children: _languages.map((lang) {
                  final isSelected = localeState.languageCode == lang['code'];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => context.read<LocaleCubit>().setLocale(lang['code']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                                    : const Color(0xFFFAF7F2)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldChampagne
                                  : AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.18),
                              width: isSelected ? 1.5 : 0.9,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      lang['label']!,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.textDarkPrimary
                                                : AppColors.textLightPrimary),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  lang['sub']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.92)
                                        : (isDark
                                            ? AppColors.textDarkSecondary
                                            : AppColors.textLightSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Theme Mode Section Header
          Text(
            context.tr('settings_theme_mode'),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr('settings_theme_subtitle'),
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2-Theme Side-by-Side Interactive Executive Cards
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isCurrentDark = themeMode == ThemeMode.dark;

              return Row(
                children: [
                  Expanded(
                    child: _buildThemeSelectionCard(
                      context,
                      title: context.tr('settings_theme_dark'),
                      caption: 'Dark Obsidian',
                      icon: Icons.nightlight_round,
                      isSelected: isCurrentDark,
                      isDark: isDark,
                      onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildThemeSelectionCard(
                      context,
                      title: context.tr('settings_theme_light'),
                      caption: 'Light Ivory',
                      icon: Icons.wb_sunny_rounded,
                      isSelected: !isCurrentDark,
                      isDark: isDark,
                      onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionCard(
    BuildContext context, {
    required String title,
    required String caption,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.20),
                    AppColors.goldDark.withValues(alpha: isDark ? 0.18 : 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? const Color(0xFF1C2433).withValues(alpha: 0.65)
                  : const Color(0xFFFAF7F2)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.goldPrimary
                : AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.18),
            width: isSelected ? 1.5 : 0.9,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Circular Medallion with Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [AppColors.goldPrimary, AppColors.goldDark]
                      : (isDark
                          ? const [Color(0xFF2A3447), Color(0xFF131A26)]
                          : const [Color(0xFFFFFDF9), Color(0xFFEDE5D5)]),
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.goldChampagne
                      : AppColors.goldPrimary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 17,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected
                          ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                          : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
