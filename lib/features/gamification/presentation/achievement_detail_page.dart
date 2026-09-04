import 'package:flutter/material.dart';

class AchievementDetailPage extends StatelessWidget {
  const AchievementDetailPage({required this.achievementId, super.key});

  final String achievementId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievement')),
      body: const SizedBox(),
    );
  }
}
