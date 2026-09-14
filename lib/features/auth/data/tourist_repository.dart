import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/tourist_model.dart';

/// Persistencia del perfil de turista (TG-92) en la tabla `turistas`
/// (FK 1:1 a `usuarios.id`). Las operaciones sobre `usuarios` en sí viven
/// en [UsuariosRepository]; este repositorio solo gestiona el perfil.
class TouristRepository {
  TouristRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _table = 'turistas';

  Future<TouristModel?> find(int usuarioId) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    return row == null ? null : TouristModel.fromMap(row);
  }

  Future<TouristModel> createProfile({
    required int usuarioId,
    required String? displayName,
  }) async {
    final nombre = _splitDisplayName(displayName);
    final row = await _client
        .from(_table)
        .insert({
          'usuario_id': usuarioId,
          'nombre': nombre.$1,
          if (nombre.$2 != null) 'apellido': nombre.$2,
        })
        .select()
        .single();
    return TouristModel.fromMap(row);
  }

  /// Separa un nombre completo ("Nombre Apellido") en (nombre, apellido)
  /// para poblar `turistas.nombre` / `turistas.apellido`.
  (String, String?) _splitDisplayName(String? displayName) {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) return ('Turista', null);

    final partes = trimmed.split(RegExp(r'\s+'));
    if (partes.length == 1) return (partes.first, null);
    return (partes.first, partes.sublist(1).join(' '));
  }
}
