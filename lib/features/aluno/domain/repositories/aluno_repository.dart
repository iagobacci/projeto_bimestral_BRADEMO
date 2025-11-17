import '../entities/aluno_entity.dart';

abstract class AlunoRepository {
  Future<String> createAluno(AlunoEntity aluno);
  Future<AlunoEntity> getAlunoById(String id);
  Future<List<AlunoEntity>> getAllAlunos();
  Future<void> updateAluno(String id, AlunoEntity aluno);
  Future<void> deleteAluno(String id);
}

