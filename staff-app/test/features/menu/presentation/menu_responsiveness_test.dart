import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/menu/presentation/pages/menu_page.dart';

class _FakeSecureStorage extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getUserProfile() async => '{"role": "SUPER_ADMIN", "username": "admin"}';
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (sl.isRegistered<SecureStorageService>()) {
      await sl.unregister<SecureStorageService>();
    }
    sl.registerSingleton<SecureStorageService>(_FakeSecureStorage());
  });

  tearDown(() async {
    if (sl.isRegistered<SecureStorageService>()) {
      await sl.unregister<SecureStorageService>();
    }
  });

  Widget wrapWithProviders(Widget child) {
    final storage = sl<SecureStorageService>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit(secureStorage: storage)),
        BlocProvider(create: (_) => ThemeCubit(secureStorage: storage)),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  const testSizes = [
    Size(320, 568),  // 320dp small phone
    Size(360, 640),  // Budget Android
    Size(393, 852),  // iPhone standard
    Size(600, 1024), // Tablet
  ];

  group('Mega Menu Page Universal Screen Responsiveness Suite', () {
    for (final size in testSizes) {
      testWidgets('MenuPage 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapWithProviders(const MenuPage()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Students'), findsOneWidget);
        expect(find.text('All Students'), findsOneWidget);
      });
    }

    testWidgets('Tapping on Attendance in left rail switches right pane content', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const MenuPage()));
      await tester.pumpAndSettle();

      // Initial state: Students is selected
      expect(find.text('All Students'), findsOneWidget);

      // Tap on Attendance in Left Rail
      final attendanceRailItem = find.text('Attendance');
      expect(attendanceRailItem, findsOneWidget);
      await tester.tap(attendanceRailItem);
      await tester.pumpAndSettle();

      // Right pane now shows Attendance sub-items
      expect(find.text('Student Attendance'), findsOneWidget);
      expect(find.text('Staff Attendance'), findsOneWidget);
      expect(find.text('Monthly Register'), findsOneWidget);
      expect(find.text('QR Attendance'), findsOneWidget);
    });

    testWidgets('Tapping on a sub-card triggers instant floating SnackBar', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const MenuPage()));
      await tester.pumpAndSettle();

      final allStudentsCard = find.text('All Students');
      expect(allStudentsCard, findsOneWidget);
      await tester.tap(allStudentsCard);
      await tester.pump();

      expect(find.text('Opening All Students...'), findsOneWidget);
    });

    testWidgets('Switching to Urdu activates RTL and displays Nastaliq Urdu translations', (tester) async {
      final storage = sl<SecureStorageService>();
      final localeCubit = LocaleCubit(secureStorage: storage);
      localeCubit.setLocale('ur');

      final themeCubit = ThemeCubit(secureStorage: storage);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: localeCubit),
            BlocProvider.value(value: themeCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ur'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: MenuPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Urdu strings must render
      expect(find.text('طلباء'), findsOneWidget);
      expect(find.text('تمام طلباء'), findsOneWidget);
      // Verify micro-header is removed
      expect(find.text('آپریشنز ہب'), findsNothing);
    });

    testWidgets('Switching to Hindi displays Devanagari Hindi translations', (tester) async {
      final storage = sl<SecureStorageService>();
      final localeCubit = LocaleCubit(secureStorage: storage);
      localeCubit.setLocale('hi');

      final themeCubit = ThemeCubit(secureStorage: storage);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: localeCubit),
            BlocProvider.value(value: themeCubit),
          ],
          child: const MaterialApp(
            locale: Locale('hi'),
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: MenuPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hindi strings must render
      expect(find.text('छात्र'), findsOneWidget);
      expect(find.text('सभी छात्र'), findsOneWidget);
      // Verify micro-header is removed
      expect(find.text('संचालन हब'), findsNothing);
    });
  });
}
