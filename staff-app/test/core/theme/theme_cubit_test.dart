import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';

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
  group('ThemeCubit Dynamic Light/Dark Architecture', () {
    late MockSecureStorageService mockStorage;
    late ThemeCubit themeCubit;

    setUp(() {
      mockStorage = MockSecureStorageService();
      themeCubit = ThemeCubit(secureStorage: mockStorage);
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state should be ThemeMode.light by default', () {
      expect(themeCubit.state, equals(ThemeMode.light));
    });

    test('toggleTheme should toggle between light and dark', () {
      expect(themeCubit.state, equals(ThemeMode.light));

      themeCubit.toggleTheme();
      expect(themeCubit.state, equals(ThemeMode.dark));

      themeCubit.toggleTheme();
      expect(themeCubit.state, equals(ThemeMode.light));
    });

    test('init should restore persisted dark mode', () async {
      await mockStorage.setString('app_theme_mode', 'dark');

      final freshCubit = ThemeCubit(secureStorage: mockStorage);
      await freshCubit.init();

      expect(freshCubit.state, equals(ThemeMode.dark));
      await freshCubit.close();
    });

    test('setThemeMode should persist the selected mode', () async {
      themeCubit.setThemeMode(ThemeMode.dark);
      expect(await mockStorage.getString('app_theme_mode'), equals('dark'));

      themeCubit.setThemeMode(ThemeMode.light);
      expect(await mockStorage.getString('app_theme_mode'), equals('light'));
    });
  });
}
