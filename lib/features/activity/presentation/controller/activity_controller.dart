import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../atividade/domain/repositories/atividade_repository.dart';
import '../../../atividade/domain/entities/atividade_entity.dart';

class ActivityController extends ChangeNotifier {
  final AtividadeRepository? atividadeRepository;
  
  String _currentView = 'Dia';
  bool _isLoading = false;
  List<AtividadeEntity> _atividades = [];
  String? _alunoId;
  
  ActivityController({this.atividadeRepository}) {
    _loadAlunoId();
  }

  String get currentView => _currentView;
  bool get isLoading => _isLoading;
  
  List<Offset> get graphPoints {
    return _calculateGraphPoints();
  }

  int get currentSteps {
    return _calculateSteps();
  }
  
  double get currentDistance {
    return _calculateDistance();
  }
  
  int get currentCalories {
    return _calculateCalories();
  }
  
  String get currentTime {
    return _formatTime(_calculateTime());
  }

  void setView(String view) {
    if (_currentView != view) {
      _currentView = view;
      // Força recálculo imediato dos valores
      notifyListeners();
    }
  }
  
  Future<void> _loadAlunoId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final alunoQuery = await FirebaseFirestore.instance
          .collection('alunos')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (alunoQuery.docs.isNotEmpty) {
        _alunoId = alunoQuery.docs.first.id;
        _loadAtividades();
      }
    } catch (e) {
      // Erro ao buscar aluno
    }
  }

  Future<void> refreshUserData() async {
    // Recarregar dados do usuário atual apenas se necessário
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final alunoQuery = await FirebaseFirestore.instance
          .collection('alunos')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (alunoQuery.docs.isNotEmpty) {
        final newAlunoId = alunoQuery.docs.first.id;
        // Só recarregar se o aluno mudou
        if (_alunoId != newAlunoId) {
          _alunoId = newAlunoId;
          _atividades.clear();
          await _loadAtividades();
          notifyListeners();
        }
      }
    } catch (e) {
      // Erro ao buscar aluno
    }
  }
  
  Future<void> _loadAtividades() async {
    if (_alunoId == null || atividadeRepository == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _atividades = await atividadeRepository!.getAtividadesByAlunoId(_alunoId!);
    } catch (e) {
      _atividades = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Recarregar alunoId e atividades
      await _loadAlunoId();
      
      // Se tiver alunoId, carregar atividades
      if (_alunoId != null) {
        await _loadAtividades();
      }
    } catch (e) {
      // Erro no refresh
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  List<AtividadeEntity> _getFilteredAtividades() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_currentView) {
      case 'Dia':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Mês':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Ano':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }
    
    return _atividades.where((atividade) {
      return atividade.dataAtividade.isAfter(startDate) || 
             atividade.dataAtividade.isAtSameMomentAs(startDate);
    }).toList();
  }
  
  int _calculateSteps() {
    final filtered = _getFilteredAtividades();
    return filtered.fold(0, (sum, atividade) => sum + (atividade.passos ?? 0));
  }
  
  double _calculateDistance() {
    final filtered = _getFilteredAtividades();
    // Converte metros para km para manter a compatibilidade com a UI
    return filtered.fold(0.0, (sum, atividade) => sum + ((atividade.distanciaMetros ?? 0.0) / 1000.0));
  }
  
  int _calculateCalories() {
    final filtered = _getFilteredAtividades();
    return filtered.fold(0, (sum, atividade) => sum + (atividade.calorias ?? 0));
  }
  
  double _calculateTime() {
    final filtered = _getFilteredAtividades();
    return filtered.fold(0.0, (sum, atividade) => sum + (atividade.duracaoMinutos ?? 0.0));
  }
  
  String _formatTime(double minutes) {
    final hours = (minutes / 60).floor();
    final mins = (minutes % 60).floor();
    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}';
    }
    return '$mins min';
  }
  
  List<Offset> _calculateGraphPoints() {
    // Gráfico estático como antes - linha reta no meio
    int periods;
    switch (_currentView) {
      case 'Dia':
        periods = 24;
        break;
      case 'Semana':
        periods = 7;
        break;
      case 'Mês':
        periods = 4;
        break;
      case 'Ano':
        periods = 12;
        break;
      default:
        periods = 7;
    }
    
    // Retorna linha reta no meio (y = 0.5)
    return List.generate(periods, (i) => Offset(i / (periods - 1), 0.5));
  }
}