import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_state.dart';
import 'package:staff_app/features/splash/presentation/widgets/minimal_splash_footer.dart';
import 'package:staff_app/features/splash/presentation/widgets/minimal_splash_logo.dart';

/// Minimal FAANG-Grade Splash Page Orchestrator (< 55 lines).
/// Smoothly initializes system and auto-navigates to Login page on success.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..initialize(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashSuccess) {
            if (state.entity.hasActiveSession) {
              context.go(RouteNames.dashboard);
            } else {
              context.go(RouteNames.login);
            }
          } else if (state is SplashFailure) {
            context.go(RouteNames.login);
          }
        },
        child: Scaffold(
          body: AppBackground(
            child: BlocBuilder<SplashCubit, SplashState>(
              builder: (context, state) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Minimal Animated Centered Logo
                    const Center(
                      child: MinimalSplashLogo(),
                    ),

                    // Bottom Attribution Badge
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MinimalSplashFooter(state: state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
