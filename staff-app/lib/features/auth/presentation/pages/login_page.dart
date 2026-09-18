import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_bottom_sheet_card.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_top_bar.dart';
import 'package:staff_app/features/auth/presentation/widgets/login_top_header.dart';

/// Screen Orchestrator for Staff Login (< 80 lines).
/// Dedicated Top Bar, Brand Header, and 50% Liquid Glass Bottom Sheet with Unified Toast Notifications.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppSnackBar.showSuccess(
              context,
              context.tr('welcome_success', params: {'username': state.user.username}),
            );
            context.go(RouteNames.dashboard);
          } else if (state is AuthFailureState) {
            AppSnackBar.showError(context, state.errorMessage);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: AppBackground(
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoginTopBar(),
                              LoginTopHeader(),
                            ],
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight * 0.50),
                            child: const LoginBottomSheetCard(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
