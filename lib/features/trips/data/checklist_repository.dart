import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/checklist_models.dart';

/// HU-26: lista de pendientes del viaje (`viaje_pendientes`). La lista
/// es personal: todo se filtra por viaje y usuario.
class ChecklistRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const _table = 'viaje_pendientes';

  /// Pendientes del usuario en el viaje, incluidas las sugerencias
  /// descartadas (la UI las usa para no volver a sugerirlas).
  Future<List<ChecklistItem>> fetchItems({required int tripId, required int userId}) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('viaje_id', tripId)
        .eq('usuario_id', userId)
        .order('created_at');
    return (rows as List).map((r) => ChecklistItem.fromMap(r as Map<String, dynamic>)).toList();
  }

  /// Agrega uno o varios pendientes. [suggestionKey] solo si viene de
  /// una sugerencia.
  Future<List<ChecklistItem>> addItems({
    required int tripId,
    required int userId,
    required List<({String title, ChecklistCategory category, String? suggestionKey})> items,
  }) async {
    if (items.isEmpty) return const [];
    final rows = await _client
        .from(_table)
        .insert([
          for (final i in items)
            {
              'viaje_id': tripId,
              'usuario_id': userId,
              'titulo': i.title.trim(),
              'categoria': i.category.name,
              if (i.suggestionKey != null) 'sugerencia_clave': i.suggestionKey,
            },
        ])
        .select();
    return (rows as List).map((r) => ChecklistItem.fromMap(r as Map<String, dynamic>)).toList();
  }

  /// Marca una sugerencia como "no aplica" para que no vuelva a salir.
  Future<ChecklistItem> dismissSuggestion({
    required int tripId,
    required int userId,
    required ChecklistSuggestion suggestion,
    required String title,
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'viaje_id': tripId,
          'usuario_id': userId,
          'titulo': title,
          'categoria': suggestion.category.name,
          'sugerencia_clave': suggestion.key,
          'descartado': true,
        })
        .select()
        .single();
    return ChecklistItem.fromMap(row);
  }

  /// Vuelve a mostrar todas las sugerencias descartadas del viaje.
  Future<void> restoreDismissed({required int tripId, required int userId}) async {
    await _client
        .from(_table)
        .delete()
        .eq('viaje_id', tripId)
        .eq('usuario_id', userId)
        .eq('descartado', true);
  }

  Future<void> setDone(int id, bool done) async {
    await _client.from(_table).update({
      'completado': done,
      'completado_at': done ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> updateItem(int id, {required String title, required ChecklistCategory category}) async {
    await _client.from(_table).update({'titulo': title.trim(), 'categoria': category.name}).eq('id', id);
  }

  Future<void> deleteItem(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Pendientes sin marcar por viaje (para los recordatorios de HU-26).
  Future<Map<int, int>> fetchPendingCounts({required int userId, required List<int> tripIds}) async {
    if (tripIds.isEmpty) return const {};
    final rows = await _client
        .from(_table)
        .select('viaje_id')
        .eq('usuario_id', userId)
        .inFilter('viaje_id', tripIds)
        .eq('completado', false)
        .eq('descartado', false);
    final counts = <int, int>{};
    for (final r in rows as List) {
      final id = (r['viaje_id'] as num).toInt();
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }
}
