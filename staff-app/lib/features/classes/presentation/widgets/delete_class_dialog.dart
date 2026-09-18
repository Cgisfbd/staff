import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_bloc.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_event.dart';

class DeleteClassDialog extends StatefulWidget {
  const DeleteClassDialog({
    super.key,
    required this.classEntity,
  });

  final ClassEntity classEntity;

  static Future<void> show(BuildContext context, {required ClassEntity classEntity}) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ClassBloc>(),
        child: DeleteClassDialog(classEntity: classEntity),
      ),
    );
  }

  @override
  State<DeleteClassDialog> createState() => _DeleteClassDialogState();
}

class _DeleteClassDialogState extends State<DeleteClassDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Enter 4-digit Administrator PIN');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    context.read<ClassBloc>().add(
          DeleteClassEvent(
            id: widget.classEntity.id,
            pin: pin,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.rosePrimary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.rosePrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: AppColors.rosePrimary, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Delete Class Section',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Are you sure you want to delete "${widget.classEntity.nameEnglish}" under ${widget.classEntity.courseName}? This action will permanently dissociate curriculum books and students assigned to this section.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'ENTER ADMIN PIN TO CONFIRM',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.rosePrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter 4-digit PIN',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                counterText: '',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.rosePrimary),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.rosePrimary, width: 1.5),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(fontSize: 10, color: AppColors.rosePrimary, fontWeight: FontWeight.w700),
              ),
            ],

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosePrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Delete Class', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
