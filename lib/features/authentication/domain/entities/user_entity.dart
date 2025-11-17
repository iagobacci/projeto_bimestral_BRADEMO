class UserEntity {
  final String uid; // ID único do Firebase Auth
  final String nome;
  final String email;
  final String? genero;
  final String? profilePhotoUrl;
  
  UserEntity({
    required this.uid,
    required this.nome,
    required this.email,
    this.genero,
    this.profilePhotoUrl,
  });
}