import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_event.dart';

/// Ultra-Premium 2FA Verification Form Fields (< 120 lines).
class Login2FAFields extends StatefulWidget {
  const Login2FAFields({
    super.key,
    required this.tempToken,
    required this.username,
    required this.isLoading,
  });

  final String tempToken;
  final String username;
  final bool isLoading;

  @override
  State<Login2FAFields> createState() => _Login2FAFieldsState();
}

class _Login2FAFieldsState extends State<Login2FAFields> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            Verify2FASubmitted(
              tempToken: widget.tempToken,
              otp: _otpController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _otpController,
            enabled: !widget.isLoading,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            maxLength: 6,
            cursorColor: isDark ? AppColors.goldLight : AppColors.goldPrimary,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8.0),
            decoration: InputDecoration(
              counterText: '',
              labelText: context.tr('otp_label'),
              hintText: context.tr('otp_hint'),
              prefixIcon: Icon(
                Icons.security_rounded,
                size: 20,
                color: isDark ? AppColors.goldChampagne : AppColors.charcoalDark,
              ),
            ),
            onFieldSubmitted: (_) => _submit(),
            validator: (v) => (v == null || v.trim().length != 6) ? context.tr('otp_required') : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [AppColors.goldPrimary, AppColors.goldDark]
                    : const [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: AppSpacing.roundedMd,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.goldPrimary.withValues(alpha: 0.35)
                      : const Color(0xFF0F172A).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppSpacing.roundedMd,
                onTap: widget.isLoading ? null : _submit,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : Text(
                          context.tr('verify_button'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: widget.isLoading
                ? null
                : () => context.read<AuthBloc>().add(const ResetToLogin()),
            child: Text(
              context.tr('back_to_login'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
