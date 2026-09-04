import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'flow_bottom_nav.dart';

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
      bottomNavigationBar: FlowBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          FlowNavDestination(
            iconAsset: 'assets/icons/onboarding/icon-home.svg',
            label: loc.navHome,
          ),
          FlowNavDestination(
            iconAsset: 'assets/icons/onboarding/icon-chart.svg',
            label: loc.navProgress,
          ),
          FlowNavDestination(
            iconAsset: 'assets/icons/onboarding/icon-trophy-nav.svg',
            label: loc.navAwards,
          ),
          FlowNavDestination(
            iconAsset: 'assets/icons/onboarding/icon-person.svg',
            label: loc.navProfile,
          ),
        ],
      ),
    );
  }
}
