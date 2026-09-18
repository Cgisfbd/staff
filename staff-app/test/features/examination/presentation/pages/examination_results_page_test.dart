import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/examination/data/datasources/results_mock_datasource.dart';
import 'package:staff_app/features/examination/domain/services/result_pdf_generator.dart';
import 'package:staff_app/features/examination/presentation/pages/examination_results_page.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('Examination Results & PDF Engine Test Suite', () {
    const testSizes = [
      Size(320, 568), // 320dp narrow phone
      Size(360, 640), // Budget Android
      Size(393, 852), // Flagship phone
      Size(600, 1024), // Tablet
    ];

    for (final size in testSizes) {
      testWidgets('Renders with 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: ExaminationResultsPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Examination Results'), findsOneWidget);
        expect(find.text('ACADEMIC HIERARCHY'), findsOneWidget);
        expect(find.text('Class Tabulation Sheet'), findsOneWidget);
      });
    }

    testWidgets('Renders cleanly in RTL Urdu Mode with 0-overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ur'),
          supportedLocales: [Locale('en'), Locale('ur'), Locale('hi')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ExaminationResultsPage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ExaminationResultsPage), findsOneWidget);
    });

    test('ResultPdfGenerator generates valid vector PDF binary for individual marksheet', () async {
      const datasource = ResultsMockDatasource();
      final students = datasource.getClassResults('cls_aal_1');
      expect(students, isNotEmpty);

      final student = students.first;
      final pdfBytes = await ResultPdfGenerator.generateStudentMarksheetPdf(student);

      expect(pdfBytes, isNotEmpty);
      // Verify PDF header magic bytes "%PDF-"
      final magicHeader = utf8.decode(pdfBytes.sublist(0, 5));
      expect(magicHeader, equals('%PDF-'));
    });

    test('ResultPdfGenerator generates valid landscape vector PDF binary for class tabulation', () async {
      const datasource = ResultsMockDatasource();
      final students = datasource.getClassResults('cls_aal_1');

      final pdfBytes = await ResultPdfGenerator.generateClassTabulationPdf(
        className: 'Aalimiyat 1st Year',
        courseName: 'Aalimiyat Degree Course',
        students: students,
        session: '2025-2026',
      );

      expect(pdfBytes, isNotEmpty);
      final magicHeader = utf8.decode(pdfBytes.sublist(0, 5));
      expect(magicHeader, equals('%PDF-'));
    });
  });
}
