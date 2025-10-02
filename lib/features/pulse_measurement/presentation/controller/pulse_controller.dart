import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// O Controller tem métodos sem dados, apenas para exemplo de uso
class PulseController extends ChangeNotifier {
  // Estado estático 
  final bool _isRecording = true; 
  final double _currentProgress = 35.0; 
  
  // Getters
  bool get isRecording => _isRecording;
  double get currentProgress => _currentProgress;
  
  // Métodos de controle para uso futuro
  void startRecording() {

  }

  void stopRecording() {

  }

}