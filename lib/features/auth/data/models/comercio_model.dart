/// Modelo de la tabla `comercios` (perfil de comercio - HU-02).
///
/// `usuarioId` es PK y FK hacia `usuarios.id` (int8, ON DELETE CASCADE).
class ComercioModel {
  final int usuarioId;
  final String nit;
  final String nombreComercio;
  final String? sede;
  final String telefonoContacto;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final String? fotoUrl;
  final String? descripcion;

  /// `comercios.horario_apertura`/`horario_cierre` — columnas `TIME` de
  /// Postgres, tal cual las serializa PostgREST ("HH:mm:ss"). Se dejan
  /// como String crudo aquí; el parseo a `TimeOfDay` para mostrarlas o
  /// editarlas vive en la UI (`business_settings_screen.dart`), no en
  /// el modelo.
  final String? horarioApertura;
  final String? horarioCierre;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComercioModel({
    required this.usuarioId,
    required this.nit,
    required this.nombreComercio,
    this.sede,
    required this.telefonoContacto,
    required this.direccion,
    this.latitud,
    this.longitud,
    this.fotoUrl,
    this.descripcion,
    this.horarioApertura,
    this.horarioCierre,
    this.estado = 'activo',
    this.createdAt,
    this.updatedAt,
  });

  factory ComercioModel.fromMap(Map<String, dynamic> map) {
    return ComercioModel(
      usuarioId: map['usuario_id'] as int,
      nit: map['nit'] as String,
      nombreComercio: map['nombre_comercio'] as String,
      sede: map['sede'] as String?,
      telefonoContacto: map['telefono_contacto'] as String,
      direccion: map['direccion'] as String,
      latitud: _toDouble(map['latitud']),
      longitud: _toDouble(map['longitud']),
      fotoUrl: map['foto_url'] as String?,
      descripcion: map['descripcion'] as String?,
      horarioApertura: map['horario_apertura'] as String?,
      horarioCierre: map['horario_cierre'] as String?,
      estado: map['estado'] as String? ?? 'activo',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// TG-157: `numeric(9,6)` -> `double`, tolerante a que PostgREST lo
  /// serialice como número o como String.
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
