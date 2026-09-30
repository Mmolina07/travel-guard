import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n_extension.dart';

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
String tripHistoryFieldLabel(BuildContext context, String campo) {
  switch (campo) {
    case 'presupuesto_maximo':
      return context.l10n.tripHistoryPresupuestoMaximo;
    case 'pagos_anticipados':
      return context.l10n.tripHistoryPagosAnticipados;
    case 'costo_hospedaje':
      return context.l10n.tripHistoryCostoHospedaje;
    case 'dinero_emergencias':
      return context.l10n.tripHistoryDineroEmergencias;
    case 'categorias_presupuesto':
      return context.l10n.tripHistoryCategoriasPresupuesto;
    default:
      return campo;
  }
}
