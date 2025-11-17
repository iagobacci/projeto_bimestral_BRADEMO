import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Cria novo usuário (POST)
  Future<UserEntity> signUp(String email, String password, String nome, String? genero);
  
  // Autentica usuário existente (GET / Login)
  Future<UserEntity> signIn(String email, String password);
  
  // Obtém o usuário atualmente logado (se houver)
  Future<UserEntity?> getCurrentUser();
}