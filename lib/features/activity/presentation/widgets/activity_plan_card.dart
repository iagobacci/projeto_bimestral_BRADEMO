import 'package:flutter/material.dart';

class ActivityPlanCard extends StatelessWidget {
  final String iconPath; 
  final String title;
  final String duration;
  final bool isLast;
  final Color cardColor; 
  final Color iconColor; 

  const ActivityPlanCard({
    super.key,
    required this.iconPath, 
    required this.title, 
    required this.duration, 
    this.isLast = false, 
    required this.cardColor, 
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, 
      // Margem lateral (zero se for o último cartão)
      margin: EdgeInsets.only(right: isLast ? 0 : 15), 
      padding: const EdgeInsets.all(10), 
      decoration: BoxDecoration(
        color: cardColor, // Fundo cinza escuro
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconPath, 
            color: iconColor,
            height: 24, 
            width: 24, 
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(duration, style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}