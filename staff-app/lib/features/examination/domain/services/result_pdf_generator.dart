import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:staff_app/features/examination/domain/models/student_result_model.dart';

/// Client-Side High-Res Vector PDF Generator for Staff App
/// Supports:
/// 1. Student Marksheet (A4 Portrait)
/// 2. Class Tabulation Sheet (A4 Landscape)
class ResultPdfGenerator {
  const ResultPdfGenerator._();

  // Primary Theme Colors
  static const PdfColor _emeraldDark = PdfColor.fromInt(0xFF047857);
  static const PdfColor _emeraldLight = PdfColor.fromInt(0xFFECFDF5);
  static const PdfColor _goldPrimary = PdfColor.fromInt(0xFFB45309);
  static const PdfColor _goldLight = PdfColor.fromInt(0xFFFFFBEB);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF1F2937);
  static const PdfColor _textMuted = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _failRed = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _passGreen = PdfColor.fromInt(0xFF16A34A);

  // ---------------------------------------------------------------------------
  // 1. INDIVIDUAL STUDENT MARKSHEET (PORTRAIT A4)
  // ---------------------------------------------------------------------------
  static Future<Uint8List> generateStudentMarksheetPdf(
    StudentResultModel student,
  ) async {
    final doc = pw.Document(
      title: '${student.nameEnglish} - Marksheet',
      author: 'TaleemOne ERP — Powered by Barkat Tech',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _emeraldDark, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildMarksheetHeader(student),
                pw.SizedBox(height: 12),
                pw.Divider(color: _goldPrimary, thickness: 1.5),
                pw.SizedBox(height: 10),

                // Student Details Box
                _buildStudentInfoGrid(student),
                pw.SizedBox(height: 14),

                // Marks Table
                _buildSubjectMarksTable(student),
                pw.SizedBox(height: 12),

                // Result Summary & Distinction Badge
                _buildResultSummaryBanner(student),
                pw.SizedBox(height: 12),

                // Grading Legend
                _buildGradingScaleLegend(),
                pw.Spacer(),

                // Signatures & Verification Stamp
                _buildSignatureFooter(),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildMarksheetHeader(StudentResultModel student) {
    return pw.Column(
      children: [
        pw.Text(
          'TALEEMONE INSTITUTIONAL ACADEMY',
          style: const pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _emeraldDark,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'ANNUAL EXAMINATION RESULT & STATEMENT OF MARKS',
          style: const pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: _goldPrimary,
            letterSpacing: 0.8,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Academic Session: ${student.academicSession} | Faculty of Islamic & Modern Sciences',
          style: const pw.TextStyle(
            fontSize: 9,
            color: _textMuted,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildStudentInfoGrid(StudentResultModel student) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _emeraldLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _emeraldDark, width: 0.5),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Student Name', student.nameEnglish),
                pw.SizedBox(height: 4),
                _buildInfoRow("Father's Name", student.fatherNameEnglish),
                pw.SizedBox(height: 4),
                _buildInfoRow('Course', student.courseName),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Roll Number', student.rollNo),
                pw.SizedBox(height: 4),
                _buildInfoRow('Admission No', student.admissionNo),
                pw.SizedBox(height: 4),
                _buildInfoRow('Class', student.className),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: const pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(
              fontSize: 9,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSubjectMarksTable(StudentResultModel student) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(28),
        1: pw.FlexColumnWidth(4),
        2: pw.FixedColumnWidth(48),
        3: pw.FixedColumnWidth(48),
        4: pw.FixedColumnWidth(54),
        5: pw.FixedColumnWidth(40),
        6: pw.FixedColumnWidth(50),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _emeraldDark),
          children: [
            _tableHeaderCell('#'),
            _tableHeaderCell('Subject / Paper Name', align: pw.TextAlign.left),
            _tableHeaderCell('Max'),
            _tableHeaderCell('Min'),
            _tableHeaderCell('Obtained'),
            _tableHeaderCell('Grade'),
            _tableHeaderCell('Status'),
          ],
        ),

        // Subject Rows
        for (int i = 0; i < student.subjects.length; i++) ...[
          _buildSubjectRow(i + 1, student.subjects[i]),
        ],

        // Grand Total Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _goldLight),
          children: [
            _tableBoldCell(''),
            _tableBoldCell('GRAND TOTAL', align: pw.TextAlign.left),
            _tableBoldCell('${student.totalMax}'),
            _tableBoldCell('${(student.totalMax * 0.4).round()}'),
            _tableBoldCell('${student.totalObtained}'),
            _tableBoldCell(student.overallGrade),
            _tableBoldCell(
              student.resultStatus,
              color: student.isPassed ? _passGreen : _failRed,
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildSubjectRow(int index, SubjectMarkDetail subject) {
    final isFail = subject.isAbsent || (subject.obtainedMarks ?? 0) < subject.minMarks;
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: index.isEven ? const PdfColor.fromInt(0xFFF9FAFB) : PdfColors.white,
      ),
      children: [
        _tableCell('$index'),
        _tableCell(subject.subjectName, align: pw.TextAlign.left),
        _tableCell('${subject.maxMarks}'),
        _tableCell('${subject.minMarks}'),
        _tableCell(
          subject.isAbsent ? 'ABS' : '${subject.obtainedMarks ?? 0}',
          color: isFail ? _failRed : _textDark,
          isBold: isFail,
        ),
        _tableCell(subject.grade, color: isFail ? _failRed : _textDark),
        _tableCell(
          subject.isAbsent
              ? 'ABSENT'
              : isFail
                  ? 'FAIL'
                  : 'PASS',
          color: isFail ? _failRed : _passGreen,
          isBold: true,
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
    PdfColor color = _textDark,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          color: color,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableBoldCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
    PdfColor color = _textDark,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildResultSummaryBanner(StudentResultModel student) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: student.isPassed ? _passGreen : _failRed, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        color: student.isPassed ? _emeraldLight : const PdfColor.fromInt(0xFFFEF2F2),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FINAL RESULT: ${student.resultStatus}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: student.isPassed ? _passGreen : _failRed,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Percentage: ${student.percentage.toStringAsFixed(1)}% | Division: ${student.division}',
                style: const pw.TextStyle(fontSize: 9, color: _textDark),
              ),
            ],
          ),
          if (student.rank != null && student.rank! <= 3) ...[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: _goldPrimary,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'RANK #${student.rank} IN CLASS',
                style: const pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildGradingScaleLegend() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _legendItem('A1: 90-100% (Mumtaz)'),
          _legendItem('A: 80-89% (Jayyid Jiddan)'),
          _legendItem('B: 70-79% (Jayyid)'),
          _legendItem('C: 60-69% (Maqbool)'),
          _legendItem('D: 40-59% (Kafi)'),
          _legendItem('F: <40% (Fail)'),
        ],
      ),
    );
  }

  static pw.Widget _legendItem(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 7, color: _textMuted),
    );
  }

  static pw.Widget _buildSignatureFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _signatureSlot('Class Teacher Signature'),
        _signatureSlot('Controller of Examinations'),
        _signatureSlot('Muhtamim / Principal Stamp'),
      ],
    );
  }

  static pw.Widget _signatureSlot(String title) {
    return pw.Column(
      children: [
        pw.Container(
          width: 130,
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _textDark, width: 0.8)),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 8, color: _textMuted),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. CLASS TABULATION SHEET / MASTER GAZETTE (LANDSCAPE A4)
  // ---------------------------------------------------------------------------
  static Future<Uint8List> generateClassTabulationPdf({
    required String className,
    required String courseName,
    required List<StudentResultModel> students,
    required String session,
  }) async {
    final doc = pw.Document(
      title: '$className - Master Tabulation Gazette',
      author: 'TaleemOne ERP — Powered by Barkat Tech',
    );

    // Subject names from the first student (or common subjects)
    final subjectNames = students.isNotEmpty
        ? students.first.subjects.map((s) => s.subjectName).toList()
        : <String>[];

    // Compute Summary Stats
    final totalEnrolled = students.length;
    final passedCount = students.where((s) => s.isPassed).length;
    final failedCount = students.where((s) => !s.isPassed && !s.isAbsent).length;
    final absentCount = students.where((s) => s.isAbsent).length;
    final passRate = totalEnrolled > 0 ? (passedCount / totalEnrolled) * 100 : 0.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Landscape Header
              pw.Row(
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
                          color: _emeraldDark,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'CLASS TABULATION REGISTER & MASTER EXAMINATION GAZETTE',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _goldPrimary,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Class: $className | Course: $courseName',
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Academic Session: $session | Total Students: $totalEnrolled',
                        style: const pw.TextStyle(fontSize: 8.5, color: _textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: _goldPrimary, thickness: 1),
              pw.SizedBox(height: 6),

              // Master Grid Table
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: _borderColor, width: 0.5),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: _emeraldDark),
                      children: [
                        _tabHeaderCell('#', width: 22),
                        _tabHeaderCell('Roll', width: 34),
                        _tabHeaderCell('Student Name', width: 110, align: pw.TextAlign.left),
                        _tabHeaderCell("Father's Name", width: 95, align: pw.TextAlign.left),
                        for (final subj in subjectNames) ...[
                          _tabHeaderCell(
                            subj.length > 10 ? '${subj.substring(0, 9)}.' : subj,
                          ),
                        ],
                        _tabHeaderCell('Total (600)', width: 48),
                        _tabHeaderCell('%', width: 36),
                        _tabHeaderCell('Div', width: 44),
                        _tabHeaderCell('Result', width: 46),
                        _tabHeaderCell('Rank', width: 32),
                      ],
                    ),

                    // Student Rows
                    for (int i = 0; i < students.length; i++) ...[
                      _buildTabulationStudentRow(i + 1, students[i]),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Bottom Analytics & Signatures
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _emeraldLight,
                  border: pw.Border.all(color: _emeraldDark, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Enrolled: $totalEnrolled  |  Passed: $passedCount  |  Failed: $failedCount  |  Absent: $absentCount  |  Pass Rate: ${passRate.toStringAsFixed(1)}%',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _emeraldDark,
                      ),
                    ),
                    pw.Row(
                      children: [
                        pw.Text('Tabulator Sign: ___________  ', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('Controller Sign: ___________  ', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('Principal Stamp: ___________', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.TableRow _buildTabulationStudentRow(int index, StudentResultModel student) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: index.isEven ? const PdfColor.fromInt(0xFFF9FAFB) : PdfColors.white,
      ),
      children: [
        _tabCell('$index'),
        _tabCell(student.rollNo, isBold: true),
        _tabCell(student.nameEnglish, align: pw.TextAlign.left),
        _tabCell(student.fatherNameEnglish, align: pw.TextAlign.left),
        for (final subj in student.subjects) ...[
          _tabCell(
            subj.isAbsent ? 'ABS' : '${subj.obtainedMarks ?? 0}',
            color: subj.isAbsent || (subj.obtainedMarks ?? 0) < subj.minMarks ? _failRed : _textDark,
          ),
        ],
        _tabCell('${student.totalObtained}', isBold: true),
        _tabCell('${student.percentage.toStringAsFixed(0)}%'),
        _tabCell(student.division),
        _tabCell(
          student.resultStatus,
          color: student.isPassed ? _passGreen : _failRed,
          isBold: true,
        ),
        _tabCell(student.rank != null ? '#${student.rank}' : '-'),
      ],
    );
  }

  static pw.Widget _tabHeaderCell(
    String text, {
    double? width,
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    final w = pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: align,
        maxLines: 1,
      ),
    );
    return width != null ? pw.Container(width: width, child: w) : w;
  }

  static pw.Widget _tabCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
    PdfColor color = _textDark,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          color: color,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
        maxLines: 1,
      ),
    );
  }
}
