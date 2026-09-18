import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Ultra-Premium Frosted Language Selector Toggle (< 85 lines).
/// Pure Liquid Glassmorphism with Zero Blue channels.
class LanguageSelectorPills extends StatelessWidget {
  const LanguageSelectorPills({super.key});

  static const _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ur', 'label': 'اردو'},
    {'code': 'hi', 'label': 'हिन्दी'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x33000000) : const Color(0x1F000000),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 4),
                  child: Icon(
                    Icons.language_rounded,
                    size: 14,
                    color: isDark ? AppColors.goldChampagne : AppColors.charcoalDark,
                  ),
                ),
                ..._languages.map((lang) {
                  final isSelected = state.languageCode == lang['code'];

                  return GestureDetector(
                    onTap: () => context.read<LocaleCubit>().setLocale(lang['code']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.goldPrimary : AppColors.charcoalDark)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: isDark
                                      ? AppColors.goldPrimary.withValues(alpha: 0.35)
                                      : AppColors.charcoalDark.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        lang['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
