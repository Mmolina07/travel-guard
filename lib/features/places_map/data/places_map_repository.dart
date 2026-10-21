import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/actividad_model.dart';
import 'models/map_place.dart';

/// HU-07: trae los puntos a mostrar en el mapa (`comercios` +
/// `lugares_interes`, ambas con lat/lng propias) y, a demanda, las
/// `actividades` de un comercio/lugar puntual (esa tabla no tiene
/// coordenadas: se asocia a través de `comercio_id`/`lugar_interes_id`).
class PlacesMapRepository {
  PlacesMapRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Solo trae comercios/lugares con coordenadas válidas (no nulas):
  /// sin lat/lng no hay dónde poner el marcador.
  Future<List<MapPlace>> fetchNearbyPlaces() async {
    final results = await Future.wait([
      _client
          .from('comercios')
          .select('*, categorias_comercio(nombre)')
          .not('latitud', 'is', null)
          .not('longitud', 'is', null),
      _client
          .from('lugares_interes')
          .select('*, categorias_lugar(nombre)'),
    ]);

    final comercios = (results[0] as List)
        .map((row) => MapPlace.fromComercioRow(row as Map<String, dynamic>));
    final lugares = (results[1] as List).map(
      (row) => MapPlace.fromLugarInteresRow(row as Map<String, dynamic>),
    );

    return [...comercios, ...lugares];
  }

  /// HU-20 / TG-289: datos actuales de un comercio (para refrescar su
  /// ficha cuando cambia). `null` si ya no tiene ubicación o no existe.
  Future<MapPlace?> fetchComercioPlace(int comercioId) async {
    final row = await _client
        .from('comercios')
        .select('*, categorias_comercio(nombre)')
        .eq('usuario_id', comercioId)
        .not('latitud', 'is', null)
        .not('longitud', 'is', null)
        .maybeSingle();
    return row == null ? null : MapPlace.fromComercioRow(row);
  }

  /// Actividades activas de un lugar para su ficha. Sin [incluirPremium]
  /// (turista sin suscripción) se omiten las exclusivas Premium y las
  /// promociones.
  Future<List<Actividad>> fetchActividadesDelLugar(
    MapPlace place, {
    bool incluirPremium = true,
  }) async {
    final columna = place.type == MapPlaceType.comercio
        ? 'comercio_id'
        : 'lugar_interes_id';

    final rows = await _client
        .from('actividades')
        .select()
        .eq(columna, place.id)
        .eq('activo', true);

    return (rows as List)
        .map((row) => Actividad.fromRow(row as Map<String, dynamic>))
        .where((a) => incluirPremium || !a.soloPremium)
        .toList();
  }

  /// HU-24: promociones exclusivas para Premium — actividades que los
  /// comercios publican con categoría "Promoción", activas y todavía
  /// vigentes. Quién las puede ver lo decide `PremiumGate` (TG-298).
  Future<List<Promocion>> fetchPromociones() async {
    final hoy = DateTime.now();
    final hoyIso =
        '${hoy.year.toString().padLeft(4, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final rows = await _client
        .from('actividades')
        .select('*, comercios(nombre_comercio, direccion)')
        .eq('categoria', Actividad.categoriaPromocion)
        .eq('activo', true)
        .or('fecha_fin.is.null,fecha_fin.gte.$hoyIso')
        .order('created_at', ascending: false);

    return (rows as List).map((row) {
      final map = row as Map<String, dynamic>;
      final comercio = map['comercios'] as Map<String, dynamic>?;
      return Promocion(
        actividad: Actividad.fromRow(map),
        comercioNombre: comercio?['nombre_comercio'] as String?,
        comercioDireccion: comercio?['direccion'] as String?,
      );
    }).toList();
  }

  /// Sección "Actividades" del turista: todo lo que los comercios tienen
  /// publicado (`activo = true`, que solo se pone en estado "Publicada")
  /// y vigente, más recientes primero. Las de categoría "Promoción" no
  /// salen aquí: son exclusivas de Premium y viven en `/promociones`.
  Future<List<ActividadConComercio>> fetchActividadesPublicadas() async {
    final hoy = DateTime.now();
    final hoyIso =
        '${hoy.year.toString().padLeft(4, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final rows = await _client
        .from('actividades')
        .select('*, comercios(nombre_comercio, direccion)')
        .eq('activo', true)
        .or('fecha_fin.is.null,fecha_fin.gte.$hoyIso')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => row as Map<String, dynamic>)
        // Se filtra aquí (y no con `neq` en la consulta) porque `neq`
        // en SQL también descartaría las actividades sin categoría.
        .where((map) => map['categoria'] != Actividad.categoriaPromocion)
        .map((map) {
      final comercio = map['comercios'] as Map<String, dynamic>?;
      return ActividadConComercio(
        actividad: Actividad.fromRow(map),
        comercioNombre: comercio?['nombre_comercio'] as String?,
        comercioDireccion: comercio?['direccion'] as String?,
      );
    }).toList();
  }

  /// "Mis actividades" del comercio (`home_screen_comercio.dart`): a
  /// diferencia de [fetchActividadesDelLugar] (solo turista, solo
  /// activas), acá el comercio ve también sus pausadas/borrador.
  Future<List<Actividad>> fetchActividadesDelComercio(int comercioId) async {
    final rows = await _client
        .from('actividades')
        .select()
        .eq('comercio_id', comercioId)
        .order('created_at');

    return (rows as List)
        .map((row) => Actividad.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// `estado` ('activa'/'pausada'/'borrador') decide también `activo`,
  /// para que [fetchActividadesDelLugar] (que filtra por `activo = true`
  /// del lado turista) siga funcionando sin tocarlo.
  Future<Actividad> createActividad({
    required int comercioId,
    required String nombre,
    required String descripcion,
    String? categoria,
    double? precio,
    required String estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool soloPremium = false,
  }) async {
    final row = await _client
        .from('actividades')
        .insert({
          'comercio_id': comercioId,
          'nombre': nombre,
          'descripcion': descripcion,
          'categoria': categoria,
          'precio': precio,
          'estado': estado,
          'activo': estado == 'activa',
          'fecha_inicio': fechaInicio != null ? _toIsoDate(fechaInicio) : null,
          'fecha_fin': fechaFin != null ? _toIsoDate(fechaFin) : null,
          // Una promoción siempre es exclusiva Premium.
          'solo_premium': soloPremium || categoria == Actividad.categoriaPromocion,
        })
        .select()
        .single();
    return Actividad.fromRow(row);
  }

  Future<void> updateActividad(Actividad actividad) async {
    await _client.from('actividades').update({
      'nombre': actividad.nombre,
      'descripcion': actividad.descripcion,
      'categoria': actividad.categoria,
      'precio': actividad.precio,
      'estado': actividad.estado,
      'activo': actividad.estado == 'activa',
      'fecha_inicio':
          actividad.fechaInicio != null ? _toIsoDate(actividad.fechaInicio!) : null,
      'fecha_fin': actividad.fechaFin != null ? _toIsoDate(actividad.fechaFin!) : null,
      'solo_premium': actividad.soloPremium || actividad.esPromocion,
    }).eq('id', actividad.id);
  }

  Future<void> deleteActividad(int id) async {
    await _client.from('actividades').delete().eq('id', id);
  }

  static String _toIsoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
