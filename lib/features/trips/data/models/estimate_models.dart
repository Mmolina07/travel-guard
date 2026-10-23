/// Modelos de las tablas `estimacion_*` de Supabase (HU-18,
/// docs/db/hu18_estimacion_presupuesto.sql). Son datos de referencia: aquí
/// no se calcula nada, eso lo hace `utils/trip_estimator.dart`.
library;

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

DateTime _toDate(dynamic v) => DateTime.parse('$v');

/// Estilo del viaje: define tarifas de hospedaje, comida, etc.
enum TripStyle {
  economico,
  estandar,
  lujo;

  String get dbValue => name;

  static TripStyle fromDb(String v) =>
      values.firstWhere((s) => s.dbValue == v, orElse: () => estandar);
}

/// Cómo llega el turista del origen al destino (ida y vuelta).
enum TravelMode {
  avion,
  bus,
  carro;

  String get dbValue => name;

  static TravelMode? fromDb(String v) {
    for (final m in values) {
      if (m.dbValue == v) return m;
    }
    return null;
  }
}

class EstimateSource {
  final String id;
  final String nombre;
  final String? url;
  final DateTime consultadoEn;

  const EstimateSource({
    required this.id,
    required this.nombre,
    required this.url,
    required this.consultadoEn,
  });

  factory EstimateSource.fromRow(Map<String, dynamic> row) => EstimateSource(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        url: row['url'] as String?,
        consultadoEn: _toDate(row['consultado_en']),
      );
}

/// Ciudad de origen o destino. Solo las que tienen [esDestino] tienen costos.
class EstimateCity {
  final String id;
  final String nombre;
  final String departamento;
  final double latitud;
  final double longitud;
  final bool tieneAeropuerto;
  final bool esDestino;

  /// Ancho del rango de la estimación (0.15 → ±15 %).
  final double variacion;

  const EstimateCity({
    required this.id,
    required this.nombre,
    required this.departamento,
    required this.latitud,
    required this.longitud,
    required this.tieneAeropuerto,
    required this.esDestino,
    required this.variacion,
  });

  factory EstimateCity.fromRow(Map<String, dynamic> row) => EstimateCity(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        departamento: row['departamento'] as String,
        latitud: _toDouble(row['latitud']),
        longitud: _toDouble(row['longitud']),
        tieneAeropuerto: row['tiene_aeropuerto'] as bool? ?? true,
        esDestino: row['es_destino'] as bool? ?? false,
        variacion: _toDouble(row['variacion']),
      );

  /// "Medellín, Antioquia": lo que se guarda como destino al crear el viaje.
  String get etiqueta => '$nombre, $departamento';
}

/// Costos de referencia de un destino para un estilo.
class EstimateCityCosts {
  final String ciudadId;
  final TripStyle estilo;

  /// Por habitación (2 personas) y por noche.
  final double hospedajeNoche;

  /// Por persona y por día.
  final double comidaDia;
  final double transporteLocalDia;
  final double toursDia;

  /// Por persona y por salida.
  final double rumbaSalida;

  /// Por persona, todo el viaje.
  final double souvenirsViaje;

  final List<String> fuentes;
  final DateTime verificadoEn;

  const EstimateCityCosts({
    required this.ciudadId,
    required this.estilo,
    required this.hospedajeNoche,
    required this.comidaDia,
    required this.transporteLocalDia,
    required this.toursDia,
    required this.rumbaSalida,
    required this.souvenirsViaje,
    required this.fuentes,
    required this.verificadoEn,
  });

  factory EstimateCityCosts.fromRow(Map<String, dynamic> row) =>
      EstimateCityCosts(
        ciudadId: row['ciudad_id'] as String,
        estilo: TripStyle.fromDb(row['estilo'] as String),
        hospedajeNoche: _toDouble(row['hospedaje_noche']),
        comidaDia: _toDouble(row['comida_dia']),
        transporteLocalDia: _toDouble(row['transporte_local_dia']),
        toursDia: _toDouble(row['tours_dia']),
        rumbaSalida: _toDouble(row['rumba_salida']),
        souvenirsViaje: _toDouble(row['souvenirs_viaje']),
        fuentes: [for (final f in row['fuentes'] as List? ?? const []) '$f'],
        verificadoEn: _toDate(row['verificado_en']),
      );
}

/// Ruta cargada entre dos ciudades (sirve en los dos sentidos).
class EstimateRoute {
  final String ciudadA;
  final String ciudadB;
  final TravelMode modo;

  /// Avión/bus: tiquete de ida por persona. Carro: peajes de ida por vehículo.
  final double costoIda;
  final int distanciaKm;
  final double duracionHoras;
  final bool recomendado;
  final String? fuenteId;
  final DateTime verificadoEn;

  const EstimateRoute({
    required this.ciudadA,
    required this.ciudadB,
    required this.modo,
    required this.costoIda,
    required this.distanciaKm,
    required this.duracionHoras,
    required this.recomendado,
    required this.fuenteId,
    required this.verificadoEn,
  });

