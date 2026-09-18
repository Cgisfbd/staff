import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:staff_app/features/attendance/presentation/pages/qr_attendance_page.dart';
import 'package:staff_app/features/settings/presentation/widgets/pin_numpad_widget.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('QrAttendancePage Multi-Lingual & RTL Test Suite', () {
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
            home: QrAttendancePage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('QR Attendance'), findsOneWidget);
        expect(find.text('Universal Exam & Event Scanner'), findsOneWidget);
        expect(find.byType(MobileScanner), findsOneWidget);
        expect(find.text('Manual Roll Number Entry'), findsOneWidget);
        expect(find.text('Mark Present'), findsOneWidget);
        expect(find.text('In Current Batch'), findsOneWidget);
        expect(find.text('Session Attendance Batch'), findsOneWidget);
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
            child: QrAttendancePage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(QrAttendancePage), findsOneWidget);
    });

    testWidgets('Interactions: Manual Roll Entry, Single-Card Batch & Server Submission', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: QrAttendancePage(),
        ),
      );
      await tester.pump();

      // 1. Initial count check (2 pre-seeded records in batch)
      expect(find.text('2'), findsWidgets);
      expect(find.text('Mohammad Zaid'), findsOneWidget);
      expect(find.text('Abdullah Khan'), findsOneWidget);

      // 2. Mark student 103 (Fatima Zahra) using manual roll number input
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '103');
      await tester.pump();

      final markPresentBtn = find.text('Mark Present');
      await tester.tap(markPresentBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // VerifyServerPinDialog should now be visible asking for staff server PIN
      expect(find.text('Server Security PIN'), findsOneWidget);
      expect(find.text('#103'), findsOneWidget);

      // Enter 6-digit server staff security PIN (123456)
      await tester.pump(const Duration(milliseconds: 300));
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        final finder = find.descendant(
          of: find.byType(PinNumpadWidget),
          matching: find.text(digit),
        );
        await tester.tap(finder, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100)); // Render setState

      // Student is authorized and added to batch
      expect(find.text('Fatima Zahra'), findsOneWidget);
      expect(find.text('3'), findsWidgets);

      // 3. Mark 103 again (client gracefully handles duplicate without prompting PIN again)
      await tester.enterText(searchField, '103');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(markPresentBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      // Batch count should remain 3, no duplicate blocked card created
      expect(find.text('3'), findsWidgets);

      // 4. Mark student 104 (Umar Farooq) with server PIN
      await tester.enterText(searchField, '104');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(markPresentBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Server Security PIN'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(
          find.descendant(
            of: find.byType(PinNumpadWidget),
            matching: find.text(digit),
          ),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100)); // Render setState

      expect(find.text('Umar Farooq'), findsOneWidget);
      expect(find.text('4'), findsWidgets);

      // 5. Finalize and Submit Batch to Server
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 300));

      final finalizeBtn = find.text('Submit Batch to Server');
      expect(finalizeBtn, findsOneWidget);

      await tester.tap(finalizeBtn, warnIfMissed: false);
      await tester.pump(); // Start async submit
      await tester.pump(const Duration(milliseconds: 800)); // Complete submit

      expect(tester.takeException(), isNull);
    });
  });
}
