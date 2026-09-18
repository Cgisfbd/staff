import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/bloc/app_bloc_observer.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/l10n/locale_state.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/theme/app_theme.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/widgets/app_lock_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure System Overlay for edge-to-edge transparent mesh gradient
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 2. Set Central BLoC State Observer
  Bloc.observer = const AppBlocObserver();

  // 3. Initialize Dependency Injection Service Locator
  await initServiceLocator();

  // 4. Initialize Hardware AES-256 Encrypted Hive Local Storage
  try {
    await sl<HiveService>().init();
  } catch (e, st) {
    AppLogger.error('Storage bootstrap error during startup', e, st);
  }

  // 5. Initialize App Lock Enclave from Secure Storage before first frame
  try {
    await sl<AppLockCubit>().init();
  } catch (e, st) {
    AppLogger.error('App lock initialization error during startup', e, st);
  }

  runApp(const StaffApp());
}

/// Root Application Widget with Multi-Lingual & Dynamic Theme Support (< 105 lines).
class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<AppLockCubit>.value(value: sl<AppLockCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: '${AppConfig.appName} - ${AppConfig.appSubTitle}',
                debugShowCheckedModeBanner: false,
                locale: localeState.locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('ur'),
                  Locale('hi'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.lightTheme.copyWith(
                  textTheme: AppTheme.lightTheme.textTheme.apply(
                    fontFamily: localeState.fontFamily,
                  ),
                ),
                darkTheme: AppTheme.darkTheme.copyWith(
                  textTheme: AppTheme.darkTheme.textTheme.apply(
                    fontFamily: localeState.fontFamily,
                  ),
                ),
                themeMode: themeMode,
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  return AppLockGate(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
