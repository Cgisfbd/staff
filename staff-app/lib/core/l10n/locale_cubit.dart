import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';

/// Central Cubit managing multi-lingual state and RTL switching (< 65 lines).
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage,
        super(const LocaleState(locale: Locale('en'), isRtl: false));

  final SecureStorageService _secureStorage;
  static const String _storageKey = 'app_user_locale';

  Future<void> init() async {
    final savedCode = await _secureStorage.getString(_storageKey);
    if (savedCode != null && ['en', 'ur', 'hi'].contains(savedCode)) {
      setLocale(savedCode);
    }
  }

  void setLocale(String languageCode) {
    if (!['en', 'ur', 'hi'].contains(languageCode)) return;

    _secureStorage.setString(_storageKey, languageCode);

    switch (languageCode) {
      case 'ur':
        emit(
          const LocaleState(
            locale: Locale('ur'),
            isRtl: true,
            fontFamily: 'Alyamama',
          ),
        );
        break;
      case 'hi':
        emit(
          const LocaleState(
            locale: Locale('hi'),
            isRtl: false,
            fontFamily: 'NotoSansDevanagari',
          ),
        );
        break;
      case 'en':
      default:
        emit(
          const LocaleState(
            locale: Locale('en'),
            isRtl: false,
          ),
        );
        break;
    }
  }
}
