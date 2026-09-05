import 'package:flutter/material.dart';

class DayDetailPage extends StatelessWidget {
  const DayDetailPage({required this.date, super.key});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(date)),
      body: const SizedBox(),
    );
  }
}
