class AlunoEntity {
  final String? id;
  final String nome;
  final String email;
  final String? telefone;
  final DateTime dataNascimento;
  final String? genero;
  final double? peso;
  final double? altura;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AlunoEntity({
    this.id,
    required this.nome,
    required this.email,
    this.telefone,
    required this.dataNascimento,
    this.genero,
    this.peso,
    this.altura,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'dataNascimento': dataNascimento.toIso8601String(),
      'genero': genero,
      'peso': peso,
      'altura': altura,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AlunoEntity.fromMap(String id, Map<String, dynamic> map) {
    return AlunoEntity(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      dataNascimento: DateTime.parse(map['dataNascimento']),
      genero: map['genero'],
      peso: map['peso']?.toDouble(),
      altura: map['altura']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  AlunoEntity copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    DateTime? dataNascimento,
    String? genero,
    double? peso,
    double? altura,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlunoEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      genero: genero ?? this.genero,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

