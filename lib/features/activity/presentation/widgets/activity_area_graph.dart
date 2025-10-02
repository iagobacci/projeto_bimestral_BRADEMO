import 'package:flutter/material.dart';
import 'package:trabalho01/core/theme/app_theme.dart'; 
import 'dart:math';

class ActivityAreaGraph extends StatelessWidget {
  final Color backgroundColor;
  final int stepsValue;
  final List<Offset> graphPoints;

  const ActivityAreaGraph({
    super.key,
    required this.backgroundColor,
    required this.stepsValue,
    required this.graphPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Formata o valor dos passos para leitura (ex: 5.845)
    final formattedSteps = stepsValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200, 
            width: double.infinity,
            child: CustomPaint(
              painter: _AreaGraphPainter(
                baseColor: baseGreen, 
                points: graphPoints,
                // Gera um número aleatório entre 10 e 30
                randomPercentage: (Random().nextInt(21) + 10), 
              ), 
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Text(formattedSteps, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)), 
              const Text('Passos', style: TextStyle(color: Colors.white54, fontSize: 14)), 
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaGraphPainter extends CustomPainter {
  final Color baseColor;
  final List<Offset> points; 
  final int randomPercentage; 

  _AreaGraphPainter({required this.baseColor, required this.points, required this.randomPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return; 

    final scaledPoints = points.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

    final areaPath = Path()..moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    
    for (int i = 0; i < scaledPoints.length - 1; i++) {
        final current = scaledPoints[i];
        final next = scaledPoints[i + 1];
        
        final c1x = current.dx + (next.dx - current.dx) * 0.5;
        final c1y = current.dy;
        
        final c2x = current.dx + (next.dx - current.dx) * 0.5;
        final c2y = next.dy;

        areaPath.cubicTo(c1x, c1y, c2x, c2y, next.dx, next.dy);
    }
    
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..color = baseColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(scaledPoints.first.dx, scaledPoints.first.dy);

    for (int i = 0; i < scaledPoints.length - 1; i++) {
        final current = scaledPoints[i];
        final next = scaledPoints[i + 1];
        
        final c1x = current.dx + (next.dx - current.dx) * 0.5;
        final c1y = current.dy;
        
        final c2x = current.dx + (next.dx - current.dx) * 0.5;
        final c2y = next.dy;

        linePath.cubicTo(c1x, c1y, c2x, c2y, next.dx, next.dy);
    }

    final linePaint = Paint()
      ..color = baseColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke; 
      
    canvas.drawPath(linePath, linePaint);

    final highlightPoint = scaledPoints.last; 
    final highlightPaint = Paint()..color = Colors.white; 
    
    canvas.drawCircle(highlightPoint, 5.0, highlightPaint);
    
    final percentageRect = Rect.fromCenter(
      center: Offset(highlightPoint.dx - 10, highlightPoint.dy - 20),
      width: 40, 
      height: 20
    );
    final percentagePaint = Paint()..color = baseColor.withOpacity(0.8);
    canvas.drawRRect(
        RRect.fromRectAndRadius(percentageRect, const Radius.circular(5)),
        percentagePaint);
        
    final textSpan = TextSpan(
      text: '$randomPercentage%', 
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    final textOffset = Offset(
      percentageRect.center.dx - textPainter.width / 2,
      percentageRect.center.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _AreaGraphPainter oldDelegate) => oldDelegate.points != points || oldDelegate.randomPercentage != randomPercentage;
}