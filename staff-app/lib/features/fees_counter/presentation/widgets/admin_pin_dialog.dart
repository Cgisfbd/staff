import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class AdminPinDialog extends StatefulWidget {
  final ValueChanged<String> onPinVerified;

  const AdminPinDialog({super.key, required this.onPinVerified});

  @override
  State<AdminPinDialog> createState() => _AdminPinDialogState();
}

class _AdminPinDialogState extends State<AdminPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() {
        _error = 'PIN must be at least 4 digits';
      });
      return;
    }
    Navigator.of(context).pop();
    widget.onPinVerified(pin);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkModalSurface : Colors.white).withValues(alpha: isDark ? 0.88 : 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Medallion
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Admin Authorization PIN',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Fee concession / waive-off requires Mohtamim or Senior Admin authorization.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // PIN Input Field
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofocus: true,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    letterSpacing: 6,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  filled: true,
                  fillColor: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _error != null ? AppColors.rosePrimary : (isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25)),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _error != null ? AppColors.rosePrimary : (isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.goldPrimary.withValues(alpha: 0.25)),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.goldPrimary,
                      width: 1.8,
                    ),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rosePrimary,
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.16) : AppColors.goldPrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Authorize',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
