import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/estimate_models.dart';

/// Datos de referencia de la estimación de presupuesto (HU-18).
///
/// Solo lee las tablas `estimacion_*` (docs/db/hu18_estimacion_presupuesto.sql).
/// Son pocas filas (~100 en total), así que se cargan completas una vez por
/// sesión y el cálculo corre en la app (`utils/trip_estimator.dart`).
class EstimateRepository {
  EstimateRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Caché compartida entre pantallas; se descarta si la carga falla para
  /// poder reintentar.
  static Future<EstimateReferenceData>? _cache;

  static final Map<String, RealSpending?> _realCache = {};

  Future<EstimateReferenceData> fetchReferenceData({bool refresh = false}) {
    if (refresh) _cache = null;
    return _cache ??= _load().catchError((Object e) {
      _cache = null;
      throw e;
    });
  }

  /// Gastos reales de la app en [cityId] (Fase 6). Es opcional para la
  /// estimación: si falla devuelve `null` y se usa solo la referencia.
  Future<RealSpending?> fetchRealSpending(String cityId) async {
    if (_realCache.containsKey(cityId)) return _realCache[cityId];
    try {
      final rows = await _client.rpc(
        'estimacion_gastos_reales',
        params: {'p_ciudad': cityId},
      ) as List;
      final result = rows.isEmpty
          ? null
          : RealSpending.fromRow(rows.first as Map<String, dynamic>);
      _realCache[cityId] = result;
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<EstimateReferenceData> _load() async {
    final results = await Future.wait([
      _client.from('estimacion_ciudades').select().order('nombre'),
      _client.from('estimacion_costos').select(),
      _client.from('estimacion_rutas').select(),
      _client.from('estimacion_temporadas').select().order('desde'),
      _client.from('estimacion_fuentes').select(),
      _client.from('estimacion_parametros').select('clave, valor'),
    ]);

    List<Map<String, dynamic>> rows(int i) =>
        (results[i] as List).cast<Map<String, dynamic>>();

    return EstimateReferenceData(
      ciudades: rows(0).map(EstimateCity.fromRow).toList(),
      costos: rows(1).map(EstimateCityCosts.fromRow).toList(),
      rutas: rows(2).map(EstimateRoute.fromRow).toList(),
      temporadas: rows(3).map(EstimateSeason.fromRow).toList(),
      fuentes: {
        for (final s in rows(4).map(EstimateSource.fromRow)) s.id: s,
      },
      parametros: {
        for (final r in rows(5))
          r['clave'] as String: (r['valor'] as num).toDouble(),
      },
    );
  }
}
