import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/widgets/app_bottom_nav_bar.dart';

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

  group('AppBottomNavBar Universal Responsiveness & Interaction Suite', () {
    late _FakeSecureStorage storage;

    setUp(() {
      storage = _FakeSecureStorage();
    });

    Widget wrapWithProviders(Widget child, {String initialLocale = 'en'}) {
      final localeCubit = LocaleCubit(secureStorage: storage);
      if (initialLocale != 'en') localeCubit.setLocale(initialLocale);

      return BlocProvider.value(
        value: localeCubit,
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: child,
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
      testWidgets('5-tab Amazon-Style Nav Bar renders with 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        int tappedIndex = -1;
        await tester.pumpWidget(
          wrapWithProviders(
            AppBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AppBottomNavBar), findsOneWidget);

        // Verify tap on Menu tab (index 3)
        await tester.tap(find.byIcon(Icons.menu_rounded));
        await tester.pump();
        expect(tappedIndex, 3);
      });
    }

    testWidgets('Renders all 5 tabs in Urdu RTL without overflow', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          AppBottomNavBar(
            currentIndex: 1,
            onTap: (_) {},
          ),
          initialLocale: 'ur',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('حاضری'), findsOneWidget);
      expect(find.text('ای کتب'), findsOneWidget);
      expect(find.text('مینو'), findsOneWidget);
      expect(find.text('سیٹنگز'), findsOneWidget);
    });
  });
}
