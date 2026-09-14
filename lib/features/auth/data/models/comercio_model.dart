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
      estado: map['estado'] as String? ?? 'activo',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
