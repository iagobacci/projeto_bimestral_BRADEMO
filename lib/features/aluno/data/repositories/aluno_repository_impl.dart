import '../../domain/entities/aluno_entity.dart';
import '../../domain/repositories/aluno_repository.dart';
import '../datasources/aluno_firebase_datasource.dart';

class AlunoRepositoryImpl implements AlunoRepository {
  final AlunoFirebaseDataSource dataSource;

  AlunoRepositoryImpl(this.dataSource);

  @override
  Future<String> createAluno(AlunoEntity aluno) async {
    return await dataSource.createAluno(aluno);
  }

  @override
  Future<AlunoEntity> getAlunoById(String id) async {
    return await dataSource.getAlunoById(id);
  }

  @override
  Future<List<AlunoEntity>> getAllAlunos() async {
    return await dataSource.getAllAlunos();
  }

  @override
  Future<void> updateAluno(String id, AlunoEntity aluno) async {
    return await dataSource.updateAluno(id, aluno);
  }

  @override
  Future<void> deleteAluno(String id) async {
    return await dataSource.deleteAluno(id);
  }
}

