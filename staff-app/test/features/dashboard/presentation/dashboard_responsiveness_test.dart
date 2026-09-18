import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_status_card.dart';

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

  group('Dashboard Universal Screen Responsiveness Suite', () {
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
          home: Scaffold(
            body: SingleChildScrollView(child: child),
          ),
        ),
      );
    }

    const testSizes = [
      Size(320, 568), // 320dp small phone
      Size(360, 640), // Budget Android
      Size(393, 852), // iPhone standard
      Size(600, 1024), // Tablet
    ];

    for (final size in testSizes) {
      testWidgets('Dashboard components 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapWithProviders(
            const Column(
              children: [
                DashboardHeader(username: 'ustad.ahmed', role: 'STAFF'),
                DashboardStatusCard(),
                DashboardQuickActions(),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('ustad.ahmed'), findsOneWidget);
        expect(find.text('STAFF'), findsOneWidget);
        expect(find.text('ONLINE'), findsOneWidget);
      });
    }
  });
}
