import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/examination/presentation/pages/question_upload_page.dart';
import 'package:staff_app/features/examination/presentation/widgets/cascading_academic_selector.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('QuestionUploadPage Comprehensive Test Suite', () {
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
            home: QuestionUploadPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Question Upload'), findsOneWidget);
        expect(find.byType(CascadingAcademicSelector), findsOneWidget);
        expect(find.text('Select Course, Class, Subject & Book above to unlock'), findsOneWidget);
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
            child: QuestionUploadPage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(QuestionUploadPage), findsOneWidget);
    });

    testWidgets('Cascading selection unlocks form, accepts 10/15/20 chips and caps page at 1000', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: QuestionUploadPage(),
        ),
      );
      await tester.pump();

      // Form initially locked
      expect(find.text('Select Course, Class, Subject & Book above to unlock'), findsOneWidget);

      // 1. Select Course (Aalimiyat Degree Course)
      final dropdowns = find.byWidgetPredicate((w) => w is DropdownButton);
      expect(dropdowns, findsNWidgets(4));

      await tester.tap(dropdowns.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aalimiyat Degree Course').last);
      await tester.pumpAndSettle();

      // 2. Select Class (Aalimiyat 1st Year (Section A))
      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aalimiyat 1st Year (Section A)').last);
      await tester.pumpAndSettle();

      // 3. Select Subject (Islamic Jurisprudence (Fiqh))
      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Islamic Jurisprudence (Fiqh)').last);
      await tester.pumpAndSettle();

      // 4. Select Book (Noor-ul-Izah)
      await tester.tap(dropdowns.at(3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Noor-ul-Izah (Kitab-ut-Taharah & Salah) • (100 Marks)').last);
      await tester.pumpAndSettle();

      // Form is now unlocked! Locked overlay gone
      expect(find.text('Select Course, Class, Subject & Book above to unlock'), findsNothing);

      // Verify Staged questions loaded for this book (2 pre-seeded questions)
      expect(find.text('2 Questions'), findsOneWidget);
      expect(find.text('15 Marks'), findsWidgets);

      // Verify Fixed Marks Chips (10, 15, 20)
      final chip20 = find.text('20 Marks').first;
      await tester.tap(chip20);
      await tester.pump();

      // Test Page Number Limiting to 1000
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2)); // Question text & Page No

      final questionField = textFields.at(0);
      final pageNoField = textFields.at(1);

      await tester.enterText(questionField, 'Explain the rules of Mabni and Mu\'rab with examples.');
      await tester.pump();

      // Try typing 1500 in page number
      await tester.enterText(pageNoField, '1500');
      await tester.pump();

      // Should automatically cap at 1000
      final pageControllerFinder = find.descendant(
        of: pageNoField,
        matching: find.text('1000'),
      );
      expect(pageControllerFinder, findsOneWidget);

      // Tap Upload Button
      final uploadBtn = find.text('Upload Question to Bank');
      expect(uploadBtn, findsOneWidget);

      await tester.tap(uploadBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // After upload, count increases to 3 Questions
      expect(find.text('3 Questions'), findsOneWidget);
      expect(find.text('Explain the rules of Mabni and Mu\'rab with examples.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
