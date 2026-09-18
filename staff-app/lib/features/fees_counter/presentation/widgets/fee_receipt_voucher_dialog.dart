import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

class FeeReceiptVoucherDialog extends StatelessWidget {
  final FeePaymentRecordEntity receipt;
  final StudentFeeRecordEntity student;

  const FeeReceiptVoucherDialog({
    super.key,
    required this.receipt,
    required this.student,
  });

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final isWaived = receipt.isWaived;

    final primaryPdfColor = isWaived ? const PdfColor.fromInt(0xFFD97706) : const PdfColor.fromInt(0xFF047857);
    final lightBgPdfColor = isWaived ? const PdfColor.fromInt(0xFFFEF3C7) : const PdfColor.fromInt(0xFFECFDF5);
    final textHeaderPdfColor = isWaived ? const PdfColor.fromInt(0xFF78350F) : const PdfColor.fromInt(0xFF064E3B);

    pw.Widget buildSlip(String copyLabel) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: primaryPdfColor,
            width: 1.5,
          ),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Bar
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: primaryPdfColor,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TALEEMONE EDUCATIONAL INSTITUTION',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        isWaived
                            ? 'Official Fee Concession & Waiver Certificate • Powered by Barkat Tech'
                            : 'Official Student Fee Deposit & Accounts Settlement Voucher • Powered by Barkat Tech',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        receipt.receiptNo,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${receipt.createdAt.day} ${_getMonthName(receipt.createdAt.month)} ${receipt.createdAt.year}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Bio Grid
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student: ${student.fullNameEn}',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Father: ${student.fatherNameEn ?? "—"}',
                          style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Course/Class: ${student.courseName} - ${student.className}',
                          style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Roll No: #${student.rollNo.toString().padLeft(2, '0')}',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(isWaived ? 'Type: WAIVED' : 'Type: DEPOSIT',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryPdfColor,
                          )),
                      pw.Text('By: ${receipt.collector}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            // Months line
            pw.Text(
              'ACADEMIC MONTHS: ${receipt.monthsPaid.join(", ")}',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),

            // Calculations row
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                color: lightBgPdfColor,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gross Amount: ₹${receipt.grossAmount.toStringAsFixed(0)}',
                      style: const pw.TextStyle(fontSize: 8)),
                  if (receipt.concessionAmount > 0 && !isWaived)
                    pw.Text('Less Concession: -₹${receipt.concessionAmount.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.red800)),
                  pw.Text(
                    'NET ${isWaived ? "WAIVED" : "PAID"}: ₹${receipt.amountPaid.toStringAsFixed(0)} /-',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: textHeaderPdfColor,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Footer / Sign
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(copyLabel,
                    style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryPdfColor)),
                pw.Text('Authorized Accounts Signature & Seal ____________________',
                    style: const pw.TextStyle(fontSize: 7.5)),
              ],
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            children: [
              buildSlip('OFFICE & AUDIT RECORD COPY'),
              pw.SizedBox(height: 14),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500, style: pw.BorderStyle.dashed)),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                    child: pw.Text('✂ — — — — CUT VOUCHER HERE (یہاں سے کاٹیں) — — — — ✂',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500, style: pw.BorderStyle.dashed)),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              buildSlip('STUDENT & GUARDIAN COPY'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static String _getMonthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWaived = receipt.isWaived;
    final statusColor = isWaived ? AppColors.statusLeave : AppColors.statusPresent;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkModalSurface : AppColors.lightModalSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: statusColor.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Success Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: 0.15),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Icon(
                    isWaived ? Icons.auto_awesome_rounded : Icons.check_circle_rounded,
                    size: 28,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  isWaived ? 'Fee Concession Approved!' : 'Fee Deposited Successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Receipt No: ${receipt.receiptNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Visual Preview Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.10) : AppColors.goldPrimary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildPreviewRow(context, 'Student Name', student.fullNameEn, isDark),
                      _buildPreviewRow(context, 'Roll No', '#${student.rollNo.toString().padLeft(2, '0')}', isDark),
                      _buildPreviewRow(context, 'Course / Class', '${student.courseName} • ${student.className}', isDark),
                      _buildPreviewRow(context, 'Months Settled', receipt.monthsPaid.join(', '), isDark),
                      _buildPreviewRow(context, 'Gross Amount', '₹${receipt.grossAmount.toStringAsFixed(0)}', isDark),
                      if (receipt.concessionAmount > 0 && !isWaived)
                        _buildPreviewRow(context, 'Concession (Riyayat)', '- ₹${receipt.concessionAmount.toStringAsFixed(0)}', isDark,
                            highlightRed: true),
                      const Divider(height: 16),
                      _buildPreviewRow(
                        context,
                        isWaived ? 'Total Waived Off' : 'Net Amount Deposited',
                        '₹${receipt.amountPaid.toStringAsFixed(0)} /-',
                        isDark,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Two-Copy Voucher Notice
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print_outlined, size: 14, color: AppColors.goldPrimary),
                      SizedBox(width: 6),
                      Text(
                        'Includes Dual Slip: Office Copy + Student Copy',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons: Print PDF, Share, Done
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (format) => _generatePdf(format),
                            name: 'Fee_Voucher_${receipt.receiptNo}',
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Print Voucher', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppColors.textLightPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: isDark ? Colors.white24 : AppColors.goldPrimary.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final bytes = await _generatePdf(PdfPageFormat.a4);
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename: 'Fee_Voucher_${receipt.receiptNo}.pdf',
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Share PDF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done & Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.goldPrimary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewRow(BuildContext context, String label, String value, bool isDark, {bool isBold = false, bool highlightRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              fontFamily: isBold ? 'monospace' : null,
              color: highlightRed
                  ? AppColors.rosePrimary
                  : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
