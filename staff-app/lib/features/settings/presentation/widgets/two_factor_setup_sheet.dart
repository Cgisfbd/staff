import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';

/// Luxury Frosted Bottom Sheet for setting up Google Authenticator 2FA (< 180 lines).
class TwoFactorSetupSheet extends StatefulWidget {
  const TwoFactorSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: const TwoFactorSetupSheet(),
      ),
    );
  }

  @override
  State<TwoFactorSetupSheet> createState() => _TwoFactorSetupSheetState();
}

class _TwoFactorSetupSheetState extends State<TwoFactorSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  String? _secret;
  bool _isGenerating = true;
  bool _isVerifying = false;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _generateSecret() async {
    setState(() {
      _isGenerating = true;
      _fetchError = null;
    });

    final res = await context.read<ProfileCubit>().generate2FA();
    if (!mounted) return;

    if (res != null && res['secret'] != null) {
      setState(() {
        _secret = res['secret']?.toString();
        _isGenerating = false;
      });
    } else {
      final err = context.read<ProfileCubit>().state.errorMessage ?? 'Failed to initialize 2FA';
      setState(() {
        _fetchError = err;
        _isGenerating = false;
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);
    final success = await context.read<ProfileCubit>().verify2FA(_otpController.text.trim());

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(context, context.tr('settings_2fa_enabled_success'));
    } else {
      final err = context.read<ProfileCubit>().state.errorMessage ?? 'Invalid verification code';
      AppSnackBar.showError(context, err);
    }
  }

  void _copyKey() {
    if (_secret == null || _secret!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _secret!));
    AppSnackBar.showSuccess(context, context.tr('settings_2fa_key_copied'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, bottomInset + AppSpacing.xl),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phonelink_lock_rounded, color: AppColors.goldPrimary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.tr('settings_two_factor'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isGenerating) ...[
                const SizedBox(height: 30),
                const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Generating Google Authenticator Key...',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ] else if (_fetchError != null) ...[
                const SizedBox(height: 20),
                Text(
                  _fetchError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _generateSecret,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                  child: Text(context.tr('common_retry'), style: const TextStyle(color: Colors.white)),
                ),
              ] else ...[
                Text(
                  context.tr('settings_2fa_setup_desc'),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C2433).withValues(alpha: 0.85)
                        : const Color(0xFFF7F5F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _secret ?? '',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      InkWell(
                        onTap: _copyKey,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.copy_rounded, size: 14, color: AppColors.goldPrimary),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('settings_2fa_copy_key'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) => (v == null || v.trim().length != 6)
                      ? 'Enter 6-digit authenticator code'
                      : null,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: context.tr('settings_2fa_enter_code'),
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isVerifying ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(context.tr('settings_2fa_verify_btn'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
