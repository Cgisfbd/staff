import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/auth/presentation/widgets/language_selector_dropdown.dart';
import 'package:staff_app/features/auth/presentation/widgets/theme_toggle_button.dart';

/// Ultra-Premium Top Bar with Theme Toggle and Language Dropdown (< 40 lines).
/// Positioned at the very top of the login screen for effortless customization.
class LoginTopBar extends StatelessWidget {
  const LoginTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ThemeToggleButton(),
          SizedBox(width: AppSpacing.sm),
          LanguageSelectorDropdown(),
        ],
      ),
    );
  }
}
