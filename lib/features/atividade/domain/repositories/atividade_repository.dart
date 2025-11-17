import '../entities/atividade_entity.dart';

abstract class AtividadeRepository {
  Future<String> createAtividade(AtividadeEntity atividade);
  Future<AtividadeEntity> getAtividadeById(String id);
  Future<List<AtividadeEntity>> getAllAtividades();
  Future<List<AtividadeEntity>> getAtividadesByAlunoId(String alunoId);
  Future<void> updateAtividade(String id, AtividadeEntity atividade);
  Future<void> deleteAtividade(String id);
}

