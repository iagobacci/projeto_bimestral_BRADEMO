import 'package:flutter/material.dart';

class ActivityController extends ChangeNotifier {
  String _currentView = 'Dia';
  final int _baseSteps = 835;
  String get currentView => _currentView;
  
  List<Offset> get graphPoints {
    return _getFixedPointsForView(_currentView);
  }

  int get currentSteps {
    switch (_currentView) {
      case 'Dia':
        return _baseSteps;
      case 'Semana':
        return _baseSteps * 7;
      case 'Mês':
        return _baseSteps * 30;
      case 'Ano':
        return _baseSteps * 365;
      default:
        return _baseSteps;
    }
  }

  void setView(String view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  // Função central para retornar um conjunto de pontos estáticos para cada view
  List<Offset> _getFixedPointsForView(String view) {
    switch (view) {
      case 'Dia':
        return [
          Offset(0.0, 0.70), Offset(0.1, 0.50), Offset(0.2, 0.65), Offset(0.3, 0.40), 
          Offset(0.4, 0.60), Offset(0.5, 0.55), Offset(0.6, 0.70), Offset(0.7, 0.45), 
          Offset(0.8, 0.60), Offset(0.9, 0.50), Offset(1.0, 0.75)
        ];
      
      case 'Semana':
        return [
          Offset(0.0, 0.85), Offset(0.16, 0.40), Offset(0.32, 0.70), Offset(0.48, 0.25), 
          Offset(0.64, 0.65), Offset(0.80, 0.55), Offset(1.0, 0.40)
        ];

      case 'Mês':
        return [
          Offset(0.0, 0.70), Offset(0.25, 0.45), Offset(0.50, 0.60), 
          Offset(0.75, 0.50), Offset(1.0, 0.35)
        ];

      case 'Ano':
        return [
          Offset(0.0, 0.60), Offset(0.1, 0.75), Offset(0.2, 0.40), Offset(0.3, 0.65), 
          Offset(0.4, 0.30), Offset(0.5, 0.50), Offset(0.6, 0.70), Offset(0.7, 0.45), 
          Offset(0.8, 0.60), Offset(0.9, 0.40), Offset(1.0, 0.55)
        ];

      default:
        return [Offset(0.0, 0.75), Offset(1.0, 0.75)]; 
    }
  }
}