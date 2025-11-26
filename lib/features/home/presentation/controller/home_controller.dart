import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../aluno/domain/repositories/aluno_repository.dart';
import '../../../medicao/domain/repositories/medicao_repository.dart';
import '../../../aluno/domain/entities/aluno_entity.dart';

class HomeController extends ChangeNotifier {
  final AlunoRepository? alunoRepository;
  final MedicaoRepository? medicaoRepository;
  
  String _userName = "Usuário";
  String _userWeight = "-";
  String _userHeight = "-";
  String _userAge = "-";
  String? _userDataNascimento;
  String _heartRateAvg = "-";
  bool _isLoading = true;
  
  HomeController({this.alunoRepository, this.medicaoRepository}) {
    _loadData();
  }
  
  String? _currentUserId;

  String get userName => _userName;
  String get userWeight => _userWeight;
  String get userHeight => _userHeight;
  String get userAge => _userAge;
  String? get userDataNascimento => _userDataNascimento;
  String get heartRateAvg => _heartRateAvg;
  bool get isLoading => _isLoading;

  // Dados do gráfico de batimentos da semana
  List<FlSpot> get heartRateSpots => const [
    FlSpot(0, 70),
    FlSpot(1, 89),
    FlSpot(2, 75),
    FlSpot(3, 80),
    FlSpot(4, 68),
    FlSpot(5, 74),
    FlSpot(6, 72),
  ];

  Future<void> refreshUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Evita recarregar desnecessariamente se for o mesmo usuário
    if (_currentUserId != user.uid) {
      _currentUserId = user.uid;
      await _loadData();
    }
  }
  
  Future<void> forceRefresh() async {
    // Atualiza tudo do zero quando o usuário pede
    await _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || alunoRepository == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _currentUserId = user.uid;

    try {
      // Buscar dados do usuário
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      _userName = userData?['nome'] ?? "Usuário";
      
      // Verificar tipo de usuário
      final tipoUsuario = userData?['tipoUsuario'] ?? 'aluno';
      
      // Buscar dados do aluno apenas se for tipo 'aluno'
      if (tipoUsuario == 'aluno') {
        final alunoQuery = await FirebaseFirestore.instance
            .collection('alunos')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
        
        
        if (alunoQuery.docs.isNotEmpty) {
        final alunoData = alunoQuery.docs.first.data();
        final aluno = AlunoEntity.fromMap(
          alunoQuery.docs.first.id,
          alunoData,
        );
        
        
        // Peso e altura - verificar se existem no documento
        if (aluno.peso != null && aluno.peso! > 0) {
          _userWeight = "${aluno.peso!.toStringAsFixed(1)} KG";
        } else {
          _userWeight = "- KG";
        }
        
        if (aluno.altura != null && aluno.altura! > 0) {
          _userHeight = "${aluno.altura!.toStringAsFixed(2)} M";
        } else {
          _userHeight = "- M";
        }
        
        // Idade - verificar se a data de nascimento existe
        try {
          final hoje = DateTime.now();
          final idade = hoje.year - aluno.dataNascimento.year;
          if (hoje.month < aluno.dataNascimento.month || 
              (hoje.month == aluno.dataNascimento.month && hoje.day < aluno.dataNascimento.day)) {
            _userAge = "${idade - 1} anos";
          } else {
            _userAge = "$idade anos";
          }
          
          // Data de Nascimento
          _userDataNascimento = DateFormat('dd/MM/yyyy').format(aluno.dataNascimento);
        } catch (e) {
          _userAge = "- anos";
          _userDataNascimento = null;
          }
          
          // Buscar medições para bem estar cardíaco
          if (medicaoRepository != null) {
            try {
              final medicoes = await medicaoRepository!.getAllMedicoes();
              if (medicoes.isNotEmpty) {
                // Calcular média de todas as medições do aluno
                final totalBpm = medicoes.fold(0, (sum, m) => sum + m.batimentosPorMinuto);
                final avgBpm = (totalBpm / medicoes.length).round();
                _heartRateAvg = "$avgBpm bpm";
              } else {
                _heartRateAvg = "-";
              }
            } catch (e) {
              // Erro ao buscar medições, manter valor padrão
              _heartRateAvg = "-";
            }
          }
        }
      }
    } catch (e) {
      // Erro ao carregar dados
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refresh() async {
    await _loadData();
  }

}