import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/comercio_model.dart';

/// Persistencia del perfil de comercio (HU-02) en la tabla `comercios`
/// (FK 1:1 a `usuarios.id`). Las operaciones sobre `usuarios` en sí viven
/// en [UsuariosRepository]; este repositorio solo gestiona el perfil.
class ComercioRepository {
  ComercioRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _table = 'comercios';

  Future<ComercioModel?> find(int usuarioId) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    return row == null ? null : ComercioModel.fromMap(row);
  }

  /// Escenario 4 de HU-02: detectar NIT ya registrado antes de intentar
  /// crear el perfil.
  Future<ComercioModel?> findByNit(String nit) async {
    final row =
        await _client.from(_table).select().eq('nit', nit).maybeSingle();
    return row == null ? null : ComercioModel.fromMap(row);
  }

  Future<ComercioModel> createProfile({
    required int usuarioId,
    required String nit,
    required String nombreComercio,
    required String direccion,
    required String telefonoContacto,
    String? sede,
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'usuario_id': usuarioId,
          'nit': nit,
          'nombre_comercio': nombreComercio,
          'direccion': direccion,
          'telefono_contacto': telefonoContacto,
          if (sede != null && sede.isNotEmpty) 'sede': sede,
        })
        .select()
        .single();
    return ComercioModel.fromMap(row);
  }
}
