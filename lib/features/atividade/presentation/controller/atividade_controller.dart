import 'package:flutter/material.dart';
import '../../domain/entities/atividade_entity.dart';
import '../../domain/repositories/atividade_repository.dart';

class AtividadeController extends ChangeNotifier {
  final AtividadeRepository repository;

  AtividadeController(this.repository);

  List<AtividadeEntity> _atividades = [];
  bool _isLoading = false;
  String? _error;

  List<AtividadeEntity> get atividades => _atividades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAtividades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _atividades = await repository.getAllAtividades();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar atividades: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAtividadesByAluno(String alunoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _atividades = await repository.getAtividadesByAlunoId(alunoId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar atividades: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAtividade(AtividadeEntity atividade) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final atividadeWithDates = atividade.copyWith(
        createdAt: DateTime.now(),
      );
      await repository.createAtividade(atividadeWithDates);
      await loadAtividades();
      return true;
    } catch (e) {
      _error = 'Erro ao criar atividade: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAtividade(String id, AtividadeEntity atividade) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateAtividade(id, atividade);
      await loadAtividades();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar atividade: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAtividade(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteAtividade(id);
      await loadAtividades();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar atividade: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

