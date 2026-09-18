import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:staff_app/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_bottom_sheet_card.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_card_header.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_top_bar.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_top_header.dart';
import '../bloc/auth_bloc_test.dart';

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

  group('Universal Screen Responsiveness & Zero-Overflow Suite', () {
    late _FakeSecureStorage storage;
    late MockAuthRepository authRepo;
    late AuthBloc authBloc;

    setUp(() {
      storage = _FakeSecureStorage();
      authRepo = MockAuthRepository();
      authBloc = AuthBloc(
        loginUseCase: LoginUseCase(authRepo),
        verify2faUseCase: Verify2FAUseCase(authRepo),
        authRepository: authRepo,
      );
    });

    tearDown(() => authBloc.close());

    const testScreenSizes = [
      Size(320, 568),  // Ultra-compact phone (iPhone SE 1st gen)
      Size(360, 640),  // Compact Android (Infinix, Redmi)
      Size(393, 852),  // Modern standard phone (iPhone 14/15)
      Size(412, 915),  // Large Android (Pixel, Samsung S23+)
      Size(600, 1024), // Small tablet / foldable
    ];

    for (final size in testScreenSizes) {
      testWidgets('LoginBottomSheetCard 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LocaleCubit(secureStorage: storage)),
              BlocProvider(create: (_) => ThemeCubit(secureStorage: storage)),
              BlocProvider<AuthBloc>.value(value: authBloc),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(child: LoginBottomSheetCard()),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Zero overflow on ${size.width} width');
      });

      testWidgets('LoginCardHeader 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LocaleCubit(secureStorage: storage)),
              BlocProvider(create: (_) => ThemeCubit(secureStorage: storage)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SizedBox(width: double.infinity, child: LoginCardHeader()),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Zero overflow on ${size.width} width');
      });
    }

    testWidgets('LoginTopBar and LoginTopHeader 0-overflow on 320 width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LocaleCubit(secureStorage: storage)),
            BlocProvider(create: (_) => ThemeCubit(secureStorage: storage)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(children: [LoginTopBar(), LoginTopHeader()]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
