import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

class SalaryReceiptVoucherDialog extends StatelessWidget {
  final SalaryReceiptEntity receipt;
  final FacultySalaryRecordEntity teacher;

  const SalaryReceiptVoucherDialog({
    super.key,
    required this.receipt,
    required this.teacher,
  });

  String _numberToIndianWords(double num) {
    final a = [
      '', 'One ', 'Two ', 'Three ', 'Four ', 'Five ', 'Six ', 'Seven ', 'Eight ', 'Nine ', 'Ten ',
      'Eleven ', 'Twelve ', 'Thirteen ', 'Fourteen ', 'Fifteen ', 'Sixteen ', 'Seventeen ', 'Eighteen ', 'Nineteen ',
    ];
    final b = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String inWords(int n) {
      if (n == 0) return '';
      if (n < 20) return a[n];
      if (n < 100) return '${b[n ~/ 10]} ${a[n % 10]}';
      if (n < 1000) return '${a[n ~/ 100]}Hundred ${inWords(n % 100)}';
      if (n < 100000) return '${inWords(n ~/ 1000)}Thousand ${inWords(n % 1000)}';
      if (n < 10000000) return '${inWords(n ~/ 100000)}Lakh ${inWords(n % 100000)}';
      return '${inWords(n ~/ 10000000)}Crore ${inWords(n % 10000000)}';
    }

    final words = inWords(num.round()).trim();
    return words.isNotEmpty ? '$words Rupees Only' : 'Zero Rupees Only';
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final grossTotal = receipt.amountPerMonth * receipt.months.length;
    final totalDeductions = receipt.deductions.fold(0.0, (sum, d) => sum + d.amount);
    final amountWords = _numberToIndianWords(receipt.totalAmount);

    pw.Widget buildSlip(String copyLabel) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.green800, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Bar
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.green800,
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
                        'Faculty Monthly Salary Disbursement Voucher • Powered by Barkat Tech',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        receipt.receiptNo,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        receipt.paymentDate,
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Teacher Info Card
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Faculty: ${teacher.name}',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Designation: ${teacher.designation}',
                          style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bank: ${teacher.bankName ?? "SBI"}',
                          style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('A/C: ${teacher.accountNumber ?? "—"}',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Mode: ${receipt.paymentMode}',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      if (receipt.transactionRef != null)
                        pw.Text('Ref: ${receipt.transactionRef}', style: const pw.TextStyle(fontSize: 7.5)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            // Months line
            pw.Text(
              'MONTHS DISBURSED: ${receipt.months.join(", ")}',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),

            // Financial Table
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                color: PdfColors.green50,
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Gross Salary (${receipt.months.length} Months): ₹${grossTotal.toStringAsFixed(0)}',
                          style: const pw.TextStyle(fontSize: 8)),
                      if (totalDeductions > 0)
                        pw.Text('Less Deductions: -₹${totalDeductions.toStringAsFixed(0)}',
                            style: pw.TextStyle(fontSize: 8, color: PdfColors.red800)),
                      pw.Text(
                        'NET DISBURSED: ₹${receipt.totalAmount.toStringAsFixed(0)} /-',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'Amount in words: $amountWords',
                      style: pw.TextStyle(fontSize: 7.5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Signature Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(copyLabel,
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                pw.Text('Employee Signature ___________   |   Authorized Accounts Seal ___________',
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
              buildSlip('FACULTY / EMPLOYEE COPY'),
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
                    child: pw.Text('✂ — — — — CUT HERE (یہاں سے کاٹیں) — — — — ✂',
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
              buildSlip('OFFICE RECORD COPY'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: AppColors.statusPresent.withValues(alpha: isDark ? 0.45 : 0.35),
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
                // Medallion
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statusPresent.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.statusPresent.withValues(alpha: 0.3), width: 1),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    size: 28,
                    color: AppColors.statusPresent,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Salary Disbursed Successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Voucher No: ${receipt.receiptNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Preview Box
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
                      _buildPreviewRow(context, 'Faculty Name', teacher.name, isDark),
                      _buildPreviewRow(context, 'Designation', teacher.designation, isDark),
                      _buildPreviewRow(context, 'Bank Account', '${teacher.bankName ?? "SBI"} (A/C: ${teacher.accountNumber ?? "—"})', isDark),
                      _buildPreviewRow(context, 'Months Disbursed', receipt.months.join(', '), isDark),
                      _buildPreviewRow(context, 'Payment Mode', receipt.paymentMode, isDark),
                      if (receipt.transactionRef != null)
                        _buildPreviewRow(context, 'Transaction Ref', receipt.transactionRef!, isDark),
                      const Divider(height: 16),
                      _buildPreviewRow(
                        context,
                        'Net Disbursed Amount',
                        '₹${receipt.totalAmount.toStringAsFixed(0)} /-',
                        isDark,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Notice
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
                        'Includes Dual Slip: Faculty Copy + Office Copy',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (format) => _generatePdf(format),
                            name: 'Salary_Voucher_${receipt.receiptNo}',
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Print Slip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
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
                            filename: 'Salary_Voucher_${receipt.receiptNo}.pdf',
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

  Widget _buildPreviewRow(BuildContext context, String label, String value, bool isDark, {bool isBold = false}) {
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
              color: isBold
                  ? AppColors.statusPresent
                  : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
