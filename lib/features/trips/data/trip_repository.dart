import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/utils/money_formatter.dart';
import '../presentation/pages/trip_model.dart';
import 'models/trip_budget_category.dart';
import 'models/trip_collaborator.dart';
import 'models/trip_history_entry.dart';

/// Persistencia de HU-05 (Crear Viaje, TG-141) en la tabla `viajes` de
/// Supabase. `turista_id` es el `usuarios.id` (int8) del turista dueño
/// del viaje — ver [AppAuthProvider.usuario].
///
/// Las categorías de presupuesto ahora son personalizables (antes eran
/// 5 columnas fijas en `viajes`: costo_tours/costo_restaurantes/etc.) y
/// viven en su propia tabla, `presupuesto_categorias`, una fila por
/// categoría — así el turista puede agregar o quitar las que quiera.
class TripRepository {
  TripRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _table = 'viajes';
  static const String _categoriesTable = 'presupuesto_categorias';
  static const String _collaboratorsTable = 'viaje_colaboradores';
  static const String _historyTable = 'viaje_historial';

  Future<Trip> createTrip({
    required int turistaId,
    required Trip trip,
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'turista_id': turistaId,
          'nombre': trip.name,
          'destino': trip.destination,
          'fecha_inicio': _toIsoDate(trip.startDate),
          'fecha_fin': _toIsoDate(trip.endDate),
          'numero_personas': trip.persons,
          'tipo_viaje': _mapTipoViaje(trip.tripType),
          'presupuesto_maximo': trip.maxBudget,
          'pagos_anticipados': trip.advancePayment,
          'tipo_hospedaje': trip.lodgingType,
          'costo_hospedaje': _positiveOrNull(trip.lodgingCost),
          'incluye_desayuno': trip.includedServices.contains('Desayuno'),
          'incluye_almuerzo': trip.includedServices.contains('Almuerzo'),
          'incluye_cena': trip.includedServices.contains('Cena'),
          'incluye_traslado': trip.includedServices.contains('Traslado'),
          'transporte_inicio': _mapTransporte(trip.startTransport),
          'transporte_durante': _mapTransporte(trip.duringTransport),
          'dinero_emergencias': _positiveOrNull(trip.emergencyMoney),
          'datos_completos': trip.datosCompletos,
        })
        .select()
        .single();

    final tripId = row['id'] as int;
    final savedCategories = await _replaceCategories(tripId, trip.categories);

