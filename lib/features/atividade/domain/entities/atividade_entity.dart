class AtividadeEntity {
  final String? id;
  final String alunoId;
  final String tipo;
  final String descricao;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final double? duracaoMinutos;
  final double? distanciaKm;
  final int? calorias;
  final int? passos;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AtividadeEntity({
    this.id,
    required this.alunoId,
    required this.tipo,
    required this.descricao,
    required this.dataInicio,
    this.dataFim,
    this.duracaoMinutos,
    this.distanciaKm,
    this.calorias,
    this.passos,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'tipo': tipo,
      'descricao': descricao,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'duracaoMinutos': duracaoMinutos,
      'distanciaKm': distanciaKm,
      'calorias': calorias,
      'passos': passos,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AtividadeEntity.fromMap(String id, Map<String, dynamic> map) {
    return AtividadeEntity(
      id: id,
      alunoId: map['alunoId'] ?? '',
      tipo: map['tipo'] ?? '',
      descricao: map['descricao'] ?? '',
      dataInicio: DateTime.parse(map['dataInicio']),
      dataFim: map['dataFim'] != null ? DateTime.parse(map['dataFim']) : null,
      duracaoMinutos: map['duracaoMinutos']?.toDouble(),
      distanciaKm: map['distanciaKm']?.toDouble(),
      calorias: map['calorias'],
      passos: map['passos'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  AtividadeEntity copyWith({
    String? id,
    String? alunoId,
    String? tipo,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? duracaoMinutos,
    double? distanciaKm,
    int? calorias,
    int? passos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AtividadeEntity(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      calorias: calorias ?? this.calorias,
      passos: passos ?? this.passos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

