/// Actividad asociada a un comercio o lugar de interés. Del lado turista
/// (`place_details_sheet.dart`) se muestra dentro del detalle del
/// [MapPlace] al que pertenece, usando solo nombre/descripcion/precio/
/// duracionMin. Del lado comercio (`create_activity_screen.dart`,
/// `home_screen_comercio.dart`) se usan además `categoria`, `estado` y
/// las fechas — ver docs/db/hu_comercio_menus_actividades.sql.
class Actividad {
  final int id;
  final int? comercioId;
  final String nombre;
  final String? descripcion;
  final String? categoria;

  /// 'activa' | 'pausada' | 'borrador'. `null` cuando viene de una fila
  /// antigua sin este campo (no debería pasar tras la migración, que le
  /// pone 'borrador' por defecto).
  final String? estado;
  final double? precio;
  final int? duracionMin;
  final bool activo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const Actividad({
    required this.id,
    this.comercioId,
    required this.nombre,
    this.descripcion,
    this.categoria,
    this.estado,
    this.precio,
    this.duracionMin,
    this.activo = true,
    this.fechaInicio,
    this.fechaFin,
  });

  factory Actividad.fromRow(Map<String, dynamic> row) {
    return Actividad(
      id: row['id'] as int,
      comercioId: row['comercio_id'] as int?,
      nombre: row['nombre'] as String,
      descripcion: row['descripcion'] as String?,
      categoria: row['categoria'] as String?,
      estado: row['estado'] as String?,
      precio: (row['precio'] as num?)?.toDouble(),
      duracionMin: row['duracion_min'] as int?,
      activo: row['activo'] as bool? ?? true,
      fechaInicio: _parseDate(row['fecha_inicio']),
      fechaFin: _parseDate(row['fecha_fin']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}
