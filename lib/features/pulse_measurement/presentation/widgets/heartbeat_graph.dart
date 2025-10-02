import 'package:flutter/material.dart';
import 'package:trabalho01/core/theme/app_theme.dart';

// Widget de exibição do gráfico de batimentos
class HeartbeatGraph extends StatelessWidget {

  final double height; 

  // Dados estáticos que definem o formato do grafico
  static const List<double> staticBeatData = [
    0.5, 0.5, 0.5, 0.5, 
    0.5, 1.5, 0.0, 1.0, 0.5, 
    0.5, 0.5, 0.5, 
    0.5, 1.5, 0.0, 1.0, 0.5, 
    0.5, 0.5, 0.5, 
    0.5, 1.5, 0.0, 1.0, 0.5, 
    0.5, 0.5, 0.5, 
    0.5, 1.5, 0.0, 1.0, 0.5, 
    0.5, 0.5, 0.5, 0.5,
  ];

  // Construtor que define a altura padrão
  const HeartbeatGraph({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, 
      width: double.infinity,
      child: CustomPaint(
        painter: _HeartbeatPainter(data: staticBeatData), 
      ),
    );
  }
}

// Lógica de desenho do gráfico
class _HeartbeatPainter extends CustomPainter {
  final List<double> data;

  _HeartbeatPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = baseGreen 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    const double minY = 0.0;
    const double maxY = 1.5;
    final double rangeY = maxY - minY;
    
    final double stepX = size.width / (data.length - 1);

    final double y0 = size.height * (1 - (data[0] - minY) / rangeY);
    path.moveTo(0, y0);

    for (int i = 1; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height * (1 - (data[i] - minY) / rangeY);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartbeatPainter oldDelegate) {
    return false; 
  }
}