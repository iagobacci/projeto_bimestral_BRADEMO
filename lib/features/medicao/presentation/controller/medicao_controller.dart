import 'package:flutter/material.dart';
import '../../domain/entities/medicao_entity.dart';
import '../../domain/repositories/medicao_repository.dart';
import '../../../../core/services/notification_service.dart';

class MedicaoController extends ChangeNotifier {
  final MedicaoRepository repository;

  MedicaoController(this.repository);

  List<MedicaoEntity> _medicoes = [];
  bool _isLoading = false;
  String? _error;

  List<MedicaoEntity> get medicoes => _medicoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMedicoes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicoes = await repository.getAllMedicoes();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar medições: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicoesByAluno(String alunoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicoes = await repository.getMedicoesByAlunoId(alunoId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar medições: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para recarregar medições baseado no tipo de usuário
  Future<void> reloadMedicoes({String? alunoId}) async {
    if (alunoId != null) {
      await loadMedicoesByAluno(alunoId);
    } else {
      await loadMedicoes();
    }
  }

  Future<bool> createMedicao(MedicaoEntity medicao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final medicaoWithDates = medicao.copyWith(
        createdAt: DateTime.now(),
      );
      await repository.createMedicao(medicaoWithDates);
      // Notificação local ao criar medição
      await NotificationService().showLocalNotification(
        title: 'Nova medição registrada',
        body: 'Medição de batimentos ${medicao.batimentosPorMinuto} bpm salva com sucesso.',
      );
      // Recarrega baseado no alunoId da medição
      await loadMedicoesByAluno(medicao.alunoId);
      return true;
    } catch (e) {
      _error = 'Erro ao criar medição: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicao(String id, MedicaoEntity medicao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateMedicao(id, medicao);
      // Recarrega baseado no alunoId da medição
      await loadMedicoesByAluno(medicao.alunoId);
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar medição: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedicao(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Salvar alunoId antes de deletar
      final alunoId = _medicoes.firstWhere((m) => m.id == id).alunoId;
      await repository.deleteMedicao(id);
      // Recarrega baseado no alunoId
      await loadMedicoesByAluno(alunoId);
      return true;
    } catch (e) {
      _error = 'Erro ao deletar medição: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}


