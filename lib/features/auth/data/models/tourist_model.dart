/// Modelo de la tabla `turistas` (perfil de turista - HU-01, TG-92).
///
/// `usuarioId` es PK y FK hacia `usuarios.id` (int8, ON DELETE CASCADE).
class TouristModel {
  final int usuarioId;
  final String nombre;
  final String? apellido;
  final String? telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TouristModel({
    required this.usuarioId,
    required this.nombre,
    this.apellido,
    this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  factory TouristModel.fromMap(Map<String, dynamic> map) {
    return TouristModel(
      usuarioId: map['usuario_id'] as int,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String?,
      telefono: map['telefono'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  String get nombreCompleto =>
      apellido == null || apellido!.isEmpty ? nombre : '$nombre $apellido';
}
