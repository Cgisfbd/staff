import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';

/// Modal bottom sheet for changing server security PIN (< 150 lines).
class ChangePinSheet extends StatefulWidget {
  const ChangePinSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: const ChangePinSheet(),
      ),
    );
  }

  @override
  State<ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends State<ChangePinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPinController.text != _confirmPinController.text) {
      AppSnackBar.showError(context, 'New PINs do not match');
      return;
    }

    setState(() => _isLoading = true);

    final currentPinText = _currentPinController.text.trim();
    final newPinText = _newPinController.text.trim();
    final success = await context.read<ProfileCubit>().changePin(
          password: _passwordController.text.trim(),
          newPin: newPinText,
          currentPin: currentPinText.isNotEmpty ? currentPinText : null,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await context.read<AppLockCubit>().setLocalPin(newPinText);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(context, context.tr('settings_pin_changed'));
    } else {
      final err = context.read<ProfileCubit>().state.errorMessage ?? 'PIN update failed';
      AppSnackBar.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, bottomInset + bottomPadding + AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(Icons.dialpad_rounded, color: AppColors.goldPrimary, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.tr('settings_change_pin'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildPinField(
                  controller: _currentPinController,
                  label: context.tr('settings_current_pin'),
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPinField(
                  controller: _newPinController,
                  label: context.tr('settings_new_pin'),
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPinField(
                  controller: _confirmPinController,
                  label: context.tr('settings_confirm_pin'),
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Password required for verification' : null,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: context.tr('settings_current_password'),
                    labelStyle: TextStyle(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, fontSize: 13),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.goldPrimary),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5)),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.tr('settings_save_changes'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: (v) => (v == null || v.trim().length != 6) ? context.tr('settings_pin_invalid') : null,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, letterSpacing: 4),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, fontSize: 13, letterSpacing: 0),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5)),
      ),
    );
  }
}
