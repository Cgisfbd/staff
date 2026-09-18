import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/examination/presentation/pages/student_marks_entry_page.dart';
import 'package:staff_app/features/examination/presentation/widgets/cascading_academic_selector.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('StudentMarksEntryPage Comprehensive Test Suite', () {
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
            home: StudentMarksEntryPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Marks Entry'), findsOneWidget);
        expect(find.byType(CascadingAcademicSelector), findsOneWidget);
        expect(find.text('Select Course, Class, Subject & Book above to load students'), findsOneWidget);
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
            child: StudentMarksEntryPage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(StudentMarksEntryPage), findsOneWidget);
    });

    testWidgets('Roster loading, absentee lock shield, ceiling protection, and server batch save', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: StudentMarksEntryPage(),
        ),
      );
      await tester.pump();

      // 1. Select 4-tier hierarchy
      final dropdowns = find.byWidgetPredicate((w) => w is DropdownButton);
      expect(dropdowns, findsNWidgets(4));

      // Select Course
      await tester.tap(dropdowns.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aalimiyat Degree Course').last);
      await tester.pumpAndSettle();

      // Select Class
      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aalimiyat 1st Year (Section A)').last);
      await tester.pumpAndSettle();

      // Select Subject
      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Islamic Jurisprudence (Fiqh)').last);
      await tester.pumpAndSettle();

      // Select Book
      await tester.tap(dropdowns.at(3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Noor-ul-Izah (Kitab-ut-Taharah & Salah) • (100 Marks)').last);
      await tester.pumpAndSettle();

      // Roster loaded!
      expect(find.text('MAX: 100'), findsOneWidget);
      expect(find.text('7 Students'), findsOneWidget);
      expect(find.text('Mohammad Zaid'), findsOneWidget);
      expect(find.text('Abdullah Khan'), findsOneWidget);
      expect(find.text('Fatima Zahra'), findsOneWidget);
      expect(find.text('Umar Farooq'), findsOneWidget);
      expect(find.text('Aisha Siddiqua'), findsOneWidget);
      expect(find.text('Bilal Ahmad'), findsOneWidget);
      expect(find.text('Zubair Qasmi'), findsOneWidget);

      // STRICT ABSENTEE PROTECTION CHECK:
      // Abdullah Khan (Roll #102) & Aisha Siddiqua (Roll #105) were absent on exam day
      expect(find.text('ABSENT'), findsNWidgets(2));
      expect(find.text('Marked Absent in Hall Roll Call'), findsOneWidget);
      expect(find.text('Medical Leave / Absent'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2));

      // Present students have text fields (5 present out of 7)
      final markFields = find.byType(TextField);
      expect(markFields, findsNWidgets(5));

      // Test Max Marks Ceiling Enforcement
      // Type 150 into student marks field (max is 100)
      final firstStudentField = markFields.first;
      await tester.enterText(firstStudentField, '150');
      await tester.pump();

      // Text should auto clamp to maxMarks (100)
      expect(find.descendant(of: firstStudentField, matching: find.text('100')), findsOneWidget);

      // Scroll down to access Save button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap Save Button
      final saveBtn = find.text('Save Marks to Server');
      expect(saveBtn, findsOneWidget);

      await tester.tap(saveBtn, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
    });
  });
}