    return trip.copyWith(id: tripId, turistaId: turistaId, categories: savedCategories);
  }

  /// Actualiza solo los campos de presupuesto de un viaje ya creado
  /// (mejora "gestor de presupuesto": antes esto se definía una sola
  /// vez al crear el viaje y no se podía ajustar después) y reemplaza
  /// por completo sus categorías personalizadas.
  ///
  /// HU-16: recibe también el viaje ANTES del cambio (`previous`) y
  /// quién edita (`editorUsuarioId`), para dejar en `viaje_historial`
  /// una fila por cada campo que realmente cambió — así el historial
  /// sirve tanto para el dueño como para cualquier colaborador que edite.
  Future<Trip> updateTripBudget({
    required Trip previous,
    required Trip trip,
    required int editorUsuarioId,
  }) async {
    final tripId = trip.id;
    if (tripId == null) {
      throw ArgumentError('No se puede actualizar un viaje sin id.');
    }

    await _client.from(_table).update({
      'presupuesto_maximo': trip.maxBudget,
      'pagos_anticipados': trip.advancePayment,
      'costo_hospedaje': _positiveOrNull(trip.lodgingCost),
      'dinero_emergencias': _positiveOrNull(trip.emergencyMoney),
    }).eq('id', tripId);

    final savedCategories = await _replaceCategories(tripId, trip.categories);
    final saved = trip.copyWith(categories: savedCategories);

    await _logBudgetChanges(
      tripId: tripId,
      editorUsuarioId: editorUsuarioId,
      previous: previous,
      updated: saved,
    );

    return saved;
  }

  /// Compara `previous` vs. `updated` campo por campo y guarda una fila
  /// de historial solo por los que de verdad cambiaron — así una edición
  /// que solo toca el presupuesto máximo no llena el historial con
  /// "categorías: sin cambios", etc.
  Future<void> _logBudgetChanges({
    required int tripId,
    required int editorUsuarioId,
    required Trip previous,
    required Trip updated,
  }) async {
    final entries = <Map<String, dynamic>>[];

    void addIfChanged(String campo, double before, double after) {
      if (before == after) return;
      entries.add({
        'viaje_id': tripId,
        'usuario_id': editorUsuarioId,
        'campo': campo,
        'valor_anterior': formatCOP(before),
        'valor_nuevo': formatCOP(after),
      });
    }

    addIfChanged('presupuesto_maximo', previous.maxBudget, updated.maxBudget);
    addIfChanged('pagos_anticipados', previous.advancePayment, updated.advancePayment);
    addIfChanged('costo_hospedaje', previous.lodgingCost, updated.lodgingCost);
    addIfChanged('dinero_emergencias', previous.emergencyMoney, updated.emergencyMoney);

    final categoriesBefore = _describeCategories(previous.categories);
    final categoriesAfter = _describeCategories(updated.categories);
    if (categoriesBefore != categoriesAfter) {
      entries.add({
        'viaje_id': tripId,
        'usuario_id': editorUsuarioId,
        'campo': 'categorias_presupuesto',
        'valor_anterior': categoriesBefore.isEmpty ? '—' : categoriesBefore,
        'valor_nuevo': categoriesAfter.isEmpty ? '—' : categoriesAfter,
      });
    }

    if (entries.isEmpty) return;
    await _client.from(_historyTable).insert(entries);
  }

  String _describeCategories(List<TripBudgetCategory> categories) {
    final sorted = [...categories]..sort((a, b) => a.nombre.compareTo(b.nombre));
    return sorted.map((c) => '${c.nombre}: ${formatCOP(c.monto)}').join(', ');
  }

  /// HU-16: últimos cambios del viaje (más reciente primero), para el
  /// "pequeño historial de cambios" del tab Grupo.
  Future<List<TripHistoryEntry>> fetchHistory(int tripId) async {
    final rows = await _client
        .from(_historyTable)
        .select('*, usuarios(email, turistas(nombre, apellido))')
        .eq('viaje_id', tripId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => TripHistoryEntry.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// HU-16: datos del dueño del viaje (`Trip.turistaId`) para mostrarlo
  /// junto a los colaboradores en el tab "Grupo" — no está en
  /// `viaje_colaboradores`, así que se busca aparte.
  Future<TripCollaborator> fetchOwner(int usuarioId) async {
    final row = await _client
        .from('usuarios')
        .select('email, turistas(nombre, apellido)')
        .eq('id', usuarioId)
        .single();
    return TripCollaborator.fromRow({
      'usuario_id': usuarioId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'usuarios': row,
    });
  }

  /// HU-16: colaboradores invitados al viaje (sin incluir al dueño, que
  /// se identifica con `Trip.turistaId`).
  Future<List<TripCollaborator>> fetchCollaborators(int tripId) async {
    final rows = await _client
        .from(_collaboratorsTable)
        // `!usuario_id` desambigua el embed: `viaje_colaboradores` tiene
        // DOS FKs hacia `usuarios` (`usuario_id` e `invitado_por`), así
        // que sin esto PostgREST no sabe cuál usar y responde con un
        // error de "more than one relationship was found" — eso era lo
        // que hacía fallar todo el tab "Grupo".
        .select('usuario_id, created_at, usuarios!usuario_id(email, turistas(nombre, apellido))')
        .eq('viaje_id', tripId)
        .order('created_at');

    return (rows as List)
        .map((row) => TripCollaborator.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Invita a un turista por correo. Inmediato (sin estado "pendiente"):
  /// si el correo ya está registrado como turista, queda agregado de
  /// una vez. Lanza [TripInviteException] con un mensaje ya listo para
  /// mostrar en pantalla cuando no se puede invitar.
  Future<TripCollaborator> addCollaboratorByEmail({
    required int tripId,
    required int ownerId,
    required String email,
    required int invitedBy,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final usuarioRow = await _client
        .from('usuarios')
        .select('id, tipo_usuario, email, turistas(nombre, apellido)')
        .eq('email', normalizedEmail)
        .maybeSingle();

    if (usuarioRow == null) {
      throw const TripInviteException(
        'Ese correo no está registrado en TravelGuard todavía.',
      );
    }
    if (usuarioRow['tipo_usuario'] != 'turista') {
      throw const TripInviteException(
        'Solo se pueden invitar cuentas de turista.',
      );
    }

    final invitedUserId = usuarioRow['id'] as int;
    if (invitedUserId == ownerId) {
      throw const TripInviteException('Ya eres el dueño de este viaje.');
    }

    final alreadyCollaborator = await _client
        .from(_collaboratorsTable)
        .select('id')
        .eq('viaje_id', tripId)
        .eq('usuario_id', invitedUserId)
        .maybeSingle();
    if (alreadyCollaborator != null) {
      throw const TripInviteException('Esa persona ya es colaboradora de este viaje.');
    }

    await _client.from(_collaboratorsTable).insert({
      'viaje_id': tripId,
      'usuario_id': invitedUserId,
      'invitado_por': invitedBy,
    });

    return TripCollaborator.fromRow({
      'usuario_id': invitedUserId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'usuarios': usuarioRow,
    });
  }

  /// Solo el dueño puede quitar colaboradores (se valida en la UI).
  Future<void> removeCollaborator({required int tripId, required int usuarioId}) async {
    await _client
        .from(_collaboratorsTable)
        .delete()
        .eq('viaje_id', tripId)
        .eq('usuario_id', usuarioId);
  }

  /// Borra las categorías existentes del viaje y crea las nuevas —
  /// más simple y confiable que calcular un diff fila por fila para
  /// una lista tan corta.
  Future<List<TripBudgetCategory>> _replaceCategories(
    int tripId,
    List<TripBudgetCategory> categories,
  ) async {
    await _client.from(_categoriesTable).delete().eq('viaje_id', tripId);

    final withAmount = categories.where((c) => c.monto > 0).toList();
    if (withAmount.isEmpty) return const [];

    final rows = await _client
        .from(_categoriesTable)
        .insert([
          for (var i = 0; i < withAmount.length; i++)
            {
              'viaje_id': tripId,
              'nombre': withAmount[i].nombre,
              'monto': withAmount[i].monto,
              'orden': i,
              if (withAmount[i].categoriaGastoId != null)
                'categoria_gasto_id': withAmount[i].categoriaGastoId,
            },
        ])
        .select('*, categorias_gasto(nombre)');

    return (rows as List)
        .map((row) => _categoryFromRow(row as Map<String, dynamic>))
        .toList();
  }

  TripBudgetCategory _categoryFromRow(Map<String, dynamic> row) {
    final categoriaGasto = row['categorias_gasto'] as Map<String, dynamic>?;
    return TripBudgetCategory(
      id: row['id'] as int,
      nombre: row['nombre'] as String,
      monto: (row['monto'] as num).toDouble(),
      categoriaGastoId: row['categoria_gasto_id'] as int?,
      categoriaGastoNombre: categoriaGasto?['nombre'] as String?,
    );
  }

  /// "Eliminar" un viaje (botón ⋯ del detalle) es en realidad un soft
  /// delete: lo pasa a `estado = 'archivado'` en vez de borrar la fila,
  /// así se conserva el historial de gastos. `fetchTripsByTurista` ya
  /// excluye los archivados, así que con esto solo basta.
  Future<void> archiveTrip(int tripId) async {
    await _client.from(_table).update({'estado': 'archivado'}).eq('id', tripId);
  }

  /// Viajes del turista, más recientes primero (excluye archivados).
  /// Sin esto, `HomeScreenClient` no puede mostrar lo ya guardado al
  /// reabrir la app: solo tenía una lista en memoria que se reinicia
  /// cada vez que se recrea la pantalla.
  ///
  /// HU-16: incluye tanto los viajes propios (`turista_id`) como los
  /// viajes de otros donde este turista quedó como colaborador — un
  /// viaje compartido debe verse igual en "Mis viajes" para todos sus
  /// miembros, no solo para quien lo creó.
  Future<List<Trip>> fetchTripsByTurista(int turistaId) async {
    final collaboratorRows = await _client
        .from(_collaboratorsTable)
        .select('viaje_id')
        .eq('usuario_id', turistaId);
    final collaboratorTripIds = (collaboratorRows as List)
        .map((row) => row['viaje_id'] as int)
        .toList();

    final ownershipFilter = collaboratorTripIds.isEmpty
        ? 'turista_id.eq.$turistaId'
        : 'turista_id.eq.$turistaId,id.in.(${collaboratorTripIds.join(',')})';

    final rows = await _client
        .from(_table)
        .select('*, $_categoriesTable(*, categorias_gasto(nombre))')
        .or(ownershipFilter)
        .neq('estado', 'archivado')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Trip _fromRow(Map<String, dynamic> row) {
    final categoryRows =
        (row[_categoriesTable] as List<dynamic>?) ?? const [];
    final categories = categoryRows
        .map((c) => _categoryFromRow(c as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    return Trip(
      id: row['id'] as int,
      turistaId: row['turista_id'] as int?,
      name: row['nombre'] as String,
      destination: row['destino'] as String,
      startDate: _fromIsoDate(row['fecha_inicio'] as String),
      endDate: _fromIsoDate(row['fecha_fin'] as String),
      persons: row['numero_personas'] as int,
      tripType: _unmapTipoViaje(row['tipo_viaje'] as String?),
      maxBudget: (row['presupuesto_maximo'] as num).toDouble(),
      advancePayment: (row['pagos_anticipados'] as num?)?.toDouble() ?? 0,
      lodgingType: row['tipo_hospedaje'] as String? ?? 'Otro',
      lodgingCost: (row['costo_hospedaje'] as num?)?.toDouble() ?? 0,
      includedServices: [
        if (row['incluye_desayuno'] == true) 'Desayuno',
        if (row['incluye_almuerzo'] == true) 'Almuerzo',
        if (row['incluye_cena'] == true) 'Cena',
        if (row['incluye_traslado'] == true) 'Traslado',
      ],
      startTransport: _unmapTransporte(row['transporte_inicio'] as String?),
      duringTransport: _unmapTransporte(row['transporte_durante'] as String?),
      categories: categories,
      emergencyMoney: (row['dinero_emergencias'] as num?)?.toDouble() ?? 0,
      datosCompletos: row['datos_completos'] as bool? ?? true,
    );
  }

  double? _positiveOrNull(double value) => value > 0 ? value : null;

  /// `dd/MM/yyyy` (formato del formulario) -> `yyyy-MM-dd` (Postgres date).
  String _toIsoDate(String ddMmYyyy) {
    final partes = ddMmYyyy.trim().split('/');
    final dia = partes[0].padLeft(2, '0');
    final mes = partes[1].padLeft(2, '0');
    final anio = partes[2];
    return '$anio-$mes-$dia';
  }

  /// `yyyy-MM-dd` (Postgres date) -> `dd/MM/yyyy` (formato de la UI).
  String _fromIsoDate(String isoDate) {
    final partes = isoDate.trim().split('-');
    final anio = partes[0];
    final mes = partes[1];
    final dia = partes[2];
    return '$dia/$mes/$anio';
  }

  String _mapTipoViaje(String value) {
    switch (value) {
      case 'Vacaciones':
        return 'vacaciones';
      case 'Trabajo':
        return 'trabajo';
      case 'Ocio':
        return 'ocio';
      default:
        return 'otro';
    }
  }

  String _unmapTipoViaje(String? value) {
    switch (value) {
      case 'vacaciones':
        return 'Vacaciones';
      case 'trabajo':
        return 'Trabajo';
      case 'ocio':
        return 'Ocio';
      default:
        return 'Otro';
    }
  }

  String _mapTransporte(String value) {
    switch (value) {
      case 'Carro':
        return 'carro';
      case 'Transporte público':
        return 'transporte_publico';
      case 'Uber':
        return 'uber';
      case 'Vuelo':
        return 'vuelo';
      default:
        return 'otro';
    }
  }

  String _unmapTransporte(String? value) {
    switch (value) {
      case 'carro':
        return 'Carro';
      case 'transporte_publico':
        return 'Transporte público';
      case 'uber':
        return 'Uber';
      case 'vuelo':
        return 'Vuelo';
      default:
        return 'Otro';
    }
  }
}

/// Error de invitación (HU-16) con un mensaje ya listo para mostrar en
/// un `SnackBar` — evita repetir la traducción de errores en la UI.
class TripInviteException implements Exception {
  const TripInviteException(this.message);

  final String message;

  @override
  String toString() => message;
}
