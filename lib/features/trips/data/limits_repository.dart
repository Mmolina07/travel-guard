import 'package:supabase_flutter/supabase_flutter.dart';

class LimitsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Límites del viaje: `categoria_id -> límite`.
  Future<Map<int, double>> fetchLimits(int tripId) async {
    final rows = await _client
        .from('limites_gasto')
        .select('categoria_id, limite')
        .eq('viaje_id', tripId);
    return {
      for (final r in rows as List)
        (r['categoria_id'] as num).toInt(): (r['limite'] as num).toDouble(),
    };
  }

  /// Reemplaza todos los límites del viaje por los recibidos.
  Future<void> saveLimits(int tripId, Map<int, double> limits) async {
    await _client.from('limites_gasto').delete().eq('viaje_id', tripId);
    if (limits.isEmpty) return;
    await _client.from('limites_gasto').insert([
      for (final e in limits.entries)
        {'viaje_id': tripId, 'categoria_id': e.key, 'limite': e.value},
    ]);
  }
}