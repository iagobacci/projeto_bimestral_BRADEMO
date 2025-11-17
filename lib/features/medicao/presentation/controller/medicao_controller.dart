import 'package:flutter/material.dart';
import '../../domain/entities/medicao_entity.dart';
import '../../domain/repositories/medicao_repository.dart';

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

  Future<bool> createMedicao(MedicaoEntity medicao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final medicaoWithDates = medicao.copyWith(
        createdAt: DateTime.now(),
      );
      await repository.createMedicao(medicaoWithDates);
      await loadMedicoes();
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
      await loadMedicoes();
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
      await repository.deleteMedicao(id);
      await loadMedicoes();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar medição: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

