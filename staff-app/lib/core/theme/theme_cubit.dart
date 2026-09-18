import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';

/// Central Cubit managing dynamic ThemeMode (Light/Dark) with Hardware Keystore persistence (< 60 lines).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage,
        super(ThemeMode.light);

  final SecureStorageService _secureStorage;
  static const String _storageKey = 'app_theme_mode';

  Future<void> init() async {
    final savedMode = await _secureStorage.getString(_storageKey);
    if (savedMode == 'dark') {
      emit(ThemeMode.dark);
    } else if (savedMode == 'light') {
      emit(ThemeMode.light);
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    _secureStorage.setString(_storageKey, mode == ThemeMode.dark ? 'dark' : 'light');
    emit(mode);
  }
}
