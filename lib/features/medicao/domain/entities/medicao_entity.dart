class MedicaoEntity {
  final String? id;
  final String alunoId;
  final int batimentosPorMinuto;
  final double? pressaoSistolica;
  final double? pressaoDiastolica;
  final double? temperatura;
  final double? latitude;
  final double? longitude;
  final String? observacoes;
  final DateTime dataMedicao;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MedicaoEntity({
    this.id,
    required this.alunoId,
    required this.batimentosPorMinuto,
    this.pressaoSistolica,
    this.pressaoDiastolica,
    this.temperatura,
    this.latitude,
    this.longitude,
    this.observacoes,
    required this.dataMedicao,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'batimentosPorMinuto': batimentosPorMinuto,
      'pressaoSistolica': pressaoSistolica,
      'pressaoDiastolica': pressaoDiastolica,
      'temperatura': temperatura,
      'latitude': latitude,
      'longitude': longitude,
      'observacoes': observacoes,
      'dataMedicao': dataMedicao.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MedicaoEntity.fromMap(String id, Map<String, dynamic> map) {
    return MedicaoEntity(
      id: id,
      alunoId: map['alunoId'] ?? '',
      batimentosPorMinuto: map['batimentosPorMinuto'] ?? 0,
      pressaoSistolica: map['pressaoSistolica']?.toDouble(),
      pressaoDiastolica: map['pressaoDiastolica']?.toDouble(),
      temperatura: map['temperatura']?.toDouble(),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      observacoes: map['observacoes'],
      dataMedicao: DateTime.parse(map['dataMedicao']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  MedicaoEntity copyWith({
    String? id,
    String? alunoId,
    int? batimentosPorMinuto,
    double? pressaoSistolica,
    double? pressaoDiastolica,
    double? temperatura,
    double? latitude,
    double? longitude,
    String? observacoes,
    DateTime? dataMedicao,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicaoEntity(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      batimentosPorMinuto: batimentosPorMinuto ?? this.batimentosPorMinuto,
      pressaoSistolica: pressaoSistolica ?? this.pressaoSistolica,
      pressaoDiastolica: pressaoDiastolica ?? this.pressaoDiastolica,
      temperatura: temperatura ?? this.temperatura,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      observacoes: observacoes ?? this.observacoes,
      dataMedicao: dataMedicao ?? this.dataMedicao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

