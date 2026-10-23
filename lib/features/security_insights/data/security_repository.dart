import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/comuna_geo.dart';
import 'models/seguridad_stats.dart';

/// Datos del mapa de incidencia delictiva histórica por comuna.
///
/// Solo lee de Supabase: los datos los carga `tool/importar_seguridad.dart`
/// desde la fuente oficial, y las sumas las hacen las funciones
/// `seguridad_*` en la base (la app nunca recibe los hurtos uno a uno).
///
/// [inicio]/[fin] son opcionales: sin ellos se usa el período de
/// `seguridad_config`. [comuna] `null` = toda la ciudad.
class SecurityRepository {
  SecurityRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<SeguridadMetadatos?> fetchMetadatos() async {
    final rows = await _client.rpc('seguridad_metadatos') as List;
    if (rows.isEmpty) return null;
    return SeguridadMetadatos.fromRow(rows.first as Map<String, dynamic>);
  }

  /// Las 21 comunas/corregimientos con su polígono (~100 KB en total).
  Future<List<ComunaGeo>> fetchComunasGeo() async {
    final rows = await _client
        .from('seguridad_comunas')
        .select('codigo, nombre, tipo, geometria')
        .order('codigo');
    return (rows as List)
        .map((row) => ComunaGeo.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ComunaTotal>> fetchTotalesPorComuna({
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final rows = await _client.rpc(
      'seguridad_totales_por_comuna',
      params: _periodo(inicio, fin),
    ) as List;
    return rows
        .map((row) => ComunaTotal.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Índice histórico de incidencia delictiva de las 21 comunas.
  Future<List<ComunaIndice>> fetchIndiceComunas({
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final rows = await _client.rpc(
      'seguridad_indice_comunas',
      params: _periodo(inicio, fin),
    ) as List;
    return rows
        .map((row) => ComunaIndice.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ModalidadTotal>> fetchPorModalidad({
    String? comuna,
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final rows = await _client.rpc(
      'seguridad_por_modalidad',
      params: {'p_comuna': comuna, ..._periodo(inicio, fin)},
    ) as List;
    return rows
        .map((row) => ModalidadTotal.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<PuntoEvolucion>> fetchEvolucion({
    String? comuna,
    Granularidad granularidad = Granularidad.mes,
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final rows = await _client.rpc(
      'seguridad_evolucion',
      params: {
        'p_comuna': comuna,
        'p_granularidad': granularidad.name,
        ..._periodo(inicio, fin),
      },
    ) as List;
    return rows
        .map((row) => PuntoEvolucion.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Vacío si la fuente no trae hora del hecho.
  Future<List<CeldaDiaHora>> fetchPorDiaHora({
    String? comuna,
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final rows = await _client.rpc(
      'seguridad_por_dia_hora',
      params: {'p_comuna': comuna, ..._periodo(inicio, fin)},
    ) as List;
    return rows
        .map((row) => CeldaDiaHora.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _periodo(DateTime? inicio, DateTime? fin) => {
        'p_inicio': _fecha(inicio),
        'p_fin': _fecha(fin),
      };

  static String? _fecha(DateTime? d) => d == null
      ? null
      : '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}
