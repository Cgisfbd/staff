import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';

class MockSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

void main() {
  group('LocaleCubit & AppStrings Multi-Lingual Architecture', () {
    late MockSecureStorageService mockStorage;
    late LocaleCubit localeCubit;

    setUp(() {
      mockStorage = MockSecureStorageService();
      localeCubit = LocaleCubit(secureStorage: mockStorage);
    });

    tearDown(() {
      localeCubit.close();
    });

    test('initial state should be English LTR', () {
      expect(localeCubit.state.locale, equals(const Locale('en')));
      expect(localeCubit.state.isRtl, isFalse);
      expect(localeCubit.state.fontFamily, isNull);
    });

    test('setting Urdu (ur) switches to RTL with Alyamama font', () {
      localeCubit.setLocale('ur');

      expect(localeCubit.state.locale, equals(const Locale('ur')));
      expect(localeCubit.state.isRtl, isTrue);
      expect(localeCubit.state.fontFamily, equals('Alyamama'));
    });

    test('setting Hindi (hi) switches to LTR with NotoSansDevanagari font', () {
      localeCubit.setLocale('hi');

      expect(localeCubit.state.locale, equals(const Locale('hi')));
      expect(localeCubit.state.isRtl, isFalse);
      expect(localeCubit.state.fontFamily, equals('NotoSansDevanagari'));
    });

    test('AppStrings provides correct translations across all 3 languages', () {
      expect(AppStrings.get('sign_in', 'en'), equals('Sign In'));
      expect(AppStrings.get('sign_in', 'ur'), equals('لاگ ان کریں'));
      expect(AppStrings.get('sign_in', 'hi'), equals('साइन इन करें'));

      expect(AppStrings.get('staff_portal', 'en'), equals('STAFF PORTAL'));
      expect(AppStrings.get('staff_portal', 'ur'), equals('اسٹاف پورٹل'));
      expect(AppStrings.get('staff_portal', 'hi'), equals('स्टाफ़ पोर्टल'));
    });

    test('AppStrings param interpolation replaces tokens correctly', () {
      final welcome = AppStrings.get('welcome_success', 'en', params: {'username': 'Ahmed'});
      expect(welcome, equals('Welcome, Ahmed! Signed in successfully.'));
    });
  });
}
