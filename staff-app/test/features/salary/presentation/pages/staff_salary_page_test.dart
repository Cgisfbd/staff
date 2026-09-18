import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/salary/presentation/pages/staff_salary_page.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('StaffSalaryPage Multi-Lingual & RTL Test Suite', () {
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
            home: StaffSalaryPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('My Salary'), findsOneWidget);
        expect(find.text('Annual Compensation'), findsOneWidget);
        expect(find.text('Total Annual Package'), findsOneWidget);
        expect(find.text('Received'), findsOneWidget);
        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('Upcoming Est.'), findsOneWidget);
        expect(find.text('Monthly Payout Trend'), findsOneWidget);
        expect(find.text('Disbursement Ratio'), findsOneWidget);
        if (size.height > 600) {
          expect(find.text('Monthly Statements'), findsOneWidget);
        }
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
            child: StaffSalaryPage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(StaffSalaryPage), findsOneWidget);
    });

    testWidgets('Late arrival penalty and advance recovery render inside expanded card', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffSalaryPage(),
        ),
      );
      await tester.pump();

      // First card is expanded by default, scroll to ensure visibility
      final baseSalaryFinder = find.text('Base Salary (Fixed)');
      await tester.scrollUntilVisible(baseSalaryFinder, 100);
      await tester.pumpAndSettle();

      expect(baseSalaryFinder, findsOneWidget);
      expect(find.text('Late Arrival Penalty (3 days)'), findsOneWidget);
      expect(find.text('Advance Recovery'), findsOneWidget);
      expect(find.text('- ₹300.00'), findsOneWidget);

      // Scroll back up slightly to tap the card header to collapse
      final cardHeaderFinder = find.byIcon(Icons.payments_rounded).first;
      await tester.scrollUntilVisible(cardHeaderFinder, -50);
      await tester.pumpAndSettle();

      await tester.tap(cardHeaderFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Late Arrival Penalty (3 days)'), findsNothing);
    });
  });
}
