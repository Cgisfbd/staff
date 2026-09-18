import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/notifications/presentation/pages/notifications_page.dart';

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

  group('NotificationsPage Universal Screen Responsiveness Suite', () {
    late _FakeSecureStorage storage;

    setUp(() {
      storage = _FakeSecureStorage();
    });

    Widget wrapWithProviders(Widget child) {
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
      Size(320, 568), // 320dp small phone (iPhone SE)
      Size(360, 640), // Budget Android
      Size(393, 852), // iPhone standard
      Size(600, 1024), // Tablet
    ];

    for (final size in testSizes) {
      testWidgets('NotificationsPage 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapWithProviders(const NotificationsPage()),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Yesterday'), findsOneWidget);
      });
    }

    testWidgets('Date filter switches to Yesterday and filters items correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const NotificationsPage()),
      );
      await tester.pumpAndSettle();

      // Tap on Yesterday chip
      await tester.tap(find.text('Yesterday'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Leave Request Approved'), findsOneWidget);
    });
  });
}
