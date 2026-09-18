import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/widgets/app_bottom_nav_bar.dart';

/// Shell Scaffold providing persistent Liquid Crystal Glass Bottom Navigation (< 50 lines).
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
