class Trip {
  final int? id;
  final String origen;
  final String destino;
  final int usuarioId;
  final bool archivado;

  Trip({
    this.id,
    required this.origen,
    required this.destino,
    required this.usuarioId,
    this.archivado = false,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      origen: json['origen'] ?? '',
      destino: json['destino'] ?? '',
      usuarioId: json['usuarioId'] ?? 0,
      archivado: json['archivado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'origen': origen,
      'destino': destino,
      'usuarioId': usuarioId,
      'archivado': archivado,
    };
  }
}