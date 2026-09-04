import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

/// The 4-tab root shell (Home/Progress/Awards/Profile), backed by a
/// `StatefulShellRoute.indexedStack` so each tab keeps its own
/// navigation stack across switches. See `app_router.dart`.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: loc.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_rounded),
            label: loc.navProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_rounded),
            label: loc.navAwards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            label: loc.navProfile,
          ),
        ],
      ),
    );
  }
}
