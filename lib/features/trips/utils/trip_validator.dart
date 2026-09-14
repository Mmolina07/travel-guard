class ViajeValidator {
  /// Valida que los campos obligatorios del viaje no estén vacíos o inválidos
  static String? validarViajeVacio({
    required String origen,
    required String destino,
    required DateTime? fechaSalida,
    required double? precio,
    required int? cupos,
  }) {
    if (origen.trim().isEmpty) return 'El lugar de origen no puede estar vacío.';
    if (destino.trim().isEmpty) return 'El lugar de destino no puede estar vacío.';
    if (fechaSalida == null) return 'Debes seleccionar una fecha y hora de salida.';
    if (precio == null || precio <= 0) return 'El precio del viaje debe ser mayor a 0.';
    if (cupos == null || cupos <= 0) return 'Debe haber al menos 1 cupo disponible.';
    return null;
  }

  /// Comprueba si ya existe un viaje registrado con el mismo origen, destino y fecha/hora
  static bool esViajeDuplicado({
    required String origen,
    required String destino,
    required DateTime fechaSalida,
    required List<dynamic> viajesExistentes,
    String? idViajeActual,
  }) {
    final claveNuevo =
        '${origen.trim().toLowerCase()}_${destino.trim().toLowerCase()}_${fechaSalida.toIso8601String()}';

    return viajesExistentes.any((viaje) {
      if (idViajeActual != null && viaje.id == idViajeActual) return false;

      final claveExistente =
          '${viaje.origen.trim().toLowerCase()}_${viaje.destino.trim().toLowerCase()}_${viaje.fechaSalida.toIso8601String()}';
      return claveExistente == claveNuevo;
    });
  }
}