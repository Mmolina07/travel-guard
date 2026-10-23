import 'dart:math' as math;

import '../data/models/estimate_models.dart';

/// Estimación del presupuesto de un viaje (HU-18). Cálculo puro sobre los
/// datos de referencia de Supabase; la fórmula está explicada en
/// docs/hu/hu-18.md ("Cómo se calcula").
///
/// Todos los montos en pesos colombianos, redondeados a miles.

/// Gastos que el turista ya tiene resueltos (p. ej. se queda donde un
/// familiar): no se suman a la estimación.
enum CoveredCost { lodging, food, intercity, localTransport }

/// Lo que el turista llena en el formulario.
class EstimateInput {
  final String originId;
  final String destinationId;

  /// Fechas sin hora; [end] es el día de regreso (inclusivo).
  final DateTime start;
  final DateTime end;
  final int travelers;
  final TripStyle style;
  final TravelMode mode;
  final bool tours;
  final bool nightlife;
  final bool souvenirs;
  final Set<CoveredCost> covered;

  const EstimateInput({
    required this.originId,
    required this.destinationId,
    required this.start,
    required this.end,
    required this.travelers,
    required this.style,
    required this.mode,
    this.tours = false,
    this.nightlife = false,
    this.souvenirs = false,
    this.covered = const {},
  });

  bool isCovered(CoveredCost c) => covered.contains(c);

  EstimateInput copyWith({TripStyle? style}) => EstimateInput(
        originId: originId,
        destinationId: destinationId,
        start: start,
        end: end,
        travelers: travelers,
        style: style ?? this.style,
        mode: mode,
        tours: tours,
        nightlife: nightlife,
        souvenirs: souvenirs,
        covered: covered,
      );
}

/// Si un medio de transporte se puede usar en una ruta y cuánto tarda.
class RouteOption {
  final TravelMode mode;
  final bool available;
  final bool recommended;
  final double hours;
  final int distanceKm;

  /// true = la ruta no está cargada y se calculó con la distancia.
  final bool approximate;

  const RouteOption({
    required this.mode,
    required this.available,
    required this.recommended,
    required this.hours,
    required this.distanceKm,
    required this.approximate,
  });
}

enum EstimateConfidence { alta, media }

class BudgetEstimate {
  final EstimateInput input;
  final EstimateCity origin;
  final EstimateCity destination;
  final int days;
  final int nights;
  final int rooms;
  final int vehicles;

  final double lodging;
  final double food;
  final double localTransport;

  /// Ida y vuelta entre origen y destino.
  final double intercity;
  final double tours;
  final double nightlife;
  final double souvenirs;

  /// Cuánto de lo anterior se debe a la temporada alta (ya incluido).
  final double seasonSurcharge;
  final List<String> seasons;

  final RouteOption route;

  /// Ancho del rango (0.15 → ±15 %).
  final double variation;
  final EstimateConfidence confidence;
  final List<EstimateSource> sources;

  /// Viajes reales de TravelGuard con los que se ajustó (0 = solo referencia).
  final int realTrips;

  /// Fecha de verificación más antigua entre los precios usados.
  final DateTime verifiedAt;

  const BudgetEstimate({
    required this.input,
    required this.origin,
    required this.destination,
    required this.days,
    required this.nights,
    required this.rooms,
    required this.vehicles,
    required this.lodging,
    required this.food,
    required this.localTransport,
    required this.intercity,
    required this.tours,
    required this.nightlife,
    required this.souvenirs,
    required this.seasonSurcharge,
    required this.seasons,
    required this.route,
    required this.variation,
    required this.confidence,
    required this.sources,
    required this.realTrips,
    required this.verifiedAt,
  });

  bool get calibrated => realTrips > 0;

  TripStyle get style => input.style;
  int get travelers => input.travelers;
  double get transport => intercity + localTransport;
  double get extras => tours + nightlife + souvenirs;
  double get total => lodging + food + transport + extras;
  double get low => _round(total * (1 - variation));
  double get high => _round(total * (1 + variation));
  double get perPerson => _round(total / travelers);
  double get perDay => _round(total / days);
  double get perPersonPerDay => _round(total / (travelers * days));
}

