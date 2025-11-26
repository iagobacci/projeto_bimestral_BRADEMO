import '../entities/medicao_entity.dart';

abstract class MedicaoRepository {
  Future<String> createMedicao(MedicaoEntity medicao);
  Future<MedicaoEntity> getMedicaoById(String id);
  Future<List<MedicaoEntity>> getAllMedicoes();
  Future<List<MedicaoEntity>> getMedicoesByAlunoId(String alunoId);
  Future<void> updateMedicao(String id, MedicaoEntity medicao);
  Future<void> deleteMedicao(String id);
}






