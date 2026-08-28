import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/environment/app_environment.dart';
import '../core/widgets/bottom_navigation/app_bottom_navigation.dart';
import '../core/widgets/bottom_navigation/app_bottom_navigation_item.dart';
import '../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  // The UI Kit tab isn't one of the shell's branches — it's a plain
  // pushed route — so it's always the last item, one past the real
  // branches, rather than participating in navigationShell.goBranch().
  void _onItemSelected(BuildContext context, int index) {
    if (AppEnvironment.current.enableUiPlayground &&
        index == navigationShell.route.branches.length) {
      context.push('/ui-playground');
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onItemSelected: (index) {
          _onItemSelected(context, index);
        },
        items: [
          AppBottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: loc.navHome,
          ),
          AppBottomNavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: loc.navProfile,
          ),
          if (AppEnvironment.current.enableUiPlayground)
            const AppBottomNavigationItem(
              icon: Icons.widgets_outlined,
              activeIcon: Icons.widgets,
              label: 'UI Kit',
            ),
        ],
      ),
    );
  }
}
