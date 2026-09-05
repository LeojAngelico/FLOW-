import 'package:flutter/material.dart';

import '../../../../core/design/components/brand_mark.dart';
import '../../../../core/design/tokens/flow_colors.dart';

/// `/` — matches the native launch screen so the handoff from it does
/// not flash (Decisions #6). `resolveRedirect` fires on
/// `initialLocation: '/'` before this can ever hold on screen — a first
/// run is redirected to `/onboarding/welcome`, a returning user to
/// `/home` — so it renders for, at most, the single frame between the
/// native splash and that redirect resolving.
///
/// No notifier, no timer, no spinner: the DB open/migrate/redirect
/// decision this screen was originally specced to cover already
/// happens in `main.dart` before `runApp` (`databaseHealthyProvider` is
/// a `main()` override). `CMP-18 Spinner` was dropped from this pass
/// with `ONB-01` — see the workplan's § Out of scope.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;

    return Scaffold(
      backgroundColor: colors.canvasGame,
      body: const Center(child: BrandMark()),
    );
  }
}
