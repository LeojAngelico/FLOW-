import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.navProgress)),
      body: const SizedBox(),
    );
  }
}
