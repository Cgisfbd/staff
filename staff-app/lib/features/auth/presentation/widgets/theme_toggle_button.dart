import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';

/// Ultra-Premium Frosted Liquid Crystal Glass Theme Toggle Button (< 60 lines).
/// Switches smoothly between Warm Off-White Light mode and Obsidian Dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, _) {
        return Tooltip(
          message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0x33000000) : const Color(0x14000000),
                  border: Border.all(
                    color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      key: ValueKey<bool>(isDark),
                      size: 17,
                      color: isDark ? AppColors.goldBright : AppColors.goldDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
