import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:staff_app/features/settings/presentation/widgets/settings_app_lock_card.dart';
import 'package:staff_app/features/settings/presentation/widgets/settings_diagnostics_card.dart';
import 'package:staff_app/features/settings/presentation/widgets/settings_legal_card.dart';
import 'package:staff_app/features/settings/presentation/widgets/settings_preferences_card.dart';
import 'package:staff_app/features/settings/presentation/widgets/settings_profile_card.dart';

/// Executive Settings & Enclave Preferences Page (< 145 lines).
/// Strictly styled to mirror the luxury aesthetic of the Mega Menu Page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (_) => sl<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<AppLockCubit>.value(
          value: sl<AppLockCubit>(),
        ),
      ],
      child: Scaffold(
        body: AppBackground(
          useSafeArea: false,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Executive Bar matching Mega Menu
                ExecutiveTopHeader(
                  icon: Icons.settings_suggest_rounded,
                  title: context.tr('settings_title'),
                  subtitle: context.tr('settings_subtitle'),
                ),
                // 2. Scrollable Body containing the 5 Refined Luxury Cards
                const Expanded(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsProfileCard(),
                        SizedBox(height: 12),
                        SettingsPreferencesCard(),
                        SizedBox(height: 12),
                        SettingsAppLockCard(),
                        SizedBox(height: 12),
                        SettingsLegalCard(),
                        SizedBox(height: 12),
                        SettingsDiagnosticsCard(),
                        SizedBox(height: 96), // Clearance for bottom navigation bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
