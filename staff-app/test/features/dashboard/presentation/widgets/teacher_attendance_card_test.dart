import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/teacher_attendance_card.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('TeacherAttendanceCard Test Suite', () {
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
            home: Scaffold(
              body: TeacherAttendanceCard(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('My Attendance Record'), findsOneWidget);
        expect(find.text('Present'), findsOneWidget);
        expect(find.text('Leaves'), findsOneWidget);
        expect(find.text('Absent'), findsOneWidget);
        expect(find.text('Rate'), findsOneWidget);
      });
    }
  });
}
