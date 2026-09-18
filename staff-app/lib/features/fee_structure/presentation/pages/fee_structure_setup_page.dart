import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_bloc.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_event.dart';

/// Ultra-Premium Fee Structure Setup Screen.
/// Matches Web ERP FeeForm.tsx 1:1.
/// Features Bound Course & Class tags, 8 ERP Fee Fields with exact labels/sublabels,
/// real-time 10-month session package calculations, and resilient scrollable layout.
class FeeStructureSetupPage extends StatefulWidget {
  const FeeStructureSetupPage({
    super.key,
    required this.clazz,
    this.fee,
    this.course,
  });

  final ClassEntity clazz;
  final FeeStructureEntity? fee;
  final CourseEntity? course;

  @override
  State<FeeStructureSetupPage> createState() => _FeeStructureSetupPageState();
}

class _FeeStructureSetupPageState extends State<FeeStructureSetupPage> {
  final _formKey = GlobalKey<FormState>();

  // 8 Exact ERP Fields from FeeForm.tsx
  late TextEditingController _tuitionFeeController;
  late TextEditingController _hostelFeeController;
  late TextEditingController _admissionHostelController;
  late TextEditingController _admissionNonHostelController;
  late TextEditingController _admissionRenewalController;
  late TextEditingController _examFeeController;
  late TextEditingController _onlineFeeController;
  late TextEditingController _onlineAdmissionController;

  bool get _isEditing => widget.fee != null;

  @override
  void initState() {
    super.initState();
    final f = widget.fee;
    _tuitionFeeController = TextEditingController(text: f != null ? '${f.tuitionFee}' : '');
    _hostelFeeController = TextEditingController(text: f != null ? '${f.hostelFee}' : '');
    _admissionHostelController = TextEditingController(text: f != null ? '${f.admissionFeeHostel}' : '');
    _admissionNonHostelController = TextEditingController(text: f != null ? '${f.admissionFeeNonHostel}' : '');
    _admissionRenewalController = TextEditingController(text: f != null ? '${f.admissionRenewalFee}' : '');
    _examFeeController = TextEditingController(text: f != null ? '${f.examFee}' : '');
    _onlineFeeController = TextEditingController(text: f != null ? '${f.onlineFee}' : '');
    _onlineAdmissionController = TextEditingController(text: f != null ? '${f.onlineAdmissionFee}' : '');
  }

  @override
  void dispose() {
    _tuitionFeeController.dispose();
    _hostelFeeController.dispose();
    _admissionHostelController.dispose();
    _admissionNonHostelController.dispose();
    _admissionRenewalController.dispose();
    _examFeeController.dispose();
    _onlineFeeController.dispose();
    _onlineAdmissionController.dispose();
    super.dispose();
  }

  int get _tuition => int.tryParse(_tuitionFeeController.text) ?? 0;
  int get _hostel => int.tryParse(_hostelFeeController.text) ?? 0;
  int get _admHostel => int.tryParse(_admissionHostelController.text) ?? 0;
  int get _admNonHostel => int.tryParse(_admissionNonHostelController.text) ?? 0;
  int get _admRenewal => int.tryParse(_admissionRenewalController.text) ?? 0;
  int get _exam => int.tryParse(_examFeeController.text) ?? 0;
  int get _online => int.tryParse(_onlineFeeController.text) ?? 0;
  int get _admOnline => int.tryParse(_onlineAdmissionController.text) ?? 0;

  // Exact formulas from FeeForm.tsx
  int get _annualResident => _admHostel + (_tuition * 10) + (_hostel * 10) + _exam;
  int get _annualDayScholar => _admNonHostel + (_tuition * 10) + _exam;
  int get _annualOnline => _admOnline + (_online * 10) + _exam;

