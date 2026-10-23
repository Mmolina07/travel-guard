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

  /// Suma de gastos reales por viaje, en una sola consulta — antes las
  /// tarjetas de viaje de Inicio y el resumen del sidebar calculaban lo
  /// "gastado" solo con los campos planeados al crear el viaje
  /// (anticipos, hospedaje, categorías, emergencias), sin contar los
  /// gastos sueltos que el turista va registrando después (HU-13). Se
  /// suma aparte, igual que ya hacía el detalle del viaje.
  Future<Map<int, double>> fetchTotalGastosPorViaje(List<int> viajeIds) async {
    if (viajeIds.isEmpty) return {};
    final rows = await _client
        .from('gastos')
        .select('viaje_id, monto')
        .inFilter('viaje_id', viajeIds);

    final totals = <int, double>{};
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      final viajeId = row['viaje_id'] as int;
      final monto = (row['monto'] as num).toDouble();
      totals[viajeId] = (totals[viajeId] ?? 0) + monto;
    }
    return totals;
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

  /// Gastos de varios viajes en una sola consulta, agrupados por viaje —
  /// para el cálculo en segundo plano del presupuesto diario (HU-11).
  Future<Map<int, List<Gasto>>> fetchGastosDeViajes(List<int> viajeIds) async {
    if (viajeIds.isEmpty) return {};
    final rows = await _client
        .from('gastos')
        .select('*, categorias_gasto(nombre)')
        .inFilter('viaje_id', viajeIds);

    final byTrip = <int, List<Gasto>>{};
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      final gasto = Gasto.fromMap(row);
      byTrip.putIfAbsent(gasto.viajeId, () => []).add(gasto);
    }
    return byTrip;
  }

  Future<Gasto> createGasto({
    required int viajeId,
    required int categoriaId,
    required double monto,
    required DateTime fecha,
    String? descripcion,
    String? establecimiento,
    int? pagadoPorId,
    bool pagadoConDineroViaje = true,
  }) async {
    final row = await _client
        .from('gastos')
        .insert({
          'viaje_id': viajeId,
          'categoria_id': categoriaId,
          'monto': monto,
          // `fecha` es `date` y la hora va en `hora` (`time`), ambas en hora
          // local: con `toUtc()` un gasto de las 8 pm en Colombia quedaba
          // guardado al día siguiente.
          'fecha': _toIsoDate(fecha),
          'hora': '${_two(fecha.hour)}:${_two(fecha.minute)}:00',
          if (descripcion != null && descripcion.trim().isNotEmpty)
            'descripcion': descripcion.trim(),
          if (establecimiento != null && establecimiento.trim().isNotEmpty)
            'establecimiento': establecimiento.trim(),
          if (pagadoPorId != null) 'pagado_por_id': pagadoPorId,
          'pagado_con_dinero_viaje': pagadoConDineroViaje,
        })
        .select('*, categorias_gasto(nombre)')
        .single();
    return Gasto.fromMap(row);
  }

  Future<void> deleteGasto(int id) async {
    await _client.from('gastos').delete().eq('id', id);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
