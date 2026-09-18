import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_bloc.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_event.dart';

class CreateSessionSheet extends StatefulWidget {
  const CreateSessionSheet({
    super.key,
    this.suggestedYear,
  });

  final String? suggestedYear;

  static Future<void> show(BuildContext context, {String? suggestedYear}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AcademicSessionBloc>(),
        child: CreateSessionSheet(suggestedYear: suggestedYear),
      ),
    );
  }

  @override
  State<CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<CreateSessionSheet> {
  late DateTime _startDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default to April 1st of next academic year
    final now = DateTime.now();
    _startDate = DateTime(now.year + 1, 4, 1);
  }

  String get _computedYearName {
    final startYear = _startDate.year;
    return '$startYear-${startYear + 1}';
  }

  Future<void> _pickStartDate(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.goldPrimary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_startDate);

    context.read<AcademicSessionBloc>().add(
          CreateAcademicSessionEvent(
            yearName: _computedYearName,
            startDate: dateStr,
          ),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Initializing session $_computedYearName...'),
        backgroundColor: const Color(0xFF059669),
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
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Initialize Next Session',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Configure the starting date for the new academic year',
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
                const SizedBox(height: 18),

                // Computed target session banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TARGET ACADEMIC SESSION',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              _computedYearName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Start Date Picker Field
                Text(
                  'SESSION START DATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickStartDate(isDark),
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
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMMM yyyy').format(_startDate),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.edit_calendar_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
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
                              Icon(Icons.add_circle_outline_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Initialize Academic Session',
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
