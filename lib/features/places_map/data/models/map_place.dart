/// Origen de un [MapPlace]: de qué tabla de Supabase viene.
enum MapPlaceType { comercio, lugarInteres }

/// Punto mostrado en el mapa de HU-07: unifica `comercios` y
/// `lugares_interes` (ambas tienen lat/lng propias; `actividades` no,
/// así que se consultan por separado cuando se abre el detalle de un
/// lugar — ver [PlacesMapRepository.fetchActividadesDelLugar]).
class MapPlace {
  final MapPlaceType type;
  final int id;
  final String nombre;
  final String categoria;
  final double latitud;
  final double longitud;
  final String? direccion;
  final String? telefono;
  final String? descripcion;
  final String? horarioApertura;
  final String? horarioCierre;
  final String? fotoUrl;

  const MapPlace({
    required this.type,
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.telefono,
    this.descripcion,
    this.horarioApertura,
    this.horarioCierre,
    this.fotoUrl,
  });

  /// TG-157: las columnas `latitud`/`longitud` son `numeric(9,6)` en
  /// Postgres. PostgREST normalmente las serializa como número JSON,
  /// pero a veces (según la versión/columna) llegan como String —
  /// `num.parse`/`double.tryParse` cubre ambos casos sin romper.
  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  factory MapPlace.fromComercioRow(Map<String, dynamic> row) {
    final categoria =
        (row['categorias_comercio'] as Map<String, dynamic>?)?['nombre']
                as String? ??
            'Comercio';
    return MapPlace(
      type: MapPlaceType.comercio,
      id: row['usuario_id'] as int,
      nombre: row['nombre_comercio'] as String,
      categoria: categoria,
      latitud: _toDouble(row['latitud']),
      longitud: _toDouble(row['longitud']),
      direccion: row['direccion'] as String?,
      telefono: row['telefono_contacto'] as String?,
      descripcion: row['descripcion'] as String?,
      horarioApertura: row['horario_apertura'] as String?,
      horarioCierre: row['horario_cierre'] as String?,
      fotoUrl: row['foto_url'] as String?,
    );
  }

  factory MapPlace.fromLugarInteresRow(Map<String, dynamic> row) {
    final categoria =
        (row['categorias_lugar'] as Map<String, dynamic>?)?['nombre']
                as String? ??
            'Lugar de interés';
    return MapPlace(
      type: MapPlaceType.lugarInteres,
      id: row['id'] as int,
      nombre: row['nombre'] as String,
      categoria: categoria,
      latitud: _toDouble(row['latitud']),
      longitud: _toDouble(row['longitud']),
      direccion: row['direccion'] as String?,
      telefono: row['telefono'] as String?,
      descripcion: row['descripcion'] as String?,
      horarioApertura: row['horario_apertura'] as String?,
      horarioCierre: row['horario_cierre'] as String?,
      fotoUrl: row['foto_url'] as String?,
    );
  }
}