double _round(double v) => (v / 1000).round() * 1000.0;

class TripEstimator {
  TripEstimator(this.data);

  final EstimateReferenceData data;

  /// Los tres medios para la ruta, en orden avión, bus, carro.
  List<RouteOption> routeOptions(String originId, String destinationId) => [
        for (final m in TravelMode.values) _routeOption(originId, destinationId, m),
      ];

  /// Calcula la estimación. Lanza [ArgumentError] si faltan datos o el
  /// medio no está disponible para la ruta (la UI lo evita antes).
  ///
  /// [real] (opcional) mezcla la referencia con los gastos reales de la app
  /// en ese destino: ver [_calibration].
  BudgetEstimate estimate(EstimateInput input, {RealSpending? real}) {
    final origin = data.city(input.originId);
    final destination = data.city(input.destinationId);
    final costs = data.costsFor(input.destinationId, input.style);
    final standard = data.costsFor(input.destinationId, TripStyle.estandar);
    if (origin == null || destination == null || costs == null || standard == null) {
      throw ArgumentError('Ciudad sin datos de referencia');
    }
    if (origin.id == destination.id) {
      throw ArgumentError('El origen y el destino son la misma ciudad');
    }
    final route = _routeOption(origin.id, destination.id, input.mode);
    final coversIntercity = input.isCovered(CoveredCost.intercity);
    if (!route.available && !coversIntercity) {
      throw ArgumentError('Medio de transporte no disponible en la ruta');
    }

    final start = _day(input.start);
    final end = _day(input.end);
    final days = end.difference(start).inDays + 1;
    final nights = days - 1;
    if (nights < 1) throw ArgumentError('El viaje debe tener al menos 1 noche');
    final travelers = math.max(1, input.travelers);

    final lodgingAdj = _calibration(real?.hospedajeNocheHabitacion, standard.hospedajeNoche, real?.viajesHospedaje);
    final foodAdj = _calibration(real?.comidaPersonaDia, standard.comidaDia, real?.viajesComida);
    final localAdj = _calibration(real?.transportePersonaDia, standard.transporteLocalDia, real?.viajesTransporte);
    final nightRate = costs.hospedajeNoche * lodgingAdj;

    final rooms = (travelers / data.param('personas_por_habitacion', 2)).ceil();
    final vehicles = (travelers / data.param('personas_por_vehiculo', 4)).ceil();

    // Hospedaje: cada noche con el factor de temporada más alto que aplique.
    final coversLodging = input.isCovered(CoveredCost.lodging);
    final lodgingBase = coversLodging ? 0.0 : nights * rooms * nightRate;
    var lodging = 0.0;
    for (var i = 0; i < (coversLodging ? 0 : nights); i++) {
      final night = DateTime(start.year, start.month, start.day + i);
      lodging += rooms * nightRate * _seasonFactor(destination.id, night, lodging: true);
    }

    final food = input.isCovered(CoveredCost.food) ? 0.0 : days * travelers * costs.comidaDia * foodAdj;
    final localTransport = input.isCovered(CoveredCost.localTransport)
        ? 0.0
        : days * travelers * costs.transporteLocalDia * localAdj;
    final tours = input.tours ? nights * travelers * costs.toursDia : 0.0;
    final nightlife = input.nightlife ? (nights / 2).ceil() * travelers * costs.rumbaSalida : 0.0;
    final souvenirs = input.souvenirs ? travelers * costs.souvenirsViaje : 0.0;

    // Ida y vuelta.
    final loaded = data.route(origin.id, destination.id, input.mode);
    double intercityBase;
    double intercity;
    if (coversIntercity) {
      intercityBase = 0;
      intercity = 0;
    } else if (input.mode == TravelMode.carro) {
      final tolls = loaded?.costoIda ?? route.distanceKm * data.param('peajes_cop_km', 220);
      final fuel = route.distanceKm / data.param('km_por_galon', 38) * data.param('precio_galon', 16300);
      intercityBase = 2 * vehicles * (tolls + fuel);
      intercity = intercityBase; // Ir en carro propio no sube en temporada.
    } else {
      final oneWay = (loaded?.costoIda ?? _fallbackTicket(origin, destination, input.mode)) *
          _ticketStyleFactor(input.mode, input.style);
      intercityBase = 2 * travelers * oneWay;
      final seasonFactor = (_seasonFactor(destination.id, start, lodging: false) +
              _seasonFactor(destination.id, end, lodging: false)) /
          2;
      intercity = intercityBase * seasonFactor;
    }

    final seasons = <String>{
      for (final s in data.temporadas)
        for (var i = 0; i < days; i++)
          if (s.appliesTo(destination.id, DateTime(start.year, start.month, start.day + i))) s.nombre,
    }.toList();

    // Fuentes realmente usadas en esta estimación.
    final sourceIds = <String>{
      ...costs.fuentes,
      if (!coversIntercity && loaded?.fuenteId != null) loaded!.fuenteId!,
      if (!coversIntercity && input.mode == TravelMode.carro) 'creg_gasolina',
    };
    final sources = [
      for (final id in sourceIds)
        if (data.fuentes[id] != null) data.fuentes[id]!,
    ];
    final verifiedAt = loaded == null || coversIntercity || costs.verificadoEn.isBefore(loaded.verificadoEn)
        ? costs.verificadoEn
        : loaded.verificadoEn;

    final variation = destination.variacion +
        (route.approximate && !coversIntercity ? data.param('variacion_ruta_estimada', 0.10) : 0);

    return BudgetEstimate(
      input: input,
      origin: origin,
      destination: destination,
      days: days,
      nights: nights,
      rooms: rooms,
      vehicles: vehicles,
      lodging: _round(lodging),
      food: _round(food),
      localTransport: _round(localTransport),
      intercity: _round(intercity),
      tours: _round(tours),
      nightlife: _round(nightlife),
      souvenirs: _round(souvenirs),
      seasonSurcharge: _round(lodging - lodgingBase + intercity - intercityBase),
      seasons: seasons,
      route: route,
      variation: variation,
      confidence: route.approximate && !coversIntercity ? EstimateConfidence.media : EstimateConfidence.alta,
      sources: sources,
      realTrips: _calibrationTrips(real, input),
      verifiedAt: verifiedAt,
    );
  }

