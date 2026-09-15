import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/usuario_model.dart';

/// Operaciones sobre la tabla `usuarios` (autenticación global, TG-92),
/// compartidas por los perfiles de turista y comercio.
///
/// `usuarios.id` es un `int8` autogenerado por Supabase. Como la
/// autenticación vive en Firebase (TG-97/TG-102):
/// - Para cuentas de Google, la clave de enlace entre sesiones es
///   `google_id` (el UID de Firebase).
/// - Para cuentas locales (email/contraseña), la clave de enlace es
///   `email` (único en la tabla), ya que Firebase ya garantiza la
///   autenticación por email/contraseña.
class UsuariosRepository {
  UsuariosRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String table = 'usuarios';

  Future<UsuarioModel?> findById(int id) async {
    final row =
        await _client.from(table).select().eq('id', id).maybeSingle();
    return row == null ? null : UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel?> findByEmail(String email) async {
    final row =
        await _client.from(table).select().eq('email', email).maybeSingle();
    return row == null ? null : UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel?> findByGoogleId(String googleId) async {
    final row = await _client
        .from(table)
        .select()
        .eq('google_id', googleId)
        .maybeSingle();
    return row == null ? null : UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel> createLocal({
    required String email,
    required String tipoUsuario,
  }) async {
    final row = await _client
        .from(table)
        .insert({
          'email': email,
          'proveedor_auth': 'local',
          'tipo_usuario': tipoUsuario,
          'estado': 'activo',
          'ultimo_login_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel> createGoogle({
    required String googleId,
    required String email,
    required String tipoUsuario,
  }) async {
    final row = await _client
        .from(table)
        .insert({
          'email': email,
          'proveedor_auth': 'google',
          'google_id': googleId,
          'tipo_usuario': tipoUsuario,
          'estado': 'activo',
          'ultimo_login_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }

  /// Actualiza `google_id`. Sirve para "reparar" cuentas que se
  /// registraron con Google cuando ese flujo todavía pasaba por
  /// Firebase (google_id = uid de Firebase) y ahora deben enlazarse con
  /// el id de la sesión nativa de Supabase, sin duplicar la fila por
  /// `email` (que sigue siendo el mismo).
  Future<UsuarioModel> updateGoogleId({
    required int id,
    required String googleId,
  }) async {
    final row = await _client
        .from(table)
        .update({'google_id': googleId})
        .eq('id', id)
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel> touchLastLogin(int id) async {
    final row = await _client
        .from(table)
        .update({'ultimo_login_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }
}
