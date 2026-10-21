import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';

/// Un cambio en los datos de comercio que ve el viajero.
class PlacesChange {
  const PlacesChange({required this.table, this.comercioId});

  final String table;

  /// Comercio afectado, si se puede saber por la fila (`menu_productos`
  /// solo trae `menu_id`: ahí es `null` y cualquier vista lo recarga).
  final int? comercioId;

  /// Si este cambio puede afectar a [id].
  bool affects(int id) => comercioId == null || comercioId == id;
}

/// HU-20 / TG-289: avisa en tiempo real (Supabase Realtime) cuando un
/// comercio cambia sus datos, su ubicación, su menú o sus actividades,
/// para que el mapa, "Comercios cercanos" y la ficha del lugar se
/// actualicen sin recargar.
///
/// Un solo canal compartido: se abre con el primer oyente de [changes]
/// y se cierra cuando se va el último.
class PlacesRealtime {
  PlacesRealtime._();

  static final PlacesRealtime instance = PlacesRealtime._();

  static const _tables = ['comercios', 'menus', 'menu_productos', 'actividades'];

  late final StreamController<PlacesChange> _controller =
      StreamController<PlacesChange>.broadcast(onListen: _start, onCancel: _stop);
  RealtimeChannel? _channel;

  Stream<PlacesChange> get changes => _controller.stream;

  void _start() {
    try {
      final client = SupabaseConfig.client;
      var channel = client.channel('travelguard-places');
      for (final table in _tables) {
        channel = channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) => _controller.add(_toChange(table, payload)),
        );
      }
      _channel = channel.subscribe((status, error) {
        if (error != null) debugPrint('PlacesRealtime $status: $error');
      });
    } catch (e, st) {
      debugPrint('PlacesRealtime._start error: $e\n$st');
    }
  }

  Future<void> _stop() async {
    final channel = _channel;
    _channel = null;
    if (channel == null) return;
    try {
      await SupabaseConfig.client.removeChannel(channel);
    } catch (e) {
      debugPrint('PlacesRealtime._stop error: $e');
    }
  }

  static PlacesChange _toChange(String table, PostgresChangePayload payload) {
    final row = payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
    final raw = switch (table) {
      'comercios' => row['usuario_id'],
      'menus' || 'actividades' => row['comercio_id'],
      _ => null,
    };
    return PlacesChange(table: table, comercioId: raw is int ? raw : int.tryParse('$raw'));
  }
}

/// Junta ráfagas de cambios (p. ej. un menú con varios productos) en una
/// sola recarga.
class Debouncer {
  Debouncer([this.delay = const Duration(milliseconds: 400)]);

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
