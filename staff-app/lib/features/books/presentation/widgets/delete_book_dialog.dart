import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:staff_app/features/books/presentation/bloc/book_event.dart';

class DeleteBookDialog extends StatefulWidget {
  const DeleteBookDialog({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  final String bookId;
  final String bookName;

  static Future<void> show(
    BuildContext context, {
    required String bookId,
    required String bookName,
  }) {
    final bloc = context.read<BookBloc>();
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DeleteBookDialog(
          bookId: bookId,
          bookName: bookName,
        ),
      ),
    );
  }

  @override
  State<DeleteBookDialog> createState() => _DeleteBookDialogState();
}

class _DeleteBookDialogState extends State<DeleteBookDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _isPinError = true);
      return;
    }

    context.read<BookBloc>().add(
          DeleteBookEvent(
            id: widget.bookId,
            pin: pin,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
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
                'Remove Book',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove "${widget.bookName}" from the academic syllabus? Any recorded examination marks linked to this book will be affected.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter Admin Security PIN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
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
                hintText: 'Enter 4-6 digit PIN',
                counterText: '',
                errorText: _isPinError ? 'Valid PIN required' : null,
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
