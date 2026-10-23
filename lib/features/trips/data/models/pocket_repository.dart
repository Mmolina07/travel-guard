import 'package:supabase_flutter/supabase_flutter.dart';

import 'pocket_models.dart';

class PocketRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Devuelve el bolsillo del usuario en el viaje, o null si aún no lo creó.
  Future<PocketSummary?> fetchMyPocket({
    required int tripId,
    required int userId,
  }) async {
    final pocket = await _client
        .from('bolsillos')
        .select()
        .eq('viaje_id', tripId)
        .eq('usuario_id', userId)
        .maybeSingle();
    if (pocket == null) return null;
    final pocketId = (pocket['id'] as num).toInt();

    final depositRows = await _client
        .from('bolsillo_aportes')
        .select()
        .eq('bolsillo_id', pocketId)
        .order('created_at', ascending: false);

    // Lo gastado desde el bolsillo = gastos que este usuario pagó "de su bolsillo".
    final spentRows = await _client
        .from('gastos')
        .select('monto')
        .eq('viaje_id', tripId)
        .eq('pagado_por_id', userId)
        .eq('pagado_con_dinero_viaje', false);

    final spent = (spentRows as List)
        .fold<double>(0.0, (s, r) => s + (r['monto'] as num).toDouble());

    return PocketSummary(
      id: pocketId,
      deposits: (depositRows as List)
          .map((r) => PocketDeposit.fromMap(r as Map<String, dynamic>))
          .toList(),
      spent: spent,
    );
  }

  Future<void> createPocket({required int tripId, required int userId}) async {
    await _client.from('bolsillos').insert({
      'viaje_id': tripId,
      'usuario_id': userId,
    });
  }

  Future<void> addDeposit({
    required int pocketId,
    required double monto,
    String? nota,
  }) async {
    await _client.from('bolsillo_aportes').insert({
      'bolsillo_id': pocketId,
      'monto': monto,
      if (nota != null && nota.trim().isNotEmpty) 'nota': nota.trim(),
    });
  }
}