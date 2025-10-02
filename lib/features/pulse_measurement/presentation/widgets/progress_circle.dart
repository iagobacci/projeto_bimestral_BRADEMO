import 'package:flutter/material.dart';
import 'package:trabalho01/core/theme/app_theme.dart';


// Widget que exibe a cápsula de progresso, ondas e porcentagem
class ProgressCircle extends StatelessWidget {
  final double progress; 

  const ProgressCircle({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    const double mainPillRadius = 50.5; 
    
    // Container principal
    return Container(
      width: 350, 
      padding: const EdgeInsets.symmetric(vertical: 15), 
      decoration: BoxDecoration(
        color: widgetsColor,
        borderRadius: BorderRadius.circular(20),
        // Borda preta ao redor do container
        border: Border.all(
          color: Colors.black,
          width: 2.0, 
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [

              // Ondas concêntricas estaticas
              ...List.generate(4, (index) {
                final double baseWidth = 100.0; 
                final double baseHeight = 140.0; 
                final double growthFactor = 30.0; 
                final double currentWidth = baseWidth + (index * growthFactor);
                final double currentHeight = baseHeight + (index * growthFactor);
                final double opacity = 0.05 + (index * 0.05); 
                final double borderRadius = mainPillRadius + (index * 15.0); 
                return Container(
                  width: currentWidth,
                  height: currentHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius), 
                    border: Border.all(
                      color: Colors.white.withOpacity(opacity),
                      width: 2.0,
                    ),
                  ),
                );
              }),
              
              // Área do desenho da cápsula e texto de porcentagem
              SizedBox(
                width: 100, 
                height: 120, 
                child: CustomPaint(
                  painter: _PillProgressPainter(progress: progress / 100.0), 
                  child: Center(
                    child: Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(
                        color: widgetsColor, 
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15), 
        
          const Text(
            'Medindo suas batidas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Lógica de desenho da cápsula de progresso
class _PillProgressPainter extends CustomPainter {
  final double progress;

  _PillProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double barWidth = 80.0; 
    final double horizontalPadding = (size.width - barWidth) / 2;
    final double radius = barWidth / 2; 
    
    final Rect fullRect = Rect.fromLTWH(horizontalPadding, 0, barWidth, size.height);

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.2) 
      ..style = PaintingStyle.fill;
      
    canvas.drawRRect(
      RRect.fromRectAndRadius(fullRect, Radius.circular(radius)), 
      trackPaint,
    );

    final double progressHeight = size.height * progress;
    final double startY = size.height - progressHeight;

    final Rect progressRect = Rect.fromLTWH(horizontalPadding, startY, barWidth, progressHeight);

    final progressPaint = Paint()
      ..color = baseGreen 
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        progressRect,
        topLeft: Radius.zero, 
        topRight: Radius.zero, 
        bottomLeft: Radius.circular(radius),  
        bottomRight: Radius.circular(radius), 
      ),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_PillProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}