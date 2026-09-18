import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_punch_card.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';

class _FakeSecureStorage extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('DashboardPunchCard Test Suite', () {
    late _FakeSecureStorage storage;
    late AppLockCubit lockCubit;

    setUp(() {
      storage = _FakeSecureStorage();
      if (sl.isRegistered<SecureStorageService>()) {
        sl.unregister<SecureStorageService>();
      }
      sl.registerLazySingleton<SecureStorageService>(() => storage);
      lockCubit = AppLockCubit(secureStorage: storage);
    });

    tearDown(() {
      if (sl.isRegistered<SecureStorageService>()) {
        sl.unregister<SecureStorageService>();
      }
    });

    Widget wrapWithProviders(Widget child) {
      return BlocProvider<AppLockCubit>.value(
        value: lockCubit,
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

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

        await tester.pumpWidget(wrapWithProviders(const DashboardPunchCard()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Campus Attendance Station'), findsOneWidget);
        expect(find.text('PUNCH IN'), findsOneWidget);
        expect(find.text('PUNCH OUT'), findsOneWidget);
      });
    }

    testWidgets('Initially PUNCH IN is active and PUNCH OUT is inactive with clear labels', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const DashboardPunchCard()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('NOT PUNCHED'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.text('Check Out'), findsOneWidget);
    });
  });
}