  factory EstimateRoute.fromRow(Map<String, dynamic> row) => EstimateRoute(
        ciudadA: row['ciudad_a'] as String,
        ciudadB: row['ciudad_b'] as String,
        modo: TravelMode.fromDb(row['modo'] as String) ?? TravelMode.bus,
        costoIda: _toDouble(row['costo_ida']),
        distanciaKm: (row['distancia_km'] as num).toInt(),
        duracionHoras: _toDouble(row['duracion_horas']),
        recomendado: row['recomendado'] as bool? ?? true,
        fuenteId: row['fuente_id'] as String?,
        verificadoEn: _toDate(row['verificado_en']),
      );

  bool connects(String a, String b) =>
      (ciudadA == a && ciudadB == b) || (ciudadA == b && ciudadB == a);
}

/// Temporada alta. [ciudadId] `null` = todo el país.
class EstimateSeason {
  final String nombre;
  final String? ciudadId;
  final DateTime desde;
  final DateTime hasta;
  final double factorHospedaje;
  final double factorTransporte;

  const EstimateSeason({
    required this.nombre,
    required this.ciudadId,
    required this.desde,
    required this.hasta,
    required this.factorHospedaje,
    required this.factorTransporte,
  });

  factory EstimateSeason.fromRow(Map<String, dynamic> row) => EstimateSeason(
        nombre: row['nombre'] as String,
        ciudadId: row['ciudad_id'] as String?,
        desde: _toDate(row['desde']),
        hasta: _toDate(row['hasta']),
        factorHospedaje: _toDouble(row['factor_hospedaje']),
        factorTransporte: _toDouble(row['factor_transporte']),
      );

  /// [day] sin hora (fecha local).
  bool appliesTo(String cityId, DateTime day) =>
      (ciudadId == null || ciudadId == cityId) &&
      !day.isBefore(desde) &&
      !day.isAfter(hasta);
}

/// Todo lo que necesita el cálculo, cargado de una sola vez.
class EstimateReferenceData {
  final List<EstimateCity> ciudades;
  final List<EstimateCityCosts> costos;
  final List<EstimateRoute> rutas;
  final List<EstimateSeason> temporadas;
  final Map<String, EstimateSource> fuentes;
  final Map<String, double> parametros;

  const EstimateReferenceData({
    required this.ciudades,
    required this.costos,
    required this.rutas,
    required this.temporadas,
    required this.fuentes,
    required this.parametros,
  });

  List<EstimateCity> get destinos =>
      ciudades.where((c) => c.esDestino).toList();

  EstimateCity? city(String id) {
    for (final c in ciudades) {
      if (c.id == id) return c;
    }
    return null;
  }

  EstimateCityCosts? costsFor(String cityId, TripStyle style) {
    for (final c in costos) {
      if (c.ciudadId == cityId && c.estilo == style) return c;
    }
    return null;
  }

  EstimateRoute? route(String a, String b, TravelMode mode) {
    for (final r in rutas) {
      if (r.modo == mode && r.connects(a, b)) return r;
    }
    return null;
  }

  /// Valor de `estimacion_parametros`, o [fallback] si no está cargado.
  double param(String key, double fallback) => parametros[key] ?? fallback;
}

/// Agregados de viajes reales de TravelGuard a un destino
/// (`estimacion_gastos_reales`, docs/db/hu18_estimacion_gastos_reales.sql).
/// Cada valor es la mediana entre viajes; `null` si hay menos viajes que
/// el mínimo de `calibracion_min_viajes`.
class RealSpending {
  final int viajes;
  final int viajesComida;
  final double? comidaPersonaDia;
  final int viajesTransporte;
  final double? transportePersonaDia;
  final int viajesHospedaje;
  final double? hospedajeNocheHabitacion;

  const RealSpending({
    required this.viajes,
    required this.viajesComida,
    required this.comidaPersonaDia,
    required this.viajesTransporte,
    required this.transportePersonaDia,
    required this.viajesHospedaje,
    required this.hospedajeNocheHabitacion,
  });

  static double? _toDoubleOrNull(dynamic v) => v == null ? null : _toDouble(v);

  factory RealSpending.fromRow(Map<String, dynamic> row) => RealSpending(
        viajes: (row['viajes'] as num?)?.toInt() ?? 0,
        viajesComida: (row['viajes_comida'] as num?)?.toInt() ?? 0,
        comidaPersonaDia: _toDoubleOrNull(row['comida_persona_dia']),
        viajesTransporte: (row['viajes_transporte'] as num?)?.toInt() ?? 0,
        transportePersonaDia: _toDoubleOrNull(row['transporte_persona_dia']),
        viajesHospedaje: (row['viajes_hospedaje'] as num?)?.toInt() ?? 0,
        hospedajeNocheHabitacion: _toDoubleOrNull(row['hospedaje_noche_habitacion']),
      );

  /// Hay al menos un componente con viajes suficientes para ajustar.
  bool get usable =>
      comidaPersonaDia != null || transportePersonaDia != null || hospedajeNocheHabitacion != null;
}
