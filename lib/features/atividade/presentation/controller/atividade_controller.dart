import 'package:flutter/material.dart';
import '../../domain/entities/atividade_entity.dart';
import '../../domain/repositories/atividade_repository.dart';
import '../../../../core/services/notification_service.dart';

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
      // Notificação local ao criar atividade
      await NotificationService().showLocalNotification(
        title: 'Nova atividade criada',
        body: 'Atividade "${atividade.tipo}" registrada com sucesso.',
      );
      // Recarrega baseado no alunoId da atividade
      await loadAtividadesByAluno(atividade.alunoId);
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
      // Recarrega baseado no alunoId da atividade
      await loadAtividadesByAluno(atividade.alunoId);
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
      // Salvar alunoId antes de deletar
      final alunoId = _atividades.firstWhere((a) => a.id == id).alunoId;
      await repository.deleteAtividade(id);
      // Recarrega baseado no alunoId
      await loadAtividadesByAluno(alunoId);
      return true;
    } catch (e) {
      _error = 'Erro ao deletar atividade: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}


