import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_bloc.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_event.dart';

class BookExamSetupSheet extends StatefulWidget {
  const BookExamSetupSheet({
    super.key,
    required this.book,
  });

  final BookEntity book;

  static Future<void> show(BuildContext context, {required BookEntity book}) {
    final bloc = context.read<ExamSettingsBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BookExamSetupSheet(book: book),
      ),
    );
  }

  @override
  State<BookExamSetupSheet> createState() => _BookExamSetupSheetState();
}

class _BookExamSetupSheetState extends State<BookExamSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _term;

  late TextEditingController _maxMarksController;
  late TextEditingController _passMarksController;

  // 4 Terms Controllers & Practical States
  late TextEditingController _t1TheoryController;
  late TextEditingController _t1PracticalController;
  late bool _t1HasPractical;

  late TextEditingController _t2TheoryController;
  late TextEditingController _t2PracticalController;
  late bool _t2HasPractical;

  late TextEditingController _t3TheoryController;
  late TextEditingController _t3PracticalController;
  late bool _t3HasPractical;

  late TextEditingController _t4TheoryController;
  late TextEditingController _t4PracticalController;
  late bool _t4HasPractical;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _term = b.term.isNotEmpty ? b.term : 'FULL_YEAR';
    final max = b.maxMarks > 0 ? b.maxMarks : 100;
    final prac = b.practicalMarks;

    _maxMarksController = TextEditingController(text: '$max');
    _passMarksController = TextEditingController(text: '${b.passMarks > 0 ? b.passMarks : (max * 0.33).round()}');

    _t1TheoryController = TextEditingController();
    _t1PracticalController = TextEditingController(text: '0');
    _t1HasPractical = false;

    _t2TheoryController = TextEditingController();
    _t2PracticalController = TextEditingController(text: '0');
    _t2HasPractical = false;

    _t3TheoryController = TextEditingController();
    _t3PracticalController = TextEditingController(text: '0');
    _t3HasPractical = false;

    _t4TheoryController = TextEditingController();
    _t4PracticalController = TextEditingController(text: '0');
    _t4HasPractical = false;

    _autoDistributeTerms(max, initialPrac: prac);
  }

  void _autoDistributeTerms(int max, {int? initialPrac}) {
    final prac = initialPrac ?? 0;

    if (_term == 'TERM_1') {
      final t1 = (max * 0.2).round();
      final t2Total = max - t1;
      final t2Prac = prac > 0 ? prac.clamp(0, t2Total - 1) : 0;
      final t2Theory = (t2Total - t2Prac).clamp(0, t2Total);

      _t1TheoryController.text = '$t1';
      _t1PracticalController.text = '0';
      _t1HasPractical = false;

      _t2TheoryController.text = '$t2Theory';
      _t2PracticalController.text = '$t2Prac';
      _t2HasPractical = t2Prac > 0;

      _t3TheoryController.text = '0';
      _t3PracticalController.text = '0';
      _t3HasPractical = false;

      _t4TheoryController.text = '0';
      _t4PracticalController.text = '0';
      _t4HasPractical = false;
    } else if (_term == 'TERM_2') {
      final t3 = (max * 0.2).round();
      final t4Total = max - t3;
      final t4Prac = prac > 0 ? prac.clamp(0, t4Total - 1) : 0;
      final t4Theory = (t4Total - t4Prac).clamp(0, t4Total);

      _t1TheoryController.text = '0';
      _t1PracticalController.text = '0';
      _t1HasPractical = false;

      _t2TheoryController.text = '0';
      _t2PracticalController.text = '0';
      _t2HasPractical = false;

      _t3TheoryController.text = '$t3';
      _t3PracticalController.text = '0';
      _t3HasPractical = false;

      _t4TheoryController.text = '$t4Theory';
      _t4PracticalController.text = '$t4Prac';
      _t4HasPractical = t4Prac > 0;
    } else {
      // FULL_YEAR (10%, 40%, 10%, 40%)
      final t1 = (max * 0.1).round();
      final t3 = (max * 0.1).round();
      final remaining = max - (t1 + t3);
      final t2Total = (remaining / 2).round();
      final t4Total = remaining - t2Total;

      final t2Prac = (prac / 2).floor();
      final t4Prac = prac - t2Prac;

      _t1TheoryController.text = '$t1';
      _t1PracticalController.text = '0';
      _t1HasPractical = false;

      _t2TheoryController.text = '${(t2Total - t2Prac).clamp(0, t2Total)}';
      _t2PracticalController.text = '$t2Prac';
      _t2HasPractical = t2Prac > 0;

      _t3TheoryController.text = '$t3';
      _t3PracticalController.text = '0';
      _t3HasPractical = false;

      _t4TheoryController.text = '${(t4Total - t4Prac).clamp(0, t4Total)}';
      _t4PracticalController.text = '$t4Prac';
      _t4HasPractical = t4Prac > 0;
    }
  }

  void _onMaxMarksChanged(String val) {
    final max = int.tryParse(val) ?? 0;
    if (max > 0) {
      _passMarksController.text = '${(max * 0.33).round()}';
      _autoDistributeTerms(max);
    }
    setState(() {});
  }

  void _balanceDifference() {
    final target = int.tryParse(_maxMarksController.text) ?? 0;
    final diff = target - _totalMaxMarks;
    if (diff == 0) return;

    if (_term == 'TERM_1') {
      final cur = int.tryParse(_t2TheoryController.text) ?? 0;
      _t2TheoryController.text = '${(cur + diff).clamp(0, target)}';
    } else {
      final cur = int.tryParse(_t4TheoryController.text) ?? 0;
      _t4TheoryController.text = '${(cur + diff).clamp(0, target)}';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _maxMarksController.dispose();
    _passMarksController.dispose();
    _t1TheoryController.dispose();
    _t1PracticalController.dispose();
    _t2TheoryController.dispose();
    _t2PracticalController.dispose();
    _t3TheoryController.dispose();
    _t3PracticalController.dispose();
    _t4TheoryController.dispose();
    _t4PracticalController.dispose();
    super.dispose();
  }

  int get _t1Total {
    final isT1Active = _term == 'FULL_YEAR' || _term == 'TERM_1';
    if (!isT1Active) return 0;
    final th = int.tryParse(_t1TheoryController.text) ?? 0;
    final pr = _t1HasPractical ? (int.tryParse(_t1PracticalController.text) ?? 0) : 0;
    return th + pr;
  }

  int get _t2Total {
    final isT2Active = _term == 'FULL_YEAR' || _term == 'TERM_1';
    if (!isT2Active) return 0;
    final th = int.tryParse(_t2TheoryController.text) ?? 0;
    final pr = _t2HasPractical ? (int.tryParse(_t2PracticalController.text) ?? 0) : 0;
    return th + pr;
  }

  int get _t3Total {
    final isT3Active = _term == 'FULL_YEAR' || _term == 'TERM_2';
    if (!isT3Active) return 0;
    final th = int.tryParse(_t3TheoryController.text) ?? 0;
    final pr = _t3HasPractical ? (int.tryParse(_t3PracticalController.text) ?? 0) : 0;
    return th + pr;
  }

  int get _t4Total {
    final isT4Active = _term == 'FULL_YEAR' || _term == 'TERM_2';
    if (!isT4Active) return 0;
    final th = int.tryParse(_t4TheoryController.text) ?? 0;
    final pr = _t4HasPractical ? (int.tryParse(_t4PracticalController.text) ?? 0) : 0;
    return th + pr;
  }

  int get _totalMaxMarks => _t1Total + _t2Total + _t3Total + _t4Total;

  int get _totalPracticalMarks {
    int sum = 0;
    if ((_term == 'FULL_YEAR' || _term == 'TERM_1') && _t1HasPractical) {
      sum += int.tryParse(_t1PracticalController.text) ?? 0;
    }
    if ((_term == 'FULL_YEAR' || _term == 'TERM_1') && _t2HasPractical) {
      sum += int.tryParse(_t2PracticalController.text) ?? 0;
    }
    if ((_term == 'FULL_YEAR' || _term == 'TERM_2') && _t3HasPractical) {
      sum += int.tryParse(_t3PracticalController.text) ?? 0;
    }
    if ((_term == 'FULL_YEAR' || _term == 'TERM_2') && _t4HasPractical) {
      sum += int.tryParse(_t4PracticalController.text) ?? 0;
    }
    return sum;
  }

  int get _totalTheoryMarks => _totalMaxMarks - _totalPracticalMarks;

  void _onRecalculate() {
    final tot = _totalMaxMarks;
    if (tot > 0) {
      _passMarksController.text = '${(tot * 0.33).round()}';
    }
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final targetMax = int.tryParse(_maxMarksController.text) ?? _totalMaxMarks;
    final maxMarks = targetMax > 0 ? targetMax : _totalMaxMarks;
    final practicalMarks = _totalPracticalMarks;
    final theoryMarks = _totalTheoryMarks;
    final passMarks = int.tryParse(_passMarksController.text) ?? (maxMarks * 0.33).round();

    context.read<ExamSettingsBloc>().add(UpdateBookExamSettingsEvent(
          book: widget.book,
          term: _term,
          maxMarks: maxMarks,
          passMarks: passMarks,
          practicalMarks: practicalMarks,
          theoryMarks: theoryMarks,
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isT1Active = _term == 'FULL_YEAR' || _term == 'TERM_1';
    final isT2Active = _term == 'FULL_YEAR' || _term == 'TERM_1';
    final isT3Active = _term == 'FULL_YEAR' || _term == 'TERM_2';
    final isT4Active = _term == 'FULL_YEAR' || _term == 'TERM_2';

    final maxTarget = int.tryParse(_maxMarksController.text) ?? 0;
    final isMatched = _totalMaxMarks == maxTarget && maxTarget > 0;
    final diff = maxTarget - _totalMaxMarks;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sheet Header with Book Details
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.emeraldPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.nameEnglish,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Configure 4-term marks & practical setup',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 1. TOP SECTION: OVERALL MARKS FRAMEWORK (FIRST AS REQUESTED)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.military_tech_rounded, color: AppColors.goldPrimary, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '1. Overall Marks Framework',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.charcoalDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final max = int.tryParse(_maxMarksController.text) ?? 100;
                              _autoDistributeTerms(max);
                              _onRecalculate();
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 12, color: AppColors.emeraldPrimary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Auto-Balance',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.emeraldPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Total Max Marks Input (TOP FIRST)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Max Marks *',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 38,
                                  child: TextFormField(
                                    controller: _maxMarksController,
                                    keyboardType: TextInputType.number,
                                    onChanged: _onMaxMarksChanged,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDark ? Colors.white10 : Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Passing Marks Input
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Passing Marks (33%)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.charcoalDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 38,
                                  child: TextFormField(
                                    controller: _passMarksController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDark ? Colors.white10 : Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Syllabus Duration *',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.charcoalDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _TermOptionTile(
                              label: 'Full Session',
                              subtitle: '4 Terms (T1-T4)',
                              isSelected: _term == 'FULL_YEAR',
                              onTap: () {
                                setState(() => _term = 'FULL_YEAR');
                                final max = int.tryParse(_maxMarksController.text) ?? 100;
                                _autoDistributeTerms(max);
                                _onRecalculate();
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _TermOptionTile(
                              label: 'First Semester',
                              subtitle: '2 Terms (T1 & T2)',
                              isSelected: _term == 'TERM_1',
                              onTap: () {
                                setState(() => _term = 'TERM_1');
                                final max = int.tryParse(_maxMarksController.text) ?? 100;
                                _autoDistributeTerms(max);
                                _onRecalculate();
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _TermOptionTile(
                              label: 'Second Semester',
                              subtitle: '2 Terms (T3 & T4)',
                              isSelected: _term == 'TERM_2',
                              onTap: () {
                                setState(() => _term = 'TERM_2');
                                final max = int.tryParse(_maxMarksController.text) ?? 100;
                                _autoDistributeTerms(max);
                                _onRecalculate();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. TERM-WISE MARKS DISTRIBUTION SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '2. 4-Term Marks Distribution',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : AppColors.charcoalDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                            : Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isMatched
                              ? AppColors.emeraldPrimary.withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMatched ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 11,
                            color: isMatched ? AppColors.emeraldPrimary : Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isMatched
                                ? 'Allocated: $_totalMaxMarks / $maxTarget (Matched)'
                                : 'Allocated: $_totalMaxMarks / $maxTarget (${diff > 0 ? '$diff left' : '${diff.abs()} over'})',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isMatched ? AppColors.emeraldPrimary : Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isMatched && diff != 0) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _balanceDifference,
                      child: const Text(
                        'Tap here to auto-balance into final term',
                        style: TextStyle(fontSize: 10, color: Colors.amber, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Term 1 Card
                _TermCardWidget(
                  termNumber: 1,
                  termName: 'Term 1',
                  termSubtitle: '1st Quarter Exam',
                  isActive: isT1Active,
                  theoryController: _t1TheoryController,
                  practicalController: _t1PracticalController,
                  hasPractical: _t1HasPractical,
                  onPracticalChanged: (val) {
                    setState(() {
                      _t1HasPractical = val;
                      if (!val) _t1PracticalController.text = '0';
                    });
                    _onRecalculate();
                  },
                  onMarksChanged: (_) => _onRecalculate(),
                  totalMarks: _t1Total,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),

                // Term 2 Card
                _TermCardWidget(
                  termNumber: 2,
                  termName: 'Term 2',
                  termSubtitle: 'Half Yearly Exam',
                  isActive: isT2Active,
                  theoryController: _t2TheoryController,
                  practicalController: _t2PracticalController,
                  hasPractical: _t2HasPractical,
                  onPracticalChanged: (val) {
                    setState(() {
                      _t2HasPractical = val;
                      if (!val) _t2PracticalController.text = '0';
                    });
                    _onRecalculate();
                  },
                  onMarksChanged: (_) => _onRecalculate(),
                  totalMarks: _t2Total,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),

                // Term 3 Card
                _TermCardWidget(
                  termNumber: 3,
                  termName: 'Term 3',
                  termSubtitle: '3rd Quarter Exam',
                  isActive: isT3Active,
                  theoryController: _t3TheoryController,
                  practicalController: _t3PracticalController,
                  hasPractical: _t3HasPractical,
                  onPracticalChanged: (val) {
                    setState(() {
                      _t3HasPractical = val;
                      if (!val) _t3PracticalController.text = '0';
                    });
                    _onRecalculate();
                  },
                  onMarksChanged: (_) => _onRecalculate(),
                  totalMarks: _t3Total,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),

                // Term 4 Card
                _TermCardWidget(
                  termNumber: 4,
                  termName: 'Term 4',
                  termSubtitle: 'Annual Final Exam',
                  isActive: isT4Active,
                  theoryController: _t4TheoryController,
                  practicalController: _t4PracticalController,
                  hasPractical: _t4HasPractical,
                  onPracticalChanged: (val) {
                    setState(() {
                      _t4HasPractical = val;
                      if (!val) _t4PracticalController.text = '0';
                    });
                    _onRecalculate();
                  },
                  onMarksChanged: (_) => _onRecalculate(),
                  totalMarks: _t4Total,
                  isDark: isDark,
                ),

                const SizedBox(height: 14),

                // 3. Live Totals Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$_totalMaxMarks',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.charcoalDark,
                                ),
                              ),
                            ),
                            const Text(
                              'Max Marks',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey.withValues(alpha: 0.3)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$_totalTheoryMarks',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.emeraldPrimary,
                                ),
                              ),
                            ),
                            const Text(
                              'Theory',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      if (_totalPracticalMarks > 0) ...[
                        Container(width: 1, height: 20, color: Colors.grey.withValues(alpha: 0.3)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$_totalPracticalMarks',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const Text(
                                'Practical',
                                style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _totalMaxMarks > 0 ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.emeraldDark,
                            AppColors.emeraldPrimary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emeraldPrimary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Save Exam Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermCardWidget extends StatelessWidget {
  const _TermCardWidget({
    required this.termNumber,
    required this.termName,
    required this.termSubtitle,
    required this.isActive,
    required this.theoryController,
    required this.practicalController,
    required this.hasPractical,
    required this.onPracticalChanged,
    required this.onMarksChanged,
    required this.totalMarks,
    required this.isDark,
  });

  final int termNumber;
  final String termName;
  final String termSubtitle;
  final bool isActive;
  final TextEditingController theoryController;
  final TextEditingController practicalController;
  final bool hasPractical;
  final ValueChanged<bool> onPracticalChanged;
  final ValueChanged<String> onMarksChanged;
  final int totalMarks;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'T$termNumber',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$termName ($termSubtitle) - Inactive',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'T$termNumber',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emeraldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$termName ($termSubtitle)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.emeraldPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Total: $totalMarks',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Inputs Row
          Row(
            children: [
              // Theory Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theory Marks',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 36,
                      child: TextFormField(
                        controller: theoryController,
                        keyboardType: TextInputType.number,
                        onChanged: onMarksChanged,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Practical Switch & Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Practical?',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 22,
                          child: Switch.adaptive(
                            value: hasPractical,
                            activeThumbColor: Colors.amber,
                            onChanged: onPracticalChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (hasPractical)
                      SizedBox(
                        height: 36,
                        child: TextFormField(
                          controller: practicalController,
                          keyboardType: TextInputType.number,
                          onChanged: onMarksChanged,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? Colors.white10 : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Text(
                          'No Practical',
                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TermOptionTile extends StatelessWidget {
  const _TermOptionTile({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldPrimary.withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.goldPrimary : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.goldPrimary : (isDark ? Colors.white : AppColors.charcoalDark),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
