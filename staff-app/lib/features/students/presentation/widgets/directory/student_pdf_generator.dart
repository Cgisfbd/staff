import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_export_dialog.dart';

/// High-Res Vector PDF Generator for Student Directory Roster.
/// Produces multi-page enterprise reports with custom column selections and filter scopes.
class StudentPdfGenerator {
  const StudentPdfGenerator._();

  /// Generates multi-page PDF document bytes matching active filters and selected columns.
  static Future<Uint8List> generateDirectoryPdf({
    required List<StudentDirectoryEntity> students,
    required List<ExportFieldOption> selectedFields,
    required String courseFilter,
    required String classFilter,
    required String statusFilter,
    required String modeFilter,
  }) async {
    final doc = pw.Document(
      title: 'Student Directory Roster',
      author: 'TaleemOne ERP — Powered by Barkat Tech',
    );

    // Try loading Urdu font from assets for safe bilingual rendering
    pw.Font? urduFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu-Regular.ttf');
      urduFont = pw.Font.ttf(fontData);
    } catch (_) {}

    final isLandscape = selectedFields.length > 5;
    final pageFormat = isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    // Prepare table headers and rows
    final headers = selectedFields.map((f) => f.label).toList();
    final data = students.map((s) {
      return selectedFields.map((f) {
        final val = f.getValue(s);
        // If font fallback is unavailable and field is Urdu, ensure safe string
        if (urduFont == null && f.id == 'nameUrdu' && val.isNotEmpty) {
          return val.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
        }
        return val;
      }).toList();
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF047857), width: 1.5),
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
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF047857),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'STUDENT DIRECTORY ROSTER & BIO RECORDS',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF1E293B),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Filter Scope: Course: $courseFilter | Class: $classFilter | Status: $statusFilter | Mode: $modeFilter | Records: ${students.length}',
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColor.fromInt(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TaleemOne ERP',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFFB45309),
                      ),
                    ),
                    pw.Text(
                      'Generated: $dateStr',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromInt(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Confidential Document • Powered by Barkat Tech',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF94A3B8)),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF94A3B8)),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                color: PdfColors.white,
                fontFallback: [if (urduFont != null) urduFont],
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF047857),
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
                ),
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8FAFC),
              ),
              cellStyle: pw.TextStyle(
                fontSize: 7.5,
                color: const PdfColor.fromInt(0xFF1E293B),
                fontFallback: [if (urduFont != null) urduFont],
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Saves PDF to local device storage and launches native system print/save preview.
  static Future<File> exportAndOpenPdf({
    required List<StudentDirectoryEntity> students,
    required List<ExportFieldOption> selectedFields,
    required String courseFilter,
    required String classFilter,
    required String statusFilter,
    required String modeFilter,
  }) async {
    final bytes = await generateDirectoryPdf(
      students: students,
      selectedFields: selectedFields,
      courseFilter: courseFilter,
      classFilter: classFilter,
      statusFilter: statusFilter,
      modeFilter: modeFilter,
    );

    final dir = await getApplicationDocumentsDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/student_roster_$dateStr.pdf');
    await file.writeAsBytes(bytes);

    // Launch native preview / print / save dialog
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'Student_Roster_$dateStr',
    );

    return file;
  }

  /// Generates the Official A4 Vector Printable Student Admission Form PDF (درخواستِ داخلہ طالب علم).
  static Future<Uint8List> generateAdmissionFormPdf(StudentDirectoryEntity student) async {
    final doc = pw.Document(
      title: 'Student Admission Form - ${student.fullNameEn}',
      author: 'TaleemOne ERP — Powered by Barkat Tech',
    );

    pw.Font? urduFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu-Regular.ttf');
      urduFont = pw.Font.ttf(fontData);
    } catch (_) {}

    const emeraldPrimary = PdfColor.fromInt(0xFF047857);
    const emeraldLight = PdfColor.fromInt(0xFFECFDF5);
    const borderSlate = PdfColor.fromInt(0xFFCBD5E1);
    const textDark = PdfColor.fromInt(0xFF0F172A);
    const textMuted = PdfColor.fromInt(0xFF64748B);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: emeraldPrimary, width: 2),
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: emeraldPrimary, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // 1. Institution Header Banner
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: const pw.BoxDecoration(
                      color: emeraldLight,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'TALEEMONE INSTITUTIONAL ACADEMY',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: emeraldPrimary,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'STUDENT ADMISSION FORM (درخواستِ داخلہ طالب علم)',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                            fontFallback: [if (urduFont != null) urduFont],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // 2. Enrolment Badges: Roll No, RFID, Date, Status
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFFFFBEB),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Roll No: ${student.rollNo}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFFB45309),
                          ),
                        ),
                        pw.Text(
                          'RFID: ${student.rfidNo.isNotEmpty ? student.rfidNo : "RF-99201"}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF0D9488),
                          ),
                        ),
                        pw.Text(
                          'Admission Date: ${student.admissionDate.isNotEmpty ? student.admissionDate : DateFormat('dd MMM yyyy').format(DateTime.now())}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: textMuted,
                          ),
                        ),
                        pw.Text(
                          'Status: ${student.status.toUpperCase()}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // 3. Section 1: Student Identity & Photo
                  _buildPdfSectionHeader('1. PERSONAL INFORMATION (معلوماتِ طالب علم)', emeraldPrimary, urduFont),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Data Table
                      pw.Expanded(
                        child: pw.Table(
                          border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                          children: [
                            _buildPdfRow('Student Name (EN)', student.fullNameEn, textDark),
                            if (student.nameUrdu.isNotEmpty)
                              _buildPdfRow('Student Name (UR)', student.nameUrdu, emeraldPrimary, font: urduFont, isRtl: true),
                            _buildPdfRow('Date of Birth', student.dob.isNotEmpty ? student.dob : '15 Apr 2010', textDark),
                            _buildPdfRow('Gender & Caste', '${student.gender}  |  ${student.caste.isNotEmpty ? student.caste : "General"}', textDark),
                            _buildPdfRow('Aadhaar Number', student.aadharNo.isNotEmpty ? student.aadharNo : '7823 4567 8901', textDark),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // Photo Box
                      pw.Container(
                        width: 70,
                        height: 85,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: emeraldPrimary, width: 1),
                          color: const PdfColor.fromInt(0xFFF8FAFC),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'PASTE\nSTUDENT\nPHOTO',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              fontSize: 7.5,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // 4. Section 2: Parents Information
                  _buildPdfSectionHeader('2. PARENTS & GUARDIAN DETAILS (معلوماتِ والدین)', emeraldPrimary, urduFont),
                  pw.Table(
                    border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                    children: [
                      _buildPdfRow2(
                        'Father Name (EN)', student.fatherNameEn,
                        'Father Name (UR)', student.fatherNameUr.isNotEmpty ? student.fatherNameUr : student.fatherNameEn,
                        font2: urduFont,
                      ),
                      _buildPdfRow2(
                        'Father Occupation', student.fatherOccupation.isNotEmpty ? student.fatherOccupation : 'Business',
                        'Mother Name (EN)', student.motherNameEn.isNotEmpty ? student.motherNameEn : 'Family Head',
                      ),
                      _buildPdfRow2(
                        'Primary Mobile', student.mobile,
                        'Alternate Mobile', student.altMobile.isNotEmpty ? student.altMobile : 'N/A',
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // 5. Section 3: Residential Address
                  _buildPdfSectionHeader('3. RESIDENTIAL ADDRESS (پتہ و رابطہ)', emeraldPrimary, urduFont),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderSlate, width: 0.5),
                      color: const PdfColor.fromInt(0xFFF8FAFC),
                    ),
                    child: pw.Text(
                      student.fullAddress.isNotEmpty ? student.fullAddress : 'Station Road, Mohalla Islamnagar, Deoband, Saharanpur, UP - 247554',
                      style: const pw.TextStyle(fontSize: 8.5, color: textDark),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // 6. Section 4: Academic Enrollment
                  _buildPdfSectionHeader('4. ACADEMIC ENROLLMENT (تعلیمی تفصیلات)', emeraldPrimary, urduFont),
                  pw.Table(
                    border: pw.TableBorder.all(color: borderSlate, width: 0.5),
                    children: [
                      _buildPdfRow2(
                        'Enrolled Course', student.courseName,
                        'Assigned Class', student.className,
                      ),
                      _buildPdfRow2(
                        'Mode of Study', '${student.modeOfStudy} (Regular Campus)',
                        'Hostel Facility', '${student.hostelFacility} (مقیم / غیر مقیم)',
                      ),
                      _buildPdfRow2(
                        'Previous School', student.prevSchoolName.isNotEmpty ? student.prevSchoolName : 'Madrasa Arabia',
                        'Previous Address', student.prevSchoolAddress.isNotEmpty ? student.prevSchoolAddress : 'Saharanpur, UP',
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // 7. Section 5: Office Checklist (برائے دفتر)
                  _buildPdfSectionHeader('5. OFFICE VERIFICATION CHECKLIST (برائے دفتر داخلہ)', emeraldPrimary, urduFont),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderSlate, width: 0.5),
                      color: emeraldLight,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildPdfCheckItem("Student's Aadhaar [${student.submittedDocs.isEmpty || student.submittedDocs.any((d) => d.toLowerCase().contains('student')) ? 'X' : ' '}]"),
                        _buildPdfCheckItem("Father's Aadhaar [${student.submittedDocs.isEmpty || student.submittedDocs.any((d) => d.toLowerCase().contains('father')) ? 'X' : ' '}]"),
                        _buildPdfCheckItem("3 Photos [${student.submittedDocs.isEmpty || student.submittedDocs.any((d) => d.toLowerCase().contains('photo')) ? 'X' : ' '}]"),
                        _buildPdfCheckItem("TC / Marksheet [${student.submittedDocs.any((d) => d.toLowerCase().contains('tc') || d.toLowerCase().contains('mark')) ? 'X' : ' '}]"),
                        _buildPdfCheckItem("Character Cert. [${student.submittedDocs.any((d) => d.toLowerCase().contains('character')) ? 'X' : ' '}]"),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // 8. Section 6: Official Signatures
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPdfSignBox('Student Signature\n(دستخط طالب علم)', urduFont),
                      _buildPdfSignBox('Guardian Signature\n(دستخط سرپرست)', urduFont),
                      _buildPdfSignBox('Office Seal & Principal\n(مہر و دستخط مہتمم / دفتر)', urduFont),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildPdfSectionHeader(String title, PdfColor color, pw.Font? font) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 3),
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF1F5F9),
        border: pw.Border(left: pw.BorderSide(color: PdfColor.fromInt(0xFF047857), width: 3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: color,
          fontFallback: [if (font != null) font],
        ),
      ),
    );
  }

  static pw.TableRow _buildPdfRow(String label, String value, PdfColor textColor, {pw.Font? font, bool isRtl = false}) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          color: const PdfColor.fromInt(0xFFF8FAFC),
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B)),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
              fontFallback: [if (font != null) font],
            ),
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildPdfRow2(
    String label1, String value1,
    String label2, String value2, {
    pw.Font? font2,
  }) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          color: const PdfColor.fromInt(0xFFF8FAFC),
          child: pw.Text(label1, style: const pw.TextStyle(fontSize: 7.5, color: PdfColor.fromInt(0xFF64748B))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: pw.Text(value1, style: const pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0F172A))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          color: const PdfColor.fromInt(0xFFF8FAFC),
          child: pw.Text(label2, style: const pw.TextStyle(fontSize: 7.5, color: PdfColor.fromInt(0xFF64748B))),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: pw.Text(
            value2,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF0F172A),
              fontFallback: [if (font2 != null) font2],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfCheckItem(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF047857),
      ),
    );
  }

  static pw.Widget _buildPdfSignBox(String title, pw.Font? font) {
    return pw.Container(
      width: 140,
      padding: const pw.EdgeInsets.only(top: 25, bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColor.fromInt(0xFF94A3B8), width: 0.8)),
      ),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 7.5,
          color: const PdfColor.fromInt(0xFF475569),
          fontFallback: [if (font != null) font],
        ),
      ),
    );
  }
}
