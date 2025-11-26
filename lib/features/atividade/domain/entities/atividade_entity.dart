class AtividadeEntity {
  final String? id;
  final String alunoId;
  final String tipo;
  final String descricao;
  final DateTime dataAtividade;
  final double? duracaoMinutos;
  final double? distanciaMetros;
  final int? calorias;
  final int? passos;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AtividadeEntity({
    this.id,
    required this.alunoId,
    required this.tipo,
    required this.descricao,
    required this.dataAtividade,
    this.duracaoMinutos,
    this.distanciaMetros,
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
      'dataAtividade': dataAtividade.toIso8601String(),
      'duracaoMinutos': duracaoMinutos,
      'distanciaMetros': distanciaMetros,
      'calorias': calorias,
      'passos': passos,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AtividadeEntity.fromMap(String id, Map<String, dynamic> map) {
    // Função auxiliar para converter para int de forma segura
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Função auxiliar para converter para double de forma segura
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AtividadeEntity(
      id: id,
      alunoId: map['alunoId']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      dataAtividade: DateTime.parse(map['dataAtividade']?.toString() ?? map['dataInicio']?.toString() ?? DateTime.now().toIso8601String()), // Compatibilidade com dados antigos
      duracaoMinutos: _toDouble(map['duracaoMinutos']),
      distanciaMetros: _toDouble(map['distanciaMetros']) ?? (map['distanciaKm'] != null ? _toDouble(map['distanciaKm'])! * 1000 : null),
      calorias: _toInt(map['calorias']),
      passos: _toInt(map['passos']),
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'].toString()) : null,
    );
  }

  AtividadeEntity copyWith({
    String? id,
    String? alunoId,
    String? tipo,
    String? descricao,
    DateTime? dataAtividade,
    double? duracaoMinutos,
    double? distanciaMetros,
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
      dataAtividade: dataAtividade ?? this.dataAtividade,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      distanciaMetros: distanciaMetros ?? this.distanciaMetros,
      calorias: calorias ?? this.calorias,
      passos: passos ?? this.passos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

