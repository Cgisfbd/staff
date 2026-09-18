import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_state.dart';
import 'package:staff_app/features/settings/presentation/widgets/app_lock_overlay.dart';

/// Central Gatekeeper that enforces hardware App Lock on launch & resume (< 90 lines).
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final cubit = context.read<AppLockCubit>();
    if (lifecycle == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (lifecycle == AppLifecycleState.resumed) {
      if (_pausedAt != null && DateTime.now().difference(_pausedAt!).inSeconds >= 2) {
        if (cubit.state.isAppLockEnabled) {
          cubit.lock();
        }
      }
      _pausedAt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C1017),
            body: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                ),
              ),
            ),
          );
        }

        final showLock = state.isAppLockEnabled && state.isLocked;
        return Stack(
          textDirection: TextDirection.ltr,
          children: [
            widget.child,
            if (showLock)
              const Positioned.fill(
                child: AppLockOverlay(),
              ),
          ],
        );
      },
    );
  }
}
