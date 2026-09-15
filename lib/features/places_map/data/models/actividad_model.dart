/// Actividad asociada a un comercio o lugar de interés (no tiene
/// coordenadas propias en el esquema: se muestra dentro del detalle del
/// [MapPlace] al que pertenece).
class Actividad {
  final int id;
  final String nombre;
  final String? descripcion;
  final double? precio;
  final int? duracionMin;

  const Actividad({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.duracionMin,
  });

  factory Actividad.fromRow(Map<String, dynamic> row) {
    return Actividad(
      id: row['id'] as int,
      nombre: row['nombre'] as String,
      descripcion: row['descripcion'] as String?,
      precio: (row['precio'] as num?)?.toDouble(),
      duracionMin: row['duracion_min'] as int?,
    );
  }
}
