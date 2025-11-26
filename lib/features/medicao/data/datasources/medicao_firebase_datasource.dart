import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/medicao_entity.dart';

class MedicaoFirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  // READ (GET) - Listar todas as medições (filtradas por tipo de usuário)
  Future<List<MedicaoEntity>> getAllMedicoes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Você precisa estar autenticado para listar medições.');
      }
      
      // Buscar tipo de usuário no Firestore
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'aluno';
      
      QuerySnapshot querySnapshot;
      
      if (tipoUsuario == 'aluno') {
        // Aluno vê apenas suas medições
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
        
        // Buscar medições do aluno (sem orderBy para evitar necessidade de índice)
        querySnapshot = await _db
            .collection(_collection)
            .where('alunoId', isEqualTo: alunoId)
            .get();
      } else {
        // Personal não deve usar getAllMedicoes diretamente
        // Deve usar getMedicoesByAlunoId com aluno selecionado
        return [];
      }
      
      // Ordenar por dataMedicao (mais recente primeiro) no código
      final medicoes = querySnapshot.docs
          .map((doc) => MedicaoEntity.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      medicoes.sort((a, b) => b.dataMedicao.compareTo(a.dataMedicao));
      return medicoes;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao listar medições: ${e.message}');
    }
  }

  // READ (GET) - Listar medições por aluno
  Future<List<MedicaoEntity>> getMedicoesByAlunoId(String alunoId) async {
    try {
      // Buscar sem orderBy para evitar necessidade de índice composto
      final querySnapshot = await _db
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .get();
      
      // Ordenar por dataMedicao (mais recente primeiro) no código
      final medicoes = querySnapshot.docs
          .map((doc) => MedicaoEntity.fromMap(doc.id, doc.data()))
          .toList();
      
      medicoes.sort((a, b) => b.dataMedicao.compareTo(a.dataMedicao));
      return medicoes;
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


