import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_2fa_fields.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_card_header.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_form_fields.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_submit_button.dart';

/// Ultra-Premium Liquid Crystal Glass Bottom Sheet with 2FA support (< 130 lines).
class LoginBottomSheetCard extends StatefulWidget {
  const LoginBottomSheetCard({super.key});

  @override
  State<LoginBottomSheetCard> createState() => _LoginBottomSheetCardState();
}

class _LoginBottomSheetCardState extends State<LoginBottomSheetCard> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(LoginSubmitted(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface;
    final borderSideColor = isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            border: Border.all(color: borderSideColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.07),
                blurRadius: 36,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final is2FA = state is AuthRequires2FA;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x4DFFFFFF) : const Color(0x26000000),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LoginCardHeader(
                      title: is2FA ? context.tr('two_factor_title') : null,
                      subtitle: is2FA ? context.tr('two_factor_subtitle') : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (is2FA)
                      Login2FAFields(
                        tempToken: state.tempToken,
                        username: state.username,
                        isLoading: isLoading,
                      )
                    else ...[
                      Form(
                        key: _formKey,
                        child: LoginFormFields(
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          isLoading: isLoading,
                          rememberMe: _rememberMe,
                          onRememberMeChanged: (v) => setState(() => _rememberMe = v),
                          onSubmit: _submit,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LoginSubmitButton(isLoading: isLoading, onPressed: _submit),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
