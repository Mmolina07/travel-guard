import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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

  /// Bucket público de Supabase Storage con las fotos de portada (ver
  /// docs/db/hu20_foto_comercio.sql). Carpeta por comercio: `<usuario_id>/`.
  static const String fotosBucket = 'comercios';

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
  /// a diferencia de `nombreComercio`/`telefonoContacto`/`descripcion`/
  /// `direccion`/`latitud`/`longitud` (HU-20 CA9), que solo se incluyen
  /// en el UPDATE si vienen no nulos.
  Future<ComercioModel> update({
    required int usuarioId,
    String? nombreComercio,
    String? telefonoContacto,
    String? descripcion,
    String? direccion,
    double? latitud,
    double? longitud,
    String? horarioApertura,
    String? horarioCierre,
    String? fotoUrl,
    bool quitarFoto = false,
  }) async {
    final row = await _client
        .from(_table)
        .update({
          if (fotoUrl != null) 'foto_url': fotoUrl,
          if (quitarFoto && fotoUrl == null) 'foto_url': null,
          if (nombreComercio != null) 'nombre_comercio': nombreComercio,
          if (telefonoContacto != null) 'telefono_contacto': telefonoContacto,
          if (descripcion != null) 'descripcion': descripcion,
          if (direccion != null) 'direccion': direccion,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
          'horario_apertura': horarioApertura,
          'horario_cierre': horarioCierre,
        })
        .eq('usuario_id', usuarioId)
        .select()
        .single();
    return ComercioModel.fromMap(row);
  }

  /// HU-20: sube la foto de portada y devuelve su URL pública. Cada subida
  /// usa un nombre nuevo (la URL cambia), así nadie ve una versión
  /// vieja guardada en caché.
  Future<String> uploadFotoPortada({
    required int usuarioId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ext = switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final path = '$usuarioId/portada-${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storage = _client.storage.from(fotosBucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
    return storage.getPublicUrl(path);
  }

  /// Borra del bucket una foto anterior (si es de este bucket). Si falla
  /// no pasa nada grave: solo queda un archivo huérfano.
  Future<void> deleteFoto(String? url) async {
    if (url == null) return;
    const marker = '/storage/v1/object/public/$fotosBucket/';
    final i = url.indexOf(marker);
    if (i < 0) return;
    try {
      await _client.storage.from(fotosBucket).remove([Uri.decodeComponent(url.substring(i + marker.length))]);
    } catch (e) {
      debugPrint('ComercioRepository.deleteFoto error: $e');
    }
  }
}
