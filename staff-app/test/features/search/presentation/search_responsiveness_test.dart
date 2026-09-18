import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/search/presentation/pages/search_page.dart';

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

  group('SearchPage Universal Screen Responsiveness Suite', () {
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
      Size(320, 568),
      Size(360, 640),
      Size(393, 852),
      Size(600, 1024),
    ];

    for (final size in testSizes) {
      testWidgets('SearchPage 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapWithProviders(const SearchPage()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Type to search students, modules, and notices...'), findsOneWidget);
      });
    }

    testWidgets('Live search shows no results found when querying non-existent or empty dataset', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SearchPage()));
      await tester.pumpAndSettle();

      // Enter query "Zaid"
      await tester.enterText(find.byType(TextField), 'Zaid');
      await tester.pumpAndSettle();

      expect(find.text('No matching results found'), findsOneWidget);
    });

    testWidgets('Category filter pills switch without overflow', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SearchPage()));
      await tester.pumpAndSettle();

      // Tap "Students" filter pill
      await tester.tap(find.text('Students'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
