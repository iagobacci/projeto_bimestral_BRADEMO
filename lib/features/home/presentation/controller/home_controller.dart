import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import para FlSpot

class HomeController extends ChangeNotifier {
  // Simulação de dados que viriam de uma camada de domínio/data
  final String _userName = "Usuário";
  final String _userWeight = "60 KG";
  final String _userHeight = "1.75 M";
  final String _userAge = "25 anos";
  final String _heartRateAvg = "76 bpm";

  String get userName => _userName;
  String get userWeight => _userWeight;
  String get userHeight => _userHeight;
  String get userAge => _userAge;
  String get heartRateAvg => _heartRateAvg;

  // Getter para fornecer os dados do gráfico de batimentos
  List<FlSpot> get heartRateSpots => const [
      FlSpot(0, 70),
      FlSpot(1, 89),
      FlSpot(2, 75),
      FlSpot(3, 80),
      FlSpot(4, 68),
      FlSpot(5, 74),
      FlSpot(6, 72),
  ];

}