  String _formatRupee(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<FeeStructureBloc>().add(
          SaveFeeStructureEvent(
            classId: widget.clazz.id,
            className: widget.clazz.nameEnglish,
            id: widget.fee?.id,
            tuitionFee: _tuition,
            hostelFee: _hostel,
            admissionFeeHostel: _admHostel,
            admissionFeeNonHostel: _admNonHostel,
            admissionRenewalFee: _admRenewal,
            examFee: _exam,
            onlineFee: _online,
            onlineAdmissionFee: _admOnline,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Executive Top Header matching ERP FeeForm header
            ExecutiveTopHeader(
              icon: Icons.arrow_back_rounded,
              title: _isEditing ? 'Edit Fee Structure' : 'Set Fee Structure',
              subtitle: widget.clazz.nameEnglish,
              onIconTap: () => Navigator.of(context).pop(),
              trailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.goldPrimary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _isEditing ? 'Save' : 'Save Fee',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Scrollable Form Area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. ERP Class & Course Bound Section (Line 127-146 in FeeForm.tsx)
                            Row(
                              children: [
                                // Course Bound Tag
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.15 : 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'COURSE',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.6,
                                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'BOUND',
                                                style: TextStyle(
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.course?.nameEnglish ?? 'General Course',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : AppColors.charcoalDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Class Bound Tag
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'CLASS',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.6,
                                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.goldPrimary.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'BOUND',
                                                style: TextStyle(
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.clazz.nameEnglish,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : AppColors.charcoalDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 2. 8 Fee Fields Grid (Line 149-182 in FeeForm.tsx)
                            Text(
                              'FEE SPECIFICATIONS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Row 1: Tuition Fee & Hostel Fee
                            Row(
                              children: [
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _tuitionFeeController,
                                    label: 'Tuition Fee (Campus)',
                                    sublabel: 'Monthly Academic',
                                    placeholder: '5000',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _hostelFeeController,
                                    label: 'Hostel / Boarding',
                                    sublabel: 'Monthly',
                                    placeholder: '3000',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Row 2: New Admission (Hostel) & New Admission (Day Scholar)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _admissionHostelController,
                                    label: 'New Adm (Hostel)',
                                    sublabel: 'Resident Students',
                                    placeholder: '2000',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _admissionNonHostelController,
                                    label: 'New Adm (Day Scholar)',
                                    sublabel: 'Offline Non-Hostel',
                                    placeholder: '1500',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Row 3: Re-Admission Fee & Examination Fee
                            Row(
                              children: [
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _admissionRenewalController,
                                    label: 'Re-Admission Fee',
                                    sublabel: 'Annual Renewal',
                                    placeholder: '1000',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _examFeeController,
                                    label: 'Examination Fee',
                                    sublabel: 'Annual',
                                    placeholder: '500',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Row 4: Online Tuition Fee & Online Admission Fee
                            Row(
                              children: [
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _onlineFeeController,
                                    label: 'Online Tuition Fee',
                                    sublabel: 'Distance / Virtual',
                                    placeholder: '1200',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildErpInputField(
                                    isDark: isDark,
                                    controller: _onlineAdmissionController,
                                    label: 'Online Adm Fee',
                                    sublabel: 'Digital Enrollment',
                                    placeholder: '500',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // 3. Real-time Live Estimated Package Preview (Matching FeeForm.tsx line 185-209)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
                                  alpha: isDark ? 0.45 : 0.94,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 14,
                                        color: AppColors.goldPrimary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'LIVE ESTIMATED PACKAGE PREVIEW',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProjectionBox(
                                          title: '🏨 Resident Session',
                                          amount: '₹${_formatRupee(_annualResident)}',
                                          sub: 'Adm + 10m Tui + 10m Hos + Exam',
                                          accentColor: const Color(0xFF8B5CF6),
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _buildProjectionBox(
                                          title: '🎒 Day Scholar Session',
                                          amount: '₹${_formatRupee(_annualDayScholar)}',
                                          sub: 'Adm + 10m Tui + Exam',
                                          accentColor: AppColors.emeraldPrimary,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _buildProjectionBox(
                                          title: '💻 Online Session',
                                          amount: '₹${_formatRupee(_annualOnline)}',
                                          sub: 'Onl Adm + 10m Onl + Exam',
                                          accentColor: const Color(0xFF0284C7),
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 4. Submit Button (Matching FeeForm.tsx line 213-219)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wallet_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEditing ? 'Save Changes' : '💰 Save Fee Structure',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ERP Input Field matching GlassInput in FeeForm.tsx
  Widget _buildErpInputField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String sublabel,
    required String placeholder,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : AppColors.textLightSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          sublabel,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.goldChampagne.withValues(alpha: 0.7) : AppColors.goldDark.withValues(alpha: 0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontWeight: FontWeight.w600,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Live Projection Box matching FeeForm.tsx preview boxes
  Widget _buildProjectionBox({
    required String title,
    required String amount,
    required String sub,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
