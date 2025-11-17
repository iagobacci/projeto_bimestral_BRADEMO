import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/atividade_entity.dart';

class AtividadeFirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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

  // READ (GET) - Listar todas as atividades
  Future<List<AtividadeEntity>> getAllAtividades() async {
    try {
      final querySnapshot = await _db.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => AtividadeEntity.fromMap(doc.id, doc.data()))
          .toList();
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

