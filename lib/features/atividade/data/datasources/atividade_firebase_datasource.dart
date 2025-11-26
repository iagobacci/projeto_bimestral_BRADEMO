import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/atividade_entity.dart';

class AtividadeFirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'atividades';

  // CREATE (POST) - Criar nova atividade
  Future<String> createAtividade(AtividadeEntity atividade) async {
    try {
      final docRef = await _db.collection(_collection).add(atividade.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao criar atividade: ${e.message}');
    }
  }

  // READ (GET) - Buscar atividade por ID
  Future<AtividadeEntity> getAtividadeById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Atividade não encontrada');
      }
      return AtividadeEntity.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar atividade: ${e.message}');
    }
  }

  // READ (GET) - Listar todas as atividades (filtradas por tipo de usuário)
  Future<List<AtividadeEntity>> getAllAtividades() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Você precisa estar autenticado para listar atividades.');
      }
      
      // Buscar tipo de usuário no Firestore
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'aluno';
      
      QuerySnapshot querySnapshot;
      
      if (tipoUsuario == 'aluno') {
        // Aluno vê apenas suas atividades
        // Primeiro, buscar o aluno pelo userId
        final alunoQuery = await _db
            .collection('alunos')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
        
        if (alunoQuery.docs.isEmpty) {
          return []; // Aluno não encontrado, retorna lista vazia
        }
        
        final alunoId = alunoQuery.docs.first.id;
        
        // Buscar atividades do aluno
        querySnapshot = await _db
            .collection(_collection)
            .where('alunoId', isEqualTo: alunoId)
            .get();
      } else {
        // Personal vê todas as atividades de seus alunos
        // Buscar todos os alunos do personal
        final alunosQuery = await _db
            .collection('alunos')
            .where('personalId', isEqualTo: user.uid)
            .get();
        
        if (alunosQuery.docs.isEmpty) {
          return []; // Nenhum aluno encontrado
        }
        
        final alunoIds = alunosQuery.docs.map((doc) => doc.id).toList();
        
        // Buscar atividades de todos os alunos do personal
        // Firestore não suporta múltiplos valores com 'isEqualTo', então fazemos consultas separadas
        List<AtividadeEntity> todasAtividades = [];
        for (final alunoId in alunoIds) {
          final atividadesQuery = await _db
              .collection(_collection)
              .where('alunoId', isEqualTo: alunoId)
              .get();
          todasAtividades.addAll(
            atividadesQuery.docs.map((doc) => AtividadeEntity.fromMap(doc.id, doc.data())).toList(),
          );
        }
        return todasAtividades;
      }
      
      // Se for aluno, retorna a lista normal
      if (tipoUsuario == 'aluno') {
        return querySnapshot.docs
            .map((doc) => AtividadeEntity.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      }
      
      // Se chegou aqui, é personal mas sem alunos selecionados
      return [];
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar atividades: ${e.message}');
    }
  }

  // READ (GET) - Listar atividades por aluno
  Future<List<AtividadeEntity>> getAtividadesByAlunoId(String alunoId) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .get();
      return querySnapshot.docs
          .map((doc) => AtividadeEntity.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar atividades do aluno: ${e.message}');
    }
  }

  // UPDATE (PUT) - Atualizar atividade
  Future<void> updateAtividade(String id, AtividadeEntity atividade) async {
    try {
      final updatedData = atividade.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();
      await _db.collection(_collection).doc(id).update(updatedData);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar atividade: ${e.message}');
    }
  }

  // DELETE - Deletar atividade
  Future<void> deleteAtividade(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao deletar atividade: ${e.message}');
    }
  }
}

