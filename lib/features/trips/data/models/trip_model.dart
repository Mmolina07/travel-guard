class Trip {
  final int? id;
  final String origen;
  final String destino;
  final int usuarioId;
  final bool archivado;

  // Usados por el resumen de viaje y el desglose de presupuesto
  // (TG-241, TG-242, TG-245, TG-246).
  final String? nombre;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? cantidadPersonas;
  final double? presupuestoTotal;
  final double? presupuestoHospedaje;
  final double? presupuestoTransporte;
  final double? presupuestoComidas;
  final double? presupuestoActividades;
  final double? presupuestoEmergencias;

  Trip({
    this.id,
    required this.origen,
    required this.destino,
    required this.usuarioId,
    this.archivado = false,
    this.nombre,
    this.fechaInicio,
    this.fechaFin,
    this.cantidadPersonas,
    this.presupuestoTotal,
    this.presupuestoHospedaje,
    this.presupuestoTransporte,
    this.presupuestoComidas,
    this.presupuestoActividades,
    this.presupuestoEmergencias,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      origen: json['origen'] ?? '',
      destino: json['destino'] ?? '',
      usuarioId: json['usuarioId'] ?? 0,
      archivado: json['archivado'] ?? false,
      nombre: json['nombre'],
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.tryParse(json['fechaInicio'])
          : null,
      fechaFin: json['fechaFin'] != null
          ? DateTime.tryParse(json['fechaFin'])
          : null,
      cantidadPersonas: json['cantidadPersonas'],
      presupuestoTotal: (json['presupuestoTotal'] as num?)?.toDouble(),
      presupuestoHospedaje:
          (json['presupuestoHospedaje'] as num?)?.toDouble(),
      presupuestoTransporte:
          (json['presupuestoTransporte'] as num?)?.toDouble(),
      presupuestoComidas: (json['presupuestoComidas'] as num?)?.toDouble(),
      presupuestoActividades:
          (json['presupuestoActividades'] as num?)?.toDouble(),
      presupuestoEmergencias:
          (json['presupuestoEmergencias'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'origen': origen,
      'destino': destino,
      'usuarioId': usuarioId,
      'archivado': archivado,
      if (nombre != null) 'nombre': nombre,
      if (fechaInicio != null)
        'fechaInicio': fechaInicio!.toIso8601String(),
      if (fechaFin != null) 'fechaFin': fechaFin!.toIso8601String(),
      if (cantidadPersonas != null) 'cantidadPersonas': cantidadPersonas,
      if (presupuestoTotal != null) 'presupuestoTotal': presupuestoTotal,
      if (presupuestoHospedaje != null)
        'presupuestoHospedaje': presupuestoHospedaje,
      if (presupuestoTransporte != null)
        'presupuestoTransporte': presupuestoTransporte,
      if (presupuestoComidas != null)
        'presupuestoComidas': presupuestoComidas,
      if (presupuestoActividades != null)
        'presupuestoActividades': presupuestoActividades,
      if (presupuestoEmergencias != null)
        'presupuestoEmergencias': presupuestoEmergencias,
    };
  }
}
