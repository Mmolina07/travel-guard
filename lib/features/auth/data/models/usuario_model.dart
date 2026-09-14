/// Modelo de la tabla `usuarios` (autenticación global, ver CLAUDE.md).
///
/// `id` es un `int8` autogenerado por Supabase (no el UID de Firebase).
/// El UID de Firebase (TG-97/TG-102) se guarda en `google_id` y es la
/// clave que se usa para buscar/enlazar el registro entre sesiones.
class UsuarioModel {
  final int id;
  final String email;
  final String proveedorAuth; // 'local' | 'google'
  final String? googleId; // UID de Firebase Authentication
  final String tipoUsuario; // 'turista' | 'comercio' | 'administrador'
  final String estado; // 'activo' | 'inactivo' | 'suspendido'
  final DateTime? ultimoLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UsuarioModel({
    required this.id,
    required this.email,
    required this.proveedorAuth,
    this.googleId,
    required this.tipoUsuario,
    required this.estado,
    this.ultimoLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int,
      email: map['email'] as String,
      proveedorAuth: map['proveedor_auth'] as String? ?? 'google',
      googleId: map['google_id'] as String?,
      tipoUsuario: map['tipo_usuario'] as String,
      estado: map['estado'] as String? ?? 'activo',
      ultimoLoginAt: _parseDate(map['ultimo_login_at']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}
