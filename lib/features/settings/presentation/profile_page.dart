import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.navProfile)),
      body: const SizedBox(),
    );
  }
}
