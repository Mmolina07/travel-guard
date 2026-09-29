/// HU-16: una fila del historial de cambios de un viaje (tabla
/// `viaje_historial`). `valorAnterior`/`valorNuevo` ya vienen
/// formateados para mostrar (p.ej. "$ 500.000") — este historial es de
/// solo lectura, no hace falta recalcular con esos valores.
class TripHistoryEntry {
  final int id;
  final String campo;
  final String? valorAnterior;
  final String? valorNuevo;
  final String editorNombre;
  final DateTime createdAt;

  const TripHistoryEntry({
    required this.id,
    required this.campo,
    this.valorAnterior,
    this.valorNuevo,
    required this.editorNombre,
    required this.createdAt,
  });

  factory TripHistoryEntry.fromRow(Map<String, dynamic> row) {
    final usuario = row['usuarios'] as Map<String, dynamic>?;
    final turista = usuario?['turistas'] as Map<String, dynamic>?;
    final nombre = turista?['nombre'] as String?;
    final editorNombre = (nombre != null && nombre.isNotEmpty)
        ? nombre
        : (usuario?['email'] as String? ?? 'Alguien');

    return TripHistoryEntry(
      id: row['id'] as int,
      campo: row['campo'] as String,
      valorAnterior: row['valor_anterior'] as String?,
      valorNuevo: row['valor_nuevo'] as String?,
      editorNombre: editorNombre,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Traduce el nombre técnico de la columna a una etiqueta legible para
/// el historial (`viaje_historial.campo`).
String tripHistoryFieldLabel(String campo) {
  switch (campo) {
    case 'presupuesto_maximo':
      return 'Presupuesto máximo';
    case 'pagos_anticipados':
      return 'Pagos anticipados';
    case 'costo_hospedaje':
      return 'Costo hospedaje';
    case 'dinero_emergencias':
      return 'Dinero emergencias';
    case 'categorias_presupuesto':
      return 'Categorías de presupuesto';
    default:
      return campo;
  }
}
