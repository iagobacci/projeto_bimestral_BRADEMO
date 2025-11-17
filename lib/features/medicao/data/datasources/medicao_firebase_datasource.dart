import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicao_entity.dart';

class MedicaoFirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'medicoes';

  // CREATE (POST) - Criar nova medição
  Future<String> createMedicao(MedicaoEntity medicao) async {
    try {
      final docRef = await _db.collection(_collection).add(medicao.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao criar medição: ${e.message}');
    }
  }

  // READ (GET) - Buscar medição por ID
  Future<MedicaoEntity> getMedicaoById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Medição não encontrada');
      }
      return MedicaoEntity.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar medição: ${e.message}');
    }
  }

  // READ (GET) - Listar todas as medições
  Future<List<MedicaoEntity>> getAllMedicoes() async {
    try {
      final querySnapshot = await _db.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => MedicaoEntity.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar medições: ${e.message}');
    }
  }

  // READ (GET) - Listar medições por aluno
  Future<List<MedicaoEntity>> getMedicoesByAlunoId(String alunoId) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .orderBy('dataMedicao', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => MedicaoEntity.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar medições do aluno: ${e.message}');
    }
  }

  // UPDATE (PUT) - Atualizar medição
  Future<void> updateMedicao(String id, MedicaoEntity medicao) async {
    try {
      final updatedData = medicao.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();
      await _db.collection(_collection).doc(id).update(updatedData);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar medição: ${e.message}');
    }
  }

  // DELETE - Deletar medição
  Future<void> deleteMedicao(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao deletar medição: ${e.message}');
    }
  }
}

