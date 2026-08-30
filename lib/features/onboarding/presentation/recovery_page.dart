import 'package:flutter/material.dart';

/// ERR-01. Reached when the database fails to open — offers Import or
/// Reset in a later phase; this foundation pass only needs the
/// placeholder destination to exist so the redirect gate has somewhere
/// real to send the user.
class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Recovery')),
      body: const SizedBox(),
    );
  }
}
