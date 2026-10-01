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
    double? latitud,
    double? longitud,
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
          // HU-07: sin esto el comercio nunca aparece en el mapa
          // (PlacesMapRepository solo trae comercios con lat/lng).
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        })
        .select()
        .single();
    return ComercioModel.fromMap(row);
  }

  /// Edición de perfil ("Mi negocio" en el home de comercio).
  /// `horarioApertura`/`horarioCierre` van como "HH:mm:00" (o `null`
  /// para dejar el horario sin definir) — siempre se mandan las dos,
  /// a diferencia de `nombreComercio`/`telefonoContacto`/`descripcion`
  /// que solo se incluyen en el UPDATE si vienen no nulos.
  Future<ComercioModel> update({
    required int usuarioId,
    String? nombreComercio,
    String? telefonoContacto,
    String? descripcion,
    String? horarioApertura,
    String? horarioCierre,
  }) async {
    final row = await _client
        .from(_table)
        .update({
          if (nombreComercio != null) 'nombre_comercio': nombreComercio,
          if (telefonoContacto != null) 'telefono_contacto': telefonoContacto,
          if (descripcion != null) 'descripcion': descripcion,
          'horario_apertura': horarioApertura,
          'horario_cierre': horarioCierre,
        })
        .eq('usuario_id', usuarioId)
        .select()
        .single();
    return ComercioModel.fromMap(row);
  }
}
