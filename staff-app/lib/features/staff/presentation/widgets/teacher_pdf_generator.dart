import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';

/// High-Res Vector PDF Generator for Faculty & Staff Dossier.
/// Produces official A4 registration dossiers mirroring Web ERP TeacherRegistrationPrintForm.
class TeacherPdfGenerator {
  const TeacherPdfGenerator._();

  static Future<Uint8List> generateFacultyDossierPdf(TeacherDirectoryEntity teacher) async {
    final doc = pw.Document(
      title: 'Faculty Dossier - ${teacher.fullNameEn}',
      author: 'TaleemOne ERP — Powered by Barkat Tech',
    );

    pw.Font? urduFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu-Regular.ttf');
      urduFont = pw.Font.ttf(fontData);
    } catch (_) {}

    const emeraldPrimary = PdfColor.fromInt(0xFF047857);
    const emeraldLight = PdfColor.fromInt(0xFFECFDF5);
    const textDark = PdfColor.fromInt(0xFF0F172A);
    const textMuted = PdfColor.fromInt(0xFF64748B);
    const borderSlate = PdfColor.fromInt(0xFFCBD5E1);

    final printDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Institution Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: emeraldPrimary, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TALEEMONE INSTITUTIONAL ACADEMY',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: emeraldPrimary,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'FACULTY EMPLOYMENT DOSSIER & REGISTRATION RECORD',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Staff Code: #${teacher.staffCode}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: emeraldPrimary,
                          ),
                        ),
                        pw.Text(
                          'Status: ${teacher.status.toUpperCase()}',
                          style: const pw.TextStyle(fontSize: 8.5, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // 2. Section 1: Personal Information
              _buildSectionHeader('1. PERSONAL & IDENTITY DETAILS (معلوماتِ ذاتی)', emeraldPrimary, urduFont),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                      children: [
                        _buildRow('Full Name (EN)', teacher.fullNameEn, textDark),
                        if (teacher.nameUrdu.isNotEmpty)
                          _buildRow('Full Name (UR)', teacher.nameUrdu, emeraldPrimary, font: urduFont, isRtl: true),
                        _buildRow("Father's Name (EN)", teacher.fatherNameEn, textDark),
                        if (teacher.fatherNameUr.isNotEmpty)
                          _buildRow("Father's Name (UR)", teacher.fatherNameUr, textDark, font: urduFont, isRtl: true),
                        _buildRow('Date of Birth', teacher.dob.isNotEmpty ? teacher.dob : 'N/A', textDark),
                        _buildRow('Gender', teacher.gender, textDark),
                        _buildRow('Aadhaar Number', teacher.aadharNo.isNotEmpty ? teacher.aadharNo : 'N/A', textDark),
                        _buildRow('RFID Smart Tag', teacher.rfidNo.isNotEmpty ? teacher.rfidNo : 'N/A', textDark),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Photo Placeholder Box
                  pw.Container(
                    width: 80,
                    height: 96,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: emeraldPrimary, width: 1),
                      color: emeraldLight,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'AFFIX\nFACULTY\nPHOTO',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // 3. Section 2: Contact & Address
              _buildSectionHeader('2. CONTACT & PERMANENT RESIDENCE (رابطہ و مستقل پتہ)', emeraldPrimary, urduFont),
              pw.Table(
                border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                children: [
                  _buildRow2(
                    'Primary Phone', teacher.phone,
                    'Family Phone', teacher.familyPhone.isNotEmpty ? teacher.familyPhone : 'N/A',
                  ),
                  _buildRow2(
                    'Email Address', teacher.email.isNotEmpty ? teacher.email : 'N/A',
                    'Residence Duty', teacher.dutyMode,
                  ),
                ],
              ),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderSlate, width: 0.5),
                  color: const PdfColor.fromInt(0xFFF8FAFC),
                ),
                child: pw.Text(
                  'Permanent Address: ${teacher.fullAddress.isNotEmpty ? teacher.fullAddress : "Campus Staff Quarters, Deoband, Saharanpur, UP"}',
                  style: const pw.TextStyle(fontSize: 8.5, color: textDark),
                ),
              ),
              pw.SizedBox(height: 10),

              // 4. Section 3: Professional & Academic Allocation
              _buildSectionHeader('3. ACADEMIC & PROFESSIONAL ALLOCATION (تعلیمی و تدریسی شعبہ)', emeraldPrimary, urduFont),
              pw.Table(
                border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                children: [
                  _buildRow2(
                    'Designation', teacher.designation,
                    'Highest Qualification', teacher.qualification,
                  ),
                  _buildRow2(
                    'Department / Subject', teacher.department.isNotEmpty ? teacher.department : 'Islamic Studies',
                    'Teaching Experience', '${teacher.experienceYears} Years',
                  ),
                  _buildRow2(
                    'Date of Joining', teacher.joiningDate,
                    'Duty Shift', '${teacher.dutyMode} (Regular Faculty)',
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // 5. Section 4: Remuneration & Banking
              _buildSectionHeader('4. REMUNERATION & BANKING RECORD (تنخواہ و بینک تفصیلات)', emeraldPrimary, urduFont),
              pw.Table(
                border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                children: [
                  _buildRow2(
                    'Monthly Remuneration', teacher.monthlySalary > 0 ? 'Rs. ${teacher.monthlySalary.toStringAsFixed(0)} /-' : 'Discretionary / Honorarium',
                    'Bank Name', teacher.bankName.isNotEmpty ? teacher.bankName : 'State Bank of India',
                  ),
                  _buildRow2(
                    'Account Number', teacher.bankAccountNo.isNotEmpty ? teacher.bankAccountNo : 'N/A',
                    'IFSC Code', teacher.bankIfsc.isNotEmpty ? teacher.bankIfsc : 'N/A',
                  ),
                ],
              ),
              pw.Spacer(),

              // 6. Signatures & Official Stamp
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: borderSlate, width: 0.8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(width: 110, height: 1, color: textMuted),
                        pw.SizedBox(height: 3),
                        pw.Text('Faculty Member Signature', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(width: 110, height: 1, color: textMuted),
                        pw.SizedBox(height: 3),
                        pw.Text('Registrar / HR Office Stamp', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(width: 110, height: 1, color: textMuted),
                        pw.SizedBox(height: 3),
                        pw.Text('Principal / Muhtamim Signature', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated on: $printDate • TaleemOne ERP',
                  style: const pw.TextStyle(fontSize: 7, color: textMuted),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor color, pw.Font? font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          font: font,
        ),
      ),
    );
  }

  static pw.TableRow _buildRow(String label, String value, PdfColor valueColor, {pw.Font? font, bool isRtl = false}) {
    return pw.TableRow(
      children: [
        pw.Container(
          width: 130,
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          color: const PdfColor.fromInt(0xFFF1F5F9),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF475569))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
              font: font,
            ),
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildRow2(String label1, String value1, String label2, String value2) {
    return pw.TableRow(
      children: [
        pw.Container(
          width: 110,
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          color: const PdfColor.fromInt(0xFFF1F5F9),
          child: pw.Text(label1, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF475569))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          child: pw.Text(value1, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0F172A))),
        ),
        pw.Container(
          width: 110,
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          color: const PdfColor.fromInt(0xFFF1F5F9),
          child: pw.Text(label2, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF475569))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          child: pw.Text(value2, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0F172A))),
        ),
      ],
    );
  }
}
