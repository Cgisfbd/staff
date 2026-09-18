import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

class HolidayFormSheet extends StatefulWidget {
  const HolidayFormSheet({
    super.key,
    this.holidayToEdit,
    required this.onSave,
  });

  final AcademicHoliday? holidayToEdit;
  final void Function(AcademicHoliday holiday) onSave;

  static Future<void> show(
    BuildContext context, {
    AcademicHoliday? holidayToEdit,
    required void Function(AcademicHoliday holiday) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HolidayFormSheet(
        holidayToEdit: holidayToEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<HolidayFormSheet> createState() => _HolidayFormSheetState();
}

class _HolidayFormSheetState extends State<HolidayFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late HolidayType _type;
  late HolidayAppliesTo _appliesTo;
  late DateTime _startDate;
  late DateTime _endDate;

  String _selectedLang = 'EN'; // 'EN', 'UR', 'HI'

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleUrController;
  late final TextEditingController _titleHiController;

  late final TextEditingController _descEnController;
  late final TextEditingController _descUrController;
  late final TextEditingController _descHiController;

  @override
  void initState() {
    super.initState();
    final h = widget.holidayToEdit;

    _type = h?.type ?? HolidayType.religious;
    _appliesTo = h?.appliesTo ?? HolidayAppliesTo.all;

    final now = DateTime.now();
    _startDate = h != null && h.startDate.isNotEmpty
        ? DateTime.tryParse(h.startDate) ?? now
        : now;
    _endDate = h != null && h.endDate.isNotEmpty
        ? DateTime.tryParse(h.endDate) ?? now
        : now;

    _titleEnController = TextEditingController(text: h?.titleEn ?? '');
    _titleUrController = TextEditingController(text: h?.titleUr ?? '');
    _titleHiController = TextEditingController(text: h?.titleHi ?? '');

    _descEnController = TextEditingController(text: h?.descEn ?? '');
    _descUrController = TextEditingController(text: h?.descUr ?? '');
    _descHiController = TextEditingController(text: h?.descHi ?? '');
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleUrController.dispose();
    _titleHiController.dispose();
    _descEnController.dispose();
    _descUrController.dispose();
    _descHiController.dispose();
    super.dispose();
  }

  int get _calculatedDuration {
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final titleEn = _titleEnController.text.trim();
    final titleUr = _titleUrController.text.trim();
    final titleHi = _titleHiController.text.trim();

    if (titleEn.isEmpty && titleUr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a holiday title in English or Urdu.')),
      );
      return;
    }

    final isoFormat = DateFormat('yyyy-MM-dd');

    final holiday = AcademicHoliday(
      id: widget.holidayToEdit?.id ?? '',
      academicYearId: widget.holidayToEdit?.academicYearId ?? '',
      type: _type,
      appliesTo: _appliesTo,
      startDate: isoFormat.format(_startDate),
      endDate: isoFormat.format(_endDate),
      title: {
        if (titleEn.isNotEmpty) 'en': titleEn,
        if (titleUr.isNotEmpty) 'ur': titleUr,
        if (titleHi.isNotEmpty) 'hi': titleHi,
      },
      description: {
        if (_descEnController.text.trim().isNotEmpty) 'en': _descEnController.text.trim(),
        if (_descUrController.text.trim().isNotEmpty) 'ur': _descUrController.text.trim(),
        if (_descHiController.text.trim().isNotEmpty) 'hi': _descHiController.text.trim(),
      },
      createdAt: widget.holidayToEdit?.createdAt,
      updatedAt: DateTime.now(),
    );

    widget.onSave(holiday);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.holidayToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEditing ? 'Edit Holiday' : 'Schedule New Holiday',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ],
              ),
              const Divider(height: 20),

              // Category Selector
              Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: HolidayType.values.map((cat) {
                  final isSelected = _type == cat;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldPrimary
                                  : (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Applies To Selector
              Text(
                'APPLIES TO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: HolidayAppliesTo.values.map((app) {
                  final isSelected = _appliesTo == app;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () => setState(() => _appliesTo = app),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldPrimary
                                  : (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            app.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Dates Selection with Duration Pill
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'START DATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: _pickStartDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.goldPrimary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    AppFormatters.formatDate(_startDate),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.charcoalDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'END DATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: _pickEndDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_rounded, size: 14, color: AppColors.goldPrimary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    AppFormatters.formatDate(_endDate),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.charcoalDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Duration Badge Indicator
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Duration: $_calculatedDuration ${_calculatedDuration == 1 ? "Day" : "Days"} off',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Multilingual Language Switcher Bar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    _buildLangTab('EN', 'English', isDark),
                    _buildLangTab('UR', 'اردو', isDark),
                    _buildLangTab('HI', 'हिन्दी', isDark),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Dynamic Input Fields according to Selected Language
              if (_selectedLang == 'EN') ...[
                TextFormField(
                  controller: _titleEnController,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                  decoration: _buildInputDecoration('Holiday Title (English) *', isDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descEnController,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                  decoration: _buildInputDecoration('Holiday description, notes, or significance (optional)', isDark),
                ),
              ] else if (_selectedLang == 'UR') ...[
                TextFormField(
                  controller: _titleUrController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldPrimary,
                  ),
                  decoration: _buildInputDecoration('تعطیل کا نام (اردو) *', isDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descUrController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                  decoration: _buildInputDecoration('تفصیل، شرعی یا انتظامی ہدایات (اختیاری)', isDark),
                ),
              ] else ...[
                TextFormField(
                  controller: _titleHiController,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                  decoration: _buildInputDecoration('अवकाश शीर्षक (हिन्दी)', isDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descHiController,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                  ),
                  decoration: _buildInputDecoration('अवकाश का विवरण या टिप्पणी (वैकल्पिक)', isDark),
                ),
              ],

              const SizedBox(height: 18),

              // Submit Button
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isEditing ? 'Update Holiday' : 'Add to Calendar',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangTab(String code, String label, bool isDark) {
    final isSelected = _selectedLang == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLang = code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
      ),
      filled: true,
      fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
