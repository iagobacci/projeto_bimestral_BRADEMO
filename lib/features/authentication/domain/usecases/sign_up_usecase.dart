// lib/features/authentication/domain/usecases/sign_up_usecase.dart

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  // O Call permite que a instância do UseCase seja chamada como uma função
  Future<UserEntity> call({
    required String email,
    required String password,
    required String nome,
    String? genero,
  }) async {
    return await repository.signUp(email, password, nome, genero);
  }
}