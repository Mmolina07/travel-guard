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

  Future<List<Actividad>> fetchActividadesDelLugar(MapPlace place) async {
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
        .toList();
  }
}
