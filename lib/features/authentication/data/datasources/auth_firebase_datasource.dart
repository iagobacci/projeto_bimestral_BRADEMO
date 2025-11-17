// lib/features/authentication/data/datasources/auth_firebase_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart'; 

class AuthFirebaseDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Implementação de Cadastro (signUp - Mantida para consistência)
  Future<void> signUp({
    required String email, 
    required String password, 
    required Map<String, dynamic> userData,
  }) async {
    try {
      // 1. Criar usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Verificar se o usuário foi criado corretamente
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Falha ao criar usuário: usuário não foi retornado após criação.');
      }
      
      final uid = user.uid;

      // 3. Aguardar um pouco para garantir que o token de autenticação esteja disponível
      // e que o usuário esteja completamente autenticado
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 4. Verificar se o usuário ainda está autenticado antes de salvar no Firestore
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != uid) {
        throw Exception('Usuário não está autenticado após criação. Tente novamente.');
      }

      // 5. Salvamento de dados no Firestore
      await _db.collection('users').doc(uid).set(userData);
    } on FirebaseAuthException {
      // Re-lança exceções de autenticação para serem tratadas no controller
      rethrow;
    } on FirebaseException catch (e) {
      // Re-lança exceções do Firestore para serem tratadas no controller
      // Adiciona mensagem mais descritiva
      throw FirebaseException(
        plugin: e.plugin,
        code: e.code,
        message: 'Erro ao salvar dados no Firestore. Código: ${e.code}. Mensagem: ${e.message}. Verifique as regras de segurança do Firestore.',
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      // Captura outros erros e os transforma em exceções mais descritivas
      throw Exception('Erro inesperado durante o cadastro: $e');
    }
  }

  // Implementação de Login (signIn - Corrigida para mapeamento seguro)
  Future<UserEntity> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    final doc = await _db.collection('users').doc(uid).get();
    
    if (!doc.exists || doc.data() == null) {
      // Se a regra de leitura falhar, o erro será capturado no controller.
      throw Exception("Dados do usuário não encontrados no Firestore após autenticação.");
    }

    final data = doc.data()!;
    // CORREÇÃO: Usando '??' para garantir que não haja falha se um campo for nulo
    return UserEntity(
      uid: uid,
      nome: data['nome'] ?? 'Usuário Sem Nome', 
      email: data['email'] ?? email,
      genero: data['genero'],
      profilePhotoUrl: data['profilePhotoUrl'],
    );
  }
}