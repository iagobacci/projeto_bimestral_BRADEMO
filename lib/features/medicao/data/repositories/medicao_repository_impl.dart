import '../../domain/entities/medicao_entity.dart';
import '../../domain/repositories/medicao_repository.dart';
import '../datasources/medicao_firebase_datasource.dart';

class MedicaoRepositoryImpl implements MedicaoRepository {
  final MedicaoFirebaseDataSource dataSource;

  MedicaoRepositoryImpl(this.dataSource);

  @override
  Future<String> createMedicao(MedicaoEntity medicao) async {
    return await dataSource.createMedicao(medicao);
  }

  @override
  Future<MedicaoEntity> getMedicaoById(String id) async {
    return await dataSource.getMedicaoById(id);
  }

  @override
  Future<List<MedicaoEntity>> getAllMedicoes() async {
    return await dataSource.getAllMedicoes();
  }

  @override
  Future<List<MedicaoEntity>> getMedicoesByAlunoId(String alunoId) async {
    return await dataSource.getMedicoesByAlunoId(alunoId);
  }

  @override
  Future<void> updateMedicao(String id, MedicaoEntity medicao) async {
    return await dataSource.updateMedicao(id, medicao);
  }

  @override
  Future<void> deleteMedicao(String id) async {
    return await dataSource.deleteMedicao(id);
  }
}

