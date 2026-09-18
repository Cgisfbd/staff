import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/features/staff_attendance/presentation/pages/staff_manual_attendance_page.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await sl.reset();
    await initServiceLocator();
  });

  group('StaffManualAttendancePage Zero-Overflow & Responsiveness Suite', () {
    const testSizes = [
      Size(320, 568),  // iPhone SE / narrow budget Android
      Size(360, 640),  // Standard budget Android
      Size(393, 852),  // iPhone 15 / Flagship Android
      Size(600, 1024), // 7-inch & 10-inch Tablets
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
            home: StaffManualAttendancePage(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.byType(StaffManualAttendancePage), findsOneWidget);
      });
    }
  });
}
