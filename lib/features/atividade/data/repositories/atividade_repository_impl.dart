import '../../domain/entities/atividade_entity.dart';
import '../../domain/repositories/atividade_repository.dart';
import '../datasources/atividade_firebase_datasource.dart';

class AtividadeRepositoryImpl implements AtividadeRepository {
  final AtividadeFirebaseDataSource dataSource;

  AtividadeRepositoryImpl(this.dataSource);

  @override
  Future<String> createAtividade(AtividadeEntity atividade) async {
    return await dataSource.createAtividade(atividade);
  }

  @override
  Future<AtividadeEntity> getAtividadeById(String id) async {
    return await dataSource.getAtividadeById(id);
  }

  @override
  Future<List<AtividadeEntity>> getAllAtividades() async {
    return await dataSource.getAllAtividades();
  }

  @override
  Future<List<AtividadeEntity>> getAtividadesByAlunoId(String alunoId) async {
    return await dataSource.getAtividadesByAlunoId(alunoId);
  }

  @override
  Future<void> updateAtividade(String id, AtividadeEntity atividade) async {
    return await dataSource.updateAtividade(id, atividade);
  }

  @override
  Future<void> deleteAtividade(String id) async {
    return await dataSource.deleteAtividade(id);
  }
}

