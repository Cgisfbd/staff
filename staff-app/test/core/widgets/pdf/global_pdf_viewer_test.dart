import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';

Future<Uint8List> _generateTestPdfBytes() async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(
            'TaleemOne ERP Institutional Test Document',
            style: const pw.TextStyle(fontSize: 24),
          ),
        );
      },
    ),
  );
  return doc.save();
}

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('en'), Size? size}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [
      Locale('en'),
      Locale('ur'),
      Locale('hi'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: MediaQuery(
      data: MediaQueryData(size: size ?? const Size(393, 852)),
      child: child,
    ),
  );
}

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('Google Drive Style GlobalPdfViewer Test Suite', () {
    const viewports = [
      Size(320, 568),
      Size(360, 640),
      Size(393, 852),
      Size(600, 1024),
    ];

    for (final vp in viewports) {
      testWidgets('Renders Google Drive PDF Viewer with 0-overflow on ${vp.width}x${vp.height}',
          (tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _wrapWithApp(
            const GlobalPdfViewer(
              title: 'Class Tabulation Sheet',
              subtitle: 'Aalimiyat 1st Year (2025-26)',
              fileName: 'Tabulation_AAL_1',
              pdfBytesFuture: _generateTestPdfBytes,
              isLandscape: true,
            ),
            size: vp,
          ),
        );

        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Class Tabulation Sheet'), findsOneWidget);
        expect(find.byType(GlobalPdfViewer), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
        expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
        expect(find.text('1 / 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Renders cleanly in RTL Urdu mode with 0-overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrapWithApp(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: GlobalPdfViewer(
              title: 'امتحانی نقشہ گزٹ',
              subtitle: 'سال اول عالمیات',
              fileName: 'Urdu_Gazette',
              pdfBytesFuture: _generateTestPdfBytes,
            ),
          ),
          locale: const Locale('ur'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('امتحانی نقشہ گزٹ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping document canvas toggles Google Drive top bar visibility', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const GlobalPdfViewer(
            title: 'Sample Document',
            fileName: 'Sample',
            pdfBytesFuture: _generateTestPdfBytes,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Initially top bar is at top: 0
      final initialFinder = find.byWidgetPredicate(
        (w) => w is AnimatedPositioned && w.top == 0,
      );
      expect(initialFinder, findsOneWidget);

      // Tap document canvas to auto-hide
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 300));

      // Top bar moved off-screen (top: -90)
      final hiddenFinder = find.byWidgetPredicate(
        (w) => w is AnimatedPositioned && w.top == -90,
      );
      expect(hiddenFinder, findsOneWidget);

      // Tap again to restore top bar
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 300));

      final restoredFinder = find.byWidgetPredicate(
        (w) => w is AnimatedPositioned && w.top == 0,
      );
      expect(restoredFinder, findsOneWidget);
    });

    testWidgets('Tapping search icon opens Google Drive in-document search bar', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const GlobalPdfViewer(
            title: 'Searchable Document',
            fileName: 'Doc_Search',
            pdfBytesFuture: _generateTestPdfBytes,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      // Find in document textfield is shown
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap close button to exit search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      // Back to standard title bar
      expect(find.text('Searchable Document'), findsOneWidget);
    });

    testWidgets('Tapping 3-dots overflow menu displays Google Drive options', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const GlobalPdfViewer(
            title: 'Menu Test Document',
            fileName: 'MenuDoc',
            pdfBytesFuture: _generateTestPdfBytes,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Tap 3-dots icon
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify menu items
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.print_outlined), findsOneWidget);
      expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });
}
