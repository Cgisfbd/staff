import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Ultra-Premium Liquid Crystal Glass Language Dropdown (< 105 lines).
/// Features a compact frosted capsule trigger and frosted popup menu with checkmarks.
class LanguageSelectorDropdown extends StatelessWidget {
  const LanguageSelectorDropdown({super.key});

  static const _languages = [
    {'code': 'en', 'label': 'English', 'sub': 'English'},
    {'code': 'ur', 'label': 'اردو', 'sub': 'Urdu'},
    {'code': 'hi', 'label': 'हिन्दी', 'sub': 'Hindi'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final currentLang = _languages.firstWhere(
          (l) => l['code'] == state.languageCode,
          orElse: () => _languages.first,
        );

        return Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: isDark ? AppColors.darkModalSurface : AppColors.lightModalSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                  width: 1.0,
                ),
              ),
              elevation: 16,
              shadowColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
            ),
          ),
          child: PopupMenuButton<String>(
            tooltip: 'Language',
            offset: const Offset(0, 36),
            position: PopupMenuPosition.under,
            onSelected: (code) => context.read<LocaleCubit>().setLocale(code),
            itemBuilder: (context) => _languages.map((lang) {
              final isSelected = lang['code'] == state.languageCode;
              return PopupMenuItem<String>(
                value: lang['code'],
                height: 42,
                child: SizedBox(
                  width: 140,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          lang['label']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? AppColors.goldLight : AppColors.goldPrimary)
                                : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${lang['sub']})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: isDark ? AppColors.goldLight : AppColors.goldPrimary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33000000) : const Color(0x14000000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 15,
                    color: isDark ? AppColors.goldLight : AppColors.goldPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentLang['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
