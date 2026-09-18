import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/visitors/presentation/pages/visitor_scanner_page.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('VisitorScannerPage Comprehensive Test Suite', () {
    const testSizes = [
      Size(320, 568), // iPhone SE / Small 320dp Android
      Size(360, 640), // Budget Android
      Size(393, 852), // Flagship Phone
      Size(600, 1024), // Foldable / Tablet
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
            home: VisitorScannerPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Visitor Pass Scanner'), findsOneWidget);
        expect(find.text('Point at Visitor Pass QR Code'), findsOneWidget);
        expect(find.text('Tariq Mahmood'), findsOneWidget);
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
            child: VisitorScannerPage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VisitorScannerPage), findsOneWidget);
    });

    testWidgets('Manual card lookup, quota deduction, and quota exhaustion flow', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: VisitorScannerPage(),
        ),
      );
      await tester.pump();

      // 1. Initial seeded card check (Tariq Mahmood)
      expect(find.text('VIS-2026-881'), findsOneWidget);
      expect(find.text('Tariq Mahmood'), findsOneWidget);
      expect(find.text('Mohammad Zaid (Roll #101)'), findsOneWidget);
      expect(find.text('Confirm & Deduct 1 Visit'), findsOneWidget);

      // 2. Tap Deduct 1 Visit
      final deductBtn = find.text('Confirm & Deduct 1 Visit');
      await tester.ensureVisible(deductBtn);
      await tester.tap(deductBtn, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);

      // 3. Test Manual Search with Low-Quota Card (VIS-2026-882)
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'VIS-2026-882');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Shabbir Ahmad'), findsOneWidget);
      expect(find.text('Abdullah Khan (Roll #102)'), findsOneWidget);

      // 4. Test Manual Search with Exhausted Card (VIS-2026-883)
      await tester.enterText(inputFinder, 'VIS-2026-883');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Rashid Ali Qasmi'), findsOneWidget);
      expect(find.text('Umar Farooq (Roll #104)'), findsOneWidget);
      expect(find.text('Visit Quota Exhausted! No visits remaining.'), findsOneWidget);
      // Deduct button should be replaced by warning shield
      expect(find.text('Confirm & Deduct 1 Visit'), findsNothing);
    });
  });
}
