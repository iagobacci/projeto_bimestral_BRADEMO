import 'package:flutter/material.dart';
import 'package:trabalho01/core/theme/app_theme.dart'; // Para baseGreen

class CustomBottomNav extends StatelessWidget {
  final Color componentColor;
  final VoidCallback onHomeTap;
  final VoidCallback onActivityTap; 
  final String activePath; 

  const CustomBottomNav({
    super.key, 
    required this.componentColor,
    required this.onHomeTap, 
    required this.onActivityTap,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {'path': 'assets/icons/icon1.png', 'action': onHomeTap}, 
      {'path': 'assets/icons/icon2.png', 'action': () {}},     
      {'path': 'assets/icons/icon3.png', 'action': () {}}, 
      {'path': 'assets/icons/icon4.png', 'action': onActivityTap},    
    ];
    
    const double iconSize = 30.0;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: componentColor, 
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Renderiza todos os itens de navegação
          ...navItems.map((item) {
            final tapAction = item['action'] as VoidCallback? ?? () {};
            // Determina se o ícone atual é o ícone ativo (verde)
            final bool isActive = item['path'] == activePath; 
            
            final color = isActive ? baseGreen : Colors.white70;

            return IconButton(
              padding: EdgeInsets.zero,
              icon: SizedBox( 
                width: iconSize,
                height: iconSize,
                child: Image.asset(
                  item['path'],
                  color: color, 
                ),
              ),
              onPressed: tapAction,
            );
          }),
        ],
      ),
    );
  }
}