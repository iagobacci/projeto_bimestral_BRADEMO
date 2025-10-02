import 'package:flutter/material.dart';

class ActivityStatItem extends StatelessWidget {

  final String value;

  final String label;

  const ActivityStatItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }
}