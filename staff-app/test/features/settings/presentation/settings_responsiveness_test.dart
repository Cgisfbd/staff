import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:staff_app/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/settings/domain/entities/staff_profile_entity.dart';
import 'package:staff_app/features/settings/domain/repositories/profile_repository.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:staff_app/features/settings/presentation/pages/settings_page.dart';
import 'package:staff_app/features/settings/presentation/widgets/circular_photo_crop_dialog.dart';

class _FakeSecureStorage extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getUserProfile() async =>
      '{"id": "usr-1", "name": "Maulana Tariq", "username": "tariq.admin", "role": "SUPER_ADMIN"}';
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, StaffProfileEntity>> getProfile() async {
    return const Right(
      StaffProfileEntity(
        id: 'usr-1',
        username: 'tariq.admin',
        fullName: 'Maulana Tariq',
        role: 'SUPER_ADMIN',
        hasPin: true,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> changePin({
    required String password,
    required String newPin,
    String? currentPin,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, String?>> uploadAvatar({
    required List<int> bytes,
    required String fileName,
  }) async =>
      const Right('https://example.com/avatar.png');

  @override
  Future<Either<Failure, Map<String, dynamic>>> generate2FA() async =>
      const Right({'secret': 'JBSWY3DPEHPK3PXP', 'qrCodeDataUrl': 'data:image/png;base64,...'});

  @override
  Future<Either<Failure, void>> verify2FA(String token) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> disable2FA(String password) async =>
      const Right(null);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String username,
    required String password,
  }) async =>
      const Right(LoginResponseEntity(requires2fa: false));

  @override
  Future<Either<Failure, UserEntity>> verify2fa({
    required String tempToken,
    required String otp,
  }) async =>
      const Right(UserEntity(id: '1', username: 'admin', role: 'SUPER_ADMIN', isActive: true));

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}

void main() {
  late _FakeSecureStorage fakeStorage;
  late _FakeProfileRepository fakeProfileRepo;
  late _FakeAuthRepository fakeAuthRepo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    fakeStorage = _FakeSecureStorage();
    fakeProfileRepo = _FakeProfileRepository();
    fakeAuthRepo = _FakeAuthRepository();

    if (sl.isRegistered<SecureStorageService>()) await sl.unregister<SecureStorageService>();
    if (sl.isRegistered<ProfileRepository>()) await sl.unregister<ProfileRepository>();
    if (sl.isRegistered<ProfileCubit>()) await sl.unregister<ProfileCubit>();
    if (sl.isRegistered<AppLockCubit>()) await sl.unregister<AppLockCubit>();
    if (sl.isRegistered<HiveService>()) await sl.unregister<HiveService>();

    sl.registerSingleton<SecureStorageService>(fakeStorage);
    sl.registerSingleton<ProfileRepository>(fakeProfileRepo);
    sl.registerSingleton<HiveService>(HiveService(fakeStorage));
    sl.registerFactory<ProfileCubit>(() => ProfileCubit(
          profileRepository: fakeProfileRepo,
          secureStorage: fakeStorage,
        ));
    final appLockCubit = AppLockCubit(secureStorage: fakeStorage);
    await appLockCubit.init();
    sl.registerSingleton<AppLockCubit>(appLockCubit);
  });

  tearDown(() async {
    if (sl.isRegistered<SecureStorageService>()) await sl.unregister<SecureStorageService>();
    if (sl.isRegistered<ProfileRepository>()) await sl.unregister<ProfileRepository>();
    if (sl.isRegistered<ProfileCubit>()) await sl.unregister<ProfileCubit>();
    if (sl.isRegistered<AppLockCubit>()) await sl.unregister<AppLockCubit>();
    if (sl.isRegistered<HiveService>()) await sl.unregister<HiveService>();
  });

  Widget wrapWithProviders(Widget child, {String languageCode = 'en'}) {
    final localeCubit = LocaleCubit(secureStorage: fakeStorage);
    if (languageCode != 'en') {
      localeCubit.setLocale(languageCode);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(secureStorage: fakeStorage)),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(fakeAuthRepo),
            verify2faUseCase: Verify2FAUseCase(fakeAuthRepo),
            authRepository: fakeAuthRepo,
          ),
        ),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            locale: localeState.locale,
            home: child,
          );
        },
      ),
    );
  }

  const testSizes = [
    Size(320, 568), // 320dp small phone
    Size(360, 640), // Budget Android
    Size(393, 852), // iPhone standard
    Size(600, 1024), // Tablet
  ];

  group('Executive Settings Page Universal Responsiveness Suite', () {
    for (final size in testSizes) {
      testWidgets('SettingsPage 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        FlutterErrorDetails? errorDetails;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errorDetails = details;

        await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;
        if (errorDetails != null) debugPrint('FULL WIDGET ERROR:\n$errorDetails');
        expect(errorDetails, isNull);
        expect(find.text('Settings & Preferences'), findsOneWidget);
        expect(find.text('Staff Profile & Credentials'), findsOneWidget);
        expect(find.text('Preferences & Appearance'), findsOneWidget);
        expect(find.text('App Lock & Biometrics'), findsOneWidget);
        expect(find.text('Institutional Desk & Legal'), findsOneWidget);
        expect(find.text('Storage & Session Enclave'), findsOneWidget);
      });
    }

    testWidgets('SettingsPage renders properly in RTL Urdu mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage(), languageCode: 'ur'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ترتیبات اور ترجیحات'), findsOneWidget);
      expect(find.text('اسٹاف پروفائل اور اسناد'), findsOneWidget);
      expect(find.text('ترجیحات اور ظاہری شکل'), findsOneWidget);
      expect(find.text('ایپ لاک اور بائیو میٹرکس'), findsOneWidget);
      expect(find.text('ادارۂ جاتی ڈیسک اور قانونی معلومات'), findsOneWidget);
      expect(find.text('اسٹوریج اور سیشن'), findsOneWidget);
    });

    testWidgets('SettingsPage renders properly in Hindi mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage(), languageCode: 'hi'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('सेटिंग्स एवं प्राथमिकताएं'), findsOneWidget);
      expect(find.text('स्टाफ़ प्रोफ़ाइल एवं साख'), findsOneWidget);
      expect(find.text('प्राथमिकताएं एवं रूप'), findsOneWidget);
      expect(find.text('ऐप लॉक एवं बायोमेट्रिक्स'), findsOneWidget);
      expect(find.text('संस्थागत डेस्क एवं कानूनी सूचना'), findsOneWidget);
      expect(find.text('स्टोरेज एवं सत्र'), findsOneWidget);
    });

    testWidgets('Tapping Change Password opens modal bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final changePwdBtn = find.text('Change Password');
      expect(changePwdBtn, findsOneWidget);
      await tester.tap(changePwdBtn);
      await tester.pumpAndSettle();

      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
    });

    testWidgets('Tapping Change Server PIN opens modal bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final changePinBtn = find.text('Change Server PIN');
      expect(changePinBtn, findsOneWidget);
      await tester.tap(changePinBtn);
      await tester.pumpAndSettle();

      expect(find.text('New 6-Digit PIN'), findsOneWidget);
      expect(find.text('Confirm New PIN'), findsOneWidget);
    });

    testWidgets('Tapping Privacy Policy opens legal bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final privacyTile = find.text('Institutional Privacy Policy');
      await tester.ensureVisible(privacyTile);
      await tester.pumpAndSettle();

      expect(privacyTile, findsOneWidget);
      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy & Data Security'), findsOneWidget);
      expect(find.text('1. Single-Institute Dedicated VPS Model'), findsOneWidget);
    });

    testWidgets('Tapping Sign Out button shows confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final signOutBtn = find.text('Sign Out');
      await tester.ensureVisible(signOutBtn);
      await tester.pumpAndSettle();

      expect(signOutBtn, findsOneWidget);
      await tester.tap(signOutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to end your active session?'), findsOneWidget);
    });

    testWidgets('Tapping avatar opens PhotoPickerSheet with camera & gallery options', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final avatarTrigger = find.byKey(const ValueKey('avatar_picker_trigger'));
      expect(avatarTrigger, findsOneWidget);
      await tester.tap(avatarTrigger);
      await tester.pumpAndSettle();

      expect(find.text('Change Photo'), findsOneWidget);
      expect(find.text('Take New Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('CircularPhotoCropDialog renders with 0-overflow on 320dp screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1x1 transparent PNG bytes
      final sampleBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0,
        0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1,
        13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CircularPhotoCropDialog.show(context, imageBytes: sampleBytes),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Move and Scale'), findsOneWidget);
      expect(find.text('Set Photo'), findsOneWidget);
      expect(find.byIcon(Icons.rotate_90_degrees_cw_rounded), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Micro-headers are removed and 2FA tile renders in SettingsPage', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      // Verify micro-headers are completely removed
      expect(find.text('PORTAL PREFERENCES & SECURITY ENCLAVE'), findsNothing);
      expect(find.text('TIER-9 ENCLAVE'), findsNothing);

      // Verify 2FA tile is rendered in the profile card and security section
      expect(find.text('Two-Factor Authentication (2FA)'), findsWidgets);
      expect(find.text('SETUP'), findsWidgets);
    });

    testWidgets('Tapping 2FA tile opens TwoFactorSetupSheet with secret key and copy button', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final twoFaTile = find.text('Two-Factor Authentication (2FA)').first;
      expect(twoFaTile, findsOneWidget);

      await tester.tap(twoFaTile);
      await tester.pumpAndSettle();

      // Verify setup sheet elements
      expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
      expect(find.text('Copy Key'), findsOneWidget);
      expect(find.text('Verify & Activate 2FA'), findsOneWidget);
      expect(find.text('Enter 6-digit code from Google Authenticator'), findsOneWidget);
    });

    testWidgets('ChangePinSheet includes Current PIN, New PIN, Confirm PIN, and Password', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const SettingsPage()));
      await tester.pumpAndSettle();

      final changePinBtn = find.text('Change Server PIN');
      expect(changePinBtn, findsOneWidget);
      await tester.tap(changePinBtn);
      await tester.pumpAndSettle();

      expect(find.text('Current 6-Digit PIN'), findsOneWidget);
      expect(find.text('New 6-Digit PIN'), findsOneWidget);
      expect(find.text('Confirm New PIN'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
    });
  });
}
