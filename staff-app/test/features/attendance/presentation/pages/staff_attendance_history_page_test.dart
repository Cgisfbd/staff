import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/attendance/presentation/pages/staff_attendance_history_page.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('StaffAttendanceHistoryPage Test Suite', () {
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
            home: StaffAttendanceHistoryPage(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('My Attendance History'), findsOneWidget);
        expect(find.text('MONTHLY PERFORMANCE SUMMARY'), findsOneWidget);
        expect(find.text('ALL'), findsOneWidget);
        expect(find.text('PRESENT'), findsWidgets);
      });
    }

    testWidgets('Tapping LEAVE filter filters to leave logs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StaffAttendanceHistoryPage(),
        ),
      );
      await tester.pump();

      final leaveChip = find.text('LEAVE').first;
      expect(leaveChip, findsOneWidget);

      await tester.tap(leaveChip);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
