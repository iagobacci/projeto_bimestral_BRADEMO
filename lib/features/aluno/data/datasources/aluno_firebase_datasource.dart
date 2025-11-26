import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/aluno_entity.dart';

class AlunoFirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'alunos';

  // CREATE (POST) - Criar novo aluno
  Future<String> createAluno(AlunoEntity aluno) async {
    try {
      // Verificar se o usuário está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Você precisa estar autenticado para criar um aluno. Faça login primeiro.');
      }
      
      final docRef = await _db.collection(_collection).add(aluno.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      String errorMessage = 'Erro ao criar aluno';
      if (e.code == 'permission-denied') {
        errorMessage = 'Permissão negada. Verifique se você está autenticado e se as regras de segurança do Firestore estão configuradas corretamente. Veja o arquivo INSTRUCOES_FIRESTORE.md para mais detalhes.';
      } else {
        errorMessage = 'Erro ao criar aluno: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Se já é uma Exception com mensagem clara, re-lança
      if (e is Exception && e.toString().contains('autenticado')) {
        rethrow;
      }
      throw Exception('Erro inesperado ao criar aluno: $e');
    }
  }

  // READ (GET) - Buscar aluno por ID
  Future<AlunoEntity> getAlunoById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Aluno não encontrado');
      }
      return AlunoEntity.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar aluno: ${e.message}');
    }
  }

  // READ (GET) - Listar todos os alunos
  Future<List<AlunoEntity>> getAllAlunos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Você precisa estar autenticado para listar alunos.');
      }
      
      // Buscar tipo de usuário no Firestore
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'aluno';
      
      QuerySnapshot querySnapshot;
      
      if (tipoUsuario == 'personal') {
        // Personal vê TODOS os alunos (tanto os que ele criou quanto os que se cadastraram sozinhos)
        querySnapshot = await _db.collection(_collection).get();
      } else {
        // Aluno não deve ver lista de alunos (mas mantém para compatibilidade)
        querySnapshot = await _db.collection(_collection).get();
      }
      
      return querySnapshot.docs
          .map((doc) => AlunoEntity.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar alunos: ${e.message}');
    }
  }
  
  // READ (GET) - Buscar aluno por userId (para aluno logado)
  Future<AlunoEntity?> getAlunoByUserId(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return AlunoEntity.fromMap(querySnapshot.docs.first.id, querySnapshot.docs.first.data());
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar aluno por userId: ${e.message}');
    }
  }

  // UPDATE (PUT) - Atualizar aluno
  Future<void> updateAluno(String id, AlunoEntity aluno) async {
    try {
      final updatedData = aluno.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();
      await _db.collection(_collection).doc(id).update(updatedData);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar aluno: ${e.message}');
    }
  }

  // DELETE - Deletar aluno
  Future<void> deleteAluno(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao deletar aluno: ${e.message}');
    }
  }
}

