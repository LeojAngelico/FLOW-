import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.navAwards)),
      body: const SizedBox(),
    );
  }
}
