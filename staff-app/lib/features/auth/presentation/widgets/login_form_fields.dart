import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Form fields for username, password, and remember me toggle (< 130 lines).
class LoginFormFields extends StatefulWidget {
  const LoginFormFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onSubmit,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSubmit;

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.usernameController,
          enabled: !widget.isLoading,
          textInputAction: TextInputAction.next,
          cursorColor: isDark ? AppColors.goldLight : AppColors.goldPrimary,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: context.tr('username_label'),
            hintText: context.tr('username_hint'),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              size: 19,
              color: isDark ? AppColors.textDarkMuted : AppColors.charcoalDark.withValues(alpha: 0.60),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('username_required') : null,
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        TextFormField(
          controller: widget.passwordController,
          enabled: !widget.isLoading,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          cursorColor: isDark ? AppColors.goldLight : AppColors.goldPrimary,
          onFieldSubmitted: (_) => widget.onSubmit(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: context.tr('password_label'),
            hintText: context.tr('password_hint'),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 19,
              color: isDark ? AppColors.textDarkMuted : AppColors.charcoalDark.withValues(alpha: 0.60),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 19,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('password_required') : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: widget.rememberMe,
                      activeColor: isDark ? AppColors.goldPrimary : AppColors.charcoalDark,
                      checkColor: Colors.white,
                      side: BorderSide(
                        color: isDark ? AppColors.darkGlassBorder : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: widget.isLoading ? null : (v) => widget.onRememberMeChanged(v ?? true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Flexible(
                    child: Text(
                      context.tr('remember_me'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                context.tr('need_help'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
