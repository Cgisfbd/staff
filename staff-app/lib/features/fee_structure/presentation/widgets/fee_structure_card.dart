import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';

/// Ultra-Premium Expandable Fee Structure Card.
/// Matches Web ERP FeeCardExpanded.tsx & FeeCardCollapsed.tsx 1:1.
/// Combines ERP's 3 Primary StatCards, 5 Metric Tiles, 3 Session Packages,
/// and Bottom Ribbon with Staff App's Executive Liquid Glass & Champagne Gold design.
class FeeStructureCard extends StatelessWidget {
  const FeeStructureCard({
    super.key,
    required this.fee,
    required this.clazz,
    this.course,
    required this.isExpanded,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final FeeStructureEntity fee;
  final ClassEntity clazz;
  final CourseEntity? course;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _formatRupee(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
                alpha: isDark ? (isExpanded ? 0.52 : 0.38) : (isExpanded ? 0.95 : 0.88),
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isExpanded
                    ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.60 : 0.48)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : AppColors.goldPrimary.withValues(alpha: 0.22)),
                width: isExpanded ? 1.2 : 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: isExpanded
                      ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12)
                      : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: isExpanded ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Matches ERP CardHeader)
                      Row(
                        children: [
                          // Status Wallet Icon Sphere
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.goldDark, AppColors.goldPrimary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Class Name Title & Course Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      fee.className,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (clazz.nameUrdu != null && clazz.nameUrdu!.isNotEmpty)
                                      Text(
                                        clazz.nameUrdu!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                  ],
                                ),
                                if (course != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      course!.nameEnglish,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Quick Action Buttons (Edit & Delete) + Expand Chevron
                          if (onEdit != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                    color: AppColors.goldPrimary,
                                  ),
                                ),
                              ),
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 4),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.rosePrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: AppColors.rosePrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // Collapsed State: ERP-style mini preview line
                      if (!isExpanded) ...[
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildMiniCollapsedPill(
                                label: 'Tuition',
                                value: '₹${_formatRupee(fee.tuitionFee)}/m',
                                isDark: isDark,
                              ),
                              const SizedBox(width: 6),
                              _buildMiniCollapsedPill(
                                label: 'Hostel',
                                value: '₹${_formatRupee(fee.hostelFee)}/m',
                                isDark: isDark,
                              ),
                              const SizedBox(width: 6),
                              _buildMiniCollapsedPill(
                                label: '10m Session',
                                value: '₹${_formatRupee(fee.annualResidentPackage)}',
                                isDark: isDark,
                                isHighlight: true,
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldLight.withValues(alpha: isDark ? 0.2 : 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.emeraldLight.withValues(alpha: 0.4),
                                    width: 0.6,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fiber_manual_record_rounded, size: 6, color: AppColors.emeraldLight),
                                    SizedBox(width: 3),
                                    Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: AppColors.emeraldLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Expanded State: Full ERP KPI StatCards, Sub-Metrics & Session Ribbon
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.goldPrimary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 14),

                        // 1. ERP Top 3 StatCards Grid (Tuition, Hostel, Exam)
                        Row(
                          children: [
                            Expanded(
                              child: _buildErpStatCard(
                                isDark: isDark,
                                title: 'Tuition (Monthly)',
                                value: '₹${_formatRupee(fee.tuitionFee)}',
                                icon: Icons.school_rounded,
                                accentColor: AppColors.goldPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildErpStatCard(
                                isDark: isDark,
                                title: 'Hostel (Monthly)',
                                value: '₹${_formatRupee(fee.hostelFee)}',
                                icon: Icons.apartment_rounded,
                                accentColor: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildErpStatCard(
                                isDark: isDark,
                                title: 'Exam (Annual)',
                                value: '₹${_formatRupee(fee.examFee)}',
                                icon: Icons.receipt_long_rounded,
                                accentColor: AppColors.emeraldPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 2. ERP 5 Sub-Metric Tiles (Adm Res, Adm Day, Renewal, Online, Reg Form)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSubMetricTile(
                                title: 'Adm (Res)',
                                amount: '₹${_formatRupee(fee.admissionFeeHostel)}',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _buildSubMetricTile(
                                title: 'Adm (Day)',
                                amount: '₹${_formatRupee(fee.admissionFeeNonHostel)}',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _buildSubMetricTile(
                                title: 'Renewal',
                                amount: '₹${_formatRupee(fee.admissionRenewalFee)}',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _buildSubMetricTile(
                                title: 'Portal',
                                amount: '₹${_formatRupee(fee.onlineFee)}',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _buildSubMetricTile(
                                title: 'Reg Form',
                                amount: '₹${_formatRupee(fee.onlineAdmissionFee)}',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 3. Live 10-Month Session Package Cards (Resident, Day Scholar, Online)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 13,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '10-MONTH SESSION ESTIMATES',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSessionPackagePill(
                                      label: '🏨 Resident',
                                      amount: '₹${_formatRupee(fee.annualResidentPackage)}',
                                      formula: 'Adm + 10m Tui + 10m Hos',
                                      accentColor: const Color(0xFF8B5CF6),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSessionPackagePill(
                                      label: '🎒 Day Scholar',
                                      amount: '₹${_formatRupee(fee.annualDayScholarPackage)}',
                                      formula: 'Adm + 10m Tui + Exam',
                                      accentColor: AppColors.emeraldPrimary,
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSessionPackagePill(
                                      label: '💻 Online',
                                      amount: '₹${_formatRupee(fee.annualOnlinePackage)}',
                                      formula: 'Onl Adm + 10m Onl',
                                      accentColor: const Color(0xFF0284C7),
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 4. ERP Bottom Highlight Ribbon (Sparkles + Max Total)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.emeraldPrimary.withValues(alpha: 0.15),
                                      AppColors.goldPrimary.withValues(alpha: 0.08),
                                    ]
                                  : [
                                      AppColors.emeraldLight.withValues(alpha: 0.12),
                                      AppColors.goldPrimary.withValues(alpha: 0.08),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 15,
                                      color: AppColors.emeraldLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Fee structure configured.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white70 : AppColors.charcoalDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                                    width: 0.6,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${_formatRupee(fee.maxTotalFee)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.emeraldLight,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'MAX TOTAL',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: AppColors.emeraldLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ERP StatCard Widget matching FeeCardExpanded.tsx
  Widget _buildErpStatCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: accentColor),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.textLightSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ERP 5 Sub-Metric Tiles (Adm Res, Adm Day, Renewal, Portal, Reg Form)
  Widget _buildSubMetricTile({
    required String title,
    required String amount,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          width: 0.6,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Live Session Package Projections Pill
  Widget _buildSessionPackagePill({
    required String label,
    required String amount,
    required String formula,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalDark,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formula,
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Collapsed Mini Pill Preview
  Widget _buildMiniCollapsedPill({
    required String label,
    required String value,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.goldPrimary.withValues(alpha: 0.15)
            : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlight
              ? AppColors.goldPrimary.withValues(alpha: 0.35)
              : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isHighlight
                  ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: isHighlight
                  ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                  : (isDark ? Colors.white : AppColors.charcoalDark),
            ),
          ),
        ],
      ),
    );
  }
}
