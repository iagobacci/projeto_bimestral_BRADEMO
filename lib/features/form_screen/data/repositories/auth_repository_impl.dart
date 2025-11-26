import 'package:cloud_firestore/cloud_firestore.dart';
// Importando o DataSource (necessário para a implementação)
import 'package:trabalho01/features/authentication/data/datasources/auth_firebase_datasource.dart'; 
// Importando a Entidade UserEntity (necessário para tipagem no retorno de login)
import 'package:trabalho01/features/authentication/domain/entities/user_entity.dart'; 

// Repositório que implementa a comunicação com o DataSource Firebase
class AuthRepositoryImpl {
  final AuthFirebaseDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  // Implementação da função de cadastro (SignUp)
  Future<void> registerNewUser({
    required String email, 
    required String nome,
    required String senha,
    required String? genero, 
    required bool lembrarSenha,
    required bool notificacoes,
    required String tipoUsuario,
  }) async {
    // Tratamento de Nulos antes do envio ao Firestore
    final finalGenero = genero ?? 'Não informado'; 

    final userData = {
      'email': email,
      'nome': nome,
      'genero': finalGenero, 
      'tipoUsuario': tipoUsuario,
      'lembrarSenha': lembrarSenha,
      'notificacoes': notificacoes,
      // FieldValue.serverTimestamp() é seguro
      'createdAt': FieldValue.serverTimestamp(), 
    };

    // Chama o DataSource para executar o cadastro no Firebase Auth e Firestore
    await dataSource.signUp(
      email: email, 
      password: senha, 
      userData: userData,
    );
  }
  // IMPLEMENTAÇÃO DE LOGIN (SignIn)
  // Chama o DataSource para autenticar e buscar os dados do usuário no Firestore
  Future<UserEntity> signIn(String email, String password) async {
    return await dataSource.signIn(email, password);
  }
}