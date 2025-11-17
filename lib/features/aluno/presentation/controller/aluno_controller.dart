import 'package:flutter/material.dart';
import '../../domain/entities/aluno_entity.dart';
import '../../domain/repositories/aluno_repository.dart';

class AlunoController extends ChangeNotifier {
  final AlunoRepository repository;

  AlunoController(this.repository);

  List<AlunoEntity> _alunos = [];
  bool _isLoading = false;
  String? _error;

  List<AlunoEntity> get alunos => _alunos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAlunos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alunos = await repository.getAllAlunos();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar alunos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAluno(AlunoEntity aluno) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final alunoWithDates = aluno.copyWith(
        createdAt: DateTime.now(),
      );
      await repository.createAluno(alunoWithDates);
      await loadAlunos();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      String errorMsg = e.toString();
      // Remove o prefixo "Exception: " se existir
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAluno(String id, AlunoEntity aluno) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateAluno(id, aluno);
      await loadAlunos();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar aluno: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAluno(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteAluno(id);
      await loadAlunos();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar aluno: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

