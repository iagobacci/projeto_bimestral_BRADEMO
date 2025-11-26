class UserEntity {
  final String uid; // ID único do Firebase Auth
  final String nome;
  final String email;
  final String? genero;
  final String? profilePhotoUrl;
  final String tipoUsuario; // 'aluno' ou 'personal'
  
  UserEntity({
    required this.uid,
    required this.nome,
    required this.email,
    this.genero,
    this.profilePhotoUrl,
    this.tipoUsuario = 'aluno', // Padrão é aluno
  });
}