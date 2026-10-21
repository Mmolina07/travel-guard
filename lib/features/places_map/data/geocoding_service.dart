import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Geocodificación de direcciones (HU-02 + HU-07): convierte el texto
/// que el comercio escribe en "Dirección" a coordenadas reales, para
/// que el mapa de ubicación pueda centrarse ahí solo, sin que el
/// usuario tenga que buscar manualmente el punto exacto.
///
/// Usa Nominatim (OpenStreetMap) en vez de la Geocoding API de Google:
/// es gratis, no requiere API key, y funciona directo desde el
/// navegador (CORS habilitado) — la Geocoding API de Google, en
/// cambio, rechaza llamadas desde el cliente con una key restringida
/// por dominio (la misma que usa `google_maps_flutter` en este
/// proyecto), porque está pensada para uso desde servidor.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Retorna la primera coincidencia para [address], o `null` si no se
  /// encontró nada o falló la consulta. `countrycodes=co` acota la
  /// búsqueda a Colombia para evitar resultados de otros países con
  /// nombres de calle parecidos.
  Future<LatLng?> geocodeAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'co',
    });

    try {
      final response = await _client.get(
        uri,
        // Nominatim exige un User-Agent identificable (política de uso
        // del servicio público); sin esto puede rechazar la solicitud.
        headers: const {'User-Agent': 'TravelGuardApp/1.0'},
      );
      if (response.statusCode != 200) return null;

      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '');
      final lon = double.tryParse(first['lon'] as String? ?? '');
      if (lat == null || lon == null) return null;

      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }

  /// Dirección legible de un punto del mapa (geocodificación inversa):
  /// "Calle 10 # 43-12, Laureles, Medellín". `barrio` trae el barrio o
  /// sector cuando Nominatim lo conoce. `null` si falla la consulta.
  Future<({String direccion, String? barrio})?> reverseGeocode(LatLng point) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
      queryParameters: {
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'es',
        'zoom': '18',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: const {'User-Agent': 'TravelGuardApp/1.0'},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        final display = data['display_name'] as String?;
        return display == null ? null : (direccion: display, barrio: null);
      }
      String? pick(List<String> keys) {
        for (final k in keys) {
          final v = address[k] as String?;
          if (v != null && v.trim().isNotEmpty) return v.trim();
        }
        return null;
      }

      final road = pick(['road', 'pedestrian', 'footway', 'path']);
      final number = pick(['house_number']);
      final barrio = pick(['neighbourhood', 'suburb', 'quarter', 'city_district']);
      final city = pick(['city', 'town', 'village', 'municipality']);
      final street = [road, number].whereType<String>().join(' # ');
      final parts = [street, barrio, city].where((p) => p != null && p.isNotEmpty);
      final direccion = parts.join(', ');
      if (direccion.isEmpty) {
        final display = data['display_name'] as String?;
        return display == null ? null : (direccion: display, barrio: barrio);
      }
      return (direccion: direccion, barrio: barrio);
    } catch (_) {
      return null;
    }
  }
}
