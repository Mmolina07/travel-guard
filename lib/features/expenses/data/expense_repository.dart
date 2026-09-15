import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/categoria_gasto_model.dart';
import 'models/gasto_model.dart';

/// HU-13: registrar y consultar gastos manuales de un viaje, en la
/// tabla `gastos` de Supabase (persistente de verdad, no una lista en
/// memoria que se pierde al salir de la pantalla).
class ExpenseRepository {
  ExpenseRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<List<CategoriaGasto>> fetchCategorias() async {
    final rows =
        await _client.from('categorias_gasto').select().order('nombre');
    return (rows as List)
        .map((row) => CategoriaGasto.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Gasto>> fetchGastosDelViaje(int viajeId) async {
    final rows = await _client
        .from('gastos')
        .select('*, categorias_gasto(nombre)')
        .eq('viaje_id', viajeId)
        .order('fecha', ascending: false)
        .order('id', ascending: false);
    return (rows as List)
        .map((row) => Gasto.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<Gasto> createGasto({
    required int viajeId,
    required int categoriaId,
    required double monto,
    required DateTime fecha,
    String? descripcion,
  }) async {
    final row = await _client
        .from('gastos')
        .insert({
          'viaje_id': viajeId,
          'categoria_id': categoriaId,
          'monto': monto,
          'fecha': _toIsoDate(fecha),
          if (descripcion != null && descripcion.trim().isNotEmpty)
            'descripcion': descripcion.trim(),
        })
        .select('*, categorias_gasto(nombre)')
        .single();
    return Gasto.fromMap(row);
  }

  Future<void> deleteGasto(int id) async {
    await _client.from('gastos').delete().eq('id', id);
  }

  String _toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
