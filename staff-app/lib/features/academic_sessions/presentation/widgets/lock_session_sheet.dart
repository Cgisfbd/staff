import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_bloc.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_event.dart';

class LockSessionSheet extends StatefulWidget {
  const LockSessionSheet({
    super.key,
    required this.session,
  });

  final AcademicSessionEntity session;

  static Future<void> show(BuildContext context, {required AcademicSessionEntity session}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AcademicSessionBloc>(),
        child: LockSessionSheet(session: session),
      ),
    );
  }

  @override
  State<LockSessionSheet> createState() => _LockSessionSheetState();
}

class _LockSessionSheetState extends State<LockSessionSheet> {
  late DateTime _endDate;
  final TextEditingController _pinController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: widget.session.startDate,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFF43F5E),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submit() {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Please enter your 4-digit Administrator PIN');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_endDate);

    context.read<AcademicSessionBloc>().add(
          LockAcademicSessionEvent(
            id: widget.session.id,
            endDate: dateStr,
            pin: pin,
          ),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sealing & locking session ${widget.session.yearName}...'),
        backgroundColor: const Color(0xFFF43F5E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 22, color: Color(0xFFF43F5E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock Session ${widget.session.yearName}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Irreversible administrative seal & historical archive',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Once locked, this academic session will transition to Read-Only mode. No further edits to student results, attendance, or fees can be made.',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF43F5E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // End Date Picker
                const Text(
                  'SESSION CLOSING DATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFFF43F5E),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickEndDate(isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 16, color: Color(0xFFF43F5E)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMMM yyyy').format(_endDate),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.edit_calendar_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 4-Digit Admin PIN Input
                const Text(
                  'ADMINISTRATOR SECURITY PIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFFF43F5E),
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
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFFF43F5E), fontWeight: FontWeight.w700),
                  ),
                ],

                const SizedBox(height: 20),

                // Submit Lock Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Seal & Lock Academic Session',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