  /// Viajes reales que de verdad movieron la estimación: el mayor número
  /// entre los componentes con dato suficiente y que no estén cubiertos.
  int _calibrationTrips(RealSpending? real, EstimateInput input) {
    if (real == null) return 0;
    return [
      if (real.hospedajeNocheHabitacion != null && !input.isCovered(CoveredCost.lodging)) real.viajesHospedaje,
      if (real.comidaPersonaDia != null && !input.isCovered(CoveredCost.food)) real.viajesComida,
      if (real.transportePersonaDia != null && !input.isCovered(CoveredCost.localTransport)) real.viajesTransporte,
    ].fold(0, math.max);
  }

  /// Factor que mezcla la referencia con lo real. Los viajes reales no
  /// dicen su estilo, así que se comparan contra el estándar y la
  /// proporción (acotada a 0,5×–2×) se aplica al estilo elegido:
  /// factor = 1 − peso + peso × (real / estándar), con
  /// peso = min(peso_max, n / (n + k)): con pocos viajes manda la referencia.
  double _calibration(double? realValue, double standardValue, int? trips) {
    if (realValue == null || trips == null || trips <= 0 || standardValue <= 0) return 1;
    final weight = math.min(
      data.param('calibracion_peso_max', 0.6),
      trips / (trips + data.param('calibracion_k', 5)),
    );
    final ratio = (realValue / standardValue).clamp(0.5, 2.0);
    return 1 - weight + weight * ratio;
  }

