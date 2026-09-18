import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class DeleteHolidayDialog extends StatefulWidget {
  const DeleteHolidayDialog({
    super.key,
    required this.holidayId,
    required this.holidayTitle,
    required this.onConfirmDelete,
  });

  final String holidayId;
  final String holidayTitle;
  final void Function(String pin) onConfirmDelete;

  static Future<void> show(
    BuildContext context, {
    required String holidayId,
    required String holidayTitle,
    required void Function(String pin) onConfirmDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => DeleteHolidayDialog(
        holidayId: holidayId,
        holidayTitle: holidayTitle,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<DeleteHolidayDialog> createState() => _DeleteHolidayDialogState();
}

class _DeleteHolidayDialogState extends State<DeleteHolidayDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _isPinError = true);
      return;
    }

    widget.onConfirmDelete(pin);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.rosePrimary, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.rosePrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.rosePrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Holiday',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${widget.holidayTitle}"?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.rosePrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.rosePrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 15, color: AppColors.rosePrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deleting this holiday will remove it from the academic calendar and reset attendance exceptions for these dates.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: isDark ? AppColors.rosePrimary : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Admin Security PIN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: TextStyle(
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                decoration: InputDecoration(
                  hintText: '••••',
                  hintStyle: const TextStyle(letterSpacing: 2),
                  errorText: _isPinError ? 'Valid 4-6 digit PIN required' : null,
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isPinError ? AppColors.rosePrimary : AppColors.goldPrimary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.goldPrimary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Delete Holiday', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
