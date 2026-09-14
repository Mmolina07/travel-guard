import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../presentation/pages/trip_model.dart';

/// Persistencia de HU-05 (Crear Viaje, TG-141) en la tabla `viajes` de
/// Supabase. `turista_id` es el `usuarios.id` (int8) del turista dueño
/// del viaje — ver [AppAuthProvider.usuario].
class TripRepository {
  TripRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _table = 'viajes';

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
          'incluye_tours_guia': trip.tours > 0,
          'costo_tours': _positiveOrNull(trip.tours),
          'incluye_restaurantes': trip.restaurants > 0,
          'costo_restaurantes': _positiveOrNull(trip.restaurants),
          'incluye_discotecas': trip.discotheque > 0,
          'costo_discotecas': _positiveOrNull(trip.discotheque),
          'incluye_souvenirs': trip.souvenirs > 0,
          'costo_souvenirs': _positiveOrNull(trip.souvenirs),
          'incluye_actividades_pagas': trip.paidActivities > 0,
          'costo_actividades_pagas': _positiveOrNull(trip.paidActivities),
          'dinero_emergencias': _positiveOrNull(trip.emergencyMoney),
          'datos_completos': trip.datosCompletos,
        })
        .select()
        .single();

    return trip.copyWith(id: row['id'] as int);
  }

  /// Viajes del turista, más recientes primero (excluye archivados).
  /// Sin esto, `HomeScreenClient` no puede mostrar lo ya guardado al
  /// reabrir la app: solo tenía una lista en memoria que se reinicia
  /// cada vez que se recrea la pantalla.
  Future<List<Trip>> fetchTripsByTurista(int turistaId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('turista_id', turistaId)
        .neq('estado', 'archivado')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Trip _fromRow(Map<String, dynamic> row) {
    return Trip(
      id: row['id'] as int,
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
      tours: (row['costo_tours'] as num?)?.toDouble() ?? 0,
      restaurants: (row['costo_restaurantes'] as num?)?.toDouble() ?? 0,
      discotheque: (row['costo_discotecas'] as num?)?.toDouble() ?? 0,
      souvenirs: (row['costo_souvenirs'] as num?)?.toDouble() ?? 0,
      paidActivities:
          (row['costo_actividades_pagas'] as num?)?.toDouble() ?? 0,
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