  /// La misma estimación en los tres estilos (comparación Premium).
  Map<TripStyle, BudgetEstimate> compareStyles(EstimateInput input, {RealSpending? real}) => {
        for (final s in TripStyle.values) s: estimate(input.copyWith(style: s), real: real),
      };

  // ── Ruta ──

  RouteOption _routeOption(String originId, String destinationId, TravelMode mode) {
    final loaded = data.route(originId, destinationId, mode);
    if (loaded != null) {
      return RouteOption(
        mode: mode,
        available: true,
        recommended: loaded.recomendado,
        hours: loaded.duracionHoras,
        distanceKm: loaded.distanciaKm,
        approximate: false,
      );
    }

    final origin = data.city(originId);
    final destination = data.city(destinationId);
    if (origin == null || destination == null || originId == destinationId) {
      return RouteOption(mode: mode, available: false, recommended: false, hours: 0, distanceKm: 0, approximate: true);
    }

    // Entre dos destinos cargados, si un medio no está en la tabla es
    // porque no existe (p. ej. no hay vuelos Barranquilla–Cartagena).
    final bothLoaded = data.rutas.any((r) => r.connects(originId, destinationId));

    final straightKm = _haversineKm(origin, destination);
    final roadKm = (straightKm * data.param('factor_vias', 1.5)).round();
    final maxHours = data.param('bus_horas_max_recomendado', 16);

    if (mode == TravelMode.avion) {
      final available = !bothLoaded &&
          origin.tieneAeropuerto &&
          destination.tieneAeropuerto &&
          straightKm >= data.param('avion_distancia_minima_km', 150);
      return RouteOption(
        mode: mode,
        available: available,
        recommended: available,
        // Vuelo directo o con una escala corta.
        hours: ((straightKm / 600 + 0.5) * 10).round() / 10,
        distanceKm: straightKm.round(),
        approximate: true,
      );
    }

    final hours = (roadKm / data.param('velocidad_bus_kmh', 45) * 10).roundToDouble() / 10;
    return RouteOption(
      mode: mode,
      available: !bothLoaded,
      recommended: !bothLoaded && hours <= maxHours,
      hours: hours,
      distanceKm: roadKm,
      approximate: true,
    );
  }

  double _fallbackTicket(EstimateCity origin, EstimateCity destination, TravelMode mode) {
    final straightKm = _haversineKm(origin, destination);
    if (mode == TravelMode.avion) {
      return data.param('avion_base', 110000) + straightKm * data.param('avion_cop_km', 180);
    }
    return straightKm * data.param('factor_vias', 1.5) * data.param('bus_cop_km', 260);
  }

  double _ticketStyleFactor(TravelMode mode, TripStyle style) => switch ((mode, style)) {
        (TravelMode.avion, TripStyle.economico) => data.param('factor_avion_economico', 0.85),
        (TravelMode.avion, TripStyle.estandar) => data.param('factor_avion_estandar', 1),
        (TravelMode.avion, TripStyle.lujo) => data.param('factor_avion_lujo', 1.6),
        (TravelMode.bus, TripStyle.lujo) => data.param('factor_bus_lujo', 1.3),
        _ => 1,
      };

  /// Factor más alto (no se multiplican) de las temporadas que caen en [day].
  double _seasonFactor(String cityId, DateTime day, {required bool lodging}) {
    var factor = 1.0;
    for (final s in data.temporadas) {
      if (!s.appliesTo(cityId, day)) continue;
      factor = math.max(factor, lodging ? s.factorHospedaje : s.factorTransporte);
    }
    return factor;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static double _haversineKm(EstimateCity a, EstimateCity b) {
    const earthKm = 6371.0;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(b.latitud - a.latitud);
    final dLon = rad(b.longitud - a.longitud);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.latitud)) * math.cos(rad(b.latitud)) * math.pow(math.sin(dLon / 2), 2);
    return 2 * earthKm * math.asin(math.sqrt(h));
  }
}
